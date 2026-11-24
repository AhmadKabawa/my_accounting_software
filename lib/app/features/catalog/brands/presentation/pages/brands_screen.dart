import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_screen.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/brands_list_config.dart';

/// Catalog brands list, composed through the shared CRUD list engine.
class BrandsScreen extends StatelessWidget {
  const BrandsScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      CrudListScreen(config: brandsListConfig);
}
