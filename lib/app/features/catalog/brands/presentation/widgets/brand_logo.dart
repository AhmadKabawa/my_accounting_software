import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_logo_thumb/app_logo_thumb.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';

/// Brand logo thumbnail backed by the shared core logo component.
class BrandLogo extends StatelessWidget {
  const BrandLogo(this.brand, {super.key, this.size = AppLogoSize.small});

  final Brand brand;
  final AppLogoSize size;

  @override
  Widget build(BuildContext context) =>
      BrandLogoImage(url: brand.logo, label: brand.name, size: size);
}

/// URL-based logo wrapper, also used for the editor's live preview.
class BrandLogoImage extends StatelessWidget {
  const BrandLogoImage({
    super.key,
    required this.url,
    required this.label,
    this.size = AppLogoSize.small,
  });

  final String? url;
  final String label;
  final AppLogoSize size;

  @override
  Widget build(BuildContext context) => AppLogoThumb(
    url: url,
    label: label,
    size: size,
    fallbackIcon: AppIcons.brands,
  );
}

/// Logo + name + slug: the primary cell of the table and the card header.
class BrandIdentity extends StatelessWidget {
  const BrandIdentity(this.brand, {super.key});
  final Brand brand;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      BrandLogo(brand),
      context.ui.spacing.gap(AppSpacing.smMd, axis: Axis.horizontal),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.raw(brand.name, type: AppTextType.titleSmall),
            AppText.raw(
              brand.slug,
              type: AppTextType.bodySmall,
              color: context.ui.theme.colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    ],
  );
}
