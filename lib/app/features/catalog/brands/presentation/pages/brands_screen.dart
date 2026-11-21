import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/permission_gate/permission_gate.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/presentation/state_management/bloc_effect_listener.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_breadcrumb/app_breadcrumb.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_confirm_dialog/confirm_dialog.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/app_page_templates.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brand_stats/brand_stats_cubit.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brand_stats/brand_stats_state.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brands_list/brands_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brands_list/brands_list_effect.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brands_list/brands_list_state.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/sections/brands_table_section.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/dialogs/brand_editor_dialog.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/widgets/brand_stats_bar.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/widgets/brands_filter_bar.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_routes.dart';

class BrandsScreen extends StatelessWidget {
  const BrandsScreen({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => sl<BrandsListCubit>()..load()),
      BlocProvider(create: (_) => sl<BrandStatsCubit>()..load()),
    ],
    child: BlocEffectListener<BrandsListEffect, BrandsListCubit>(
      onEffect: (context, effect) {
        if (effect is BrandsMutatedEffect) {
          context.read<BrandStatsCubit>().refresh();
        }
      },
      child: BlocBuilder<BrandStatsCubit, BrandStatsState>(
        builder: (context, statsState) =>
            BlocBuilder<BrandsListCubit, BrandsListState>(
              builder: (context, state) {
                final cubit = context.read<BrandsListCubit>();
                final page = state.result;
                final query = state.query;
                final stats = statsState.stats;
                final rows = page?.items ?? const <Brand>[];
                final total = page?.totalCount ?? 0;
                final failure = state.hasData ? null : state.failure;
                final refreshFailure = state.hasData ? state.failure : null;
                final loading = state.isInitialLoading;
                final refreshing = state.isRefreshing;
    
                return ListPageTemplate(
                  titleKey: BrandsKeys.title,
                  breadcrumb: AppBreadcrumb(
                    items: [
                      AppBreadcrumbItem(
                        label: NavKeys.catalog,
                        onTap: () => context.go(CatalogRoutes.hub.path),
                      ),
                      const AppBreadcrumbItem(label: BrandsKeys.title),
                    ],
                  ),
                  count: total,
                  actions: stats == null ? null : BrandStatsBar(stats),
                  primaryAction: PermissionGate(
                    permission: Permissions.masterData.manage,
                    child: AppButton(
                      BrandsKeys.add,
                      icon: AppIcons.add,
                      onPressed: () => _edit(context),
                    ),
                  ),
                  filterBar: BrandsFilterBar(
                    query: query,
                    onSearchChanged: cubit.searchChanged,
                    onStatusChanged: cubit.setStatus,
                    onClearAll: cubit.clearFilters,
                  ),
                  state: loading
                      ? AppPageState.loading
                      : failure != null
                      ? AppPageState.error
                      : AppPageState.content,
                  dataTable: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (refreshFailure != null) ...[
                        InlineBanner(
                          messageKey: refreshFailure.messageKey,
                          variant: InlineBannerVariant.error,
                        ),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: AppButton(
                            CatalogUiKeys.retry,
                            variant: AppButtonVariant.text,
                            onPressed: cubit.refresh,
                          ),
                        ),
                      ],
                      BrandsTableSection(
                        query: query,
                        onRetry: cubit.refresh,
                        onSort: (sort) =>
                            cubit.setSort(ascending: sort.ascending),
                        onPageChanged: cubit.setPage,
                        rows: rows,
                        total: total,
                        loading: loading || refreshing,
                        failure: failure,
                        onAdd: () => _edit(context),
                        onEdit: (brand) => _edit(context, brand),
                        onDelete: (brand) => _delete(context, brand),
                        onToggleStatus: (brand) => _status(context, brand),
                      ),
                    ],
                  ),
                );
              },
            ),
      ),
    ),
  );

  Future<void> _edit(BuildContext context, [Brand? brand]) async {
    final saved = await showBrandEditor(context, brand: brand);
    if (saved == true && context.mounted) {
      await context.read<BrandsListCubit>().onBrandSaved(isNew: brand == null);
    }
  }

  Future<void> _delete(BuildContext context, Brand brand) async {
    await showConfirmDialog(
      context,
      titleKey: BrandsKeys.delete,
      messageKey: BrandsKeys.confirmDelete,
      severity: ConfirmDialogSeverity.warning,
      targetName: brand.name,
      onConfirm: () async {
        final result = await context.read<BrandsListCubit>().delete(brand);
        return result.fold((failure) => failure.messageKey, (_) => null);
      },
    );
  }

  Future<void> _status(BuildContext context, Brand brand) async {
    final cubit = context.read<BrandsListCubit>();
    if (!brand.isActive) {
      await cubit.activate(brand.id);
      return;
    }

    await showConfirmDialog(
      context,
      titleKey: BrandsKeys.deactivateTitle,
      messageKey: BrandsKeys.deactivateMessage,
      severity: ConfirmDialogSeverity.warning,
      targetName: brand.name,
      onConfirm: () async {
        final result = await cubit.deactivate(brand.id);
        return result.fold((failure) => failure.messageKey, (_) => null);
      },
    );
  }
}
