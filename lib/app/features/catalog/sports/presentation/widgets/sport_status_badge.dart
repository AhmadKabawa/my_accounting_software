import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/localization/sports_keys.dart';

class SportStatusBadge extends StatelessWidget {
  const SportStatusBadge(this.sport, {super.key});
  final Sport sport;

  @override
  Widget build(BuildContext context) => AppBadge(
    label: sport.isActive ? SportsKeys.active : SportsKeys.inactive,
    tone: sport.isActive ? AppBadgeTone.success : AppBadgeTone.neutral,
    size: AppBadgeSize.small,
  );
}
