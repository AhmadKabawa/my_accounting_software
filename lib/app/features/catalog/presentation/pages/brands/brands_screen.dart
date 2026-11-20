import 'package:accounting_software/app/core/presentation/widgets/app_row_actions/app_row_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_routes.dart';
import 'package:accounting_software/app/core/access/permission_gate/permission_gate.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_breadcrumb/app_breadcrumb.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_confirm_dialog/confirm_dialog.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_empty_state/app_empty_state.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/app_page_templates.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/features/catalog/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/domain/entity/brand_list_query.dart';
import 'package:accounting_software/app/features/catalog/domain/failures/brand_failures.dart';
import 'package:accounting_software/app/features/catalog/presentation/cubit/brand_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/presentation/cubit/brands_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/presentation/localization/brands_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/features/catalog/presentation/pages/brands/widgets/brand_card.dart';
import 'package:accounting_software/app/features/catalog/presentation/pages/brands/widgets/brand_editor_dialog.dart';
import 'package:accounting_software/app/features/catalog/presentation/pages/brands/widgets/brand_logo.dart';
import 'package:accounting_software/app/features/catalog/presentation/pages/brands/widgets/brand_stats_bar.dart';
import 'package:accounting_software/app/features/catalog/presentation/pages/brands/widgets/brand_status_badge.dart';
import 'package:accounting_software/app/features/catalog/presentation/pages/brands/widgets/brands_filter_bar.dart';

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
        child: BrandEditorDialog(brand: brand),
      ),
    );
    if (saved == true && context.mounted) {
      await context.read<BrandsListCubit>().refresh(refreshStats: true);
    }
  }

  void _toast(BuildContext context, AppKey key) =>
      MessageViewWidgets.showMessage(context, messageKey: key, type: MessageType.success);

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
      result.fold((f) => MessageViewWidgets.showMessage(context, messageKey: f.messageKey, type: MessageType.error),
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
        breadcrumb: AppBreadcrumb(items: [
          AppBreadcrumbItem(
            label: NavKeys.catalog,
            onTap: () => context.go(CatalogRoutes.hub.path),
          ),
          const AppBreadcrumbItem(label: BrandsKeys.title),
        ]),
        count: total,
        actions: stats == null ? null : BrandStatsBar(stats),
        primaryAction: PermissionGate(
          permission: Permissions.masterData.manage,
          child: AppButton(BrandsKeys.add, icon: AppIcons.add,
              onPressed: () => _edit(context)),
        ),
        filterBar: BrandsFilterBar(query: query, cubit: cubit),
        state: loading ? AppPageState.loading
            : failure != null ? AppPageState.error : AppPageState.content,
        dataTable: AppDataTable<Brand>(
          columns: [
            DataTableColumn(labelKey: BrandsKeys.brandName, sortKey: 'name',
              priority: DataTableColumnPriority.primary, flex: 3,
              cellBuilder: (_, b) => BrandIdentity(b)),
            DataTableColumn(labelKey: BrandsKeys.description,
              priority: DataTableColumnPriority.secondary, flex: 2,
              cellBuilder: (c, b) {
                final description = b.description?.trim() ?? '';
                return AppText.raw(
                  description,
                  color: c.ui.theme.colors.onSurfaceVariant,
                  maxLines: 2,
                );
              }),
            DataTableColumn(labelKey: BrandsKeys.productCount,
              priority: DataTableColumnPriority.secondary, numeric: true,
              cellBuilder: (_, b) => BrandProductsBadge(b)),
            DataTableColumn(labelKey: BrandsKeys.status,
              priority: DataTableColumnPriority.secondary,
              cellBuilder: (_, b) => BrandStatusBadge(b)),
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
          cardBuilder: (_, b) => BrandCard(b),
          rowActionsBuilder: (c, b) => PermissionGate(
            permission: Permissions.masterData.manage,
            child: AppRowActions(
              primary: [
                AppRowAction(
                  icon: AppIcons.edit,
                  labelKey: BrandsKeys.edit,
                  onPressed: () => _edit(context, b),
                ),
                if (b.productCount == 0)
                  AppRowAction(
                    icon: AppIcons.delete,
                    labelKey: BrandsKeys.delete,
                    destructive: true,
                    onPressed: () => _delete(context, b),
                  ),
              ],
              overflow: [
                AppRowAction(
                  icon: b.isActive ? AppIcons.block : AppIcons.restore,
                  labelKey: b.isActive ? BrandsKeys.deactivate : BrandsKeys.activate,
                  onPressed: () => _status(context, b),
                ),
              ],
            ),
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

}
