import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/foundation/validation/hex_color.dart';

void main() {
  group('HexColor.isValid', () {
    test('accepts #RRGGBB and #RRGGBBAA in any case', () {
      expect(HexColor.isValid('#FF0000'), isTrue);
      expect(HexColor.isValid('#ff00aa'), isTrue);
      expect(HexColor.isValid('#FF000080'), isTrue);
    });

    test('rejects everything else', () {
      for (final value in [
        null,
        '',
        'FF0000',
        '#FFF',
        '#FF00',
        '#GG0000',
        '#FF00000',
        '#FF0000800',
        ' #FF0000',
      ]) {
        expect(HexColor.isValid(value), isFalse, reason: '$value');
      }
    });
  });

  group('HexColor.toArgb', () {
    test('adds an opaque alpha to #RRGGBB', () {
      expect(HexColor.toArgb('#FF0000'), 0xFFFF0000);
      expect(HexColor.toArgb('#0a1b2c'), 0xFF0A1B2C);
    });

    test('moves a trailing alpha to the front (CSS to Flutter order)', () {
      expect(HexColor.toArgb('#FF000080'), 0x80FF0000);
    });

    test('is null for invalid input', () {
      expect(HexColor.toArgb('red'), isNull);
      expect(HexColor.toArgb(null), isNull);
    });
  });

  test('normalize trims, upper-cases and turns blank into null', () {
    expect(HexColor.normalize('  #ff0000 '), '#FF0000');
    expect(HexColor.normalize('   '), isNull);
    expect(HexColor.normalize(null), isNull);
  });
}
