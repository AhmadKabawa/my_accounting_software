import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/localization/keys/common_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_card/app_card.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_empty_state/app_empty_state.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_switch/app_switch.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_link_option.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_size_group_link.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/cubit/product_type_details/product_type_details_cubit.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/cubit/product_type_details/product_type_details_state.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/localization/product_types_keys.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/sections/product_type_detail_section_helpers.dart';

class ProductTypeSizeGroupsSection extends StatefulWidget {
  const ProductTypeSizeGroupsSection({
    super.key,
    required this.state,
    required this.canManage,
  });

  final ProductTypeDetailsLoaded state;
  final bool canManage;

  @override
  State<ProductTypeSizeGroupsSection> createState() =>
      _ProductTypeSizeGroupsSectionState();
}

class _ProductTypeSizeGroupsSectionState
    extends State<ProductTypeSizeGroupsSection> {
  int? _genderId;
  bool _default = false;

  @override
  Widget build(BuildContext context) {
    final linkedIds = widget.state.sizeGroups
        .map((item) => item.sizeGroupId)
        .toSet();
    final options = widget.state.sizeGroupOptions
        .where((item) => !linkedIds.contains(item.id))
        .toList(growable: false);
    final cubit = context.read<ProductTypeDetailsCubit>();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProductTypeSectionTitle(
            ProductTypesKeys.sizeGroups,
            widget.state.sizeGroups.length,
          ),
          if (widget.canManage && options.isNotEmpty) ...[
            SearchableDropdown<ProductTypeLinkOption>(
              options: options,
              labelKey: ProductTypesKeys.addSizeGroup,
              optionLabel: (item) => item.name,
              optionSubtitle: (item) => item.code,
              value: null,
              onChanged: (item) {
                if (item == null) return;
                cubit.addSizeGroup(
                  sizeGroupId: item.id,
                  genderId: _genderId,
                  isDefault: _default,
                );
                setState(() => _default = false);
              },
              mode: SearchableDropdownMode.panel,
              clearable: false,
              enabled: !widget.state.processing.contains('size-group-add'),
            ),
            context.ui.spacing.gap(AppSpacing.sm),
            if (widget.state.genderOptions.isNotEmpty)
              SearchableDropdown<ProductTypeLinkOption>(
                options: widget.state.genderOptions,
                labelKey: ProductTypesKeys.gender,
                optionLabel: (item) => item.name,
                value:
                    widget.state.genderOptions
                        .where((item) => item.id == _genderId)
                        .toList(growable: false)
                        .isEmpty
                    ? null
                    : widget.state.genderOptions
                          .where((item) => item.id == _genderId)
                          .first,
                onChanged: (item) => setState(() => _genderId = item?.id),
                mode: SearchableDropdownMode.panel,
              ),
            AppSwitch(
              value: _default,
              labelKey: ProductTypesKeys.isDefault,
              onChanged: (value) => setState(() => _default = value),
            ),
          ] else if (widget.canManage)
            const AppEmptyState(
              icon: AppIcons.info,
              titleKey: ProductTypesKeys.noAvailableOptions,
              descriptionKey: ProductTypesKeys.noAvailableOptions,
              compact: true,
            ),
          context.ui.spacing.gap(AppSpacing.sm),
          if (widget.state.sizeGroups.isEmpty)
            const AppEmptyState(
              icon: AppIcons.catalog,
              titleKey: ProductTypesKeys.noSizeGroups,
              descriptionKey: ProductTypesKeys.noSizeGroups,
              compact: true,
            )
          else
            AppDataTable<ProductTypeSizeGroupLink>(
              columns: [
                DataTableColumn(
                  labelKey: ProductTypesKeys.sizeGroups,
                  priority: DataTableColumnPriority.primary,
                  flex: 2,
                  cellBuilder: (_, item) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.raw(item.sizeGroupName),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: AppText.raw(
                          item.sizeGroupCode,
                          type: AppTextType.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ),
                DataTableColumn(
                  labelKey: ProductTypesKeys.sizeSystem,
                  cellBuilder: (_, item) => item.sizeSystemName == null
                      ? const AppText(CommonKeys.noValue)
                      : AppText.raw(item.sizeSystemName!),
                ),
                DataTableColumn(
                  labelKey: ProductTypesKeys.gender,
                  cellBuilder: (_, item) => item.genderName == null
                      ? const AppText(CommonKeys.noValue)
                      : AppText.raw(item.genderName!),
                ),
                DataTableColumn(
                  labelKey: ProductTypesKeys.isDefault,
                  cellBuilder: (_, item) => AppSwitch(
                    value: item.isDefault,
                    labelKey: ProductTypesKeys.isDefault,
                    onChanged:
                        !widget.canManage ||
                            widget.state.processing.contains(
                              'size-group-${item.id}',
                            )
                        ? null
                        : (value) => cubit.updateSizeGroup(
                            link: item,
                            isDefault: value,
                          ),
                    loading: widget.state.processing.contains(
                      'size-group-${item.id}',
                    ),
                  ),
                ),
                DataTableColumn(
                  labelKey: ProductTypesKeys.sortOrder,
                  cellBuilder: (_, item) =>
                      AppText.raw(item.sortOrder.toString()),
                ),
              ],
              rows: widget.state.sizeGroups,
              rowId: (item) => item.id,
              rowActionsBuilder: widget.canManage
                  ? (context, item) => AppIconButton(
                      AppIcons.close,
                      tooltipKey: ProductTypesKeys.removeLink,
                      onPressed:
                          widget.state.processing.contains(
                            'size-group-${item.id}',
                          )
                          ? null
                          : () => _confirmRemoveSizeGroup(context, item, cubit),
                    )
                  : null,
            ),
        ],
      ),
    );
  }

  Future<void> _confirmRemoveSizeGroup(
    BuildContext context,
    ProductTypeSizeGroupLink item,
    ProductTypeDetailsCubit cubit,
  ) async {
    await confirmProductTypeLinkRemoval(
      context,
      () => cubit.removeSizeGroup(item),
    );
  }
}
