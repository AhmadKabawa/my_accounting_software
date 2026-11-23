import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

/// An on/off switch with an accessible name. With [labelKey] the label is
/// shown beside the switch (and tapping it toggles); without it the name is
/// read by screen readers only ([semanticsKey]). `onChanged == null` disables.
///
/// While [loading] the change is already running: the switch shows a spinner
/// and ignores taps, so the user sees the action started and cannot repeat it.
class AppSwitch extends StatelessWidget {
  const AppSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.labelKey,
    this.semanticsKey,
    this.loading = false,
  }) : assert(labelKey != null || semanticsKey != null);

  final bool value;
  final ValueChanged<bool>? onChanged;
  final AppKey? labelKey;
  final AppKey? semanticsKey;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final name = (labelKey ?? semanticsKey)!.tr(context: context);
    final change = loading ? null : onChanged;
    final control = Switch(value: value, onChanged: change);
    final indicator = loading ? _spinner(context, control) : control;
    final shown = labelKey == null
        ? indicator
        : InkWell(
            onTap: change == null ? null : () => change(!value),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                indicator,
                context.ui.spacing.gap(AppSpacing.sm, axis: Axis.horizontal),
                Flexible(child: AppText(labelKey!)),
              ],
            ),
          );
    return Semantics(
      toggled: value,
      label: name,
      enabled: change != null,
      excludeSemantics: true,
      onTap: change == null ? null : () => change(!value),
      child: shown,
    );
  }

  Widget _spinner(BuildContext context, Widget control) => Stack(
    alignment: Alignment.center,
    children: [
      control,
      SizedBox.square(
        dimension: AppIconSize.sm.of(context),
        child: CircularProgressIndicator(
          strokeWidth: AppBorderWidth.thick.of(context),
        ),
      ),
    ],
  );
}
