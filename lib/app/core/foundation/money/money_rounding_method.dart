/// طريقة تقريب العملة، مطابقة لقيم `currencies.rounding_method` في القاعدة
/// (`HALF_UP` و`UP` و`DOWN`، انظر DATA_MODEL §4.2).
///
/// الدلالات المعتمدة هنا (تحتاج مطابقة مع الدالة `erp.round_currency` في القاعدة،
/// فنصها لم يرد في الوثائق):
/// - [halfUp]: إلى الأقرب، وعند التعادل بعيداً عن الصفر (كـ `round` في PostgreSQL).
/// - [up]: بعيداً عن الصفر دائماً عند وجود باقٍ.
/// - [down]: نحو الصفر (قطع).
enum MoneyRoundingMethod {
  halfUp('HALF_UP'),
  up('UP'),
  down('DOWN');

  const MoneyRoundingMethod(this.code);

  /// القيمة المخزنة في `currencies.rounding_method`.
  final String code;

  /// يحوّل قيمة العمود إلى النوع. يرمي [FormatException] لقيمة غير معروفة.
  static MoneyRoundingMethod fromCode(String code) {
    for (final method in values) {
      if (method.code == code) return method;
    }
    throw FormatException('Unknown rounding method code', code);
  }
}
