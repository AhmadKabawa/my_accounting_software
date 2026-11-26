import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_screen.dart';
import 'package:accounting_software/app/features/catalog/units/presentation/units_list_config.dart';

class UnitsScreen extends StatelessWidget {
  const UnitsScreen({super.key});

  @override
  Widget build(BuildContext context) => CrudListScreen(config: unitsListConfig);
}
