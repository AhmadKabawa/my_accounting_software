import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';

class DividerWidget extends StatelessWidget {
  const DividerWidget({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Divider(
          color: context.ui.theme.colors.onBackground,
          thickness: .5,
          indent: 10,
          endIndent: 10,
        ),
        Container(
          color: context.ui.theme.colors.surface,
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),

          child: Text(text, style: context.ui.theme.textTheme.labelLarge),
        ),
      ],
    );
  }
}
