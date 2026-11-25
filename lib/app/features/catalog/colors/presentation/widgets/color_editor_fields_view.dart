import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/sections/color_appearance_section.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/sections/color_identity_section.dart';

/// Feature-owned color fields rendered inside the shared CRUD editor shell.
class ColorEditorFieldsView extends StatelessWidget {
  const ColorEditorFieldsView({
    super.key,
    required this.name,
    required this.code,
    required this.hex,
    required this.sortOrder,
    required this.suggestedName,
    required this.onNameChanged,
    required this.onChanged,
    required this.onCodeChanged,
    required this.onHexChanged,
  });

  final TextEditingController name;
  final TextEditingController code;
  final TextEditingController hex;
  final TextEditingController sortOrder;
  final String? suggestedName;
  final VoidCallback onNameChanged;
  final VoidCallback onChanged;
  final VoidCallback onCodeChanged;
  final VoidCallback onHexChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ColorIdentitySection(
        name: name,
        code: code,
        sortOrder: sortOrder,
        suggestedName: suggestedName,
        onNameChanged: onNameChanged,
        onChanged: onChanged,
        onCodeChanged: onCodeChanged,
      ),
      context.ui.spacing.gap(AppSpacing.md),
      ColorAppearanceSection(hex: hex, onChanged: onHexChanged),
    ],
  );
}
