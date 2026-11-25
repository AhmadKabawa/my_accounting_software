import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/foundation/image/image_policy.dart';
import 'package:accounting_software/app/core/localization/keys/image_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_logo_thumb/app_logo_thumb.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

/// Responsive contents for the shared clickable upload zone.
class AppImageUploadZoneContent extends StatelessWidget {
  const AppImageUploadZoneContent({
    super.key,
    required this.busy,
    required this.hasImage,
    required this.supportsDrop,
    required this.isHovering,
    required this.imageUrl,
    required this.label,
    required this.policy,
    required this.uploadLabel,
    required this.replaceLabel,
    required this.dropHint,
    required this.previewSize,
  });

  final bool busy;
  final bool hasImage;
  final bool supportsDrop;
  final bool isHovering;
  final String? imageUrl;
  final String label;
  final ImagePolicy policy;
  final AppKey uploadLabel;
  final AppKey replaceLabel;
  final AppKey dropHint;
  final AppLogoSize previewSize;

  String _formatLabel(String mimeType) => switch (mimeType) {
    'image/jpeg' => 'JPEG',
    'image/png' => 'PNG',
    'image/webp' => 'WebP',
    _ => mimeType.split('/').last.toUpperCase(),
  };

  String _policyHint(BuildContext context) {
    final formats = policy.allowedMimeTypes.map(_formatLabel).toList()..sort();
    final mb = policy.maxBytes / (1024 * 1024);
    final size = mb >= 1
        ? '${mb.toStringAsFixed(mb == mb.roundToDouble() ? 0 : 1)} MB'
        : '${(policy.maxBytes / 1024).ceil()} KB';
    return ImageKeys.uploadPolicy.tr(
      context: context,
      namedArgs: {'formats': formats.join(', '), 'size': size},
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.ui.theme.colors;
    final gap = context.ui.spacing;
    final actionKey = hasImage ? replaceLabel : uploadLabel;
    if (busy) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: AppComponentSize.large.of(context),
            child: CircularProgressIndicator(color: colors.primary),
          ),
          gap.gap(AppSpacing.sm),
          AppText(actionKey, type: AppTextType.titleSmall),
        ],
      );
    }
    if (hasImage) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppLogoThumb(
            url: imageUrl,
            label: label,
            size: previewSize,
            fallbackIcon: AppIcons.image,
          ),
          gap.gap(AppSpacing.sm),
          AppText(actionKey, type: AppTextType.titleSmall),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon(
          AppIcons.upload,
          size: AppIconSize.lg,
          color: isHovering ? colors.primary : colors.onSurfaceVariant,
        ),
        gap.gap(AppSpacing.sm),
        AppText(actionKey, type: AppTextType.titleSmall),
        if (supportsDrop) ...[
          gap.gap(AppSpacing.xs),
          AppText(
            dropHint,
            type: AppTextType.bodySmall,
            color: isHovering ? colors.primary : colors.onSurfaceVariant,
            textAlign: TextAlign.center,
          ),
        ],
        gap.gap(AppSpacing.xs),
        AppText.raw(
          _policyHint(context),
          type: AppTextType.bodySmall,
          color: colors.onSurfaceVariant,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
