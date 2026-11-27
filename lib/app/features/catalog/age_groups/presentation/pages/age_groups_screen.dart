import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_screen.dart';
import 'package:accounting_software/app/features/catalog/age_groups/presentation/age_groups_list_config.dart';

class AgeGroupsScreen extends StatelessWidget {
  const AgeGroupsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      CrudListScreen(config: ageGroupsListConfig);
}
