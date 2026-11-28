import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/foundation/date/date_only.dart';
import 'package:accounting_software/app/core/localization/keys/date_picker_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field_style.dart';

/// Read-only date input. Features must use this field rather than opening the
/// raw Material date picker themselves.
class AppDatePickerField extends StatelessWidget {
  const AppDatePickerField({
    super.key, required this.label, required this.value, required this.onChanged,
    this.firstDate, this.lastDate, this.errorText, this.validator, this.helper,
    this.enabled = true, this.clearable = false,
  });

  final AppKey label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? errorText;
  final String? Function(DateTime?)? validator;
  final AppKey? helper;
  final bool enabled;
  final bool clearable;

  Future<void> _openPicker(BuildContext context) async {
    if (!enabled) return;
    final today = DateOnly.normalize(DateTime.now());
    final first = DateOnly.normalize(firstDate ?? DateTime(1900));
    final last = DateOnly.normalize(lastDate ?? DateTime(2100, 12, 31));
    assert(!first.isAfter(last), 'firstDate must not be after lastDate');
    final selected = value == null ? today : DateOnly.normalize(value!);
    final initial = selected.isBefore(first)
        ? first
        : selected.isAfter(last)
            ? last
            : selected;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
    if (picked != null) onChanged(DateOnly.normalize(picked));
  }

  @override
  Widget build(BuildContext context) {
    final style = AppTextFieldStyle(context);
    final validationError = errorText ?? validator?.call(value);
    final decoration = style.decoration(
      label: label.tr(context: context),
      suffix: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (clearable && value != null)
            IconButton(
              tooltip: DatePickerKeys.clear.tr(context: context),
              onPressed: enabled ? () => onChanged(null) : null,
              icon: AppIcon(AppIcons.close, color: style.iconColor),
            ),
          IconButton(
            tooltip: DatePickerKeys.open.tr(context: context),
            onPressed: enabled ? () => _openPicker(context) : null,
            icon: AppIcon(AppIcons.calendar, color: style.iconColor),
          ),
        ],
      ),
    ).copyWith(
      helperText: helper?.tr(context: context),
      errorText: validationError,
    );

    return TextFormField(
      key: ValueKey<String?>(
        value == null ? null : DateOnly.toApiString(value!),
      ),
      initialValue: value == null ? '' : DateOnly.format(context, value!),
      enabled: enabled,
      readOnly: true,
      onTap: enabled ? () => _openPicker(context) : null,
      validator: (_) => validationError,
      style: style.textStyle,
      decoration: decoration,
    );
  }
}
