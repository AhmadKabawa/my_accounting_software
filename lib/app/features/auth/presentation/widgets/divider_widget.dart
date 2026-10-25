import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/theme/logic/theme_extension.dart';

class DividerWidget extends StatelessWidget {
  const DividerWidget({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Divider(
          color: context.colors.onBackground,
          thickness: .5,
          indent: 10,
          endIndent: 10,
        ),
        Container(
          color: context.colors.surface,
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),

          child: Text(text, style: context.textTheme.labelLarge),
        ),
      ],
    );
  }
}
