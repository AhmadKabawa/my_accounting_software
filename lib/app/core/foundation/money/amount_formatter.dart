import 'package:decimal/decimal.dart';

import 'package:accounting_software/app/core/foundation/money/money.dart';
import 'package:accounting_software/app/core/foundation/money/money_decimal_math.dart';
import 'package:accounting_software/app/core/foundation/money/money_rounding.dart';
import 'package:accounting_software/app/core/foundation/money/money_rounding_method.dart';

/// موضع رمز العملة بالنسبة للرقم في الترتيب **المنطقي** للنص (في سياق RTL يظهر
/// `before` على اليمين).
enum CurrencyLabelPlacement { none, before, after }

/// بيانات عرض عملة واحدة، تأتي من جدول `currencies` عبر مصدر الواجهة:
/// عدد الخانات (`decimal_places`) وطريقة التقريب (`rounding_method`) ورمز العملة.
///
/// التقريب هنا **للعرض فقط**؛ القيمة المحفوظة والمحسوبة لا تتغير، وتقريب الترحيل
/// يمر عبر [MoneyRounding] و`Money.rounded`.
final class CurrencyDisplay {
  const CurrencyDisplay({
    required this.currencyId,
    required this.decimalPlaces,
    this.roundingMethod = MoneyRoundingMethod.halfUp,
    this.label,
    this.labelPlacement = CurrencyLabelPlacement.after,
  });

  /// من إعدادات التقريب نفسها المستعملة في الحساب.
  factory CurrencyDisplay.fromRounding(
    MoneyRounding rounding, {
    required int currencyId,
    String? label,
    CurrencyLabelPlacement labelPlacement = CurrencyLabelPlacement.after,
  }) {
    return CurrencyDisplay(
      currencyId: currencyId,
      decimalPlaces: rounding.decimalPlaces,
      roundingMethod: rounding.method,
      label: label,
      labelPlacement: labelPlacement,
    );
  }

  final int currencyId;
  final int decimalPlaces;
  final MoneyRoundingMethod roundingMethod;

  /// رمز العملة أو كودها (`ل.س` أو `USD`)، أو `null` لبلا رمز.
  final String? label;
  final CurrencyLabelPlacement labelPlacement;
}

/// C13: تنسيق المبالغ. دوال خالصة (لا Widget، لا `BuildContext`، لا Locale).
///
/// القواعد المعتمدة (DESIGN_SYSTEM وقرار-77 وخطة المكوّنات C13):
/// - أرقام غربية (0-9) دائماً، فاصل آلاف `,` وفاصل عشري `.`.
/// - عدد الكسور من العملة (`decimal_places`) وليس من القيمة: `5` بخانتين تظهر `5.00`.
/// - علامة السالب `−` (U+2212) لا `-`، ولا تظهر لقيمة تصير صفراً بعد التقريب.
/// - عزل اتجاه (Bidi isolate): الرقم كله بعلامته داخل `LRI…PDI` فتبقى العلامة يسار
///   الأرقام داخل نص عربي مختلط. رمز العملة يبقى خارج العزل بفاصل غير قابل للكسر.
/// - لا اختصار للمبالغ (1.2M) إطلاقاً.
///
/// لا يجمع ولا يحوّل بين عملات: يعرض ما يُعطى له فقط.
abstract final class AmountFormatter {
  static const String minusSign = '\u2212';
  static const String thousandsSeparator = ',';
  static const String decimalSeparator = '.';

  /// `LEFT-TO-RIGHT ISOLATE` (U+2066) و`POP DIRECTIONAL ISOLATE` (U+2069).
  static const String leftToRightIsolate = '\u2066';
  static const String popDirectionalIsolate = '\u2069';

  /// فاصل غير قابل للكسر (U+00A0) بين الرقم ورمز العملة.
  static const String labelSeparator = '\u00A0';

  static const int _groupSize = 3;

  /// الرقم وحده بلا رمز عملة.
  ///
  /// [decimalPlaces] من 0 إلى [MoneyRounding.maxDecimalPlaces]، وإلا [RangeError].
  /// [roundingMethod] لتقريب العرض فقط. [bidiIsolate] `false` لمخرجات لا تدعم
  /// محارف الاتجاه (CSV مثلاً).
  static String formatDecimal(
    Decimal amount, {
    required int decimalPlaces,
    MoneyRoundingMethod roundingMethod = MoneyRoundingMethod.halfUp,
    bool bidiIsolate = true,
  }) {
    RangeError.checkValueInInterval(
      decimalPlaces,
      0,
      MoneyRounding.maxDecimalPlaces,
      'decimalPlaces',
    );

    final rounded = MoneyDecimalMath.roundToScale(
      amount,
      decimalPlaces,
      roundingMethod,
    );
    final parts = MoneyDecimalMath.split(rounded);
    final units = parts.scale < decimalPlaces
        ? parts.unscaled * MoneyDecimalMath.pow10(decimalPlaces - parts.scale)
        : parts.unscaled;

    final negative = units.isNegative;
    var digits = units.abs().toString();
    var fraction = '';
    if (decimalPlaces > 0) {
      digits = digits.padLeft(decimalPlaces + 1, '0');
      final cut = digits.length - decimalPlaces;
      fraction = digits.substring(cut);
      digits = digits.substring(0, cut);
    }

    final number = fraction.isEmpty
        ? _group(digits)
        : '${_group(digits)}$decimalSeparator$fraction';
    final signed = negative ? '$minusSign$number' : number;
    return bidiIsolate
        ? '$leftToRightIsolate$signed$popDirectionalIsolate'
        : signed;
  }

  /// مبلغ كامل مع رمز عملته.
  ///
  /// يرمي [CurrencyMismatchException] إن اختلف `money.currencyId` عن
  /// `currency.currencyId` (يمنع عرض مبلغ بخانات عملة أخرى).
  static String format(
    Money money, {
    required CurrencyDisplay currency,
    bool bidiIsolate = true,
  }) {
    if (money.currencyId != currency.currencyId) {
      throw CurrencyMismatchException(
        money.currencyId,
        currency.currencyId,
        'format',
      );
    }
    final number = formatDecimal(
      money.amount,
      decimalPlaces: currency.decimalPlaces,
      roundingMethod: currency.roundingMethod,
      bidiIsolate: bidiIsolate,
    );
    final label = currency.label;
    if (label == null || label.isEmpty) return number;
    return switch (currency.labelPlacement) {
      CurrencyLabelPlacement.none => number,
      CurrencyLabelPlacement.before => '$label$labelSeparator$number',
      CurrencyLabelPlacement.after => '$number$labelSeparator$label',
    };
  }

  static String _group(String digits) {
    final buffer = StringBuffer();
    final head = digits.length % _groupSize;
    if (head > 0) buffer.write(digits.substring(0, head));
    for (var i = head; i < digits.length; i += _groupSize) {
      if (buffer.isNotEmpty) buffer.write(thousandsSeparator);
      buffer.write(digits.substring(i, i + _groupSize));
    }
    return buffer.toString();
  }
}
