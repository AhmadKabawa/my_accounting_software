import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_image/app_image.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';

/// Brand logo thumbnail; falls back to a generic icon when missing/invalid.
class BrandLogo extends StatelessWidget {
  const BrandLogo(this.brand, {super.key});
  final Brand brand;

  @override
  Widget build(BuildContext context) =>
      BrandLogoImage(url: brand.logo, label: brand.name);
}

/// Logo thumbnail from a raw URL (also used for the live preview in the editor).
class BrandLogoImage extends StatelessWidget {
  const BrandLogoImage({super.key, required this.url, required this.label});
  final String? url;
  final String label;

  @override
  Widget build(BuildContext context) {
    final raw = url?.trim() ?? '';
    final uri = Uri.tryParse(raw);
    final valid =
        uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    final width = context.ui.size.width(AppComponentSize.avatarSmall);
    final height = context.ui.size.height(AppComponentSize.avatarSmall);
    return ClipRRect(
      borderRadius: AppRadius.sm.circular(context),
      child: SizedBox(
        width: width,
        height: height,
        child: valid
            ? AppImage.network(
                raw,
                width: width,
                height: height,
                shape: AppImageShape.rounded,
                borderRadius: AppRadius.sm.of(context),
                semanticsLabel: label,
                errorWidget: const Center(child: AppIcon(AppIcons.brokenImage)),
              )
            : ColoredBox(
                color: context.ui.theme.colors.surfaceContainerHighest,
                child: const Center(child: AppIcon(AppIcons.brands)),
              ),
      ),
    );
  }
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
