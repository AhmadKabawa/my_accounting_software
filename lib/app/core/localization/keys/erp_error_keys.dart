import 'package:accounting_software/app/core/localization/translations/app_key.dart';

/// Texts of the `erp` section: the business-rule errors raised by the
/// database as `SQLSTATE = ERPnn` (decision 76).
///
/// Arabic follows `docs/backend/DATA_MODEL.md` section 5 / appendix هـ
/// (two technical status words were replaced by plain Arabic). The server's
/// own text is never shown to the user; it is kept with the code for
/// diagnostics only. Look an error up with [ErpErrorKeys.fromCode].
enum ErpErrorKeys implements AppKey {
  docLocked(
    code: 'ERP01',
    ar: 'مستند مُرحَّل أو ملغى لا يُعدَّل ولا يُحذف',
    en: 'A posted or cancelled document cannot be edited or deleted',
  ),
  docBadTransition(
    code: 'ERP02',
    ar: 'انتقال حالة غير مسموح للمستند — الإلغاء للمسودات فقط، والمستند المرحّل يُعكس بمستند معاكس',
    en: 'This status change is not allowed — only drafts can be cancelled; a posted document is reversed with an opposite document',
  ),
  docItemsLocked(
    code: 'ERP03',
    ar: 'لا يجوز تعديل بنود مستند ليس في حالة مسودة',
    en: 'Items of a document that is not a draft cannot be edited',
  ),
  insufficientStock(
    code: 'ERP04',
    ar: 'الرصيد غير كافٍ والسياسة تمنع الرصيد السالب',
    en: 'Insufficient stock, and the policy forbids negative stock',
  ),
  appendOnly(
    code: 'ERP05',
    ar: 'جدول للإضافة فقط، التصحيح بحركة معاكسة',
    en: 'This record is append-only; correct it with an opposite entry',
  ),
  fxRateImmutable(
    code: 'ERP06',
    ar: 'أسعار الصرف لا تُعدَّل ولا تُحذف، تُضاف أسعار جديدة',
    en: 'Exchange rates cannot be edited or deleted; add a new rate instead',
  ),
  journalUnbalanced(
    code: 'ERP07',
    ar: 'القيد غير متوازن (مجموع المدين لا يساوي الدائن)',
    en: 'The journal entry is unbalanced (total debit differs from total credit)',
  ),
  periodClosed(
    code: 'ERP08',
    ar: 'الفترة المحاسبية مغلقة أو التاريخ خارج الفترة',
    en: 'The accounting period is closed or the date is outside the period',
  ),
  glAccountNotPostable(
    code: 'ERP09',
    ar: 'حساب غير قابل للترحيل أو غير فعّال',
    en: 'The account cannot be posted to or is inactive',
  ),
  currencyMismatch(
    code: 'ERP10',
    ar: 'عدم تطابق العملات',
    en: 'Currencies do not match',
  ),
  warehouseNotSellable(
    code: 'ERP11',
    ar: 'المستودع غير قابل للبيع',
    en: 'This warehouse is not sellable',
  ),
  posSessionNotReconciled(
    code: 'ERP12',
    ar: 'لا تُغلق الوردية قبل اعتماد جرد كل عملة',
    en: 'The shift cannot be closed before every currency count is approved',
  ),
  periodLocked(
    code: 'ERP13',
    ar: 'الفترة المحاسبية مقفلة نهائياً',
    en: 'The accounting period is permanently locked',
  ),
  glParentPostable(
    code: 'ERP14',
    ar: 'الحساب الأب يجب أن يكون تجميعياً وغير قابل للترحيل',
    en: 'A parent account must be a group account that cannot be posted to',
  ),
  transferRateInvalid(
    code: 'ERP15',
    ar: 'بيانات سعر الصرف أو المبالغ في تحويل الأموال غير صحيحة',
    en: 'The exchange rate or amounts of the money transfer are invalid',
  ),
  permissionDenied(
    code: 'ERP16',
    ar: 'لا تملك الصلاحية المطلوبة لهذه العملية',
    en: 'You do not have the permission required for this operation',
  ),
  reasonMismatch(
    code: 'ERP17',
    ar: 'سبب الدفع/التسوية لا يطابق نوع العملية',
    en: 'The payment/adjustment reason does not match the operation type',
  ),
  docLinkMismatch(
    code: 'ERP18',
    ar: 'عدم تطابق بين المستند ومرجعه (فاتورة/بند/دفعة)',
    en: 'The document does not match its reference (invoice/item/payment)',
  ),
  priceRateRequired(
    code: 'ERP19',
    ar: 'يلزم سعر صرف السعر عند اختلاف عملة السعر عن عملة الفاتورة',
    en: 'An exchange rate is required when the price currency differs from the invoice currency',
  ),
  accountTypeInvalid(
    code: 'ERP20',
    ar: 'نوع الحساب المالي غير مناسب للعملية',
    en: 'The financial account type is not suitable for this operation',
  ),
  journalTooFewLines(
    code: 'ERP21',
    ar: 'القيد يحتاج سطرين على الأقل',
    en: 'A journal entry needs at least two lines',
  ),
  invalidState(
    code: 'ERP22',
    ar: 'حالة أو بيانات غير صالحة للعملية',
    en: 'Invalid state or data for this operation',
  ),
  priceListNotAllowed(
    code: 'ERP23',
    ar: 'قائمة الأسعار غير مسموحة لهذا المستخدم أو نقطة البيع',
    en: 'This price list is not allowed for this user or POS terminal',
  ),
  priceMismatch(
    code: 'ERP24',
    ar: 'السعر لا يطابق سعر القائمة المعتمد ولا يجوز تعديل سعر السطر',
    en: 'The price does not match the approved list price, and the line price cannot be changed',
  ),
  priceNotFound(
    code: 'ERP25',
    ar: 'لا يوجد سعر قابل للحل للصنف في قائمة الأسعار',
    en: 'No price could be resolved for this item in the price list',
  ),
  discountCapExceeded(
    code: 'ERP26',
    ar: 'الخصم يتجاوز السقف المسموح',
    en: 'The discount exceeds the allowed cap',
  ),
  attributeValueInvalid(
    code: 'ERP27',
    ar: 'قيمة الخاصية لا تطابق نوعها أو خياراتها',
    en: 'The attribute value does not match its type or options',
  ),
  requiredAttributesMissing(
    code: 'ERP28',
    ar: 'خصائص إلزامية ناقصة، لا يمكن نشر المنتج',
    en: 'Required attributes are missing; the product cannot be published',
  ),
  productMustStartDraft(
    code: 'ERP29',
    ar: 'يُنشأ المنتج مسودة أولاً ثم تُحفظ خصائصه ثم يُنشر',
    en: 'Create the product as a draft first, save its attributes, then publish it',
  ),
  unknown(
    code: null,
    ar: 'تعذر تنفيذ العملية، يرجى المحاولة مرة أخرى أو التواصل مع الدعم',
    en: 'The operation could not be completed; try again or contact support',
  );

  const ErpErrorKeys({required this.code, required this.ar, required this.en});

  /// The database code (`ERPnn`); `null` for the generic [unknown] text.
  final String? code;

  @override
  final String ar;
  @override
  final String en;

  @override
  String get key => 'erp.$name';

  static final Map<String, ErpErrorKeys> _byCode = {
    for (final k in values)
      if (k.code != null) k.code!: k,
  };

  /// Matches `ERP` followed by two digits, nothing else.
  static final RegExp _pattern = RegExp(r'^ERP\d{2}$');

  /// True when [code] has the shape of a business-rule code.
  static bool isErpCode(String? code) => code != null && _pattern.hasMatch(code);

  /// The text for [code]; [unknown] for a well-formed code this app does not
  /// know yet (a newer database), so the user never sees the raw server text.
  static ErpErrorKeys fromCode(String? code) => _byCode[code] ?? unknown;
}
