import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/localization/keys/template_keys.dart';
import 'package:accounting_software/app/core/routing/unsaved_changes_guard.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_card/app_card.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_data_view.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_view_mode.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/view_mode_switcher.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/list_toolbar_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/list_add_action.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_confirm_dialog/confirm_dialog.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_empty_state/app_empty_state.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_body/app_page_body.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_header/app_page_header.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_skeleton/app_skeleton.dart';

enum AppPageState { content, loading, empty, error }

/// T3 form frame. The screen owns fields, validation and business state.
///
/// [child] may be an ordinary form widget, which this template makes
/// scrollable, or a [ScrollView] such as [ListView], which is used directly
/// to avoid nesting scroll views.
class FormPageTemplate extends StatefulWidget {
  const FormPageTemplate({
    super.key,
    required this.titleKey,
    required this.child,
    this.state = AppPageState.content,
    this.errorKey,
    this.emptyState,
    this.dirty = false,
    this.onDiscard,
    this.onSave,
    this.saving = false,
  });

  final AppKey titleKey;
  final Widget child;
  final AppPageState state;
  final AppKey? errorKey;
  final Widget? emptyState;
  final bool dirty;
  final VoidCallback? onDiscard;
  final VoidCallback? onSave;
  final bool saving;

  @override
  State<FormPageTemplate> createState() => _FormPageTemplateState();
}

class _FormPageTemplateState extends State<FormPageTemplate> {
  UnsavedChangesGuard? _guard;
  int? _guardBranchIndex;
  bool _discarded = false;

  bool get _isDirty => widget.dirty && !_discarded;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = UnsavedChangesGuardScope.maybeOf(context);
    if (scope == null) {
      _guard?.unregister(this);
      _guard = null;
      _guardBranchIndex = null;
      return;
    }
    if (!identical(_guard, scope.guard)) {
      _guard?.unregister(this);
      _guard = scope.guard;
      _guardBranchIndex = scope.activeBranchIndex;
    } else {
      // A branch keeps its State in indexedStack; retain the branch index
      // captured when this form was first mounted.
      _guardBranchIndex ??= scope.activeBranchIndex;
    }
    _syncGuardRegistration();
  }

  @override
  void didUpdateWidget(FormPageTemplate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.dirty || !oldWidget.dirty) _discarded = false;
    _syncGuardRegistration();
  }

  void _syncGuardRegistration() {
    final guard = _guard;
    final branchIndex = _guardBranchIndex;
    if (guard == null || branchIndex == null) return;
    guard.updateForm(
      key: this,
      branchIndex: branchIndex,
      dirty: _isDirty,
      confirm: _confirmLeave,
      discard: _discardForm,
    );
  }

  Future<bool> _confirmLeave() async {
    if (!_isDirty) return true;
    final confirmed = await showConfirmDialog(
      context,
      titleKey: widget.titleKey,
      messageKey: TemplateKeys.unsavedChanges,
      severity: ConfirmDialogSeverity.warning,
    );
    return confirmed;
  }

  void _discardForm() {
    if (!_isDirty || !mounted) return;
    setState(() => _discarded = true);
    _syncGuardRegistration();
    widget.onDiscard?.call();
  }

  @override
  void dispose() {
    _guard?.unregister(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || !_isDirty) return;
        final navigator = Navigator.of(context);
        final leave = await _confirmLeave();
        if (leave && mounted && navigator.mounted) {
          // Navigator.pop bypasses this PopScope's canPop check.
          _discardForm();
          navigator.pop();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPageHeader(titleKey: widget.titleKey),
          widget.state == AppPageState.error
              ? InlineBanner(
                  messageKey: widget.errorKey ?? TemplateKeys.defaultError,
                  variant: InlineBannerVariant.error,
                )
              : const SizedBox.shrink(),
          Expanded(child: _scrollableBody()),
          if (widget.onSave != null)
            AppButton(
              TemplateKeys.save,
              onPressed: widget.saving ? null : widget.onSave,
              isLoading: widget.saving,
              expand: true,
            ),
        ],
      ),
    );
  }

  Widget _emptyState() => AppEmptyState(
    icon: AppIcons.info,
    titleKey: TemplateKeys.emptyTitle,
    descriptionKey: TemplateKeys.emptyDescription,
  );

  Widget _stateBody() => switch (widget.state) {
    AppPageState.loading => const Column(
      children: [AppSkeleton.line(), AppSkeleton.block()],
    ),
    AppPageState.empty => widget.emptyState ?? _emptyState(),
    AppPageState.error || AppPageState.content => widget.child,
  };

  Widget _scrollableBody() {
    final body = _stateBody();
    if (body is ScrollView) return body;
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: body,
        ),
      ),
    );
  }
}

