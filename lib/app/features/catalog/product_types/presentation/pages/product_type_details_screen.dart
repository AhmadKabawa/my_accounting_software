import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_breadcrumb/app_breadcrumb.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_skeleton/app_skeleton.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_body/app_page_body.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_header/app_page_header.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/cubit/product_type_details/product_type_details_cubit.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/cubit/product_type_details/product_type_details_state.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/localization/product_types_keys.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/routing/product_types_routes.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/sections/product_type_attributes_section.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/sections/product_type_option_sets_section.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/sections/product_type_size_groups_section.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_routes.dart';

class ProductTypeDetailsScreen extends StatelessWidget {
  const ProductTypeDetailsScreen({super.key, required this.productTypeId});

  final int productTypeId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<ProductTypeDetailsCubit>()..load(productTypeId),
    child: _ProductTypeDetailsBody(productTypeId: productTypeId),
  );
}

class _ProductTypeDetailsBody extends StatelessWidget {
  const _ProductTypeDetailsBody({required this.productTypeId});

  final int productTypeId;

  @override
  Widget build(BuildContext context) {
    final canManage = context.watch<AccessCubit>().can(
      Permissions.masterData.manage,
    );
    return BlocBuilder<ProductTypeDetailsCubit, ProductTypeDetailsState>(
      builder: (context, state) => AppPageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppPageHeader(
              titleKey: ProductTypesKeys.detailTitle,
              subtitle: state is ProductTypeDetailsLoaded
                  ? Directionality(
                      textDirection: TextDirection.ltr,
                      child: AppText.raw(
                        ProductTypesKeys.detailSubtitle.tr(
                          context: context,
                          namedArgs: {
                            'name': state.productType.name,
                            'code': state.productType.code,
                          },
                        ),
                      ),
                    )
                  : null,
              breadcrumb: AppBreadcrumb(
                items: [
                  AppBreadcrumbItem(
                    label: NavKeys.catalog,
                    onTap: () => context.go(CatalogRoutes.hub.path),
                  ),
                  AppBreadcrumbItem(
                    label: ProductTypesKeys.title,
                    onTap: () =>
                        context.go(ProductTypesRoutes.productTypes.path),
                  ),
                  const AppBreadcrumbItem(label: ProductTypesKeys.detailTitle),
                ],
              ),
            ),
            if (state is ProductTypeDetailsLoading ||
                state is ProductTypeDetailsInitial)
              Column(
                children: [
                  AppSkeleton.card(height: AppComponentSize.cardHeight.of(context)),
                  context.ui.spacing.gap(AppSpacing.md),
                  AppSkeleton.card(height: AppComponentSize.cardHeight.of(context)),
                  context.ui.spacing.gap(AppSpacing.md),
                  AppSkeleton.card(height: AppComponentSize.cardHeight.of(context)),
                ],
              )
            else if (state is ProductTypeDetailsFailed)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InlineBanner(
                    messageKey: state.failure.messageKey,
                    variant: InlineBannerVariant.error,
                  ),
                  context.ui.spacing.gap(AppSpacing.sm),
                  AppButton(
                    ProductTypesKeys.retry,
                    onPressed: () => context
                        .read<ProductTypeDetailsCubit>()
                        .load(productTypeId),
                  ),
                ],
              )
            else if (state is ProductTypeDetailsLoaded) ...[
              if (state.updateFailure != null)
                InlineBanner(
                  messageKey: state.updateFailure!.messageKey,
                  variant: InlineBannerVariant.error,
                ),
              if ((state.publishedProductCount ?? 0) > 0)
                InlineBanner(
                  messageKey: ProductTypesKeys.publishedProductsWarning,
                  variant: InlineBannerVariant.warning,
                ),
              ProductTypeSizeGroupsSection(state: state, canManage: canManage),
              context.ui.spacing.gap(AppSpacing.md),
              ProductTypeAttributesSection(state: state, canManage: canManage),
              context.ui.spacing.gap(AppSpacing.md),
              ProductTypeOptionSetsSection(state: state, canManage: canManage),
            ],
          ],
        ),
      ),
    );
  }
}
