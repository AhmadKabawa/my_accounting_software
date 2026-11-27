import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/localization/keys/common_keys.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_breadcrumb/app_breadcrumb.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_card/app_card.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_confirm_dialog/confirm_dialog.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_empty_state/app_empty_state.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_body/app_page_body.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_header/app_page_header.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_switch/app_switch.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_attribute_link.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_link_option.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_option_set_link.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_size_group_link.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/cubit/product_type_details/product_type_details_cubit.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/cubit/product_type_details/product_type_details_state.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/localization/product_types_keys.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/routing/product_types_routes.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_routes.dart';

class ProductTypeDetailsScreen extends StatelessWidget {
  const ProductTypeDetailsScreen({super.key, required this.productTypeId});

  final int productTypeId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<ProductTypeDetailsCubit>()..load(productTypeId),
    child: const _ProductTypeDetailsBody(),
  );
}

class _ProductTypeDetailsBody extends StatelessWidget {
  const _ProductTypeDetailsBody();

  @override
  Widget build(BuildContext context) {
    final canManage = context.watch<AccessCubit>().can(
      Permissions.masterData.manage,
    );
    return BlocBuilder<ProductTypeDetailsCubit, ProductTypeDetailsState>(
      builder: (context, state) {
        return AppPageBody(
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
                    const AppBreadcrumbItem(
                      label: ProductTypesKeys.detailTitle,
                    ),
                  ],
                ),
              ),
              if (state is ProductTypeDetailsLoading ||
                  state is ProductTypeDetailsInitial)
                const AppEmptyState(
                  icon: AppIcons.catalog,
                  titleKey: ProductTypesKeys.busy,
                  descriptionKey: ProductTypesKeys.busy,
                )
              else if (state is ProductTypeDetailsFailed)
                InlineBanner(
                  messageKey: state.failure.messageKey,
                  variant: InlineBannerVariant.error,
                )
              else if (state is ProductTypeDetailsLoaded) ...[
                if (state.updateFailure != null)
                  InlineBanner(
                    messageKey: state.updateFailure!.messageKey,
                    variant: InlineBannerVariant.error,
                  ),
                if ((state.publishedProductCount ?? 0) > 0)
                  AppCard(
                    child: AppText.raw(
                      ProductTypesKeys.publishedProductsWarning.tr(
                        context: context,
                        namedArgs: {
                          'count': state.publishedProductCount.toString(),
                        },
                      ),
                    ),
                  ),
                _SizeGroupsSection(state: state, canManage: canManage),
                context.ui.spacing.gap(AppSpacing.md),
                _AttributesSection(state: state, canManage: canManage),
                context.ui.spacing.gap(AppSpacing.md),
                _OptionSetsSection(state: state, canManage: canManage),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SizeGroupsSection extends StatefulWidget {
  const _SizeGroupsSection({required this.state, required this.canManage});

  final ProductTypeDetailsLoaded state;
  final bool canManage;

  @override
  State<_SizeGroupsSection> createState() => _SizeGroupsSectionState();
}

class _SizeGroupsSectionState extends State<_SizeGroupsSection> {
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
          _SectionTitle(
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
    final confirmed = await showConfirmDialog(
      context,
      titleKey: ProductTypesKeys.removeLink,
      messageKey: ProductTypesKeys.removeLinkConfirmation,
      severity: ConfirmDialogSeverity.warning,
      confirmLabelKey: ProductTypesKeys.removeLink,
    );
    if (confirmed) await cubit.removeSizeGroup(item);
  }
}

class _AttributesSection extends StatelessWidget {
  const _AttributesSection({required this.state, required this.canManage});

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
          _SectionTitle(ProductTypesKeys.attributes, state.attributes.length),
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
                          : () => _confirmRemove(
                              context,
                              cubit,
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

class _OptionSetsSection extends StatelessWidget {
  const _OptionSetsSection({required this.state, required this.canManage});

  final ProductTypeDetailsLoaded state;
  final bool canManage;

  @override
  Widget build(BuildContext context) {
    final linkedIds = state.optionSets.map((item) => item.optionSetId).toSet();
    final options = state.optionSetOptions
        .where((item) => !linkedIds.contains(item.id))
        .toList(growable: false);
    final cubit = context.read<ProductTypeDetailsCubit>();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionTitle(ProductTypesKeys.optionSets, state.optionSets.length),
          if (canManage && options.isNotEmpty)
            SearchableDropdown<ProductTypeLinkOption>(
              options: options,
              labelKey: ProductTypesKeys.addOptionSet,
              optionLabel: (item) => item.name,
              optionSubtitle: (item) => item.code,
              value: null,
              onChanged: (item) {
                if (item != null) cubit.addOptionSet(optionSetId: item.id);
              },
              mode: SearchableDropdownMode.panel,
              clearable: false,
              enabled: !state.processing.contains('option-set-add'),
            )
          else if (canManage)
            const AppEmptyState(
              icon: AppIcons.info,
              titleKey: ProductTypesKeys.noAvailableOptions,
              descriptionKey: ProductTypesKeys.noAvailableOptions,
              compact: true,
            ),
          context.ui.spacing.gap(AppSpacing.sm),
          if (state.optionSets.isEmpty)
            const AppEmptyState(
              icon: AppIcons.catalog,
              titleKey: ProductTypesKeys.noOptionSets,
              descriptionKey: ProductTypesKeys.noOptionSets,
              compact: true,
            )
          else
            AppDataTable<ProductTypeOptionSetLink>(
              columns: [
                DataTableColumn(
                  labelKey: ProductTypesKeys.optionSets,
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
                  labelKey: ProductTypesKeys.isRequired,
                  cellBuilder: (_, item) => AppSwitch(
                    value: item.isRequired,
                    labelKey: ProductTypesKeys.isRequired,
                    onChanged:
                        !canManage ||
                            state.processing.contains(
                              'option-set-${item.optionSetId}',
                            )
                        ? null
                        : (value) =>
                              cubit.updateOptionSet(item, isRequired: value),
                    loading: state.processing.contains(
                      'option-set-${item.optionSetId}',
                    ),
                  ),
                ),
                DataTableColumn(
                  labelKey: ProductTypesKeys.sortOrder,
                  cellBuilder: (_, item) =>
                      AppText.raw(item.sortOrder.toString()),
                ),
              ],
              rows: state.optionSets,
              rowId: (item) => item.optionSetId,
              rowActionsBuilder: canManage
                  ? (context, item) => AppIconButton(
                      AppIcons.close,
                      tooltipKey: ProductTypesKeys.removeLink,
                      onPressed:
                          state.processing.contains(
                            'option-set-${item.optionSetId}',
                          )
                          ? null
                          : () => _confirmRemove(
                              context,
                              cubit,
                              () => cubit.removeOptionSet(item),
                            ),
                    )
                  : null,
            ),
        ],
      ),
    );
  }
}

Future<void> _confirmRemove(
  BuildContext context,
  ProductTypeDetailsCubit cubit,
  Future<void> Function() remove,
) async {
  final confirmed = await showConfirmDialog(
    context,
    titleKey: ProductTypesKeys.removeLink,
    messageKey: ProductTypesKeys.removeLinkConfirmation,
    severity: ConfirmDialogSeverity.warning,
    confirmLabelKey: ProductTypesKeys.removeLink,
  );
  if (confirmed) await remove();
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label, this.count);

  final AppKey label;
  final int count;

  @override
  Widget build(BuildContext context) => Padding(
    padding: context.ui.padding.only(bottom: AppSpacing.sm),
    child: Row(
      children: [
        Expanded(child: AppText(label, type: AppTextType.titleMedium)),
        AppBadge(
          label: label == ProductTypesKeys.sizeGroups
              ? ProductTypesKeys.sizeGroupsCount
              : label == ProductTypesKeys.attributes
              ? ProductTypesKeys.attributesCount
              : ProductTypesKeys.optionSetsCount,
          labelArgs: {'count': count.toString()},
          size: AppBadgeSize.small,
        ),
      ],
    ),
  );
}