/// T5 dashboard frame. The screen supplies role-filtered cards.
class DashboardTemplate extends StatelessWidget {
  const DashboardTemplate({
    super.key,
    required this.titleKey,
    required this.cards,
    this.state = AppPageState.content,
    this.errorKey,
    this.emptyState,
  });

  final AppKey titleKey;
  final List<Widget> cards;
  final AppPageState state;
  final AppKey? errorKey;
  final Widget? emptyState;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppPageHeader(titleKey: titleKey),
        state == AppPageState.error
            ? InlineBanner(
                messageKey: errorKey ?? TemplateKeys.defaultError,
                variant: InlineBannerVariant.error,
              )
            : const SizedBox.shrink(),
        Expanded(
          child: switch (state) {
            AppPageState.loading => const AppSkeleton.card(),
            AppPageState.empty => _emptyState(),
            AppPageState.content || AppPageState.error =>
              cards.isEmpty ? _emptyState() : _cardsGrid(context),
          },
        ),
      ],
    );
  }

  Widget _emptyState() =>
      emptyState ??
      AppEmptyState(
        icon: AppIcons.info,
        titleKey: TemplateKeys.emptyTitle,
        descriptionKey: TemplateKeys.emptyDescription,
      );

  Widget _cardsGrid(BuildContext context) => GridView.builder(
    padding: context.ui.padding.all(AppSpacing.md),
    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: context.ui.screen.isMobile
          ? 400
          : context.ui.size.width(AppComponentSize.cardWidth),
      mainAxisExtent: context.ui.size.height(AppComponentSize.cardHeight),
      crossAxisSpacing: context.ui.spacing.md,
      mainAxisSpacing: context.ui.spacing.md,
    ),
    itemCount: cards.length,
    itemBuilder: (_, index) => cards[index],
  );
}

/// T1 list frame: the page header, optional stats, then ONE surface card that
/// holds the toolbar/filters, the data and its footer.
///
/// Preferred slots (all optional except [titleKey] and [dataTable]):
/// | Need | Preferred | Alternative |
/// | Toolbar and filters | [toolbar] ([ListToolbarConfig]) | Legacy: [filterBar], [activeFilters], [viewModeSwitcher] |
/// | Summary cards | [stats] with [ListStatsBar] | Legacy: [actions] |
/// | Create action | [addAction] | Legacy: [primaryAction] |
/// | Header record count | [count] | No legacy alternative; still supported |
///
/// [dataTable] is the data area (normally `AppDataView`), including its
/// footer. Use the preferred slot for all new list screens.
///
/// Error contract (one place): with [state] == [AppPageState.error] and an
/// [errorKey], this template shows the banner and the retry button instead of
/// the data. A failure while stale data is still shown is [refreshErrorKey]:
/// the banner appears above the data and the data stays. Without [errorKey]
/// the old behavior stays: the [dataTable] draws its own error.
///
/// Loading shows placeholders that match [loadingViewMode].
///
/// Scroll: the whole page is one scroll inside [AppPageBody] (padding, max
/// width). The body has unbounded height, so nothing below uses `Expanded`.
/// Slots keep fixed positions, so state in the toolbar (search text) survives
/// the others appearing or disappearing.
class ListPageTemplate extends StatelessWidget {
  static const _loadingPlaceholderCount = 5;

  const ListPageTemplate({
    super.key,
    required this.titleKey,
    required this.dataTable,
    this.filterBar,
    this.toolbar,
    this.state = AppPageState.content,
    this.count,
    this.primaryAction,
    this.addAction,
    this.actions,
    this.stats,
    this.activeFilters,
    this.viewModeSwitcher,
    this.emptyState,
    this.breadcrumb,
    this.errorKey,
    this.onRetry,
    this.refreshErrorKey,
    this.loadingViewMode,
  }) : assert(
         addAction == null || primaryAction == null,
         'Pass either addAction or primaryAction, not both.',
       );

  final AppKey titleKey;
  final Widget? breadcrumb;

  /// Legacy: use [toolbar] to let the template build the filter toolbar.
  final Widget? filterBar;

  /// Preferred over [filterBar]: the template builds the toolbar itself.
  final ListToolbarConfig? toolbar;
  final Widget dataTable;

  /// `error` renders [dataTable] unless [errorKey] is given.
  final AppPageState state;

  /// Optional record count displayed beside the page title.
  final int? count;

  /// Legacy: use [addAction] to build the standard permission-gated action.
  final Widget? primaryAction;
  final ListAddAction? addAction;

  /// Legacy: use [stats] for summary cards.
  final Widget? actions;
  final Widget? stats;

  /// Legacy: configure active filters through [toolbar].
  final Widget? activeFilters;

  /// Legacy: configure view modes through [toolbar].
  final Widget? viewModeSwitcher;
  final Widget? emptyState;
  final AppKey? errorKey;
  final VoidCallback? onRetry;
  final AppKey? refreshErrorKey;
  final AppViewMode? loadingViewMode;

