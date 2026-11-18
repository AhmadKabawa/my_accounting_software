import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:accounting_software/app/core/foundation/money/money.dart';
import 'package:accounting_software/app/core/foundation/money/money_rounding.dart';
import 'package:accounting_software/app/core/foundation/money/money_rounding_method.dart';

void main() {
  Decimal d(String value) => Decimal.parse(value);

  MoneyRounding scale(
    int places, [
    MoneyRoundingMethod method = MoneyRoundingMethod.halfUp,
  ]) => MoneyRounding(decimalPlaces: places, method: method);

  group('HALF_UP (إلى الأقرب، التعادل بعيداً عن الصفر)', () {
    test('خانتان', () {
      expect(scale(2).apply(d('1.005')), d('1.01'));
      expect(scale(2).apply(d('1.004')), d('1'));
      expect(scale(2).apply(d('1.014999')), d('1.01'));
      expect(scale(2).apply(d('-1.005')), d('-1.01'));
      expect(scale(2).apply(d('-1.004')), d('-1'));
    });

    test('صفر خانات', () {
      expect(scale(0).apply(d('2.5')), d('3'));
      expect(scale(0).apply(d('-2.5')), d('-3'));
      expect(scale(0).apply(d('2.4999')), d('2'));
    });

    test('لا تغيير عندما تكون الخانات أقل أو تساوي المطلوب', () {
      expect(scale(4).apply(d('12.3456')), d('12.3456'));
      expect(scale(4).apply(d('12.3')), d('12.3'));
      expect(scale(8).apply(d('0.12345678')), d('0.12345678'));
    });

    test('تقريب كسر صغير جداً إلى صفر', () {
      expect(scale(2).apply(d('0.004')), Decimal.zero);
      expect(scale(2).apply(d('-0.004')), Decimal.zero);
    });
  });

  group('UP (بعيداً عن الصفر عند وجود باقٍ)', () {
    test('موجب وسالب', () {
      final up = MoneyRoundingMethod.up;
      expect(scale(2, up).apply(d('1.001')), d('1.01'));
      expect(scale(2, up).apply(d('-1.001')), d('-1.01'));
      expect(scale(2, up).apply(d('1.000')), d('1'));
      expect(scale(0, up).apply(d('0.1')), d('1'));
    });
  });

  group('DOWN (نحو الصفر)', () {
    test('موجب وسالب', () {
      final down = MoneyRoundingMethod.down;
      expect(scale(2, down).apply(d('1.009')), d('1'));
      expect(scale(2, down).apply(d('-1.009')), d('-1'));
      expect(scale(0, down).apply(d('2.99')), d('2'));
    });
  });

  group('rounding_increment', () {
    MoneyRounding withStep(
      String step,
      int places, [
      MoneyRoundingMethod method = MoneyRoundingMethod.halfUp,
    ]) => MoneyRounding(
      decimalPlaces: places,
      roundingIncrement: d(step),
      method: method,
    );

    test('خطوة 0.05 بخانتين', () {
      final r = withStep('0.05', 2);
      expect(r.apply(d('1.02')), d('1'));
      expect(r.apply(d('1.03')), d('1.05'));
      expect(r.apply(d('1.025')), d('1.05'));
      expect(r.apply(d('-1.03')), d('-1.05'));
    });

    test('خطوة 5 بصفر خانات', () {
      final r = withStep('5', 0);
      expect(r.apply(d('12')), d('10'));
      expect(r.apply(d('13')), d('15'));
      expect(r.apply(d('12.5')), d('15'));
      expect(r.apply(d('-13')), d('-15'));
    });

    test('الخطوة مع UP وDOWN', () {
      expect(withStep('5', 0, MoneyRoundingMethod.up).apply(d('11')), d('15'));
      expect(
        withStep('5', 0, MoneyRoundingMethod.down).apply(d('14')),
        d('10'),
      );
      expect(
        withStep('5', 0, MoneyRoundingMethod.up).apply(d('-11')),
        d('-15'),
      );
    });

    test('الخطوة صفر تعني بلا خطوة', () {
      expect(withStep('0.000000', 2).apply(d('1.234')), d('1.23'));
    });
  });

  group('Money.rounded', () {
    test('يقرّب ويحفظ العملة', () {
      final value = Money.parse('10.005', 7).rounded(scale(2));
      expect(value, Money.parse('10.01', 7));
      expect(value.currencyId, 7);
    });
  });

  group('MoneyRounding.fromCurrencyRow', () {
    test('صف currencies كما يصل من القاعدة (نص numeric)', () {
      final r = MoneyRounding.fromCurrencyRow(
        decimalPlaces: 2,
        roundingIncrement: '0.000000',
        roundingMethod: 'HALF_UP',
      );
      expect(r.decimalPlaces, 2);
      expect(r.roundingIncrement, Decimal.zero);
      expect(r.method, MoneyRoundingMethod.halfUp);
    });

    test('رقم أو null للخطوة', () {
      expect(
        MoneyRounding.fromCurrencyRow(
          decimalPlaces: 0,
          roundingIncrement: 5,
          roundingMethod: 'DOWN',
        ).roundingIncrement,
        d('5'),
      );
      expect(
        MoneyRounding.fromCurrencyRow(
          decimalPlaces: 0,
          roundingIncrement: null,
          roundingMethod: 'UP',
        ).roundingIncrement,
        Decimal.zero,
      );
    });

    test('طريقة غير معروفة ترمي FormatException', () {
      expect(
        () => MoneyRounding.fromCurrencyRow(
          decimalPlaces: 2,
          roundingIncrement: '0',
          roundingMethod: 'BANKERS',
        ),
        throwsFormatException,
      );
    });
  });

  group('التحقق من المعاملات', () {
    test('عدد الخانات خارج 0..8 يرمي RangeError', () {
      expect(() => MoneyRounding(decimalPlaces: -1), throwsRangeError);
      expect(() => MoneyRounding(decimalPlaces: 9), throwsRangeError);
      expect(MoneyRounding(decimalPlaces: 8).decimalPlaces, 8);
    });

    test('خطوة سالبة ترمي', () {
      expect(
        () => MoneyRounding(decimalPlaces: 2, roundingIncrement: d('-0.05')),
        throwsArgumentError,
      );
    });

    test('المساواة بالقيمة', () {
      expect(scale(2), scale(2));
      expect(scale(2).hashCode, scale(2).hashCode);
      expect(scale(2), isNot(scale(3)));
      expect(scale(2), isNot(scale(2, MoneyRoundingMethod.down)));
    });

    test('fromCode لكل طريقة', () {
      for (final method in MoneyRoundingMethod.values) {
        expect(MoneyRoundingMethod.fromCode(method.code), method);
      }
    });
  });
}
