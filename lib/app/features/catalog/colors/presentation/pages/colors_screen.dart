import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_screen.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/colors_list_config.dart';

/// Catalog colors list, composed through the shared CRUD list engine.
class ColorsScreen extends StatelessWidget {
  const ColorsScreen({super.key});

  static const screenId = 'catalog.colors';

  @override
  Widget build(BuildContext context) =>
      CrudListScreen(config: colorsListConfig);
}
