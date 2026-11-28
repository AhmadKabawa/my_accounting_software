import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_screen.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/presentation/care_instructions_list_config.dart';

class CareInstructionsScreen extends StatelessWidget {
  const CareInstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      CrudListScreen(config: careInstructionsListConfig);
}
