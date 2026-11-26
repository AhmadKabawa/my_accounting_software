import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_screen.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/product_types_list_config.dart';

class ProductTypesScreen extends StatelessWidget {
  const ProductTypesScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      CrudListScreen(config: productTypesListConfig);
}
