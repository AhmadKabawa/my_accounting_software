import 'dart:math' as math;

/// A compact, local apparel-oriented color vocabulary and RGB reference values.
enum ColorName {
  black(0x000000),
  charcoal(0x36454F),
  gray(0x808080),
  silver(0xC0C0C0),
  white(0xFFFFFF),
  ivory(0xFFFFF0),
  beige(0xF5F5DC),
  cream(0xFFFDD0),
  brown(0x8B4513),
  chocolate(0x7B3F00),
  tan(0xD2B48C),
  camel(0xC19A6B),
  taupe(0x483C32),
  burgundy(0x800020),
  maroon(0x800000),
  red(0xFF0000),
  coral(0xFF7F50),
  salmon(0xFA8072),
  pink(0xFFC0CB),
  rose(0xF4C2C2),
  fuchsia(0xFF00FF),
  magenta(0xFF00FF),
  purple(0x800080),
  violet(0x8F00FF),
  lavender(0xE6E6FA),
  lilac(0xC8A2C8),
  indigo(0x4B0082),
  navy(0x000080),
  blue(0x0000FF),
  royalBlue(0x4169E1),
  skyBlue(0x87CEEB),
  babyBlue(0x89CFF0),
  turquoise(0x40E0D0),
  teal(0x008080),
  aqua(0x00FFFF),
  mint(0x98FF98),
  sage(0x9CAF88),
  olive(0x808000),
  lime(0x00FF00),
  green(0x008000),
  forestGreen(0x228B22),
  emerald(0x50C878),
  seaGreen(0x2E8B57),
  mustard(0xFFDB58),
  yellow(0xFFFF00),
  gold(0xFFD700),
  orange(0xF57C21),
  peach(0xFFE5B4),
  rust(0xB7410E),
  terracotta(0xE2725B);

  const ColorName(this.rgb);
  final int rgb;
}

/// Suggests the nearest named color using CIELAB and Delta E 76.
///
/// Returns null for malformed hex values. This pure-Dart utility only suggests
/// a name; the hex value remains the canonical color data.
abstract final class ColorNameResolver {
  static final RegExp _hex = RegExp(r'^#?([0-9a-fA-F]{6})(?:[0-9a-fA-F]{2})?$');

  static ColorName? resolve(String? hex) {
    if (hex == null) return null;
    final match = _hex.firstMatch(hex.trim());
    if (match == null) return null;
    final rgb = int.parse(match.group(1)!, radix: 16);
    final target = _lab(rgb);
    ColorName? closest;
    var best = double.infinity;
    for (final name in ColorName.values) {
      final distance = _delta(target, _lab(name.rgb));
      if (distance < best) {
        best = distance;
        closest = name;
      }
    }
    return closest;
  }

  static List<double> _lab(int rgb) {
    double linear(int value) {
      final channel = value / 255;
      return channel <= 0.04045
          ? channel / 12.92
          : math.pow((channel + 0.055) / 1.055, 2).toDouble();
    }

    final r = linear((rgb >> 16) & 0xff);
    final g = linear((rgb >> 8) & 0xff);
    final b = linear(rgb & 0xff);
    final x = (r * 0.4124 + g * 0.3576 + b * 0.1805) / 0.95047;
    final y = r * 0.2126 + g * 0.7152 + b * 0.0722;
    final z = (r * 0.0193 + g * 0.1192 + b * 0.9505) / 1.08883;

    double f(double value) =>
        value > 0.008856 ? math.pow(value, 1 / 3).toDouble() : (7.787 * value) + (16 / 116);
    final fx = f(x), fy = f(y), fz = f(z);
    return [116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz)];
  }

  static double _delta(List<double> a, List<double> b) {
    final dl = a[0] - b[0], da = a[1] - b[1], db = a[2] - b[2];
    return math.sqrt(dl * dl + da * da + db * db);
  }
}
