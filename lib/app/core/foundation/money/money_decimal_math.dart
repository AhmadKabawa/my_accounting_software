import 'package:decimal/decimal.dart';

import 'package:accounting_software/app/core/foundation/money/money_rounding_method.dart';

/// أدوات داخلية للحساب العشري الدقيق خلف `Money` و`MoneyRounding` و`AmountFormatter`.
///
/// لا تُستعمل مباشرة من الميزات: الواجهة العامة هي `Money` و`MoneyRounding`
/// و`AmountFormatter`. لا `double` في أي خطوة حسابية هنا؛ كل التقريب بحساب
/// `BigInt` على (قيمة صحيحة، مقياس) مستخرجة من التمثيل النصي العشري.
abstract final class MoneyDecimalMath {
  static const int _radix = 10;

  /// سقف الأس المقبول عند قراءة نص علمي (`1e-7`). يمنع نصاً خبيثاً من تضخيم الذاكرة.
  static const int _maxExponent = 64;

  static final RegExp _mantissa = RegExp(r'^(\d*)(?:\.(\d*))?$');
  static final RegExp _exponent = RegExp(r'^[+-]?\d+$');

  /// `10^exponent` بدقة كاملة.
  static BigInt pow10(int exponent) => BigInt.from(_radix).pow(exponent);

  /// يقرأ مبلغاً من `String` أو `int` أو `BigInt` أو `double` منتهٍ أو `Decimal`.
  ///
  /// يرمي [FormatException] لنص غير صالح، ولـ `null`، وللأرقام العربية-الهندية
  /// (تطبيعها مسؤولية حقل الإدخال C03 لا هذه الدالة)، وللفواصل (`1,234.5`).
  ///
  /// تنبيه: القيمة `double` تصل إلى هنا بعد أن حُلِّلت من JSON كـ `double`، فدقتها
  /// تقتصر على نحو 15 رقماً معنوياً. للمبالغ الكبيرة اطلب من الخادم النص (`::text`).
  static Decimal parse(Object? raw) {
    if (raw is Decimal) return raw;
    final String text;
    if (raw is String) {
      text = raw;
    } else if (raw is int || raw is BigInt) {
      text = raw.toString();
    } else if (raw is double) {
      if (!raw.isFinite) {
        throw FormatException('Amount must be a finite number', raw.toString());
      }
      text = raw.toString();
    } else {
      throw FormatException('Unsupported amount type: ${raw.runtimeType}');
    }
    final parts = _splitPlain(text);
    return fromScaled(parts.unscaled, parts.scale);
  }

  /// يفكّك [value] إلى (قيمة صحيحة، مقياس) بحيث `value = unscaled / 10^scale`.
  static ({BigInt unscaled, int scale}) split(Decimal value) =>
      _splitPlain(value.toString());

  /// يبني [Decimal] من (قيمة صحيحة، مقياس).
  static Decimal fromScaled(BigInt unscaled, int scale) =>
      Decimal.parse(_plain(unscaled, scale));

  /// التمثيل النصي العشري العادي (بلا أس) للقيمة.
  static String toPlainString(Decimal value) {
    final parts = split(value);
    return _plain(parts.unscaled, parts.scale);
  }

  /// يقرّب الكسر `numerator / denominator` إلى عدد صحيح بالطريقة [method].
  /// `denominator` يجب أن يكون موجباً.
  static BigInt roundFraction(
    BigInt numerator,
    BigInt denominator,
    MoneyRoundingMethod method,
  ) {
    if (denominator.sign <= 0) {
      throw ArgumentError.value(denominator, 'denominator', 'must be > 0');
    }
    final negative = numerator.isNegative;
    final magnitude = numerator.abs();
    var quotient = magnitude ~/ denominator;
    final remainder = magnitude.remainder(denominator);
    final bump = switch (method) {
      MoneyRoundingMethod.down => false,
      MoneyRoundingMethod.up => remainder != BigInt.zero,
      MoneyRoundingMethod.halfUp => remainder * BigInt.two >= denominator,
    };
    if (bump) quotient += BigInt.one;
    return negative ? -quotient : quotient;
  }

  /// يقرّب [value] إلى [scale] خانة عشرية.
  static Decimal roundToScale(
    Decimal value,
    int scale,
    MoneyRoundingMethod method,
  ) {
    final parts = split(value);
    if (parts.scale <= scale) return value;
    final divisor = pow10(parts.scale - scale);
    final rounded = roundFraction(parts.unscaled, divisor, method);
    return fromScaled(rounded, scale);
  }

  /// يقرّب [value] إلى أقرب مضاعف للخطوة [increment] (موجبة).
  static Decimal roundToIncrement(
    Decimal value,
    Decimal increment,
    MoneyRoundingMethod method,
  ) {
    final v = split(value);
    final step = split(increment);
    if (step.unscaled.sign <= 0) {
      throw ArgumentError.value(increment, 'increment', 'must be > 0');
    }
    // value / increment = (v.u * 10^step.s) / (step.u * 10^v.s)
    final numerator = v.unscaled * pow10(step.scale);
    final denominator = step.unscaled * pow10(v.scale);
    final steps = roundFraction(numerator, denominator, method);
    return fromScaled(steps * step.unscaled, step.scale);
  }

  static ({BigInt unscaled, int scale}) _splitPlain(String raw) {
    var text = raw.trim();
    var negative = false;
    if (text.startsWith('-')) {
      negative = true;
      text = text.substring(1);
    } else if (text.startsWith('+')) {
      text = text.substring(1);
    }

    var exponent = 0;
    final exponentIndex = text.indexOf(RegExp('[eE]'));
    if (exponentIndex >= 0) {
      final exponentText = text.substring(exponentIndex + 1);
      if (!_exponent.hasMatch(exponentText)) {
        throw FormatException('Invalid decimal exponent', raw);
      }
      exponent = int.parse(exponentText);
      if (exponent.abs() > _maxExponent) {
        throw FormatException('Decimal exponent is out of range', raw);
      }
      text = text.substring(0, exponentIndex);
    }

    final match = _mantissa.firstMatch(text);
    final whole = match?.group(1) ?? '';
    final fraction = match?.group(2) ?? '';
    if (match == null || (whole.isEmpty && fraction.isEmpty)) {
      throw FormatException('Invalid decimal amount', raw);
    }

    var unscaled = BigInt.parse('$whole$fraction');
    var scale = fraction.length - exponent;
    if (scale < 0) {
      unscaled *= pow10(-scale);
      scale = 0;
    }
    return (unscaled: negative ? -unscaled : unscaled, scale: scale);
  }

  static String _plain(BigInt unscaled, int scale) {
    final negative = unscaled.isNegative;
    var digits = unscaled.abs().toString();
    if (scale > 0) {
      if (digits.length <= scale) digits = digits.padLeft(scale + 1, '0');
      final cut = digits.length - scale;
      digits = '${digits.substring(0, cut)}.${digits.substring(cut)}';
    }
    return negative ? '-$digits' : digits;
  }
}
