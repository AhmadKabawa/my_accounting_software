import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/entity/gender.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/localization/genders_keys.dart';

class GenderStatusBadge extends StatelessWidget {
  const GenderStatusBadge(this.gender, {super.key});
  final Gender gender;
  @override
  Widget build(BuildContext context) => AppBadge(
    label: gender.isActive ? GendersKeys.active : GendersKeys.inactive,
    tone: gender.isActive ? AppBadgeTone.success : AppBadgeTone.neutral,
    size: AppBadgeSize.small,
  );
}
