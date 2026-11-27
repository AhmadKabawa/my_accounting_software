import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_switch/app_switch.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/localization/sports_keys.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/sections/sport_details_section.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/sections/sport_identity_section.dart';

/// Feature-owned sport fields rendered inside the shared CRUD editor shell.
class SportEditorFieldsView extends StatelessWidget {
  const SportEditorFieldsView({
    super.key,
    required this.name,
    required this.code,
    required this.description,
    required this.sortOrder,
    required this.isActive,
    required this.onActiveChanged,
    required this.onChanged,
  });

  final TextEditingController name;
  final TextEditingController code;
  final TextEditingController description;
  final TextEditingController sortOrder;
  final bool isActive;
  final ValueChanged<bool> onActiveChanged;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SportIdentitySection(name: name, code: code, onChanged: onChanged),
      context.ui.spacing.gap(AppSpacing.sm),
      AppSwitch(
        value: isActive,
        labelKey: SportsKeys.active,
        onChanged: onActiveChanged,
      ),
      context.ui.spacing.gap(AppSpacing.md),
      SportDetailsSection(
        description: description,
        sortOrder: sortOrder,
        onChanged: onChanged,
      ),
    ],
  );
}
