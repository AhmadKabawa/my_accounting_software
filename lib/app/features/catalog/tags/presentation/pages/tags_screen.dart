import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_screen.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/tags_list_config.dart';

/// Catalog tags list, composed through the shared CRUD list engine.
class TagsScreen extends StatelessWidget {
  const TagsScreen({super.key});

  @override
  Widget build(BuildContext context) => CrudListScreen(config: tagsListConfig);
}
