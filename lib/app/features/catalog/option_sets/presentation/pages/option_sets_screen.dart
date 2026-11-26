import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_screen.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/option_sets_list_config.dart';

class OptionSetsScreen extends StatelessWidget {
  const OptionSetsScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      CrudListScreen(config: optionSetsListConfig);
}
