import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_card/app_card.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_empty_state/app_empty_state.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_switch/app_switch.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_attribute_link.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_link_option.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/cubit/product_type_details/product_type_details_cubit.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/cubit/product_type_details/product_type_details_state.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/localization/product_types_keys.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/sections/product_type_detail_section_helpers.dart';

class ProductTypeAttributesSection extends StatelessWidget {
  const ProductTypeAttributesSection({required this.state, required this.canManage});

  final ProductTypeDetailsLoaded state;
  final bool canManage;

  @override
  Widget build(BuildContext context) {
    final linkedIds = state.attributes.map((item) => item.attributeId).toSet();
    final options = state.attributeOptions
        .where((item) => !linkedIds.contains(item.id))
        .toList(growable: false);
    final cubit = context.read<ProductTypeDetailsCubit>();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProductTypeSectionTitle(ProductTypesKeys.attributes, state.attributes.length),
          if (canManage && options.isNotEmpty)
            SearchableDropdown<ProductTypeLinkOption>(
              options: options,
              labelKey: ProductTypesKeys.addAttribute,
              optionLabel: (item) => item.name,
              optionSubtitle: (item) => '${item.code} · ${item.detail ?? ''}',
              value: null,
              onChanged: (item) {
                if (item != null) cubit.addAttribute(attributeId: item.id);
              },
              mode: SearchableDropdownMode.panel,
              clearable: false,
              enabled: !state.processing.contains('attribute-add'),
            )
          else if (canManage)
            const AppEmptyState(
              icon: AppIcons.info,
              titleKey: ProductTypesKeys.noAvailableOptions,
              descriptionKey: ProductTypesKeys.noAvailableOptions,
              compact: true,
            ),
          context.ui.spacing.gap(AppSpacing.sm),
          if (state.attributes.isEmpty)
            const AppEmptyState(
              icon: AppIcons.catalog,
              titleKey: ProductTypesKeys.noAttributes,
              descriptionKey: ProductTypesKeys.noAttributes,
              compact: true,
            )
          else
            AppDataTable<ProductTypeAttributeLink>(
              columns: [
                DataTableColumn(
                  labelKey: ProductTypesKeys.attributes,
                  priority: DataTableColumnPriority.primary,
                  flex: 2,
                  cellBuilder: (_, item) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.raw(item.name),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: AppText.raw(
                          item.code,
                          type: AppTextType.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ),
                DataTableColumn(
                  labelKey: ProductTypesKeys.dataType,
                  cellBuilder: (_, item) => AppText.raw(item.dataType),
                ),
                DataTableColumn(
                  labelKey: ProductTypesKeys.isRequired,
                  cellBuilder: (_, item) => AppSwitch(
                    value: item.isRequired,
                    labelKey: ProductTypesKeys.isRequired,
                    onChanged:
                        !canManage ||
                            state.processing.contains(
                              'attribute-${item.attributeId}',
                            )
                        ? null
                        : (value) =>
                              cubit.updateAttribute(item, isRequired: value),
                    loading: state.processing.contains(
                      'attribute-${item.attributeId}',
                    ),
                  ),
                ),
                DataTableColumn(
                  labelKey: ProductTypesKeys.sortOrder,
                  cellBuilder: (_, item) =>
                      AppText.raw(item.sortOrder.toString()),
                ),
              ],
              rows: state.attributes,
              rowId: (item) => item.attributeId,
              rowActionsBuilder: canManage
                  ? (context, item) => AppIconButton(
                      AppIcons.close,
                      tooltipKey: ProductTypesKeys.removeLink,
                      onPressed:
                          state.processing.contains(
                            'attribute-${item.attributeId}',
                          )
                          ? null
                          : () => confirmProductTypeLinkRemoval(
                              context,
                              () => cubit.removeAttribute(item),
                            ),
                    )
                  : null,
            ),
        ],
      ),
    );
  }
}
