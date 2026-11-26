import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_screen.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/sports_list_config.dart';

/// Catalog sports list, composed through the shared CRUD list engine.
class SportsScreen extends StatelessWidget {
  const SportsScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      CrudListScreen(config: sportsListConfig);
}
