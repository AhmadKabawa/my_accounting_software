import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_image/app_image.dart';

enum AppLogoSize { small, large }

/// A square, non-cropping logo thumbnail shared by catalog features.
class AppLogoThumb extends StatelessWidget {
  const AppLogoThumb({
    super.key,
    required this.url,
    required this.label,
    required this.size,
    required this.fallbackIcon,
  });

  final String? url;
  final String label;
  final AppLogoSize size;
  final AppIconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final raw = url?.trim() ?? '';
    final uri = Uri.tryParse(raw);
    final valid = uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    final dimension = context.ui.size.width(
      size == AppLogoSize.small
          ? AppComponentSize.avatarSmall
          : AppComponentSize.logoPreview,
    );
    final padding = context.ui.spacing.xs;
    final imageSize = dimension - padding * 2;
    final colors = context.ui.theme.colors;

    return Align(
      alignment: AlignmentDirectional.center,
      child: Semantics(
        label: label,
        image: true,
        child: SizedBox.square(
          key: const ValueKey('app-logo-thumb-square'),
          dimension: dimension,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: AppRadius.sm.circular(context),
              border: Border.all(
                color: colors.outlineVariant,
                width: AppBorderWidth.thin.of(context),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: valid
                  ? AppImage.network(
                      raw,
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.contain,
                      shape: AppImageShape.rounded,
                      borderRadius: AppRadius.xs.of(context),
                      errorWidget: Center(child: AppIcon(fallbackIcon)),
                    )
                  : Center(child: AppIcon(fallbackIcon)),
            ),
          ),
        ),
      ),
    );
  }
}
