import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_screen.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/presentation/size_systems_list_config.dart';

class SizeSystemsScreen extends StatelessWidget {
  const SizeSystemsScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      CrudListScreen(config: sizeSystemsListConfig);
}
