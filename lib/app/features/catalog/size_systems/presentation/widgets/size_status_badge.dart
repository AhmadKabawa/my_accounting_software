import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/localization/size_systems_keys.dart';

class SizeStatusBadge extends StatelessWidget {
  const SizeStatusBadge({super.key, required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) => AppBadge(
    label: isActive ? SizeSystemsKeys.active : SizeSystemsKeys.inactive,
    tone: isActive ? AppBadgeTone.success : AppBadgeTone.neutral,
    size: AppBadgeSize.small,
  );
}
