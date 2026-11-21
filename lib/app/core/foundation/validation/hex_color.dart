/// Parsing and checking of `#RRGGBB` / `#RRGGBBAA` color strings.
///
/// Pure Dart (no Flutter), so domain and data layers can validate a color
/// without importing the UI. The accepted shape mirrors the database check
/// `colors_hex_code_check`.
abstract final class HexColor {
  static final pattern = RegExp(r'^#[0-9A-Fa-f]{6}([0-9A-Fa-f]{2})?$');

  static const _opaque = 0xFF;
  static const _alphaShift = 24;
  static const _rgbLength = 6;
  static const _hexRadix = 16;

  static bool isValid(String? value) =>
      value != null && pattern.hasMatch(value);

  /// The `0xAARRGGBB` integer Flutter's `Color` takes, or null when [value] is
  /// not a valid hex color. A trailing `AA` (CSS order) becomes the alpha.
  static int? toArgb(String? value) {
    if (value == null || !isValid(value)) return null;
    final digits = value.substring(1);
    final rgb = int.parse(digits.substring(0, _rgbLength), radix: _hexRadix);
    final alpha = digits.length > _rgbLength
        ? int.parse(digits.substring(_rgbLength), radix: _hexRadix)
        : _opaque;
    return (alpha << _alphaShift) | rgb;
  }

  /// Trimmed, upper-cased, or null when blank. Does not validate.
  static String? normalize(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed.toUpperCase();
  }
}
