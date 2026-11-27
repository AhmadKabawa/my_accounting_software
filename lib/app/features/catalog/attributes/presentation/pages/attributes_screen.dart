import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_screen.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/attributes_list_config.dart';

class AttributesScreen extends StatelessWidget {
  const AttributesScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      CrudListScreen(config: attributesListConfig);
}
