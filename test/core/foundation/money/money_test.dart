import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:accounting_software/app/core/foundation/money/money.dart';

void main() {
  const usd = 1;
  const syp = 2;

  Money m(String amount, [int currency = usd]) => Money.parse(amount, currency);

  group('Money: المساواة والدقة', () {
    test('1.0 و1.00 بالعملة نفسها متساويان ولهما hashCode واحد', () {
      expect(m('1.0'), m('1.00'));
      expect(m('1.0').hashCode, m('1.00').hashCode);
    });

    test('العملة جزء من المساواة', () {
      expect(m('1', usd), isNot(m('1', syp)));
    });

    test('0.1 + 0.2 يساوي 0.3 تماماً (لا انحراف double)', () {
      expect(m('0.1') + m('0.2'), m('0.3'));
    });

    test('عشرة أضعاف 0.1 تساوي 1 تماماً', () {
      final total = Money.sum(usd, List.filled(10, m('0.1')));
      expect(total, m('1'));
    });

    test('عيّنة numeric(20,4) بأربع خانات تُحفظ كما هي', () {
      final value = Money.fromRaw('12345.6789', usd);
      expect(value.toPlainString(), '12345.6789');
      expect(value + m('0.0001'), m('12345.679'));
    });

    test('sum لقائمة فارغة تعطي صفراً بالعملة المطلوبة', () {
      expect(Money.sum(syp, const []), Money.zero(syp));
    });
  });

  group('Money: العمليات', () {
    test('الجمع والطرح والسالب والقيمة المطلقة', () {
      expect(m('10.50') + m('2.25'), m('12.75'));
      expect(m('10.50') - m('12.75'), m('-2.25'));
      expect(-m('2.25'), m('-2.25'));
      expect(m('-2.25').abs(), m('2.25'));
    });

    test('isZero وisNegative وisPositive', () {
      expect(m('0.00').isZero, isTrue);
      expect(m('-0.01').isNegative, isTrue);
      expect(m('0.01').isPositive, isTrue);
      expect(m('0').isPositive, isFalse);
    });

    test('times: الضرب بنسبة أو كمية يُبقي العملة', () {
      final result = m('19.99').times(Decimal.parse('3'));
      expect(result, m('59.97'));
      expect(m('200').times(Decimal.parse('0.15')), m('30'));
    });

    test('convert: الضرب بسعر الصرف ويغيّر العملة', () {
      final result = m('100').convert(
        rate: Decimal.parse('13000.5'),
        toCurrencyId: syp,
      );
      expect(result, m('1300050', syp));
    });

    test('convert يرفض نفس العملة وسعراً غير موجب', () {
      expect(
        () => m('1').convert(rate: Decimal.parse('2'), toCurrencyId: usd),
        throwsArgumentError,
      );
      expect(
        () => m('1').convert(rate: Decimal.zero, toCurrencyId: syp),
        throwsArgumentError,
      );
      expect(
        () => m('1').convert(rate: Decimal.parse('-1'), toCurrencyId: syp),
        throwsArgumentError,
      );
    });

    test('المقارنة بالعملة نفسها', () {
      expect(m('1.5') < m('2'), isTrue);
      expect(m('2') <= m('2.00'), isTrue);
      expect(m('3') > m('2.99'), isTrue);
      expect(m('3') >= m('3'), isTrue);
      expect(m('1').compareTo(m('2')), lessThan(0));
    });

    test('الفرز بالعملة نفسها يعمل', () {
      final list = [m('3'), m('1'), m('2')]..sort();
      expect(list, [m('1'), m('2'), m('3')]);
    });
  });

  group('Money: اختلاف العملات يرمي', () {
    test('الجمع والطرح والمقارنة وsum', () {
      expect(
        () => m('1', usd) + m('1', syp),
        throwsA(isA<CurrencyMismatchException>()),
      );
      expect(
        () => m('1', usd) - m('1', syp),
        throwsA(isA<CurrencyMismatchException>()),
      );
      expect(
        () => m('1', usd) < m('1', syp),
        throwsA(isA<CurrencyMismatchException>()),
      );
      expect(
        () => Money.sum(usd, [m('1', usd), m('1', syp)]),
        throwsA(isA<CurrencyMismatchException>()),
      );
    });

    test('الاستثناء يحمل المعرّفين والعملية', () {
      try {
        m('1', usd) + m('1', syp);
        fail('expected CurrencyMismatchException');
      } on CurrencyMismatchException catch (e) {
        expect(e.leftCurrencyId, usd);
        expect(e.rightCurrencyId, syp);
        expect(e.operation, '+');
      }
    });
  });

  group('Money.fromRaw: قراءة PostgREST دون المرور بـ double للنصوص', () {
    test('نص numeric', () {
      expect(Money.fromRaw('1234.5600', usd), m('1234.56'));
      expect(Money.fromRaw('-0.5', usd), m('-0.5'));
    });

    test('رقم صحيح', () {
      expect(Money.fromRaw(5, usd), m('5'));
      expect(Money.fromRaw(BigInt.parse('12345678901234567890'), usd),
          m('12345678901234567890'));
    });

    test('رقم عشري قصير الدقة', () {
      expect(Money.fromRaw(12.3456, usd), m('12.3456'));
    });

    test('تدوين علمي يُوسَّع دون فقد', () {
      expect(Money.fromRaw(1e-7, usd).toPlainString(), '0.0000001');
      expect(Money.fromRaw('1.5e3', usd), m('1500'));
      expect(Money.fromRaw('25E-2', usd), m('0.25'));
    });

    test('Decimal يمر كما هو', () {
      expect(Money.fromRaw(Decimal.parse('7.25'), usd), m('7.25'));
    });

    test('قيم غير صالحة ترمي FormatException', () {
      for (final bad in <Object?>[
        '',
        '-',
        'abc',
        '1,234.5',
        '1.2.3',
        '١٢٣',
        '1e',
        '1e0x1',
        '1e999',
        double.nan,
        double.infinity,
        null,
        true,
      ]) {
        expect(
          () => Money.fromRaw(bad, usd),
          throwsFormatException,
          reason: 'input: $bad',
        );
      }
    });
  });

  test('toPlainString بلا أس ولا فواصل للقيم الصغيرة والكبيرة', () {
    expect(m('0.0001').toPlainString(), '0.0001');
    expect(m('-0.0001').toPlainString(), '-0.0001');
    expect(m('99999999999999999999.9999').toPlainString(),
        '99999999999999999999.9999');
  });
}
