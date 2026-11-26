import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/catalog_tag.dart';

/// Icon + name: the primary cell of the table and the card header.
class TagIdentity extends StatelessWidget {
  const TagIdentity(
    this.tag, {
    super.key,
    this.size = AppIconSize.lg,
    this.maxNameLines,
  });
  final CatalogTag tag;
  final AppIconSize size;
  final int? maxNameLines;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      AppIcon(AppIcons.tags, size: size),
      context.ui.spacing.gap(AppSpacing.smMd, axis: Axis.horizontal),
      Expanded(
        child: AppText.raw(
          tag.name,
          type: AppTextType.titleSmall,
          maxLines: maxNameLines,
          overflow: maxNameLines == null ? null : TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}
