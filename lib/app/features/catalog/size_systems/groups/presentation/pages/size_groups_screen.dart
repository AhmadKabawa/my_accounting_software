import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_screen.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/presentation/size_groups_list_config.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/routing/size_systems_routes.dart';

class SizeGroupsScreen extends StatelessWidget {
  const SizeGroupsScreen({super.key, required this.systemId, this.labels});

  final int systemId;
  final SizeRouteContext? labels;

  @override
  Widget build(BuildContext context) => CrudListScreen(
    key: ValueKey('size-groups-$systemId'),
    config: sizeGroupsListConfig(systemId, labels: labels),
  );
}