  static const _none = SizedBox.shrink();

  @override
  Widget build(BuildContext context) {
    final above = stats ?? actions;
    final gap = context.ui.spacing.md;
    return AppPageBody(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPageHeader(
            titleKey: titleKey,
            count: count,
            primaryAction: addAction != null
                ? ListAddButton(action: addAction!)
                : primaryAction,
            breadcrumb: breadcrumb,
          ),
          above != null
              ? Padding(
                  padding: context.ui.padding.only(bottom: AppSpacing.md),
                  child: above,
                )
              : _none,
          AppCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                filterBar ?? _toolbar(context),
                activeFilters != null
                    ? Padding(
                        padding: EdgeInsets.only(top: gap),
                        child: activeFilters,
                      )
                    : _none,
                viewModeSwitcher != null
                    ? Padding(
                        padding: EdgeInsets.only(top: gap),
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: viewModeSwitcher,
                        ),
                      )
                    : _none,
                SizedBox(height: gap),
                refreshErrorKey != null
                    ? Padding(
                        padding: EdgeInsets.only(bottom: gap),
                        child: _PageError(
                          messageKey: refreshErrorKey!,
                          onRetry: onRetry,
                        ),
                      )
                    : _none,
                _body(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolbar(BuildContext context) {
    final config = toolbar;
    if (config == null) return _none;
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasModes = config.viewModes.length > 1;
        return FilterBar(
          searchHintKey: config.searchHintKey,
          debounce: config.searchDebounce,
          onSearchChanged: config.onSearchChanged,
          onClearAll: config.onClearAll,
          activeFilters: config.activeFilters,
          filterControls: config.filterControls,
          sortOptions: config.sortOptions,
          sortKey: config.sortKey,
          sortAscending: config.sortAscending,
          onSort: config.onSort,
          sorts: config.sorts,
          onSortsChanged: config.onSortsChanged,
          maxSorts: config.maxSorts,
          leading: hasModes && config.onViewModeChanged != null
              ? ViewModeSwitcher(
                  modes: config.viewModes,
                  selected:
                      config.viewMode ??
                      AppDataView.defaultModeFor(
                        context,
                        availableWidth: constraints.maxWidth,
                      ),
                  onChanged: config.onViewModeChanged!,
                )
              : null,
          searchSuffix: config.onRefresh == null &&
                  config.onSelectionModeToggle == null
              ? null
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (config.onRefresh != null)
                      AppIconButton(
                        AppIcons.refresh,
                        tooltipKey: CatalogUiKeys.refresh,
                        onPressed: config.refreshing ? null : config.onRefresh,
                      ),
                    if (config.onSelectionModeToggle != null)
                      Semantics(
                        selected: config.selectionModeActive,
                        child: AppIconButton(
                          AppIcons.checklist,
                          tooltipKey: config.selectionModeActive
                              ? CatalogUiKeys.finishSelection
                              : CatalogUiKeys.select,
                          variant: config.selectionModeActive
                              ? AppButtonVariant.primary
                              : AppButtonVariant.outlined,
                          onPressed: config.onSelectionModeToggle,
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }

  Widget _body(BuildContext context) => switch (state) {
    AppPageState.loading => _loading(context),
    AppPageState.empty => Padding(
      padding: context.ui.padding.symmetric(vertical: AppSpacing.xl),
      child:
          emptyState ??
          AppEmptyState(
            icon: AppIcons.info,
            titleKey: CatalogUiKeys.emptyTitle,
            descriptionKey: CatalogUiKeys.emptyDescription,
          ),
    ),
    AppPageState.error when errorKey != null => _PageError(
      messageKey: errorKey!,
      onRetry: onRetry,
    ),
    AppPageState.content || AppPageState.error => dataTable,
  };

  Widget _loading(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final effectiveMode =
          loadingViewMode ??
          AppDataView.defaultModeFor(
            context,
            availableWidth: constraints.hasBoundedWidth
                ? constraints.maxWidth
                : null,
          );
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < _loadingPlaceholderCount; index++)
            effectiveMode == AppViewMode.table
                ? const AppSkeleton.tableRow()
                : Padding(
                    padding: EdgeInsets.only(bottom: context.ui.spacing.md),
                    child: const AppSkeleton.card(),
                  ),
        ],
      );
    },
  );
}

/// The page-level failure: the banner plus a retry action.
class _PageError extends StatelessWidget {
  const _PageError({required this.messageKey, this.onRetry});

  final AppKey messageKey;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      InlineBanner(messageKey: messageKey, variant: InlineBannerVariant.error),
      if (onRetry != null)
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: AppButton(
            CatalogUiKeys.retry,
            variant: AppButtonVariant.text,
            onPressed: onRetry,
          ),
        ),
    ],
  );
}
