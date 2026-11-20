import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/access/permission_gate/permission_gate.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_card/app_card.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_breadcrumb/app_breadcrumb.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_confirm_dialog/confirm_dialog.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_empty_state/app_empty_state.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_image/app_image.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/app_page_templates.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/features/catalog/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/domain/entity/brand_draft.dart';
import 'package:accounting_software/app/features/catalog/domain/entity/brand_list_query.dart';
import 'package:accounting_software/app/features/catalog/domain/entity/brand_stats.dart';
import 'package:accounting_software/app/features/catalog/domain/failures/brand_failures.dart';
import 'package:accounting_software/app/features/catalog/presentation/cubit/brand_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/presentation/cubit/brands_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/presentation/localization/brands_keys.dart';

class BrandsScreen extends StatelessWidget {
  const BrandsScreen({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<BrandsListCubit>()..load(),
    child: const _BrandsView(),
  );
}

class _BrandsView extends StatelessWidget {
  const _BrandsView();

  Future<void> _edit(BuildContext context, [Brand? brand]) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => BlocProvider(
        create: (_) => sl<BrandFormCubit>(),
        child: _BrandEditor(brand: brand),
      ),
    );
    if (saved == true && context.mounted) {
      await context.read<BrandsListCubit>().refresh(refreshStats: true);
    }
  }

  void _toast(BuildContext context, AppKey key) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: AppText(key)));
  }

  Future<void> _status(BuildContext context, Brand brand) async {
    final cubit = context.read<BrandsListCubit>();
    if (brand.isActive) {
      final changed = await showConfirmDialog(
        context,
        titleKey: BrandsKeys.deactivateTitle,
        messageKey: BrandsKeys.deactivateMessage,
        severity: ConfirmDialogSeverity.warning,
        targetName: brand.name,
        onConfirm: () async {
          final result = await cubit.setActive(id: brand.id, isActive: false);
          return result.fold((f) => f.messageKey, (_) => null);
        },
      );
      if (changed && context.mounted) _toast(context, BrandsKeys.statusUpdated);
    } else {
      final result = await cubit.setActive(id: brand.id, isActive: true);
      if (!context.mounted) return;
      result.fold((f) => _toast(context, f.messageKey),
          (_) => _toast(context, BrandsKeys.statusUpdated));
    }
  }

  Future<void> _delete(BuildContext context, Brand brand) async {
    final deleted = await showConfirmDialog(
      context,
      titleKey: BrandsKeys.delete,
      messageKey: BrandsKeys.confirmDelete,
      severity: ConfirmDialogSeverity.critical,
      targetName: brand.name,
      requireTypedName: true,
      onConfirm: () async {
        final result = await context.read<BrandsListCubit>().delete(brand);
        return result.fold(
          (f) => f is BrandInUseFailure ? BrandsKeys.brandInUse : f.messageKey,
          (_) => null,
        );
      },
    );
    if (deleted && context.mounted) _toast(context, BrandsKeys.deleted);
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<BrandsListCubit, BrandsListState>(
    builder: (context, state) {
      final cubit = context.read<BrandsListCubit>();
      final page = state is BrandsListReady ? state : null;
      final query = page?.query ?? cubit.query;
      final stats = page?.stats ?? cubit.stats;
      final rows = page?.result.items ?? const <Brand>[];
      final total = page?.result.totalCount ?? 0;
      final failure = state is BrandsListFailed ? state.failure : null;
      final loading = state is BrandsListInitial || state is BrandsListLoading;

      return ListPageTemplate(
        titleKey: BrandsKeys.title,
        breadcrumb: const AppBreadcrumb(items: [
          AppBreadcrumbItem(label: NavKeys.catalog),
          AppBreadcrumbItem(label: BrandsKeys.title),
        ]),
        count: total,
        actions: stats == null ? null : _statsCards(context, stats),
        primaryAction: PermissionGate(
          permission: Permissions.masterData.manage,
          child: AppButton(BrandsKeys.add, icon: AppIcons.add,
              onPressed: () => _edit(context)),
        ),
        filterBar: FilterBar(
          searchHintKey: BrandsKeys.searchHint,
          debounce: Duration.zero,
          onSearchChanged: cubit.searchChanged,
          onClearAll: () {
            cubit.searchChanged('');
            cubit.setStatus(BrandStatusFilter.all);
          },
          activeFilters: [
            if (query.search.isNotEmpty)
              FilterBarFilter(id: 'search', label: BrandsKeys.searchHint,
                value: query.search, onRemove: () => cubit.searchChanged('')),
            if (query.status != BrandStatusFilter.all)
              FilterBarFilter(id: 'status', label: BrandsKeys.status,
                value: (query.status == BrandStatusFilter.active
                    ? BrandsKeys.active : BrandsKeys.inactive).tr(context: context),
                onRemove: () => cubit.setStatus(BrandStatusFilter.all)),
          ],
          filterControls: [
            SearchableDropdown<BrandStatusFilter>(
              options: BrandStatusFilter.values,
              labelKey: BrandsKeys.status,
              optionLabel: (value) => (switch (value) {
                BrandStatusFilter.all => BrandsKeys.allStatuses,
                BrandStatusFilter.active => BrandsKeys.active,
                BrandStatusFilter.inactive => BrandsKeys.inactive,
              }).tr(context: context),
              value: query.status,
              clearable: false,
              onChanged: (value) {
                if (value != null) cubit.setStatus(value);
              },
            ),
          ],
        ),
        state: loading ? AppPageState.loading
            : failure != null ? AppPageState.error : AppPageState.content,
        dataTable: AppDataTable<Brand>(
          columns: [
            DataTableColumn(labelKey: BrandsKeys.brandName, sortKey: 'name',
              priority: DataTableColumnPriority.primary, flex: 3,
              cellBuilder: _identity),
            DataTableColumn(labelKey: BrandsKeys.description,
              priority: DataTableColumnPriority.secondary, flex: 2,
              cellBuilder: (c, b) {
                final description = b.description?.trim() ?? '';
                return AppText.raw(
                  description.isNotEmpty ? description : '—',
                  color: c.ui.theme.colors.onSurfaceVariant,
                  maxLines: 2,
                );
              }),
            DataTableColumn(labelKey: BrandsKeys.productCount,
              priority: DataTableColumnPriority.secondary, numeric: true,
              cellBuilder: (_, b) => AppText.raw(b.productCount?.toString() ?? '—')),
            DataTableColumn(labelKey: BrandsKeys.status,
              priority: DataTableColumnPriority.secondary,
              cellBuilder: (_, b) => _statusBadge(b)),
          ],
          rows: rows, rowId: (b) => b.id, loading: loading,
          errorKey: failure?.messageKey, onRetry: cubit.refresh,
          emptyState: AppEmptyState(
            icon: AppIcons.brands,
            titleKey: query.search.isEmpty && query.status == BrandStatusFilter.all
                ? BrandsKeys.empty : BrandsKeys.noResults,
            descriptionKey: query.search.isEmpty && query.status == BrandStatusFilter.all
                ? BrandsKeys.emptyDescription : BrandsKeys.noResultsDescription,
            action: query.search.isEmpty && query.status == BrandStatusFilter.all
                ? PermissionGate(permission: Permissions.masterData.manage,
                    child: AppButton(BrandsKeys.add, icon: AppIcons.add,
                      onPressed: () => _edit(context))) : null,
          ),
          cardBuilder: _card,
          rowActionsBuilder: (c, b) => PermissionGate(
            permission: Permissions.masterData.manage,
            child: Wrap(spacing: context.ui.spacing.xs, runSpacing: context.ui.spacing.xs, children: [
              AppButton(BrandsKeys.edit, size: AppButtonSize.small,
                variant: AppButtonVariant.outlined, onPressed: () => _edit(context, b)),
              AppButton(b.isActive ? BrandsKeys.deactivate : BrandsKeys.activate,
                size: AppButtonSize.small, variant: AppButtonVariant.text,
                onPressed: () => _status(context, b)),
              if (b.productCount == 0)
                AppButton(BrandsKeys.delete, size: AppButtonSize.small,
                  variant: AppButtonVariant.danger, onPressed: () => _delete(context, b)),
            ]),
          ),
          sortKey: 'name', sortAscending: query.sortAscending,
          onSort: (s) => cubit.setSort(ascending: s.ascending),
          page: query.page, pageSize: query.pageSize, totalCount: total,
          hasMore: query.page * query.pageSize < total,
          onPageChanged: cubit.setPage,
        ),
      );
    },
  );

  Widget _statsCards(BuildContext context, BrandStats stats) => Wrap(
    spacing: context.ui.spacing.sm,
    runSpacing: context.ui.spacing.sm,
    children: [
      _statCard(context, BrandsKeys.totalBrands, stats.total),
      _statCard(context, BrandsKeys.activeBrands, stats.active),
      _statCard(context, BrandsKeys.inactiveBrands, stats.inactive),
    ],
  );

  Widget _statCard(BuildContext context, AppKey label, int value) => SizedBox(
    width: context.ui.size.width(AppComponentSize.cardWidth),
    child: AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(label, type: AppTextType.labelMedium,
            color: context.ui.theme.colors.onSurfaceVariant),
          context.ui.spacing.gap(AppSpacing.xs),
          AppText.raw(value.toString(), type: AppTextType.headlineSmall),
        ],
      ),
    ),
  );

  Widget _identity(BuildContext context, Brand brand) => Row(
    children: [
      _logo(context, brand),
      context.ui.spacing.gap(AppSpacing.smMd, axis: Axis.horizontal),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.raw(brand.name, type: AppTextType.titleSmall),
          AppText.raw(brand.slug, type: AppTextType.bodySmall,
            color: context.ui.theme.colors.onSurfaceVariant),
        ],
      )),
    ],
  );

  Widget _logo(BuildContext context, Brand brand) {
    final raw = brand.logo?.trim() ?? '';
    final uri = Uri.tryParse(raw);
    final valid = uri != null && uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
    return ClipRRect(
      borderRadius: AppRadius.sm.circular(context),
      child: SizedBox(
        width: context.ui.size.width(AppComponentSize.avatarSmall),
        height: context.ui.size.height(AppComponentSize.avatarSmall),
        child: valid
            ? AppImage.network(
                raw,
                width: context.ui.size.width(AppComponentSize.avatarSmall),
                height: context.ui.size.height(AppComponentSize.avatarSmall),
                shape: AppImageShape.rounded, borderRadius: AppRadius.sm.of(context),
                semanticsLabel: brand.name,
                errorWidget: const Center(child: AppIcon(AppIcons.brokenImage)))
            : ColoredBox(
                color: context.ui.theme.colors.surfaceContainerHighest,
                child: const Center(child: AppIcon(AppIcons.brands)))),
    );
  }

  Widget _statusBadge(Brand b) => AppBadge(
    label: b.isActive ? BrandsKeys.active : BrandsKeys.inactive,
    tone: b.isActive ? AppBadgeTone.success : AppBadgeTone.neutral,
    size: AppBadgeSize.small,
  );

  Widget _card(BuildContext context, Brand b) {
    final description = b.description?.trim() ?? '';
    return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _identity(context, b),
      if (description.isNotEmpty) ...[
        context.ui.spacing.gap(AppSpacing.sm),
        AppText.raw(description, type: AppTextType.bodySmall,
          color: context.ui.theme.colors.onSurfaceVariant, maxLines: 2),
      ],
      context.ui.spacing.gap(AppSpacing.sm),
      Wrap(spacing: context.ui.spacing.sm, runSpacing: context.ui.spacing.sm, children: [
        _statusBadge(b),
        AppText.raw(BrandsKeys.productCount.tr(context: context) + ': ' +
          (b.productCount?.toString() ?? '—'), type: AppTextType.bodySmall),
      ]),
    ],
  );
  }
}

