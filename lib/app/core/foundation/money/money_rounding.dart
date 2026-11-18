import 'package:decimal/decimal.dart';

import 'package:accounting_software/app/core/foundation/money/money_decimal_math.dart';
import 'package:accounting_software/app/core/foundation/money/money_rounding_method.dart';

/// إعدادات تقريب عملة واحدة، تُقرأ من جدول `currencies` ولا تُثبَّت في Flutter
/// (قرار-70): `decimal_places` و`rounding_increment` و`rounding_method`.
///
/// الترتيب المعتمد عند [apply]:
/// 1. إن كانت [roundingIncrement] أكبر من الصفر: تقريب إلى أقرب مضاعف لها.
/// 2. ثم التقريب إلى [decimalPlaces] خانة عشرية.
///
/// الخطوتان بالطريقة [method] نفسها. [roundingIncrement] صفر تعني: لا تقريب بخطوة.
///
/// **قيد مفتوح:** هذه الدلالات (خصوصاً معنى `rounding_increment` > 0) استُنتجت من
/// أسماء الأعمدة وقيودها لا من نص `erp.round_currency`؛ يجب مطابقتها معه قبل اعتماد
/// أي ترحيل يعتمد على هذا التقريب.
final class MoneyRounding {
  MoneyRounding({
    required this.decimalPlaces,
    Decimal? roundingIncrement,
    this.method = MoneyRoundingMethod.halfUp,
  }) : roundingIncrement = roundingIncrement ?? Decimal.zero {
    RangeError.checkValueInInterval(
      decimalPlaces,
      0,
      maxDecimalPlaces,
      'decimalPlaces',
    );
    if (this.roundingIncrement.signum < 0) {
      throw ArgumentError.value(
        roundingIncrement,
        'roundingIncrement',
        'must be >= 0',
      );
    }
  }

  /// يبني الإعدادات من صف `currencies` كما يصل من PostgREST.
  ///
  /// [roundingIncrement] قد يصل رقماً أو نصاً (`numeric(20,6)`)؛ يُقرأ دون المرور بـ `double`
  /// حين يصل نصاً.
  factory MoneyRounding.fromCurrencyRow({
    required int decimalPlaces,
    required Object? roundingIncrement,
    required String roundingMethod,
  }) {
    return MoneyRounding(
      decimalPlaces: decimalPlaces,
      roundingIncrement: roundingIncrement == null
          ? null
          : MoneyDecimalMath.parse(roundingIncrement),
      method: MoneyRoundingMethod.fromCode(roundingMethod),
    );
  }

  /// أقصى عدد خانات عشرية تسمح به القاعدة (قيد `currencies_decimal_places_check`).
  static const int maxDecimalPlaces = 8;

  /// `currencies.decimal_places`.
  final int decimalPlaces;

  /// `currencies.rounding_increment` (صفر = بلا خطوة).
  final Decimal roundingIncrement;

  /// `currencies.rounding_method`.
  final MoneyRoundingMethod method;

  /// يقرّب [value] وفق إعدادات العملة.
  Decimal apply(Decimal value) {
    var result = value;
    if (roundingIncrement.signum > 0) {
      result = MoneyDecimalMath.roundToIncrement(
        result,
        roundingIncrement,
        method,
      );
    }
    return MoneyDecimalMath.roundToScale(result, decimalPlaces, method);
  }

  @override
  bool operator ==(Object other) =>
      other is MoneyRounding &&
      other.decimalPlaces == decimalPlaces &&
      other.roundingIncrement == roundingIncrement &&
      other.method == method;

  @override
  int get hashCode => Object.hash(decimalPlaces, roundingIncrement, method);

  @override
  String toString() =>
      'MoneyRounding(decimalPlaces: $decimalPlaces, '
      'increment: ${MoneyDecimalMath.toPlainString(roundingIncrement)}, '
      'method: ${method.code})';
}
