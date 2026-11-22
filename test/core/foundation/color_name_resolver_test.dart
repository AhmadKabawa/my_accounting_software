import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/foundation/color/color_name_resolver.dart';

void main() {
  test('resolves common apparel colors with Lab distance', () {
    expect(ColorNameResolver.resolve('#228B22'), ColorName.forestGreen);
    expect(ColorNameResolver.resolve('#F57C21'), ColorName.orange);
    expect(
      ColorNameResolver.resolve('#05AD9D'),
      anyOf(ColorName.teal, ColorName.turquoise),
    );
    expect(ColorNameResolver.resolve('#000000'), ColorName.black);
    expect(ColorNameResolver.resolve('#FFFFFF'), ColorName.white);
  });

  test('returns null for invalid and empty inputs', () {
    expect(ColorNameResolver.resolve(null), isNull);
    expect(ColorNameResolver.resolve(''), isNull);
    expect(ColorNameResolver.resolve('red'), isNull);
    expect(ColorNameResolver.resolve('#12'), isNull);
    expect(ColorNameResolver.resolve('#GGGGGG'), isNull);
  });

  test('accepts RGB and RGBA forms', () {
    expect(ColorNameResolver.resolve('#FFFFFF00'), ColorName.white);
    expect(ColorNameResolver.resolve('228B22'), ColorName.forestGreen);
  });
}
