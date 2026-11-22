import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

/// An on/off switch with an accessible name. With [labelKey] the label is
/// shown beside the switch (and tapping it toggles); without it the name is
/// read by screen readers only ([semanticsKey]). `onChanged == null` disables.
class AppSwitch extends StatelessWidget {
  const AppSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.labelKey,
    this.semanticsKey,
  }) : assert(labelKey != null || semanticsKey != null);

  final bool value;
  final ValueChanged<bool>? onChanged;
  final AppKey? labelKey;
  final AppKey? semanticsKey;

  @override
  Widget build(BuildContext context) {
    final name = (labelKey ?? semanticsKey)!.tr(context: context);
    final control = Switch(value: value, onChanged: onChanged);
    final shown = labelKey == null
        ? control
        : InkWell(
            onTap: onChanged == null ? null : () => onChanged!(!value),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                control,
                context.ui.spacing.gap(AppSpacing.sm, axis: Axis.horizontal),
                Flexible(child: AppText(labelKey!)),
              ],
            ),
          );
    return Semantics(
      toggled: value,
      label: name,
      enabled: onChanged != null,
      excludeSemantics: true,
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: shown,
    );
  }
}
