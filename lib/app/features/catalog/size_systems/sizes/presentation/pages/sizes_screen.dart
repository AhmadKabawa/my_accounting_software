import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_screen.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/routing/size_systems_routes.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/presentation/size_sizes_list_config.dart';

class SizesScreen extends StatelessWidget {
  const SizesScreen({
    super.key,
    required this.systemId,
    required this.groupId,
    this.labels,
  });

  final int systemId;
  final int groupId;
  final SizeRouteContext? labels;

  @override
  Widget build(BuildContext context) => CrudListScreen(
    key: ValueKey('sizes-$groupId'),
    config: sizesListConfig(systemId, groupId, labels: labels),
  );
}
