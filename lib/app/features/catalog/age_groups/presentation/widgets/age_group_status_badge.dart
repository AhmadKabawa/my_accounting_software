import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/entity/age_group.dart';
import 'package:accounting_software/app/features/catalog/age_groups/presentation/localization/age_groups_keys.dart';
class AgeGroupStatusBadge extends StatelessWidget {
  const AgeGroupStatusBadge(this.ageGroup,{super.key});
  final AgeGroup ageGroup;
  @override Widget build(BuildContext context)=>AppBadge(label:ageGroup.isActive?AgeGroupsKeys.active:AgeGroupsKeys.inactive,tone:ageGroup.isActive?AppBadgeTone.success:AppBadgeTone.neutral,size:AppBadgeSize.small);
}
