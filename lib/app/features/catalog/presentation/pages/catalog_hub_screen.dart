import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_card/app_card.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_body/app_page_body.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_header/app_page_header.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';
import 'package:accounting_software/app/features/catalog/presentation/localization/catalog_hub_keys.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/routing/brands_routes.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/localization/colors_keys.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/routing/colors_routes.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/localization/categories_keys.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/routing/categories_routes.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/localization/product_types_keys.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/routing/product_types_routes.dart';
import 'package:accounting_software/app/features/catalog/units/presentation/localization/units_keys.dart';
import 'package:accounting_software/app/features/catalog/units/presentation/routing/units_routes.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/localization/option_sets_keys.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/routing/option_sets_routes.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/localization/attributes_keys.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/routing/attributes_routes.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/localization/tags_keys.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/routing/tags_routes.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/localization/sports_keys.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/routing/sports_routes.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/localization/genders_keys.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/routing/genders_routes.dart';
import 'package:accounting_software/app/features/catalog/age_groups/presentation/localization/age_groups_keys.dart';
import 'package:accounting_software/app/features/catalog/age_groups/presentation/routing/age_groups_routes.dart';
import 'package:accounting_software/app/features/catalog/materials/presentation/routing/materials_routes.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/presentation/routing/fabric_types_routes.dart';

class CatalogHubScreen extends StatelessWidget {
  const CatalogHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = [
      _CatalogGroup(CatalogHubKeys.groupProductDefinition, [
        _CatalogArea(
          AppIcons.brands,
          BrandsKeys.title,
          CatalogHubKeys.brandsDescription,
          () => context.go(BrandsRoutes.brands.path),
        ),
        _CatalogArea(
          AppIcons.catalog,
          CategoriesKeys.title,
          CatalogHubKeys.categoriesDescription,
          () => context.go(CategoriesRoutes.categories.path),
        ),
        _CatalogArea(
          AppIcons.productTypes,
          ProductTypesKeys.title,
          ProductTypesKeys.hubDescription,
          () => context.go(ProductTypesRoutes.productTypes.path),
        ),
        _CatalogArea(
          AppIcons.units,
          UnitsKeys.title,
          CatalogHubKeys.unitsDescription,
          () => context.go(UnitsRoutes.units.path),
        ),
      ]),
      _CatalogGroup(CatalogHubKeys.groupProperties, [
        _CatalogArea(
          AppIcons.attributes,
          AttributesKeys.title,
          CatalogHubKeys.attributesDescription,
          () => context.go(AttributesRoutes.attributes.path),
        ),
        _CatalogArea(
          AppIcons.optionSets,
          OptionSetsKeys.title,
          CatalogHubKeys.optionSetsDescription,
          () => context.go(OptionSetsRoutes.optionSets.path),
        ),
        _CatalogArea(
          AppIcons.colors,
          ColorsKeys.title,
          CatalogHubKeys.colorsDescription,
          () => context.go(ColorsRoutes.colors.path),
        ),
        _CatalogArea(
          AppIcons.materials,
          CatalogHubKeys.materialsTitle,
          CatalogHubKeys.materialsDescription,
          () => context.go(MaterialsRoutes.materials.path),
        ),
        _CatalogArea(
          AppIcons.fabricTypes,
          CatalogHubKeys.fabricTypesTitle,
          CatalogHubKeys.fabricTypesDescription,
          () => context.go(FabricTypesRoutes.fabricTypes.path),
        ),
      ]),
      _CatalogGroup(CatalogHubKeys.groupClassification, [
        _CatalogArea(
          AppIcons.tags,
          TagsKeys.title,
          CatalogHubKeys.tagsDescription,
          () => context.go(TagsRoutes.tags.path),
        ),
        _CatalogArea(
          AppIcons.sports,
          SportsKeys.title,
          CatalogHubKeys.sportsDescription,
          () => context.go(SportsRoutes.sports.path),
        ),
        _CatalogArea(
          AppIcons.genders,
          GendersKeys.title,
          CatalogHubKeys.gendersDescription,
          () => context.go(GendersRoutes.genders.path),
        ),
        _CatalogArea(
          AppIcons.ageGroups,
          AgeGroupsKeys.title,
          CatalogHubKeys.ageGroupsDescription,
          () => context.go(AgeGroupsRoutes.ageGroups.path),
        ),
      ]),
    ];
    return AppPageBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPageHeader(
            titleKey: CatalogHubKeys.title,
            subtitle: AppText(
              CatalogHubKeys.subtitle,
              type: AppTextType.bodyMedium,
              color: context.ui.theme.colors.onSurfaceVariant,
            ),
          ),
          context.ui.spacing.gap(AppSpacing.lg),
          for (final group in groups) ...[
            AppText(group.title, type: AppTextType.titleLarge),
            context.ui.spacing.gap(AppSpacing.sm),
            Wrap(
              spacing: context.ui.spacing.md,
              runSpacing: context.ui.spacing.md,
              children: [
                for (final area in group.areas)
                  _AreaCard(
                    icon: area.icon,
                    titleKey: area.title,
                    descriptionKey: area.description,
                    onOpen: area.open,
                  ),
              ],
            ),
            context.ui.spacing.gap(AppSpacing.lg),
          ],
        ],
      ),
    );
  }
}

class _CatalogGroup {
  const _CatalogGroup(this.title, this.areas);
  final AppKey title;
  final List<_CatalogArea> areas;
}

class _CatalogArea {
  const _CatalogArea(this.icon, this.title, this.description, this.open);
  final AppIconData icon;
  final AppKey title;
  final AppKey description;
  final VoidCallback open;
}

class _AreaCard extends StatelessWidget {
  const _AreaCard({
    required this.icon,
    required this.titleKey,
    required this.descriptionKey,
    required this.onOpen,
  });
  final AppIconData icon;
  final AppKey titleKey;
  final AppKey descriptionKey;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: context.ui.size.width(AppComponentSize.cardWidth),
      minWidth: context.ui.size.width(AppComponentSize.cardWidth),
    ),
    child: AppCard(
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIcon(icon, size: AppIconSize.lg),
          context.ui.spacing.gap(AppSpacing.sm),
          AppText(titleKey, type: AppTextType.titleMedium),
          context.ui.spacing.gap(AppSpacing.xs),
          AppText(
            descriptionKey,
            type: AppTextType.bodySmall,
            color: context.ui.theme.colors.onSurfaceVariant,
          ),
          context.ui.spacing.gap(AppSpacing.sm),
          AppButton(
            CatalogHubKeys.open,
            variant: AppButtonVariant.outlined,
            size: AppButtonSize.small,
            onPressed: onOpen,
          ),
        ],
      ),
    ),
  );
}
