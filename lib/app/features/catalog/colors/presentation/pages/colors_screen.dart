import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/permission_gate/permission_gate.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_breadcrumb/app_breadcrumb.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_confirm_dialog/confirm_dialog.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/app_page_templates.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/colors_list/colors_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/colors_list/colors_list_state.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/dialogs/color_editor_dialog.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/localization/colors_keys.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/sections/colors_table_section.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/widgets/colors_filter_bar.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_routes.dart';

class ColorsScreen extends StatelessWidget {
  const ColorsScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<ColorsListCubit>()..load(),
    child: BlocBuilder<ColorsListCubit, ColorsListState>(
      builder: (context, state) {
        final cubit = context.read<ColorsListCubit>();
        final page = state.result;
        final query = state.query;
        final rows = page?.items ?? const <CatalogColor>[];
        final total = page?.totalCount ?? 0;
        final failure = state.hasData ? null : state.failure;
        final refreshFailure = state.hasData ? state.failure : null;
        final loading = state.isInitialLoading;

        return ListPageTemplate(
          titleKey: ColorsKeys.title,
          breadcrumb: AppBreadcrumb(
            items: [
              AppBreadcrumbItem(
                label: NavKeys.catalog,
                onTap: () => context.go(CatalogRoutes.hub.path),
              ),
              const AppBreadcrumbItem(label: ColorsKeys.title),
            ],
          ),
          count: total,
          primaryAction: PermissionGate(
            permission: Permissions.masterData.manage,
            child: AppButton(
              ColorsKeys.add,
              icon: AppIcons.add,
              onPressed: () => _edit(context),
            ),
          ),
          filterBar: ColorsFilterBar(
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
              ColorsTableSection(
                query: query,
                onRetry: cubit.refresh,
                onSort: (sort) => cubit.setSort(
                  ColorSortKeys.field(sort.key),
                  ascending: sort.ascending,
                ),
                onPageChanged: cubit.setPage,
                rows: rows,
                total: total,
                loading: loading,
                refreshing: state.isRefreshing,
                failure: failure,
                onAdd: () => _edit(context),
                onEdit: (color) => _edit(context, color),
                onToggleStatus: (color) => _status(context, color),
              ),
            ],
          ),
        );
      },
    ),
  );

  Future<void> _edit(BuildContext context, [CatalogColor? color]) async {
    final saved = await showColorEditor(context, color: color);
    if (saved == true && context.mounted) {
      await context.read<ColorsListCubit>().onColorSaved(isNew: color == null);
    }
  }

  Future<void> _status(BuildContext context, CatalogColor color) async {
    final cubit = context.read<ColorsListCubit>();
    if (!color.isActive) {
      await cubit.activate(color.id);
      return;
    }

    await showConfirmDialog(
      context,
      titleKey: ColorsKeys.deactivateTitle,
      messageKey: ColorsKeys.deactivateMessage,
      severity: ConfirmDialogSeverity.warning,
      targetName: color.name,
      onConfirm: () async {
        final result = await cubit.deactivate(color.id);
        return result.fold((failure) => failure.messageKey, (_) => null);
      },
    );
  }
}