class _BrandEditor extends StatefulWidget {
  const _BrandEditor({this.brand});
  final Brand? brand;
  @override
  State<_BrandEditor> createState() => _BrandEditorState();
}

class _BrandEditorState extends State<_BrandEditor> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _name, _slug, _logo, _description;
  bool _saving = false;
  AppKey? _failure;

  @override
  void initState() {
    super.initState();
    final b = widget.brand;
    _name = TextEditingController(text: b?.name ?? '');
    _slug = TextEditingController(text: b?.slug ?? '');
    _logo = TextEditingController(text: b?.logo ?? '');
    _description = TextEditingController(text: b?.description ?? '');
  }

  @override
  void dispose() {
    _name.dispose(); _slug.dispose(); _logo.dispose(); _description.dispose();
    super.dispose();
  }

  String _slugify(String s) => s.trim().toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');

  Future<void> _save() async {
    if (_saving || !_key.currentState!.validate()) return;
    setState(() { _saving = true; _failure = null; });
    final result = await context.read<BrandFormCubit>().save(
      id: widget.brand?.id,
      draft: BrandDraft(
        name: _name.text.trim(), slug: _slug.text.trim(),
        logo: _logo.text.trim().isEmpty ? null : _logo.text.trim(),
        description: _description.text.trim().isEmpty ? null : _description.text.trim(),
      ),
    );
    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _saving = false;
        _failure = f is BrandDuplicateFailure ? BrandsKeys.duplicateError : f.messageKey;
      }),
      (_) => Navigator.of(context).pop(true),
    );
  }

  @override
  Widget build(BuildContext context) => Dialog(
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: context.ui.size.width(AppComponentSize.cardWidth) * 2,
        maxHeight: context.ui.size.height(AppComponentSize.cardHeight) * 3,
      ),
      child: Padding(
        padding: context.ui.padding.all(AppSpacing.md),
        child: Form(
          key: _key,
          child: SingleChildScrollView(child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppText(widget.brand == null ? BrandsKeys.add : BrandsKeys.edit,
                type: AppTextType.titleLarge),
              context.ui.spacing.gap(AppSpacing.xs),
              AppText(BrandsKeys.editorSubtitle, type: AppTextType.bodySmall),
              context.ui.spacing.gap(AppSpacing.md),
              if (_failure != null) ...[
                InlineBanner(messageKey: _failure!, variant: InlineBannerVariant.error),
                context.ui.spacing.gap(AppSpacing.smMd),
              ],
              AppTextField(controller: _name, labelKey: BrandsKeys.brandName,
                validator: (v) {
                  final s = v?.trim() ?? '';
                  if (s.isEmpty) return BrandsKeys.required.tr(context: context);
                  if (s.length > 150) return BrandsKeys.brandName.tr(context: context);
                  return null;
                },
                onChanged: (v) {
                  if (_slug.text.isEmpty) _slug.text = _slugify(v);
                  if (_failure != null) setState(() => _failure = null);
                }),
              context.ui.spacing.gap(AppSpacing.smMd),
              AppTextField(controller: _slug, labelKey: BrandsKeys.slug,
                validator: (v) {
                  final s = v?.trim() ?? '';
                  if (s.isEmpty) return BrandsKeys.slugRequired.tr(context: context);
                  if (s.length > 150) return BrandsKeys.slugTooLong.tr(context: context);
                  if (!RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(s)) {
                    return BrandsKeys.slugFormat.tr(context: context);
                  }
                  return null;
                }),
              context.ui.spacing.gap(AppSpacing.smMd),
              AppTextField(controller: _logo, labelKey: BrandsKeys.logo,
                keyboardType: TextInputType.url,
                validator: (v) {
                  final s = v?.trim() ?? '';
                  if (s.isEmpty) return null;
                  if (s.length > 500) return BrandsKeys.logoTooLong.tr(context: context);
                  final u = Uri.tryParse(s);
                  if (u == null || !u.hasScheme ||
                      (u.scheme != 'http' && u.scheme != 'https') || u.host.isEmpty) {
                    return BrandsKeys.invalidLogoUrl.tr(context: context);
                  }
                  return null;
                }),
              context.ui.spacing.gap(AppSpacing.smMd),
              AppTextField(controller: _description, labelKey: BrandsKeys.description, maxLines: 3),
              context.ui.spacing.gap(AppSpacing.md),
              Wrap(alignment: WrapAlignment.end, spacing: context.ui.spacing.sm, children: [
                AppButton(BrandsKeys.cancel, variant: AppButtonVariant.text,
                  onPressed: _saving ? null : () => Navigator.of(context).pop(false)),
                AppButton(BrandsKeys.save, isLoading: _saving,
                  onPressed: _saving ? null : _save),
              ]),
            ],
          )),
        ),
      ),
    ),
  );
}
