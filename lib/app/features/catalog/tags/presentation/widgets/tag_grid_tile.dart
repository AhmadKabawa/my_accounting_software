import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/catalog_tag.dart';
import 'tag_identity.dart';
import 'tag_status_badge.dart';

/// Grid-mode tile for one catalog tag.
class TagGridTile extends StatelessWidget {
  const TagGridTile(this.tag, {super.key});

  final CatalogTag tag;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TagIdentity(tag, size: AppIconSize.xl, maxNameLines: 2),
      context.ui.spacing.gap(AppSpacing.xs),
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppText.raw(
          tag.slug,
          type: AppTextType.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      context.ui.spacing.gap(AppSpacing.sm),
      TagStatusBadge(tag),
    ],
  );
}
