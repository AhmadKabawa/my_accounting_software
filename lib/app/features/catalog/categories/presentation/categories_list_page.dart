import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_screen.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_list_query.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_node.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/cubit/categories_list/categories_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/cubit/categories_list/categories_list_effect.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/categories_list_config.dart';

class CategoriesListPage extends StatelessWidget {
  const CategoriesListPage({super.key});

  @override
  Widget build(BuildContext context) =>
      CrudListScreen<
        CategoryNode,
        CategoryListQuery,
        CategoriesListCubit,
        CategoriesListEffect
      >(config: categoriesListConfig);
}
