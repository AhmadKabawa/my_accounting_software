import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_screen.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/genders_list_config.dart';

class GendersScreen extends StatelessWidget {
  const GendersScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      CrudListScreen(config: gendersListConfig);
}
