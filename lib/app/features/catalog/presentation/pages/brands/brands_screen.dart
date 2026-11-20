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
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/app_page_templates.dart';
import 'package:accounting_software/app/features/catalog/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/domain/failures/brand_failures.dart';
import 'package:accounting_software/app/features/catalog/presentation/cubit/brand_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/presentation/cubit/brands_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/presentation/cubit/brand_stats_cubit.dart';
import 'package:accounting_software/app/features/catalog/presentation/localization/brands_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/features/catalog/presentation/pages/brands/sections/brands_table_section.dart';
import 'package:accounting_software/app/features/catalog/presentation/pages/brands/widgets/brand_editor_dialog.dart';
import 'package:accounting_software/app/features/catalog/presentation/pages/brands/widgets/brand_stats_bar.dart';
import 'package:accounting_software/app/features/catalog/presentation/pages/brands/widgets/brands_filter_bar.dart';

class BrandsScreen extends StatelessWidget {
  const BrandsScreen({super.key});
  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => sl<BrandsListCubit>()..load()),
      BlocProvider(create: (_) => sl<BrandStatsCubit>()..load()),
    ],
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
      await context.read<BrandsListCubit>().refresh();
      await context.read<BrandStatsCubit>().refresh();
    }
  }

  void _toast(BuildContext context, AppKey key) =>
      MessageViewWidgets.showMessage(
        context,
        messageKey: key,
        type: MessageType.success,
      );

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
      if (changed && context.mounted) {
        await context.read<BrandStatsCubit>().refresh();
        _toast(context, BrandsKeys.statusUpdated);
      }
    } else {
      final result = await cubit.setActive(id: brand.id, isActive: true);
      if (!context.mounted) return;
      result.fold(
        (f) => MessageViewWidgets.showMessage(
          context,
          messageKey: f.messageKey,
          type: MessageType.error,
        ),
        (_) {
          context.read<BrandStatsCubit>().refresh();
          _toast(context, BrandsKeys.statusUpdated);
        },
      );
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
    if (deleted && context.mounted) {
      await context.read<BrandStatsCubit>().refresh();
      _toast(context, BrandsKeys.deleted);
    }
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<BrandStatsCubit, BrandStatsState>(
        builder: (context, statsState) =>
          BlocBuilder<BrandsListCubit, BrandsListState>(
        builder: (context, state) {
          final cubit = context.read<BrandsListCubit>();
          final page = state is BrandsListReady ? state : null;
          final query = cubit.query;
          final stats = statsState is BrandStatsLoaded ? statsState.stats : null;
          final rows = page?.result.items ?? const <Brand>[];
          final total = page?.result.totalCount ?? 0;
          final failure = state is BrandsListFailed ? state.failure : null;
          final loading =
              state is BrandsListInitial || state is BrandsListLoading;

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
            filterBar: BrandsFilterBar(query: query, cubit: cubit),
            state: loading
                ? AppPageState.loading
                : failure != null
                ? AppPageState.error
                : AppPageState.content,
            dataTable: BrandsTableSection(
              cubit: cubit,
              query: query,
              rows: rows,
              total: total,
              loading: loading,
              failure: failure,
              onAdd: () => _edit(context),
              onEdit: (brand) => _edit(context, brand),
              onDelete: (brand) => _delete(context, brand),
              onToggleStatus: (brand) => _status(context, brand),
            ),
          );
        },
      ),
    );
}
