import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:accounting_software/app/core/foundation/money/amount_formatter.dart';
import 'package:accounting_software/app/core/foundation/money/money.dart';
import 'package:accounting_software/app/core/foundation/money/money_rounding.dart';
import 'package:accounting_software/app/core/foundation/money/money_rounding_method.dart';

void main() {
  const lri = '\u2066';
  const pdi = '\u2069';
  const minus = '\u2212';
  const nbsp = '\u00A0';

  Decimal d(String value) => Decimal.parse(value);
  String iso(String text) => '$lri$text$pdi';

  String fmt(
    String value,
    int places, {
    MoneyRoundingMethod method = MoneyRoundingMethod.halfUp,
    bool isolate = true,
  }) => AmountFormatter.formatDecimal(
    d(value),
    decimalPlaces: places,
    roundingMethod: method,
    bidiIsolate: isolate,
  );

  group('formatDecimal: فواصل الآلاف والكسور', () {
    test('موجب بخانتين', () {
      expect(fmt('1234567.891', 2), iso('1,234,567.89'));
      expect(fmt('999.999', 2), iso('1,000.00'));
      expect(fmt('100', 2), iso('100.00'));
      expect(fmt('1000', 2), iso('1,000.00'));
      expect(fmt('123456', 0), iso('123,456'));
    });

    test('الكسور من العملة لا من القيمة: صفر و2 و4', () {
      expect(fmt('5', 0), iso('5'));
      expect(fmt('5', 2), iso('5.00'));
      expect(fmt('5', 4), iso('5.0000'));
      expect(fmt('12.34567', 4), iso('12.3457'));
      expect(fmt('0.5', 2), iso('0.50'));
      expect(fmt('0.05', 2), iso('0.05'));
      expect(fmt('0.00001234', 8), iso('0.00001234'));
    });

    test('صفر', () {
      expect(fmt('0', 0), iso('0'));
      expect(fmt('0', 2), iso('0.00'));
      expect(fmt('0', 4), iso('0.0000'));
    });

    test('لا اختصار للمبالغ الكبيرة', () {
      expect(fmt('1200000', 0), iso('1,200,000'));
      expect(fmt('1200000000.5', 2), iso('1,200,000,000.50'));
    });

    test('أرقام غربية فقط (0-9)', () {
      final text = fmt('1234567.89', 2, isolate: false);
      expect(RegExp(r'^[0-9,.]+$').hasMatch(text), isTrue);
    });
  });

  group('formatDecimal: السالب', () {
    test('علامة − (U+2212) لا شرطة الطرح', () {
      expect(fmt('-1234.5', 2), iso('${minus}1,234.50'));
      expect(fmt('-1234.5', 2).contains('-'), isFalse);
    });

    test('لا علامة لقيمة تصير صفراً بعد التقريب', () {
      expect(fmt('-0.001', 2), iso('0.00'));
      expect(fmt('-0.4', 0), iso('0'));
    });

    test('السالب يقرَّب بعيداً عن الصفر عند التعادل في HALF_UP', () {
      expect(fmt('-2.5', 0), iso('${minus}3'));
      expect(fmt('-0.005', 2), iso('${minus}0.01'));
    });

    test('سالب بين 0 و1 بخانات كثيرة', () {
      expect(fmt('-0.05', 2), iso('${minus}0.05'));
      expect(fmt('-0.0001', 4), iso('${minus}0.0001'));
    });
  });

  group('formatDecimal: طرق التقريب للعرض', () {
    test('HALF_UP وUP وDOWN', () {
      expect(fmt('1234.5', 0), iso('1,235'));
      expect(fmt('1234.5', 0, method: MoneyRoundingMethod.down), iso('1,234'));
      expect(fmt('1234.1', 0, method: MoneyRoundingMethod.up), iso('1,235'));
      expect(
        fmt('-1234.1', 0, method: MoneyRoundingMethod.up),
        iso('${minus}1,235'),
      );
    });
  });

  group('formatDecimal: عزل الاتجاه', () {
    test('الافتراضي: الرقم بعلامته داخل LRI…PDI', () {
      final text = fmt('-5', 2);
      expect(text.startsWith(lri), isTrue);
      expect(text.endsWith(pdi), isTrue);
      expect(text, '$lri${minus}5.00$pdi');
    });

    test('بلا عزل عند الطلب', () {
      expect(fmt('-5', 2, isolate: false), '${minus}5.00');
      expect(fmt('1234.5', 2, isolate: false), '1,234.50');
    });

    test('داخل نص عربي مختلط تبقى العلامة داخل العزل مع الأرقام', () {
      final amount = fmt('-1500', 0);
      final line = 'الرصيد المتبقي: $amount ل.س';
      expect(line, contains('$lri${minus}1,500$pdi'));
    });
  });

  group('formatDecimal: التحقق', () {
    test('عدد خانات خارج 0..8 يرمي RangeError', () {
      expect(() => fmt('1', -1), throwsRangeError);
      expect(() => fmt('1', 9), throwsRangeError);
      expect(fmt('1', 8), iso('1.00000000'));
    });
  });

  group('format: مع رمز العملة', () {
    const usd = CurrencyDisplay(currencyId: 1, decimalPlaces: 2, label: 'USD');
    final amount = Money.parse('1234.5', 1);

    test('الرمز بعد الرقم (الافتراضي)', () {
      expect(
        AmountFormatter.format(amount, currency: usd),
        '${iso('1,234.50')}${nbsp}USD',
      );
    });

    test('الرمز قبل الرقم', () {
      const before = CurrencyDisplay(
        currencyId: 1,
        decimalPlaces: 2,
        label: 'USD',
        labelPlacement: CurrencyLabelPlacement.before,
      );
      expect(
        AmountFormatter.format(amount, currency: before),
        'USD$nbsp${iso('1,234.50')}',
      );
    });

    test('رمز عربي خارج العزل', () {
      const syp = CurrencyDisplay(
        currencyId: 2,
        decimalPlaces: 0,
        label: 'ل.س',
      );
      expect(
        AmountFormatter.format(Money.parse('-2500', 2), currency: syp),
        '${iso('${minus}2,500')}$nbsp${'ل.س'}',
      );
    });

    test('بلا رمز أو بموضع none يعطي الرقم وحده', () {
      const noLabel = CurrencyDisplay(currencyId: 1, decimalPlaces: 2);
      const none = CurrencyDisplay(
        currencyId: 1,
        decimalPlaces: 2,
        label: 'USD',
        labelPlacement: CurrencyLabelPlacement.none,
      );
      const empty = CurrencyDisplay(currencyId: 1, decimalPlaces: 2, label: '');
      expect(
        AmountFormatter.format(amount, currency: noLabel),
        iso('1,234.50'),
      );
      expect(AmountFormatter.format(amount, currency: none), iso('1,234.50'));
      expect(AmountFormatter.format(amount, currency: empty), iso('1,234.50'));
    });

    test('عملة المبلغ تختلف عن عملة العرض ترمي', () {
      expect(
        () => AmountFormatter.format(Money.parse('1', 2), currency: usd),
        throwsA(isA<CurrencyMismatchException>()),
      );
    });

    test('fromRounding يأخذ الخانات والطريقة من إعدادات العملة', () {
      final display = CurrencyDisplay.fromRounding(
        MoneyRounding(decimalPlaces: 0, method: MoneyRoundingMethod.down),
        currencyId: 2,
        label: 'ل.س',
      );
      expect(display.decimalPlaces, 0);
      expect(display.roundingMethod, MoneyRoundingMethod.down);
      expect(
        AmountFormatter.format(Money.parse('1999.9', 2), currency: display),
        '${iso('1,999')}$nbsp${'ل.س'}',
      );
    });

    test('عدم تقريب القيمة المحفوظة: العرض فقط', () {
      final value = Money.parse('1.005', 1);
      AmountFormatter.format(value, currency: usd);
      expect(value, Money.parse('1.005', 1));
    });
  });
}
