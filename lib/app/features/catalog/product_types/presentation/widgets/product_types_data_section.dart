import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/localization/keys/common_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_data_section.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_labels.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_list_query.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/cubit/product_types_list/product_types_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/localization/product_types_keys.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/routing/product_types_routes.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/widgets/product_type_card.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/widgets/product_type_status_badge.dart';

class ProductTypesDataSection extends StatelessWidget {
  const ProductTypesDataSection({
    super.key,
    required this.data,
    required this.labels,
  });

  final CrudDataContext<
    ProductType,
    ProductTypeListQuery,
    ProductTypesListCubit
  >
  data;
  final CrudLabels labels;

  @override
  Widget build(BuildContext context) =>
      CrudDataSection<ProductType, ProductTypeListQuery, ProductTypesListCubit>(
        data: data,
        columns: [
          DataTableColumn(
            labelKey: ProductTypesKeys.nameLabel,
            priority: DataTableColumnPriority.primary,
            flex: 3,
            cellBuilder: (_, item) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.raw(item.name, type: AppTextType.titleSmall),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: AppText.raw(
                    item.code,
                    type: AppTextType.labelSmall,
                    color: context.ui.theme.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          DataTableColumn(
            labelKey: ProductTypesKeys.products,
            numeric: true,
            priority: DataTableColumnPriority.secondary,
            cellBuilder: (context, item) => item.productCount == null
                ? const AppText(CommonKeys.noValue)
                : AppText.raw(
                    ProductTypesKeys.productsCount.tr(
                      context: context,
                      namedArgs: {'count': item.productCount.toString()},
                    ),
                  ),
          ),
          DataTableColumn(
            labelKey: ProductTypesKeys.descriptionLabel,
            priority: DataTableColumnPriority.secondary,
            flex: 2,
            cellBuilder: (context, item) => AppText.raw(
              item.description?.trim() ?? '',
              color: context.ui.theme.colors.onSurfaceVariant,
              maxLines: 2,
            ),
          ),
        ],
        labels: labels,
        statusColumn: CrudStatusColumnConfig<ProductType>(
          labelKey: ProductTypesKeys.status,
          isActive: (item) => item.isActive,
          badgeBuilder: (_, item) => ProductTypeStatusBadge(item),
        ),
        cardBuilder: (_, item) => ProductTypeCard(item),
        gridBuilder: (_, item) => ProductTypeCard(item),
        icon: AppIcons.catalog,
        emptyTitleKey: ProductTypesKeys.empty,
        emptyDescriptionKey: ProductTypesKeys.emptyDescription,
        noResultsTitleKey: ProductTypesKeys.noResults,
        noResultsDescriptionKey: ProductTypesKeys.noResultsDescription,
        onRowTap: (item) => context.push(ProductTypesRoutes.details(item.id)),
      );
}
