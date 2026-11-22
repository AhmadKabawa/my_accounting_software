import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/foundation/validation/hex_color.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_color_picker/app_color_picker.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/localization/colors_keys.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/widgets/color_field_validators.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/widgets/color_presets.dart';

/// Editor section: the shared color picker and optional HEX validation.
class ColorAppearanceSection extends StatefulWidget {
  const ColorAppearanceSection({
    super.key,
    required this.hex,
    required this.onChanged,
  });

  final TextEditingController hex;
  final VoidCallback onChanged;

  @override
  State<ColorAppearanceSection> createState() => _ColorAppearanceSectionState();
}

class _ColorAppearanceSectionState extends State<ColorAppearanceSection> {
  String? _pickerValue;

  @override
  void initState() {
    super.initState();
    _pickerValue = _validHex(widget.hex.text);
  }

  @override
  void didUpdateWidget(covariant ColorAppearanceSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hex != widget.hex) {
      _pickerValue = _validHex(widget.hex.text);
    }
  }

  String? _validHex(String? value) {
    final normalized = HexColor.normalize(ColorFieldValidators.withHash(value));
    return HexColor.isValid(normalized) ? normalized : null;
  }

  void _setText(String value) {
    widget.hex.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AppText(ColorsKeys.appearanceSection, type: AppTextType.titleSmall),
      context.ui.spacing.gap(AppSpacing.sm),
      FormField<String>(
        initialValue: widget.hex.text,
        validator: (_) => ColorFieldValidators.hex(widget.hex.text),
        builder: (field) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppColorPicker(
              value: _pickerValue,
              presets: ColorPresets.hexes,
              onInputChanged: (raw) {
                _setText(raw);
                field.didChange(raw);
                widget.onChanged();
              },
              onChanged: (value) {
                final normalized = value == null
                    ? ''
                    : HexColor.normalize(value) ?? value;
                _setText(normalized);
                field.didChange(normalized);
                setState(() => _pickerValue = _validHex(normalized));
                widget.onChanged();
              },
            ),
            if (field.errorText != null) ...[
              context.ui.spacing.gap(AppSpacing.xs),
              AppText.raw(
                field.errorText!,
                type: AppTextType.bodySmall,
                color: context.ui.theme.colors.error,
              ),
            ],
          ],
        ),
      ),
    ],
  );
}
