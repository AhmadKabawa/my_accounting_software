import 'package:decimal/decimal.dart';

import 'package:accounting_software/app/core/foundation/money/money_decimal_math.dart';
import 'package:accounting_software/app/core/foundation/money/money_rounding.dart';

/// مبلغ مالي: قيمة عشرية دقيقة + معرّف عملة (قرار-70، ARCHITECTURE_RULES §7).
///
/// - لا `double` في أي عملية حسابية: الجمع والطرح والضرب بدقة عشرية كاملة.
/// - الجمع والطرح والمقارنة بين عملتين مختلفتين ترمي [CurrencyMismatchException]
///   (يقابل `ERP10` في القاعدة)؛ التحويل بين العملات صريح عبر [convert] فقط.
/// - التقريب لا يحدث ضمنياً: يُطلب صراحة عبر [rounded] بإعدادات العملة من القاعدة
///   ([MoneyRounding]). لا قاعدة تقريب ثابتة في Flutter.
/// - المساواة بالقيمة العددية والعملة معاً: `1.0` و`1.00` بالعملة نفسها متساويان.
///
/// ممنوع تسجيل قيم [Money] في `Logger` (AGENTS §1: لا بيانات مالية في السجلات)؛
/// `toString` موجود للاختبارات والتشخيص المحلي فقط.
final class Money implements Comparable<Money> {
  Money(this.amount, this.currencyId);

  /// صفر بعملة معيّنة.
  factory Money.zero(int currencyId) => Money(Decimal.zero, currencyId);

  /// من نص عشري عادي، مثل `"1234.5600"`. يرمي [FormatException] لنص غير صالح.
  factory Money.parse(String amount, int currencyId) =>
      Money(MoneyDecimalMath.parse(amount), currencyId);

  /// من قيمة خام قادمة من PostgREST (`numeric(20,4)` يصل رقماً أو نصاً) دون المرور
  /// بـ `double` حين يصل نصاً. انظر تحفظ الدقة في [MoneyDecimalMath.parse].
  factory Money.fromRaw(Object? amount, int currencyId) =>
      Money(MoneyDecimalMath.parse(amount), currencyId);

  /// مجموع [items] كلها بعملة [currencyId]؛ فارغة تعطي صفراً. تعدد العملات يرمي.
  static Money sum(int currencyId, Iterable<Money> items) {
    var total = Money.zero(currencyId);
    for (final item in items) {
      total += item;
    }
    return total;
  }

  final Decimal amount;
  final int currencyId;

  bool get isZero => amount.sign == 0;
  bool get isNegative => amount.sign < 0;
  bool get isPositive => amount.sign > 0;

  Money operator +(Money other) {
    _requireSameCurrency(other, '+');
    return Money(amount + other.amount, currencyId);
  }

  Money operator -(Money other) {
    _requireSameCurrency(other, '-');
    return Money(amount - other.amount, currencyId);
  }

  Money operator -() => Money(-amount, currencyId);

  Money abs() => Money(amount.abs(), currencyId);

  /// الضرب بنسبة أو كمية أو سعر؛ تبقى العملة كما هي. للتحويل بين عملتين استعمل [convert].
  Money times(Decimal factor) => Money(amount * factor, currencyId);

  /// التحويل إلى عملة أخرى بمعامل [rate] جاهز (يُجلب من `erp.get_rate` أو `exchange_rates`
  /// ويُحفظ مع المستند: العملة الأصلية والمبلغ وسعر الصرف ومصدره، ARCHITECTURE_RULES §7).
  /// اتجاه السعر مسؤولية المستدعي. لا تقريب ضمني: استدعِ [rounded] بعده.
  Money convert({required Decimal rate, required int toCurrencyId}) {
    if (toCurrencyId == currencyId) {
      throw ArgumentError.value(
        toCurrencyId,
        'toCurrencyId',
        'must differ from the current currency',
      );
    }
    if (rate.sign <= 0) {
      throw ArgumentError.value(rate.toString(), 'rate', 'must be > 0');
    }
    return Money(amount * rate, toCurrencyId);
  }

  /// يقرّب المبلغ وفق إعدادات عملته من القاعدة.
  Money rounded(MoneyRounding rounding) =>
      Money(rounding.apply(amount), currencyId);

  /// مقارنة بين مبلغين بالعملة نفسها؛ عملتان مختلفتان ترمي [CurrencyMismatchException].
  @override
  int compareTo(Money other) {
    _requireSameCurrency(other, 'compareTo');
    return amount.compareTo(other.amount);
  }

  bool operator <(Money other) => compareTo(other) < 0;
  bool operator <=(Money other) => compareTo(other) <= 0;
  bool operator >(Money other) => compareTo(other) > 0;
  bool operator >=(Money other) => compareTo(other) >= 0;

  /// التمثيل النصي العشري العادي (بلا أس ولا فواصل) للإرسال إلى الخادم.
  String toPlainString() => MoneyDecimalMath.toPlainString(amount);

  void _requireSameCurrency(Money other, String operation) {
    if (other.currencyId != currencyId) {
      throw CurrencyMismatchException(currencyId, other.currencyId, operation);
    }
  }

  @override
  bool operator ==(Object other) =>
      other is Money &&
      other.currencyId == currencyId &&
      other.amount == amount;

  @override
  int get hashCode => Object.hash(currencyId, amount);

  @override
  String toString() => 'Money(${toPlainString()}, currency: $currencyId)';
}

/// عملية على مبلغين بعملتين مختلفتين (يقابل `ERP10 CURRENCY_MISMATCH` في القاعدة).
/// خطأ برمجي لا رسالة للمستخدم: لا تعرض [toString] في الواجهة.
final class CurrencyMismatchException implements Exception {
  const CurrencyMismatchException(
    this.leftCurrencyId,
    this.rightCurrencyId,
    this.operation,
  );

  final int leftCurrencyId;
  final int rightCurrencyId;
  final String operation;

  @override
  String toString() =>
      'CurrencyMismatchException: cannot apply "$operation" to currencies '
      '$leftCurrencyId and $rightCurrencyId';
}
