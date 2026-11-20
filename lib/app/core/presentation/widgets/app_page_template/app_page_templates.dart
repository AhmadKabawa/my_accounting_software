import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/localization/keys/template_keys.dart';
import 'package:accounting_software/app/core/routing/unsaved_changes_guard.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_confirm_dialog/confirm_dialog.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_empty_state/app_empty_state.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';
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
        final leave = await _confirmLeave();
        if (leave && mounted) {
          // Navigator.pop bypasses this PopScope's canPop check.
          _discardForm();
          Navigator.of(context).pop();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPageHeader(titleKey: widget.titleKey),
          if (widget.state == AppPageState.error)
            InlineBanner(
              messageKey: widget.errorKey ?? TemplateKeys.defaultError,
              variant: InlineBannerVariant.error,
            ),
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
        if (state == AppPageState.error)
          InlineBanner(
            messageKey: errorKey ?? TemplateKeys.defaultError,
            variant: InlineBannerVariant.error,
          ),
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

/// T1 list frame. The feature supplies the page state and the already-wired
/// FilterBar/DataTable; neither data access nor business rules live here.
///
/// Error contract: unlike [FormPageTemplate] and [DashboardTemplate], this
/// template draws no error banner or retry of its own. [AppDataTable] owns
/// them, so [AppPageState.error] only keeps the table on screen. A screen
/// that reports `state: AppPageState.error` MUST also pass `errorKey` (and
/// `onRetry`) to its [AppDataTable]; otherwise the failure is invisible.
class ListPageTemplate extends StatelessWidget {
  static const _loadingPlaceholderCount = 5;

  const ListPageTemplate({
    super.key,
    required this.titleKey,
    required this.filterBar,
    required this.dataTable,
    this.state = AppPageState.content,
    this.count,
    this.primaryAction,
    this.actions,
    this.emptyState,
  });

  final AppKey titleKey;
  final Widget filterBar;
  final Widget dataTable;

  /// `error` renders [dataTable]; see the error contract on the class.
  final AppPageState state;
  final int? count;
  final Widget? primaryAction;
  final Widget? actions;
  final Widget? emptyState;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppPageHeader(
          titleKey: titleKey,
          count: count,
          primaryAction: primaryAction,
        ),
        if (actions != null)
          Padding(
            padding: context.ui.padding.symmetric(vertical: AppSpacing.sm),
            child: actions!,
          ),
        filterBar,
        context.ui.spacing.gap(AppSpacing.md),
        Expanded(
          child: switch (state) {
            AppPageState.loading => ListView(
              children: [
                for (var index = 0; index < _loadingPlaceholderCount; index++)
                  const AppSkeleton.tableRow(),
              ],
            ),
            AppPageState.empty =>
              emptyState ??
                  AppEmptyState(
                    icon: AppIcons.info,
                    titleKey: CatalogUiKeys.emptyTitle,
                    descriptionKey: CatalogUiKeys.emptyDescription,
                  ),
            // AppDataTable owns its error banner and retry action. Do not
            // render a second page-level error/retry pair here.
            AppPageState.content || AppPageState.error => dataTable,
          },
        ),
      ],
    );
  }
}
