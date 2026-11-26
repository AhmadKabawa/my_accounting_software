import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/catalog_tag.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/localization/tags_keys.dart';

class TagStatusBadge extends StatelessWidget {
  const TagStatusBadge(this.tag, {super.key});
  final CatalogTag tag;

  @override
  Widget build(BuildContext context) => AppBadge(
    label: tag.isActive ? TagsKeys.active : TagsKeys.inactive,
    tone: tag.isActive ? AppBadgeTone.success : AppBadgeTone.neutral,
    size: AppBadgeSize.small,
  );
}
