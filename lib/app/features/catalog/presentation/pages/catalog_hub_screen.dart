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
import 'package:accounting_software/app/features/catalog/sports/presentation/localization/sports_keys.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/routing/sports_routes.dart';

/// The Catalog tab: a hub that lists the catalog areas. Each area opens its own
/// page inside the Catalog branch (so the bottom bar / sidebar stays on Catalog).
class CatalogHubScreen extends StatelessWidget {
  const CatalogHubScreen({super.key});

  @override
  Widget build(BuildContext context) => AppPageBody(
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
        context.ui.spacing.gap(AppSpacing.md),
        Wrap(
          spacing: context.ui.spacing.md,
          runSpacing: context.ui.spacing.md,
          children: [
            _AreaCard(
              icon: AppIcons.brands,
              titleKey: BrandsKeys.title,
              descriptionKey: CatalogHubKeys.brandsDescription,
              onOpen: () => context.go(BrandsRoutes.brands.path),
            ),
            _AreaCard(
              icon: AppIcons.catalog,
              titleKey: CategoriesKeys.title,
              descriptionKey: CatalogHubKeys.categoriesDescription,
              onOpen: () => context.go(CategoriesRoutes.categories.path),
            ),
            _AreaCard(
              icon: AppIcons.colors,
              titleKey: ColorsKeys.title,
              descriptionKey: CatalogHubKeys.colorsDescription,
              onOpen: () => context.go(ColorsRoutes.colors.path),
            ),
            _AreaCard(
              icon: AppIcons.sports,
              titleKey: SportsKeys.title,
              descriptionKey: CatalogHubKeys.sportsDescription,
              onOpen: () => context.go(SportsRoutes.sports.path),
            ),
          ],
        ),
      ],
    ),
  );
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
