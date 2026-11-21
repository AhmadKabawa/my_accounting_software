import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/localization/colors_keys.dart';

class ColorStatusBadge extends StatelessWidget {
  const ColorStatusBadge(this.color, {super.key});
  final CatalogColor color;

  @override
  Widget build(BuildContext context) => AppBadge(
    label: color.isActive ? ColorsKeys.active : ColorsKeys.inactive,
    tone: color.isActive ? AppBadgeTone.success : AppBadgeTone.neutral,
    size: AppBadgeSize.small,
  );
}
