**وثيقة سيناريوهات الاستخدام**

نظام محاسبة وإدارة مخزون وحسابات مالية لمتجر

مرجع لتصميم الواجهات (Wireframes / UI) على Flutter: ويب، موبايل، Windows

| **البند** | **التفصيل** |
| --- | --- |
| المصدر | مخطط قاعدة بيانات Supabase: المشروع test vaude store with claude (schema public) |
| حجم القاعدة | 121 جدولاً، 460 سياسة RLS في public، 8 سياسات Storage، 292 Trigger، 55 دالة في public، 103 دوال في erp، 19 View |
| المنصة | Flutter: ويب وتطبيق موبايل وWindows. متصل بالإنترنت (قرار-02) |
| الأدوار | SUPER_ADMIN MANAGER CASHIER WAREHOUSE ACCOUNTANT PURCHASER AUDITOR |
| عدد السيناريوهات | 81 سيناريو (45 أصلياً محدَّثة و36 جديدة)، كلٌّ بهدف واحد وحتى 4 جداول رئيسية |
| تاريخ الإعداد | النسخة الأولى 8 نوفمبر 2026، والنسخة المطوَّرة المطابقة للقاعدة 9 نوفمبر 2026، والنسخة النهائية v1: 13 نوفمبر 2026 |
| اصطلاحات | أسماء الجداول والأعمدة بالإنجليزية داخل خط أحادي. القاعدة هي المرجع عند أي اختلاف مع هذه الوثيقة (قرار-51). عمود «الحالة» في الفهرس يبيّن: جديد، محدَّث، كما هو؛ وعمود «المنصة الأساسية» يحدد المنصة التي تُصمَّم لها الشاشة أولاً. |
| الملاحق | الملحق ط: سجل القرارات (قرار-01 إلى قرار-63). وفي آخر الوثيقة: خارج نطاق v1، وقائمة التشغيل قبل الإطلاق. |

# 1\. الفهم

## 1.1 ملخص النظام

نظام ERP لمتجر ملابس ومستلزمات رياضية متعدد الفروع والمستودعات: كتالوج بموديلات وألوان ومقاسات، نقطة بيع بجلسات صندوق، مشتريات، مخزون وتحويلات وجرد، سندات مالية متعددة العملات، ومحاسبة بقيود يومية وفترات مالية، وسجل تدقيق.

- لا توجد Enums: الحالات قيود CHECK (مثل doc_status: DRAFT / POSTED / CANCELLED / REVERSED).
- الإجراءات الحرجة دوال RPC: post_sale وpost_purchase_invoice وpost_payment وpost_sales_return وpost_purchase_return وpost_expense وpost_money_transfer وpost_balance_adjustment وpost_stock_adjustment وpost_cash_reconciliation وapprove_transfer وship_transfer وreceive_transfer وcancel_transfer، ومعها دوال التسعير والتكلفة (resolve_price وset_model_price وset_variant_cost) وسقف الخصم (set_discount_cap) وأدوات المسودة (get_draft_price_warnings وrefresh_draft_line_prices) والأرصدة الافتتاحية (post_opening_stock وpost_opening_cash وpost_opening_party_balance وopening_readiness)، والأطراف (quick_add_customer)، والسلف (apply_advance وlist_party_advances)، ومراجعة المصروف (mark_expense_reviewed وlist_expenses_for_review) وإيصاله (attach_expense_receipt)، وصور المنتج والألوان (attach_product_image وattach_color_image وdelete_product_image وdelete_color_image).
- الترحيل بالدوال فقط (قرار-43): trigger ‏forbid_direct_post يمنع تغيير الحالة إلى POSTED بـ UPDATE مباشر على expenses وmoney_transfers وbalance_adjustments وstock_adjustments وcash_reconciliations؛ ولا يصير مستند POSTED بلا قيد وحركة مقابلة. حركة CASH_DIFFERENCE تُولَّد من الجرد النقدي بقيد على CASH_OVER أو CASH_SHORT.
- العكس (قرار-44): reverse_payment (payment.cancel) وreverse_expense وreverse_balance_adjustment وreverse_money_transfer وreverse_journal_entry (accounting.post) وreverse_stock_adjustment (inventory.adjust مع صلاحية المستودع) وreverse_cash_reconciliation (accounting.post أو reconcile.cash مع pos.manage) تنشئ مستنداً معاكساً مرتبطاً بالأصل عبر reversal_of؛ فلا عكس مزدوج، ولا يُعكس المستند العكسي، وreverse_journal_entry ترفض القيد المرتبط بمستند (يُعكس المستند نفسه). حالة المعكوس موحَّدة: كل مستند مرحّل جرى عكسه تصبح حالته REVERSED (قرار-58)، وCANCELLED لإلغاء المسودات فقط (والتحويل المخزني الملغى قبل الشحن). protect_posted_doc لم تُضعَف: الإلغاء المباشر محظور.
- أرصدة المخزون وسجل الأطراف والقيود المحاسبية والحركات المالية تُولَّد تلقائياً عند الترحيل، ولا تُعدَّل من الواجهة. stock_movements للإضافة فقط (ERP05).
- المستند المرحّل محمي من التعديل (protect_posted_doc، ERP03).
- القاعدة ليست فارغة. البيانات الأولية: الأدوار السبعة والصلاحيات (46) وربطها (151)، وإعدادات أولية، ومستودعات تالف لكل فرع، والعملة الأساسية USD، وقائمة التجزئة الافتراضية RETAIL-SYP، و24 فترة محاسبية من يناير 2026 إلى ديسمبر 2027 (ويُولَّد ما بعدها تلقائياً عند الطلب، قرار-47)، و51 حساباً في الدليل المحاسبي و24 ربطاً محاسبياً، و8 فئات مصروف، و13 سبب دفع، والمستخدم admin. وبيانات اختبار محدودة (4 منتجات و4 فواتير وقاعدة تسعير تجريبية TEST-CAP-MU20 تُحذف عند أول إدخال حقيقي).
- التخزين: bucket خاص باسم expense-receipts لإيصالات المصروف يبدأ المسار فيه برقم الفرع، وbucket عام للقراءة باسم product-images لصور المنتج والألوان (jpeg وpng وwebp، بحد 5 MB). وعدد سياسات Storage (8) هو الإجمالي على مستوى المخطط.
- كل دالة RPC تفحص الصلاحية داخلها، فإخفاء الأزرار في الواجهة لا يكفي؛ والبيع تحرسه القاعدة نفسها: قائمة الأسعار المسموحة، مطابقة السعر، سقف الخصم، فرع المستودع (ERP23 إلى ERP26).
- أعمدة التكلفة محجوبة عن الجداول الأساسية، وتُقرأ عبر Views للقراءة فقط تُفلتَر بـ costs.view والفرع.

## 1.2 القرارات المعتمدة

سجل القرارات في الملحق ط بترقيم واحد (قرار-01 إلى قرار-63)، وتشير إليه السيناريوهات برقم القرار. عند تعارض أي قرار مع القاعدة فالقاعدة هي المرجع (قرار-51).

## 1.3 الأدوار والصلاحيات (منقولة من القاعدة)

الصلاحيات في القاعدة أكواد (has_permission) وليست أسماء أدوار. الجدول يعكس ما هو مكتوب فعلاً في role_permissions (46 صلاحية، 151 ربطاً). عند غياب الصلاحية ترمي الدوال ERP16 PERMISSION_DENIED. قاعدتان تنطبقان على الجميع: SUPER_ADMIN يتجاوز فحوص الفروع، وغيره يحتاج صفاً في user_branch_access (can_view للقراءة وcan_operate للتنفيذ). قاموس الصلاحيات في الملحق ز.

| **الدور** | **يستطيع (الأكواد)** | **لا يستطيع** |
| --- | --- | --- |
| SUPER_ADMIN (45) | كل شيء عبر is_super_admin()، وتشمل صلاحياته users.manage وorg.manage وsettings.manage وhr.manage؛ ويحمل كل الصلاحيات المربوطة عدا parties.quick_add لأنه يملك parties.manage. | لا شيء (لكن يلزم سبب عند الإلغاء). |
| MANAGER (36) | accounting.view audit.view catalog.manage costs.manage costs.view discount.exceptional finance.expenses finance.payments finance.view fx.rate.manual hr.manage hr.view inventory.adjust inventory.transfer inventory.transfer.approve inventory.view inventory.view_other_branches masterdata.manage parties.manage parties.view payment.cancel pos.manage pos.session pricing.manage purchasing.create purchasing.post purchasing.return purchasing.view reconcile.cash reports.view sales.create sales.discount sales.post sales.return sales.view warehouse.central.access | users.manage org.manage settings.manage finance.manage accounting.manage accounting.post balance.adjust fx.rate.manage owner.transactions parties.quick_add |
| CASHIER (13) | finance.expenses finance.payments inventory.view inventory.view_other_branches parties.quick_add parties.view pos.session reconcile.cash sales.create sales.discount sales.post sales.return sales.view | parties.manage (فلا يكتب في parties وcustomers مباشرة) costs.view inventory.adjust purchasing.\* accounting.\* catalog.manage pos.manage hr.\* |
| WAREHOUSE (9) | catalog.manage inventory.adjust inventory.transfer inventory.transfer.approve inventory.view inventory.view_other_branches masterdata.manage purchasing.view warehouse.central.access | المبيعات والمالية والمحاسبة (وكتابة ملاحظات المورد) |
| ACCOUNTANT (23) | accounting.manage accounting.post accounting.view audit.view balance.adjust costs.manage costs.view finance.expenses finance.manage finance.payments finance.view fx.rate.manage fx.rate.manual hr.view inventory.view owner.transactions parties.manage parties.view payment.cancel purchasing.view reconcile.cash reports.view sales.view | إنشاء مبيعات أو تحويلات مخزون؛ hr.manage users.manage |
| PURCHASER (14) | catalog.manage costs.view finance.payments inventory.view inventory.view_other_branches masterdata.manage parties.manage parties.view purchasing.create purchasing.post purchasing.return purchasing.view reports.view warehouse.central.access | المبيعات والمحاسبة وتحويل المخزون |
| AUDITOR (11) | accounting.view audit.view costs.view finance.view hr.view inventory.view parties.view purchasing.view reports.view sales.view warehouse.central.access | أي إنشاء أو ترحيل أو إلغاء أو تعديل أو تعليم مراجعة |

قيود أنواع الدفعات في post_payment (قرار-46): OWNER_WITHDRAWAL وOWNER_CONTRIBUTION تتطلبان owner.transactions؛ وEMPLOYEE_PAYMENT يتطلب finance.payments مع accounting.manage أو finance.manage. فلا يرحّلها المشتري ولا الكاشير رغم حملهما finance.payments. وهي تُنفَّذ عبر غلاف public.post_payment فوق erp.post_payment_core.

## 1.4 الكيانات الرئيسية والعلاقات

| **المجال** | **الجداول والعلاقات** |
| --- | --- |
| التنظيم | branches ← warehouses (أنواع: GENERAL SHOP_FLOOR CENTRAL RETURNS DAMAGED)، employees ← parties. |
| الأمان | users ← user_roles ← roles ← role_permissions ← permissions، وuser_branch_access، وuser_pos_terminals، وuser_price_lists. |
| الأطراف | parties (PERSON/COMPANY) والطرف نفسه قد يكون في customers وsuppliers وemployees وowners. |
| الكتالوج | products ← product_variants (لون × مقاس) ← barcodes؛ ألوان (colors، product_colors، product_color_components، color_images)، ومقاسات (size_systems ← size_groups ← sizes)، وbrands وcategories وproduct_types وunits. |
| الوصف والخصائص | sports age*groups genders seasons collections tags materials fabric_types care_instructions وجداول الربط product*\*؛ attributes وoption_sets وoptions وproduct_attribute_values وproduct_option_values وvariant_option_values. |
| التسعير والتكلفة | price_lists ← variant_prices، price_rules، discounts ← discount_targets، variant_costs (متوسط وآخر شراء)، cost_adjustments، pos_terminal_price_lists. |
| الإعدادات والعرض | settings (GLOBAL/BRANCH/USER)، display_preferences، document_sequences، error_codes، currencies وexchange_rates. |
| المبيعات | sales ← sale_items، sales_returns ← sales_return_items، مرتبطة بـ pos_sessions ← pos_terminals، customers وcustomer_addresses. |
| المشتريات | purchase_invoices ← purchase_invoice_items، purchase_returns ← purchase_return_items، supplier_notes، suppliers. |
| المخزون | inventory_balances، stock_movements (للإضافة فقط)، stock_transfers ← stock_transfer_items، stock_adjustments ← stock_adjustment_items، variant_reorder_levels. |
| المالية | payments ← payment_lines ← payment_allocations، expenses، expense_categories، payment_reasons، money_transfers، financial_accounts (صندوق/بنك)، financial_transactions، party_ledger_entries، balance_adjustments، cash_reconciliations. |
| المحاسبة | gl_accounts وgl_account_mappings وfiscal_periods وjournal_entries ← journal_entry_lines. |
| الرقابة | audit_logs. |

# 2\. فهرس السيناريوهات

الأولوية: 1 أساسي، 2 مهم، 3 ثانوي. الحالة: جديد، محدَّث، كما هو.

| **الرقم** | **السيناريو** | **الدور** | **الوحدة** | **أولوية** | **الحالة** | **المنصة الأساسية** |
| --- | --- | --- | --- | --- | --- | --- |
| S01 | تسجيل الدخول وتحميل الصلاحيات | جميع المستخدمين (SUPER_ADMIN MANAGER CASHIER WAREHOUSE ACCOUNTANT PURCHASER AUDITOR) | الدخول والمستخدمون والصلاحيات | 1 | محدَّث | ويب وموبايل وWindows |
| S02 | إنشاء مستخدم وتعيين دوره وفروعه | SUPER_ADMIN | الدخول والمستخدمون والصلاحيات | 1 | محدَّث | ويب |
| S03 | إدارة الأدوار وصلاحياتها | SUPER_ADMIN | الدخول والمستخدمون والصلاحيات | 1 | محدَّث | ويب |
| S59 | إعادة تعيين كلمة المرور وتعطيل الحساب | SUPER_ADMIN (users.manage) | الدخول والمستخدمون والصلاحيات | 1 | جديد | ويب |
| S60 | ربط مالك أو طرف قائم بحساب دخول | SUPER_ADMIN (users.manage) | الدخول والمستخدمون والصلاحيات | 2 | جديد | ويب |
| S61 | تبديل الفرع وتقارير كل الفروع | جميع المستخدمين متعددي الفروع (المدير غالباً) | الدخول والمستخدمون والصلاحيات | 1 | جديد | ويب وموبايل وWindows |
| S62 | إدارة الموظفين | MANAGER وSUPER_ADMIN (hr.manage) والاطلاع للمحاسب والمدقق (hr.view) | الدخول والمستخدمون والصلاحيات | 2 | جديد | ويب |
| S81 | لوحة التحكم حسب الدور | جميع الأدوار | الدخول والمستخدمون والصلاحيات | 2 | جديد | ويب وموبايل وWindows |
| S82 | تغيير كلمة المرور الاختياري وتسجيل الخروج | جميع المستخدمين | الدخول والمستخدمون والصلاحيات | 2 | جديد | ويب وموبايل وWindows |
| S04 | إدارة الفروع والمستودعات | SUPER_ADMIN (لأن org.manage) | الهيكل والإعدادات | 2 | محدَّث | ويب |
| S05 | إعداد نقاط البيع والصناديق | MANAGER (pos.manage) وSUPER_ADMIN | الهيكل والإعدادات | 2 | محدَّث | ويب |
| S06 | العملات وأسعار الصرف والإعدادات | ACCOUNTANT وSUPER_ADMIN | الهيكل والإعدادات | 2 | محدَّث | ويب |
| S43 | تفضيلات عرض العملة | جميع المستخدمين (لتفضيلهم الشخصي) | الهيكل والإعدادات | 2 | محدَّث | ويب وموبايل وWindows |
| S58 | ربط المستخدمين ونقاط البيع بقوائم الأسعار | SUPER_ADMIN (users.manage) لقوائم المستخدمين، وMANAGER (pos.manage) لقوائم النقاط | الهيكل والإعدادات | 1 | جديد | ويب |
| S63 | ضبط سقف خصم الكاشير لكل فرع | MANAGER (pricing.manage) وSUPER_ADMIN | الهيكل والإعدادات | 1 | جديد | ويب |
| S77 | ترقيم المستندات التلقائي | النظام (بلا شاشة) | الهيكل والإعدادات | 3 | جديد | النظام (بلا شاشة) |
| S78 | إدارة مفاتيح الإعدادات | SUPER_ADMIN (settings.manage) | الهيكل والإعدادات | 1 | جديد | ويب |
| S07 | إنشاء منتج (موديل) | MANAGER وPURCHASER وWAREHOUSE (catalog.manage) | الكتالوج والتسعير | 1 | محدَّث | ويب |
| S08 | إضافة الألوان والمقاسات والباركود (المتغيرات) | MANAGER وPURCHASER وWAREHOUSE | الكتالوج والتسعير | 1 | محدَّث | ويب |
| S09 | تسعير المنتجات | MANAGER (pricing.manage) | الكتالوج والتسعير | 2 | محدَّث | ويب |
| S10 | تحديد تكلفة المنتج وتعديلها | ACCOUNTANT وMANAGER (costs.manage) | الكتالوج والتسعير | 2 | محدَّث | ويب |
| S11 | إدارة الخصومات | MANAGER (pricing.manage) | الكتالوج والتسعير | 3 | محدَّث | ويب |
| S46 | إدارة الألوان (البسيطة والمركّبة وصور الألوان) | MANAGER وPURCHASER وWAREHOUSE (masterdata.manage) | الكتالوج والتسعير | 1 | جديد | ويب |
| S47 | أنظمة المقاسات ومجموعاتها ومقاساتها | MANAGER وPURCHASER وWAREHOUSE (masterdata.manage) | الكتالوج والتسعير | 1 | جديد | ويب |
| S48 | ربط المقاسات بنوع المنتج وبالمنتج | MANAGER وPURCHASER وWAREHOUSE (masterdata.manage) | الكتالوج والتسعير | 1 | جديد | ويب |
| S49 | الماركات والتصنيفات وأنواع المنتجات | MANAGER وPURCHASER وWAREHOUSE (masterdata.manage) | الكتالوج والتسعير | 1 | جديد | ويب |
| S50 | وحدات القياس | MANAGER وPURCHASER وWAREHOUSE (masterdata.manage) | الكتالوج والتسعير | 1 | جديد | ويب |
| S51 | إكمال وصف المنتج (الجداول الوصفية) | MANAGER وPURCHASER وWAREHOUSE (catalog.manage) | الكتالوج والتسعير | 2 | جديد | ويب |
| S52 | إدارة الجداول المرجعية الوصفية | MANAGER وPURCHASER وWAREHOUSE (masterdata.manage) | الكتالوج والتسعير | 2 | جديد | ويب |
| S53 | الخصائص الديناميكية للمنتج | MANAGER وPURCHASER وWAREHOUSE (masterdata.manage لتعريف الخصائص، catalog.manage لتعبئتها) | الكتالوج والتسعير | 2 | جديد | ويب |
| S54 | نشر المنتج وأرشفته وإيقاف المتغير | MANAGER وPURCHASER وWAREHOUSE (catalog.manage) | الكتالوج والتسعير | 2 | جديد | ويب |
| S55 | صور المنتج والألوان | MANAGER وPURCHASER وWAREHOUSE (catalog.manage) | الكتالوج والتسعير | 2 | جديد | ويب وموبايل (الكاميرا) |
| S56 | الباركود: إدخال يدوي وتوليد داخلي وطباعة الملصقات | MANAGER وPURCHASER وWAREHOUSE (catalog.manage) | الكتالوج والتسعير | 2 | جديد | ويب (الطباعة على Windows) |
| S57 | قواعد التسعير (Markup / Margin) | MANAGER (pricing.manage) | الكتالوج والتسعير | 1 | جديد | ويب |
| S12 | إدارة الزبائن | MANAGER وACCOUNTANT وPURCHASER (parties.manage) وCASHIER (parties.quick_add: إضافة سريعة) | الأطراف (زبائن وموردون) | 2 | محدَّث | Windows (والموبايل للمسح) |
| S13 | إدارة الموردين | PURCHASER | الأطراف (زبائن وموردون) | 2 | محدَّث | ويب |
| S14 | فتح جلسة صندوق | CASHIER | المبيعات ونقطة البيع | 1 | محدَّث | Windows (والموبايل للمسح) |
| S15 | البحث عن صنف وإضافته للسلة | CASHIER | المبيعات ونقطة البيع | 1 | محدَّث | Windows (والموبايل للمسح) |
| S16 | إتمام البيع (دفع نقدي/متعدد) | CASHIER | المبيعات ونقطة البيع | 1 | محدَّث | Windows (والموبايل للمسح) |
| S17 | بيع آجل أو بدفعة جزئية | CASHIER وMANAGER | المبيعات ونقطة البيع | 2 | محدَّث | Windows (والموبايل للمسح) |
| S18 | إغلاق جلسة الصندوق والجرد النقدي | CASHIER أو MANAGER (أيهما) | المبيعات ونقطة البيع | 1 | محدَّث | Windows (والموبايل للمسح) |
| S19 | مرتجع مبيعات | CASHIER وMANAGER | المبيعات ونقطة البيع | 1 | محدَّث | Windows (والموبايل للمسح) |
| S20 | إدارة الفواتير المعلّقة والمسودات | CASHIER وMANAGER | المبيعات ونقطة البيع | 2 | محدَّث | Windows (والموبايل للمسح) |
| S64 | اختيار قائمة الأسعار في نقطة البيع (جملة وتجزئة) | CASHIER وMANAGER | المبيعات ونقطة البيع | 1 | جديد | Windows (والموبايل للمسح) |
| S67 | زبون يطلب صنفاً غير متوفر في فرعي | CASHIER ثم WAREHOUSE وMANAGER | المبيعات ونقطة البيع | 1 | جديد | Windows (والموبايل للمسح) |
| S80 | قائمة المبيعات وإعادة الطباعة والمشاركة | CASHIER وMANAGER | المبيعات ونقطة البيع | 2 | جديد | Windows (والموبايل للمسح) |
| S21 | إنشاء فاتورة شراء (مسودة) | PURCHASER | المشتريات | 1 | محدَّث | ويب |
| S22 | ترحيل فاتورة شراء واستلام البضاعة | PURCHASER (يرحّل بنفسه، قرار-16) | المشتريات | 1 | محدَّث | ويب |
| S23 | مرتجع مشتريات | PURCHASER (purchasing.return) | المشتريات | 2 | كما هو | ويب |
| S24 | ملاحظات المورد | PURCHASER (كتابة) وWAREHOUSE (قراءة فقط) | المشتريات | 3 | محدَّث | ويب |
| S25 | عرض أرصدة المخزون وحركته | WAREHOUSE وMANAGER وAUDITOR (ويطّلع الكاشير والمحاسب والمشتري بحسب inventory.view) | المخزون | 1 | محدَّث | موبايل وويب |
| S26 | إنشاء تحويل مخزون والموافقة عليه | WAREHOUSE (المرسل يوافق، قرار-17) وMANAGER | المخزون | 1 | محدَّث | موبايل وويب |
| S27 | شحن التحويل واستلامه | WAREHOUSE (المرسل يشحن والمستلم يستلم) | المخزون | 2 | محدَّث | موبايل وويب |
| S28 | تسوية الجرد | WAREHOUSE وMANAGER | المخزون | 1 | محدَّث | موبايل وويب |
| S29 | مستويات إعادة الطلب | MANAGER وPURCHASER وWAREHOUSE (catalog.manage) | المخزون | 3 | محدَّث | ويب |
| S66 | الاطلاع على مخزون الفروع الأخرى | CASHIER وMANAGER وWAREHOUSE وPURCHASER (inventory.view_other_branches) | المخزون | 1 | جديد | موبايل وويب |
| S71 | معالجة المخزون التالف | WAREHOUSE وMANAGER (inventory.adjust وinventory.transfer) | المخزون | 2 | جديد | موبايل وويب |
| S30 | سند قبض من زبون وتخصيصه | ACCOUNTANT وCASHIER وMANAGER (finance.payments) | المالية | 1 | محدَّث | ويب |
| S31 | سند دفع لمورد | ACCOUNTANT وPURCHASER (finance.payments، قرار-16) | المالية | 1 | محدَّث | ويب |
| S32 | تسجيل مصروف | ACCOUNTANT (ينشئ ويرحّل) وCASHIER (مصروف صغير من الصندوق) | المالية | 1 | محدَّث | ويب |
| S33 | تحويل أموال بين الحسابات | ACCOUNTANT (finance.manage) | المالية | 2 | محدَّث | ويب |
| S34 | كشف حساب طرف وأرصدته | ACCOUNTANT وAUDITOR | المالية | 1 | كما هو | ويب |
| S35 | تسوية رصيد طرف | ACCOUNTANT (balance.adjust) | المالية | 3 | محدَّث | ويب |
| S36 | سحوبات ومساهمات الملاك | ACCOUNTANT (owner.transactions وfinance.payments) | المالية | 3 | محدَّث | ويب |
| S37 | إدارة البنوك والحسابات المالية | ACCOUNTANT (finance.manage) | المالية | 2 | كما هو | ويب |
| S65 | مراجعة المصروفات الصغيرة للكاشير | ACCOUNTANT (accounting.manage) وMANAGER (finance.view وfinance.expenses) | المالية | 2 | جديد | ويب |
| S68 | الأرصدة الافتتاحية وبدء التشغيل | ACCOUNTANT وSUPER_ADMIN (accounting.manage) | المالية | 1 | جديد | ويب |
| S69 | دفعة راتب أو سلفة لموظف | ACCOUNTANT (finance.payments) | المالية | 2 | جديد | ويب |
| S70 | فئات المصروف وأسباب الدفع | ACCOUNTANT (accounting.manage أو finance.manage) | المالية | 2 | جديد | ويب |
| S72 | إدارة الملاك | ACCOUNTANT وSUPER_ADMIN (owner.transactions) | المالية | 2 | جديد | ويب |
| S79 | تطبيق سلفة على فاتورة | ACCOUNTANT وMANAGER وCASHIER وPURCHASER (finance.payments) | المالية | 2 | جديد | ويب |
| S38 | دليل الحسابات المحاسبي | ACCOUNTANT (accounting.manage) | المحاسبة والتقارير والرقابة | 2 | محدَّث | ويب |
| S39 | عرض قيود اليومية وعكسها | ACCOUNTANT وAUDITOR | المحاسبة والتقارير والرقابة | 2 | محدَّث | ويب |
| S40 | إدارة الفترات المحاسبية | ACCOUNTANT (يغلق ويقفل، قرار-20) | المحاسبة والتقارير والرقابة | 2 | محدَّث | ويب |
| S41 | تقارير المبيعات والمخزون | MANAGER وACCOUNTANT وAUDITOR | المحاسبة والتقارير والرقابة | 2 | محدَّث | ويب |
| S45 | تقارير الحسابات والأرصدة | ACCOUNTANT وAUDITOR | المحاسبة والتقارير والرقابة | 2 | كما هو | ويب |
| S42 | سجل التدقيق | AUDITOR وSUPER_ADMIN | المحاسبة والتقارير والرقابة | 1 | محدَّث | ويب |
| S73 | تقرير الربحية وتكلفة البضاعة المباعة | MANAGER وACCOUNTANT وAUDITOR (costs.view) | المحاسبة والتقارير والرقابة | 2 | جديد | ويب |
| S74 | تقارير إدارية إضافية | ACCOUNTANT وMANAGER وSUPER_ADMIN وAUDITOR | المحاسبة والتقارير والرقابة | 3 | جديد | ويب |
| S75 | إقفال السنة المالية وترحيل الأرباح المحتجزة | ACCOUNTANT (accounting.post وaccounting.manage) | المحاسبة والتقارير والرقابة | 3 | جديد | ويب |
| S44 | مركز الإشعارات داخل التطبيق | جميع الأدوار (كل دور يرى ما يعنيه) | الإشعارات | 2 | كما هو | ويب وموبايل وWindows |

# 3\. السيناريوهات

كل سيناريو يتبع القالب ذي الأقسام الثلاثة عشر، ويحمل تحت عنوانه سطر «المنصة الأساسية».

## وحدة 1: الدخول والمستخدمون والصلاحيات

### S01 — تسجيل الدخول وتحميل الصلاحيات

**المنصة الأساسية:** ويب وموبايل وWindows

**1\. رقم واسم السيناريو**

S01 — تسجيل الدخول وتحميل الصلاحيات

**2\. الدور (Actor)**

جميع المستخدمين (SUPER_ADMIN MANAGER CASHIER WAREHOUSE ACCOUNTANT PURCHASER AUDITOR)

**3\. الهدف**

الدخول إلى النظام، وتحميل الأدوار والفروع المسموحة، واختيار الفرع الذي سيعمل عليه المستخدم في هذه الجلسة.

**4\. الشروط المسبقة (Preconditions)**

- الحساب موجود في users وis_active = true (أنشأه المدير عبر admin_provision_user؛ لا تسجيل ذاتي).
- للمستخدم غير SUPER_ADMIN صف واحد على الأقل في user_branch_access.
- الدخول من الواجهة مباشرة عبر Supabase Auth: يولّد التطبيق إيميلاً داخلياً مخفياً من اسم المستخدم (مثل username@store.local) ما لم يكن للمستخدم إيميل معتمد. الدخول مباشر بلا Edge Function (قرار-37).

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| users | id, username, email, is_active, must_change_password |
| user_roles | user_id, role_id |
| user_branch_access | user_id, branch_id, can_view, can_operate |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يدخل اسم المستخدم وكلمة المرور | شاشة تسجيل الدخول | حقل المستخدم، حقل كلمة المرور، زر «دخول» | Supabase Auth (signInWithPassword) ثم SELECT | users.username, users.email (الإيميل الداخلي المولَّد من الاسم مرتبط بـ auth.users) |
| 2 | النظام يفحص حالة الحساب | شاشة تسجيل الدخول (حالة انتظار) | مؤشر تحميل على الزر | SELECT | users.is_active |
| 3 | يُحمَّل الأدوار والفروع | شاشة التحميل | مؤشر تقدم | RPC get_my_access() (تُرجع الأدوار والصلاحيات والفروع والمستودعات ونقاط البيع) | user_roles.role_id, user_branch_access.branch_id, can_view, can_operate |
| 4 | إن كانت must_change_password = true يغيّر كلمة المرور (قبل اختيار الفرع) | شاشة تغيير كلمة المرور | حقل كلمة جديدة، تأكيدها، زر حفظ | Supabase Auth (تحديث كلمة المرور) ثم RPC complete_password_change() | users.must_change_password (يُصفَّر عبر الدالة SECURITY DEFINER) |
| 5 | يختار الفرع (في كل مرة دخول) | شاشة اختيار الفرع | قائمة بطاقات الفروع (الاسم + شارة «عرض فقط» إن can_operate = false)، زر «متابعة» | SELECT (ضمن نتيجة الدالة) | user_branch_access.branch_id |
| 6 | يدخل إلى لوحة التحكم | لوحة التحكم | قائمة جانبية مبنية على الصلاحيات | — | — |

**7\. المسارات البديلة (Alternative Flows)**

- كلمة مرور خاطئة: رسالة عامة دون كشف السبب.
- مستخدم له فرع واحد: يسجل على الفرع مباشرة.
- مستخدم له عدة فروع (مدير مثلاً): يختار فرعاً في كل دخول ثم يبدّله من الشريط العلوي ← S61.
- تغيير كلمة المرور الإجباري يسبق اختيار الفرع: لا يصل المستخدم بكلمة مؤقتة إلى أي فرع.
- نسيان كلمة المرور: لا يوجد رابط استرجاع؛ تُعرض رسالة «تواصل مع مدير النظام» (قرار-05: المدير يعيد التعيين ← S59).

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| حساب غير نشط | users.is_active = false | حسابك معطّل، تواصل مع المدير |
| لا فروع مسموحة | لا صفوف في user_branch_access (غير SUPER_ADMIN) | لم تُمنح أي فرع، تواصل مع المدير |
| كلمة مرور خاطئة | رفض Supabase Auth | اسم المستخدم أو كلمة المرور غير صحيحة |

**9\. الصلاحيات (RLS)**

- users وuser_roles: القراءة تتطلب users.manage فلا يقرؤهما المستخدم العادي مباشرة؛ لذلك يُحمَّل كل شيء عبر get_my_access() (SECURITY DEFINER).
- user_branch_access: سياسة القراءة مبنية على auth.uid() فيرى المستخدم صفوفه فقط.
- get_my_access() لا تُرجع إلا بيانات المستخدم نفسه، وتتضمن المستودعات المسموحة (can_access_warehouse) ونقاط البيع المعيّنة له.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | مؤشر على زر الدخول ثم شاشة تحميل الصلاحيات. |
| فارغ | لا فروع مسموحة (رسالة وزر خروج). |
| خطأ | رسالة تحت الحقول دون كشف أي الحقلين خاطئ. |
| نجاح | الانتقال للوحة التحكم مع اسم الفرع في الشريط العلوي. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- جلسة صالحة وفرع نشط محدد.
- must_change_password مصفَّر إن كان المستخدم قد غيّر كلمته المؤقتة.

**12\. معايير القبول (Acceptance Criteria)**

- S01-AC1: عندما يدخل مستخدم بيانات صحيحة وحسابه نشط فإن تظهر له شاشة اختيار الفرع بفروعه المسموحة فقط.
- S01-AC2: عندما يكون must_change_password = true فإن لا يصل لشاشة اختيار الفرع ولا للوحة التحكم قبل تغيير كلمة المرور.
- S01-AC3: عندما يكون الحساب غير نشط (is_active = false) فإن يُمنع من متابعة العمل وتظهر رسالة التعطيل.

**13\. ملاحظات للمصمم**

- أبرز اسم الفرع دائماً في الشريط العلوي مع زر «تبديل الفرع».
- شارة «عرض فقط» ضرورية لأن can_operate = false يمنع الكتابة.
- لا تضع رابط «نسيت كلمة المرور».
- ولّد الإيميل الداخلي من اسم المستخدم دون عرضه للمستخدم.

### S02 — إنشاء مستخدم وتعيين دوره وفروعه

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S02 — إنشاء مستخدم وتعيين دوره وفروعه

**2\. الدور (Actor)**

SUPER_ADMIN

**3\. الهدف**

تجهيز موظف جديد بحساب دخول (اسم مستخدم وكلمة مؤقتة) ودور وفروع ونقاط بيع.

**4\. الشروط المسبقة (Preconditions)**

- المنفّذ يملك users.manage (SUPER_ADMIN فقط؛ المدير لا يملكها).
- الموظف يُنشأ ضمن العملية (طرف ثم موظف ثم مستخدم)، أو يُربط بطرف موجود كمالك يعمل بالنظام ← S60.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| users | id, employee_id, username, email, is_active, must_change_password |
| employees | party_id, employee_code, job_title, branch_id, hire_date, is_active |
| user_roles | user_id, role_id, assigned_by, assigned_at |
| user_branch_access | user_id, branch_id, can_view, can_operate |
| user_price_lists | user_id, price_list_id, is_default (تُسنَد القائمة الافتراضية تلقائياً) |
| user_pos_terminals | user_id, pos_terminal_id, is_default (من S05) |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح قائمة المستخدمين ويضغط «مستخدم جديد» | قائمة المستخدمين | جدول (الاسم، الدور، الفروع، الحالة)، بحث، زر «مستخدم جديد» | SELECT | users.username, users.is_active, employees.job_title |
| 2 | يعبّئ بيانات الحساب | نموذج مستخدم جديد | اسم المستخدم (يتحول لإيميل داخلي مخفي)، الإيميل الحقيقي (اختياري)، الاسم الكامل، الهاتف (للتواصل فقط، لا للدخول)، المسمى الوظيفي، الفرع الرئيسي، كلمة مؤقتة (التغيير الإجباري عند أول دخول دائماً) | — | users.username, users.email, employees.job_title, employees.branch_id |
| 3 | يختار الأدوار | نموذج مستخدم جديد (قسم الأدوار) | مربعات اختيار متعددة للأدوار (من roles الفعّالة) | SELECT | roles.code, roles.name |
| 4 | يحدد الفروع وصلاحية كل فرع | نموذج مستخدم جديد (قسم الفروع) | صف لكل فرع بمفتاحي «يعرض» و«ينفّذ» (فرع واحد على الأقل لغير SUPER_ADMIN) | SELECT | user_branch_access.can_view, can_operate |
| 5 | يحفظ | نموذج مستخدم جديد | زر «حفظ وإنشاء» | Edge Function provision-user (تقبل branches وتنشئ مستخدم Auth بإيميل داخلي وكلمة مؤقتة) ثم RPC admin_provision_user(..., p_branches jsonb) | users, employees, user_roles, user_branch_access, user_price_lists |
| 6 | يعطي كلمة المرور المؤقتة للموظف | شاشة تأكيد الإنشاء | كلمة مؤقتة قابلة للنسخ تظهر مرة واحدة | — | — |
| 7 | يربط نقاط البيع (اختياري) | شاشة تأكيد الإنشاء | زر «ربط بنقاط بيع» | INSERT (S05) | user_pos_terminals.user_id, pos_terminal_id |

**7\. المسارات البديلة (Alternative Flows)**

- تعديل مستخدم قائم: تغيير الأدوار أو الفروع أو is_active.
- إعادة تعيين كلمة المرور (الاسترجاع الوحيد) ← S59.
- تعطيل مستخدم بدل حذفه (is_active = false).
- تعدد الأدوار مدعوم (مثل مدير ومحاسب)؛ والمدير لا يحتاج دوراً ثانياً ليبيع، يكفيه can_operate وربطه بنقطة بيع (قرار-40).
- طرف موجود (مالك يعمل بالنظام): يُمرَّر p_party_id فلا يُنشأ طرف جديد ← S60.
- صيغة p_branches: [{"branch_id":1,"can_view":true,"can_operate":true}, ...]؛ ويُقبل رقم مجرد (= عرض وتشغيل)، وغياب can_operate يساوي can_view.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| اسم مستخدم مكرر | UNIQUE على users.username | اسم المستخدم مستخدم مسبقاً |
| إنشاء دور نظام بدون صلاحية | ERP16 PERMISSION_DENIED | إنشاء أدوار النظام لمدير النظام فقط |
| بلا دور | ERP22 INVALID_STATE من admin_provision_user | يجب تحديد دور واحد على الأقل |
| موظف بلا طرف | NOT NULL على employees.party_id | بيانات الموظف ناقصة |
| بلا فرع (لغير SUPER_ADMIN) | ERP22 INVALID_STATE من admin_provision_user | يجب تحديد فرع واحد على الأقل |
| فرع مكرر أو غير موجود أو غير فعّال | ERP22 INVALID_STATE | الفرع المحدد مكرر أو غير موجود أو غير فعّال |
| تشغيل بلا عرض (can_operate = true مع can_view = false) | ERP22 INVALID_STATE | لا يُمنح التشغيل على فرع دون العرض |
| طرف مرتبط بحساب مسبقاً | ERP22 | هذا الطرف مرتبط بحساب مستخدم مسبقاً |
| دور غير موجود أو معطّل | ERP22 | الدور \[الرمز\] غير موجود أو معطّل |

**9\. الصلاحيات (RLS)**

- users وuser_roles وuser_branch_access وuser_price_lists: كل العمليات تتطلب users.manage.
- admin_provision_user دالة SECURITY DEFINER تتحقق من users.manage ولا تعمل إلا لمستخدم Auth موجود (تُنشئه provision-user أولاً).
- employees: الكتابة hr.manage (المدير وSUPER_ADMIN) والقراءة hr.view؛ التنفيذ عبر الدالة وليس مباشرة.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل (skeleton) للجدول. |
| فارغ | «لا مستخدمين» مع زر الإنشاء. |
| خطأ | رسالة تحت الحقل المخالف. |
| نجاح | شاشة تأكيد بكلمة مؤقتة. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- حساب نشط بدور وفروع، وmust_change_password = true.
- قائمة الأسعار الافتراضية العامة مُسنَدة للمستخدم تلقائياً كي لا يُحجب عن البيع.
- سجل CREATE في audit_logs.

**12\. معايير القبول (Acceptance Criteria)**

- S02-AC1: عندما يحفظ المدير نموذجاً صحيحاً فإن ينشأ المستخدم بأدواره وفروعه دفعة واحدة.
- S02-AC2: عندما يتكرر username فإن لا يُنشأ شيء وتظهر رسالة على الحقل.
- S02-AC3: عندما يفتح مستخدم بلا users.manage الشاشة فإن لا تظهر له في القائمة.
- S02-AC4: عندما يُنشأ مستخدم جديد فإن تُسنَد له قائمة الأسعار الافتراضية تلقائياً ويُلزَم بتغيير كلمة المرور عند أول دخول.
- S02-AC5: عندما يُحفظ مستخدم غير SUPER_ADMIN بلا فرع فإن يُرفض بـ ERP22 «يجب تحديد فرع واحد على الأقل».
- S02-AC6: عندما تتكرر الفروع أو يكون فرع غير موجود أو غير فعّال أو يُمنح التشغيل بلا عرض فإن يُرفض الإنشاء بـ ERP22.
- S02-AC7: عندما يُحدَّد لفرع «يعرض» دون «ينفّذ» فإن يقرأ المستخدم بيانات الفرع ولا ينفّذ عليه.

**13\. ملاحظات للمصمم**

- اجمع الأدوار والفروع في شاشة واحدة بخطوات ظاهرة.
- اعرض ملخصاً قبل الحفظ.
- كلمة المرور المؤقتة تظهر مرة واحدة فقط.
- لكل فرع صف بمفتاحي «يعرض» و«ينفّذ»؛ لا يُفعَّل «ينفّذ» دون «يعرض»، ويلزم فرع واحد على الأقل لغير SUPER_ADMIN.

### S03 — إدارة الأدوار وصلاحياتها

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S03 — إدارة الأدوار وصلاحياتها

**2\. الدور (Actor)**

SUPER_ADMIN

**3\. الهدف**

تحديد ما يستطيع كل دور فعله بربطه بأكواد الصلاحيات.

**4\. الشروط المسبقة (Preconditions)**

- المنفّذ يملك users.manage.
- permissions معبّأ (45 صلاحية في 15 وحدة) وrole_permissions مبذور (150 ربطاً) بحسب القرارات؛ القاموس في الملحق ز.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| roles | code, name, description, is_system_role, is_active |
| permissions | code, name, module, description |
| role_permissions | role_id, permission_id |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح قائمة الأدوار | قائمة الأدوار | بطاقات الأدوار مع شارة «دور نظام»، زر «دور جديد» | SELECT | roles.code, roles.name, roles.is_system_role |
| 2 | يختار دوراً | تفاصيل الدور | الاسم، الوصف، مفتاح «فعّال» | SELECT | roles.name, roles.description, roles.is_active |
| 3 | يعدّل الصلاحيات | مصفوفة الصلاحيات | قائمة مجمّعة حسب permissions.module بمربعات اختيار | SELECT / INSERT / DELETE | permissions.code, permissions.module, role_permissions.role_id, permission_id |
| 4 | يحفظ | مصفوفة الصلاحيات | زر «حفظ التغييرات» مع عدّاد التغييرات | INSERT / DELETE | role_permissions |

**7\. المسارات البديلة (Alternative Flows)**

- إنشاء دور مخصص جديد.
- تعطيل دور بدل حذفه (أدوار النظام لا تُحذف).
- نسخ صلاحيات دور إلى دور جديد: عملية واجهة فقط.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| حذف دور نظام | ERP01 DOC_LOCKED | أدوار النظام لا تُحذف (يمكن تعطيلها) |
| تعديل بلا صلاحية | ERP16 PERMISSION_DENIED | لا تملك صلاحية تعديل الأدوار |
| كود دور مكرر | UNIQUE على roles.code | رمز الدور مستخدم مسبقاً |

**9\. الصلاحيات (RLS)**

- roles: القراءة مفتوحة، والكتابة تتطلب users.manage.
- role_permissions تُحرَس بـ role_permissions_guard (trigger).

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل للمصفوفة. |
| فارغ | «لا أدوار». |
| خطأ | شريط أحمر أعلى المصفوفة. |
| نجاح | إشعار «تم الحفظ» وتحديث العدّاد. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- ارتباط الدور بالصلاحيات محدّث.
- تُطبَّق التغييرات في الدخول التالي لحاملي الدور.

**12\. معايير القبول (Acceptance Criteria)**

- S03-AC1: عندما يحدد المدير صلاحية لدور ويحفظ فإن يظهر سطر جديد في role_permissions.
- S03-AC2: عندما يحاول حذف دور نظام فإن يُرفض بالرسالة الصادرة من ERP01.

**13\. ملاحظات للمصمم**

- اعرض الأدوار السبعة الأساسية كأدوار نظام.
- المصفوفة: الوحدات صفوف والصلاحيات أعمدة مع بحث.
- تغيير الصلاحيات يؤثر عند الدخول التالي لحاملي الدور؛ ارجع إلى الملحق ز لمعرفة ما تحرسه كل صلاحية.

### S59 — إعادة تعيين كلمة المرور وتعطيل الحساب

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S59 — إعادة تعيين كلمة المرور وتعطيل الحساب

**2\. الدور (Actor)**

SUPER_ADMIN (users.manage)

**3\. الهدف**

إعطاء المستخدم كلمة مؤقتة جديدة وإلزامه بتغييرها، أو تعطيل حسابه.

**4\. الشروط المسبقة (Preconditions)**

- المنفّذ يملك users.manage.
- لا رابط «نسيت كلمة المرور» (قرار-05).

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| users | id, username, is_active, must_change_password |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح المستخدم | تفاصيل المستخدم | بطاقة المستخدم وأزرار الإجراءات | SELECT | users.username, is_active |
| 2 | يضغط «إعادة تعيين كلمة المرور» | نافذة إعادة التعيين | تأكيد | Edge Function reset-password | users.must_change_password = true |
| 3 | يعطي الكلمة المؤقتة | نافذة إعادة التعيين | كلمة مؤقتة قابلة للنسخ تظهر مرة واحدة | — | — |
| 4 | يعطّل أو يفعّل الحساب | تفاصيل المستخدم | مفتاح «فعّال» بتأكيد | UPDATE | users.is_active |

**7\. المسارات البديلة (Alternative Flows)**

- المستخدم بعد الدخول يغيّر كلمته فتُصفَّر must_change_password عبر complete_password_change().
- تعطيل بدل حذف.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| بلا صلاحية | ERP16 PERMISSION_DENIED | لا تملك صلاحية إدارة المستخدمين |

**9\. الصلاحيات (RLS)**

- users: الكتابة users.manage.
- reset-password تتطلب users.manage.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | — |
| خطأ | على الحقل. |
| نجاح | تظهر الكلمة المؤقتة مرة واحدة. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- كلمة مؤقتة جديدة وmust_change_password = true.

**12\. معايير القبول (Acceptance Criteria)**

- S59-AC1: عندما تُعاد التعيين فإن لا يصل المستخدم للوحة قبل تغيير كلمته.

**13\. ملاحظات للمصمم**

- اعرض الكلمة مرة واحدة فقط مع زر نسخ.

### S60 — ربط مالك أو طرف قائم بحساب دخول

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S60 — ربط مالك أو طرف قائم بحساب دخول

**2\. الدور (Actor)**

SUPER_ADMIN (users.manage)

**3\. الهدف**

منح مالك يعمل بالنظام (أو طرف موجود) حساب دخول على الطرف نفسه دون تكرار.

**4\. الشروط المسبقة (Preconditions)**

- الطرف موجود في parties (ومالك في owners إن كان مالكاً).
- المنفّذ يملك users.manage.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| owners | party_id, ownership_percentage, is_active |
| parties | name, party_type |
| employees | party_id, job_title, branch_id |
| users | employee_id, username |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح الملاك أو الأطراف | قائمة الملاك | زر «منح حساب» بجانب المالك | SELECT | owners.party_id, parties.name |
| 2 | يعبّئ بيانات الحساب | نموذج مستخدم جديد | الدور (MANAGER أو SUPER_ADMIN)، الفروع (صف لكل فرع بمفتاحي «يعرض» و«ينفّذ»)، الكلمة المؤقتة | — | — |
| 3 | يحفظ | نموذج مستخدم جديد | زر «إنشاء» | RPC admin_provision_user(..., p_party_id, p_branches) | employees (يُنشأ إن غاب), users, user_roles |

**7\. المسارات البديلة (Alternative Flows)**

- مالك لا يعمل بالنظام: سجل owners فقط بلا حساب.
- مالك يدير: موظف بدور MANAGER أو SUPER_ADMIN مع سجل owners على نفس الـ party.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| طرف مرتبط بحساب مسبقاً | ERP22 | هذا الطرف مرتبط بحساب مستخدم مسبقاً |
| طرف غير موجود | ERP22 | الطرف المحدد غير موجود |
| بلا فرع (لغير SUPER_ADMIN) | ERP22 | يجب تحديد فرع واحد على الأقل |

**9\. الصلاحيات (RLS)**

- users.manage لإنشاء الحساب؛ owners تُكتب بـ owner.transactions.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | — |
| خطأ | على الحقل. |
| نجاح | حساب بنفس الطرف. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- حساب مرتبط بالطرف نفسه (owners وemployees وusers).

**12\. معايير القبول (Acceptance Criteria)**

- S60-AC1: عندما يُمرَّر طرف موجود فإن لا يُنشأ طرف جديد.

**13\. ملاحظات للمصمم**

- اعرض شارة «له حساب» في قائمة الملاك.

### S61 — تبديل الفرع وتقارير كل الفروع

**المنصة الأساسية:** ويب وموبايل وWindows

**1\. رقم واسم السيناريو**

S61 — تبديل الفرع وتقارير كل الفروع

**2\. الدور (Actor)**

جميع المستخدمين متعددي الفروع (المدير غالباً)

**3\. الهدف**

تبديل الفرع الفعّال في العمليات، وعرض التقارير على كل الفروع المسموحة مع مرشح.

**4\. الشروط المسبقة (Preconditions)**

- للمستخدم أكثر من صف في user_branch_access.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| user_branch_access | user_id, branch_id, can_view, can_operate |
| branches | code, name, is_active |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يضغط «تبديل الفرع» | الشريط العلوي | قائمة الفروع المسموحة مع شارة «عرض فقط» | SELECT (get_my_access) | user_branch_access.branch_id, can_operate |
| 2 | يختار فرعاً | الشريط العلوي | اختيار فرع | — | — |
| 3 | يفتح تقريراً | شاشة التقارير | مرشح الفروع: كل الفروع افتراضياً | SELECT | v_sales_daily.branch_id وغيرها |

**7\. المسارات البديلة (Alternative Flows)**

- العمليات (بيع، شراء، تحويل) تُنفَّذ بالفرع المحدد؛ والتقارير على كل الفروع المسموحة افتراضياً مع مرشح.
- فرع بـ can_operate = false: عرض فقط.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| كتابة على فرع عرض فقط | ERP16 | لا تملك صلاحية تشغيل على هذا الفرع |

**9\. الصلاحيات (RLS)**

- can_access_branch(branch, operate) تحكم القراءة والكتابة؛ SUPER_ADMIN يتجاوز.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا فروع مسموحة». |
| خطأ | على الحقل. |
| نجاح | الفرع الجديد يظهر في الشريط. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- فرع فعّال جديد في الجلسة.

**12\. معايير القبول (Acceptance Criteria)**

- S61-AC1: عندما يبدّل فرعاً فإن تُنفَّذ العمليات التالية بالفرع الجديد.

**13\. ملاحظات للمصمم**

- أبرز اسم الفرع دائماً؛ نبّه عند التبديل بسلة مفتوحة.

### S62 — إدارة الموظفين

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S62 — إدارة الموظفين

**2\. الدور (Actor)**

MANAGER وSUPER_ADMIN (hr.manage) والاطلاع للمحاسب والمدقق (hr.view)

**3\. الهدف**

إضافة الموظفين وتعديل بياناتهم الوظيفية.

**4\. الشروط المسبقة (Preconditions)**

- المنفّذ يملك hr.manage للكتابة أو hr.view للقراءة.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| employees | party_id, employee_code, job_title, branch_id, hire_date, is_active |
| parties | name, phone, email |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح الموظفين | قائمة الموظفين | جدول، بحث، «موظف جديد» | SELECT | employees.employee_code, job_title, branch_id |
| 2 | يضيف موظفاً | نموذج موظف | الاسم، الهاتف، المسمى، الفرع، تاريخ التعيين | INSERT | parties; employees |
| 3 | يعطّل موظفاً | قائمة الموظفين | مفتاح «فعّال» | UPDATE | employees.is_active |
| 4 | يمنحه حساب دخول (اختياري، لمن يملك users.manage وهو SUPER_ADMIN فقط) | ← | S02 أو S60 | — | — |

**7\. المسارات البديلة (Alternative Flows)**

- راتب أو سلفة ← S69.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| بلا صلاحية | ERP16 | لا تملك صلاحية إدارة الموظفين |

**9\. الصلاحيات (RLS)**

- employees: القراءة hr.view والكتابة hr.manage (المدير وSUPER_ADMIN)؛ والمدير لا يملك users.manage فلا يمنح حسابات.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا موظفين». |
| خطأ | على الحقل. |
| نجاح | الموظف يظهر في القائمة. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- موظف فعّال.

**12\. معايير القبول (Acceptance Criteria)**

- S62-AC1: عندما يملك المحاسب أو المدقق hr.view فإن يرى الموظفين ولا يعدّلهم.
- S62-AC2: عندما يملك المدير hr.manage فإن يضيف الموظفين ويعدّلهم ويعطّلهم، ولا يمنحهم حسابات دخول.

**13\. ملاحظات للمصمم**

- القراءة فقط للمحاسب والمدقق؛ والمدير يكتب لكنه لا يمنح حسابات دخول.

### S81 — لوحة التحكم حسب الدور

**المنصة الأساسية:** ويب وموبايل وWindows

**1\. رقم واسم السيناريو**

S81 — لوحة التحكم حسب الدور

**2\. الدور (Actor)**

جميع المستخدمين (SUPER_ADMIN MANAGER CASHIER WAREHOUSE ACCOUNTANT PURCHASER AUDITOR)

**3\. الهدف**

شاشة البداية بعد الدخول واختيار الفرع، تعرض ما يعني الدور من مؤشرات وإجراءات سريعة بحسب الصلاحيات.

**4\. الشروط المسبقة (Preconditions)**

- دخول ناجح وفرع محدد (S01).
- الصلاحيات محمَّلة عبر get_my_access().

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| v_sales_daily (View) | sale_day, branch_id, invoices_count, total_amount |
| v_low_stock (View) | warehouse_id, variant_id, quantity_on_hand, min_quantity |
| v_pos_session_summary (View) | pos_session_id, cashier_username, status, invoices_count |
| v_financial_account_balances / v_open_documents (Views) | balance, remaining_amount, days_overdue |
| stock_transfers | status, from_warehouse_id, to_warehouse_id |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يدخل بعد اختيار الفرع | لوحة التحكم | بطاقات المؤشرات بحسب الصلاحيات، وأزرار الإجراءات السريعة | SELECT (Views بحسب الدور) | الـ Views أعلاه |
| 2 | يضغط بطاقة | لوحة التحكم | ينتقل إلى الشاشة المعنية (S25 وS26 وS30 وS41 وغيرها) | — | — |

**7\. المسارات البديلة (Alternative Flows)**

- الكاشير: بدء أو متابعة الوردية (S14)، مبيعات جلسته، الفواتير المعلّقة (S20).
- المدير: مبيعات اليوم، المخزون المنخفض، التحويلات بانتظار الموافقة، الجلسات المفتوحة.
- أمين المستودع: الواردات بالطريق، التحويلات بانتظار الموافقة، المخزون المنخفض، مخزون التالف (S71).
- المحاسب: أرصدة الحسابات المالية، المستندات المتأخرة، مصروفات الكاشير للمراجعة (S65)، الفترات المفتوحة.
- المشتري: فواتير الشراء المستحقة، المخزون المنخفض، المسودات.
- المدقق: آخر سجلات التدقيق وملخصات القراءة فقط.
- مدير النظام: المستخدمون والإعدادات وحالة الجاهزية للتشغيل (S68).
- تُبنى بطاقات كل دور من الصلاحيات الممنوحة له في get_my_access().

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| فشل تحميل بطاقة | انقطاع الاتصال | تعذر تحميل هذه البطاقة |

**9\. الصلاحيات (RLS)**

- كل بطاقة تخضع لسياسة جدولها أو الـ View الخاصة بها، فلا تظهر لمن لا يملك الصلاحية.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل لكل بطاقة بشكل مستقل. |
| فارغ | «لا بيانات» داخل البطاقة. |
| خطأ | رسالة صغيرة مع إعادة محاولة. |
| نجاح | البطاقات تظهر بحسب الدور. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- لا تغيّر (قراءة).

**12\. معايير القبول (Acceptance Criteria)**

- S81-AC1: عندما يدخل كاشير فإن تظهر له بطاقة الوردية ولا تظهر بطاقات المحاسبة.
- S81-AC2: عندما لا يملك المستخدم صلاحية قراءة مؤشر فإن لا تظهر بطاقته.

**13\. ملاحظات للمصمم**

- اجعل لوحة الكاشير على Windows ملاصقة لشاشة البيع.
- لا تضع أعمدة التكلفة في أي بطاقة لمن لا يملك costs.view.

### S82 — تغيير كلمة المرور الاختياري وتسجيل الخروج

**المنصة الأساسية:** ويب وموبايل وWindows

**1\. رقم واسم السيناريو**

S82 — تغيير كلمة المرور الاختياري وتسجيل الخروج

**2\. الدور (Actor)**

جميع المستخدمين

**3\. الهدف**

تغيير المستخدم كلمة مروره بنفسه في أي وقت (بخلاف التغيير الإجباري في S01)، وإنهاء جلسته بتسجيل الخروج.

**4\. الشروط المسبقة (Preconditions)**

- جلسة دخول صالحة.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| users | username, must_change_password, is_active |
| auth.users (Supabase Auth) | كلمة المرور والجلسات (خارج schema public) |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح الإعدادات الشخصية | الإعدادات الشخصية | قسم «الحساب» وزر «تغيير كلمة المرور» | — | — |
| 2 | يدخل كلمة المرور الحالية والجديدة وتأكيدها | شاشة تغيير كلمة المرور | ثلاثة حقول وزر حفظ | Supabase Auth (تحديث كلمة المرور) | auth (لا أعمدة في public) |
| 3 | يسجّل الخروج | قائمة المستخدم | زر «تسجيل الخروج» بتأكيد | Supabase Auth (signOut) | — |

**7\. المسارات البديلة (Alternative Flows)**

- التغيير الإجباري عند أول دخول أو بعد إعادة التعيين ← S01 وS59 (must_change_password عبر complete_password_change()).
- مدير النظام يعيد التعيين لمن نسي كلمته ← S59؛ لا رابط «نسيت كلمة المرور» (قرار-05).
- تسجيل الخروج يخص الجهاز الحالي فقط، بلا خروج تلقائي بعد خمول.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| كلمة حالية خاطئة | رفض Supabase Auth | كلمة المرور الحالية غير صحيحة |
| كلمة جديدة ضعيفة | سياسة Auth (حماية كلمات المرور المسرَّبة تُفعَّل من لوحة Supabase Auth، قائمة التشغيل) | كلمة المرور لا تستوفي الشروط |
| تأكيد لا يطابق | تحقق واجهة | التأكيد لا يطابق كلمة المرور الجديدة |

**9\. الصلاحيات (RLS)**

- التغيير والخروج عبر Supabase Auth للمستخدم نفسه؛ لا صلاحية خاصة.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | مؤشر على زر الحفظ. |
| فارغ | — |
| خطأ | تحت الحقل المخالف. |
| نجاح | إشعار «تم التغيير». |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- كلمة مرور جديدة سارية، أو جلسة منتهية وعودة لشاشة الدخول.
- تغيير كلمة المرور والخروج يجريان عبر Supabase Auth ولا يُدوَّنان في audit_logs.

**12\. معايير القبول (Acceptance Criteria)**

- S82-AC1: عندما يغيّر المستخدم كلمته بحقول صحيحة فإن تُقبل في الدخول التالي.
- S82-AC2: عندما يسجّل الخروج فإن تُمسح الجلسة المحلية وتُعرض شاشة الدخول.

**13\. ملاحظات للمصمم**

- ضع «تسجيل الخروج» في الشريط العلوي بتأكيد.
- لا تعرض كلمة المرور بنص صريح؛ زر إظهار اختياري.

## وحدة 2: الهيكل والإعدادات

### S04 — إدارة الفروع والمستودعات

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S04 — إدارة الفروع والمستودعات

**2\. الدور (Actor)**

SUPER_ADMIN (لأن org.manage)

**3\. الهدف**

تعريف فرع ومستودعاته وأنواعها.

**4\. الشروط المسبقة (Preconditions)**

- المنفّذ يملك org.manage.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| branches | code, name, address, phone, is_active |
| warehouses | branch_id, code, name, warehouse_type, is_sellable, is_online_fulfillment, address, is_active |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح قائمة الفروع | قائمة الفروع | جدول الفروع وزر «فرع جديد» | SELECT | branches.code, branches.name, branches.is_active |
| 2 | ينشئ فرعاً | نموذج فرع | الرمز، الاسم، العنوان، الهاتف | INSERT | branches.code, branches.name, branches.address, branches.phone |
| 3 | يضيف مستودعاً للفرع | نموذج مستودع | الاسم، الرمز، قائمة النوع (عام، صالة، مركزي، مرتجعات، تالف)، «قابل للبيع»، «تجهيز طلبات أونلاين» | INSERT | warehouses.branch_id, warehouse_type, is_sellable, is_online_fulfillment |
| 4 | يعطّل فرعاً أو مستودعاً | قائمة الفروع / المستودعات | مفتاح «فعّال» | UPDATE | branches.is_active, warehouses.is_active |

**7\. المسارات البديلة (Alternative Flows)**

- مستودع مركزي بلا فرع (branch_id فارغ): يتطلب warehouse.central.access.
- مستودعا «مرتجعات» و«تالف» يُضبطان is_sellable = false من الواجهة (لا قيد في القاعدة يفرضه).
- لكل فرع مستودع DAMAGED فعّال (WH-DAMAGED للرئيسي وWH2-DAMAGED للفرع الثاني)؛ بدونه يفشل استلام تحويل فيه كمية تالفة إلى ذلك الفرع (ERP22)، ولا يرجع الاستلام إلى مستودع تالف في فرع آخر (قرار-42).

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| رمز مكرر | UNIQUE على code | الرمز مستخدم مسبقاً |
| نوع مستودع غير صالح | CHECK على warehouse_type | اختر نوعاً من القائمة |
| اسم فارغ | NOT NULL على name | الاسم مطلوب |
| فرع بلا مستودع تالف عند استلام تحويل بتالف | ERP22 INVALID_STATE من receive_transfer | لا يوجد مستودع تالف فعّال لاستقبال التالف |

**9\. الصلاحيات (RLS)**

- branches وwarehouses: الكتابة تتطلب org.manage.
- القراءة: can_access_branch للفروع وcan_access_warehouse للمستودعات.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل للقوائم. |
| فارغ | «لا فروع بعد». |
| خطأ | رسالة على الحقل. |
| نجاح | ظهور الفرع في القائمة. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- فرع ومستودع جديدان (فعّالان).

**12\. معايير القبول (Acceptance Criteria)**

- S04-AC1: عندما يُنشأ مستودع بنوع DAMAGED فإن تضبط الواجهة is_sellable = false افتراضياً (القاعدة لا تفرضه).
- S04-AC2: عندما يحاول مستخدم بلا org.manage الكتابة فإن تُرفض العملية.
- S04-AC3: عندما يُنشأ فرع جديد فإن يقترح المعالج إنشاء مستودع DAMAGED له قبل أول استلام تحويل.

**13\. ملاحظات للمصمم**

- اعرض المستودعات متداخلة تحت الفرع.
- لون مختلف لكل نوع مستودع.

### S05 — إعداد نقاط البيع والصناديق

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S05 — إعداد نقاط البيع والصناديق

**2\. الدور (Actor)**

MANAGER (pos.manage) وSUPER_ADMIN

**3\. الهدف**

ربط جهاز البيع بصندوق ومستودع وحساب بنكي افتراضي، وتعيين الكاشير عليه، وتحديد قوائم الأسعار المسموحة له.

**4\. الشروط المسبقة (Preconditions)**

- فرع ومستودع قابل للبيع موجودان.
- المنفّذ يملك pos.manage ويعمل (can_operate) على الفرع.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| pos_terminals | branch_id, name, code, cashbox_id, default_bank_account_id, default_warehouse_id, is_active |
| cashboxes | branch_id, name, code, is_active |
| cashbox_accounts | cashbox_id, currency_id, is_active |
| user_pos_terminals | user_id, pos_terminal_id, is_default |
| pos_terminal_price_lists | pos_terminal_id, price_list_id, is_default |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح نقاط البيع | قائمة نقاط البيع | جدول النقاط وزر «نقطة جديدة» | SELECT | pos_terminals.name, code, is_active |
| 2 | ينشئ صندوقاً | نموذج صندوق | الاسم، الرمز | INSERT | cashboxes.branch_id, name, code |
| 3 | يضيف عملات للصندوق | نموذج صندوق (عملات) | قائمة عملات مع مفتاح تفعيل | INSERT | cashbox_accounts.cashbox_id, currency_id |
| 4 | ينشئ نقطة بيع ويربطها | نموذج نقطة بيع | الاسم، الرمز، الصندوق، المستودع الافتراضي، الحساب البنكي الافتراضي | INSERT | pos_terminals.cashbox_id, default_warehouse_id, default_bank_account_id |
| 5 | يعيّن الكاشير | تعيين المستخدمين | قائمة كاشيرات، مفتاح «الافتراضي» | INSERT | user_pos_terminals.user_id, pos_terminal_id, is_default |
| 6 | يحدد قوائم الأسعار المسموحة للنقطة (اختياري) | تعيين قوائم الأسعار | قائمة قوائم مع مفتاح «الافتراضية» | INSERT / DELETE (S58) | pos_terminal_price_lists.pos_terminal_id, price_list_id, is_default |

**7\. المسارات البديلة (Alternative Flows)**

- كاشير على أكثر من نقطة: نقطة واحدة فقط is_default.
- تعطيل نقطة بيع لا تحتوي جلسة مفتوحة.
- نقطة بلا قوائم مقيِّدة: تُتاح للمستخدم قوائمه كلها؛ ومع قوائم مقيِّدة تُتاح القوائم المشتركة بين قوائم المستخدم وقوائم النقطة (المدير يتجاوز عبر pricing.manage).
- المدير يبيع من نقطة بيع بصلاحياته الحالية بشرط can_operate وربطه بنقطة (user_pos_terminals) بلا دور إضافي.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| مستودع غير قابل للبيع | ERP11 WAREHOUSE_NOT_SELLABLE عند أول بيع | المستودع غير قابل للبيع |
| رمز مكرر | UNIQUE على code | الرمز مستخدم مسبقاً |
| تكرار تعيين كاشير | UNIQUE على (user_id, pos_terminal_id) مع نقطة افتراضية واحدة لكل مستخدم | الكاشير معيّن على هذه النقطة |

**9\. الصلاحيات (RLS)**

- pos_terminals: القراءة (pos.session,pos.manage,sales.create,sales.view,finance.view) والكتابة pos.manage، مع can_access_branch.
- cashboxes وcashbox_accounts: الكتابة finance.manage أو pos.manage.
- user_pos_terminals وpos_terminal_price_lists: الكتابة pos.manage أو users.manage (المستخدم يرى نقاطه عبر get_my_access()).

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا نقاط بيع». |
| خطأ | على الحقل. |
| نجاح | النقطة تظهر نشطة في القائمة. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- نقطة بيع جاهزة لفتح جلسة.

**12\. معايير القبول (Acceptance Criteria)**

- S05-AC1: عندما تُربط نقطة بصندوق فإن تُستخدم عملاته عند فتح الجلسة.
- S05-AC2: عندما يُعيَّن كاشير على نقطة فإن تظهر له عند فتح الجلسة.
- S05-AC3: عندما تُقيَّد نقطة بقوائم أسعار فإن لا يرى الكاشير في البيع إلا القوائم المشتركة مع قوائمه.

**13\. ملاحظات للمصمم**

- معالج من 3 خطوات: صندوق ← نقطة ← كاشيرات.
- اعرض تحذيراً إن لم يكن للمستودع is_sellable.

### S06 — العملات وأسعار الصرف والإعدادات

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S06 — العملات وأسعار الصرف والإعدادات

**2\. الدور (Actor)**

ACCOUNTANT وSUPER_ADMIN

**3\. الهدف**

تحديد العملة الأساسية وأسعار الصرف المعتمدة؛ أما مفاتيح الإعدادات فتفصَّل في S78.

**4\. الشروط المسبقة (Preconditions)**

- المنفّذ يملك fx.rate.manage لأسعار الصرف وsettings.manage للإعدادات.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| currencies | code, name, symbol, decimal_places, is_base, is_active, rounding_increment, rounding_method |
| exchange_rates | from_currency_id, to_currency_id, rate, rate_date, is_approved, source, note |
| settings | scope_type, branch_id, user_id, setting_key, value_text |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح العملات | قائمة العملات | جدول العملات، شارة «أساسية» | SELECT | currencies.code, symbol, is_base, is_active |
| 2 | يضيف سعر صرف | نموذج سعر صرف | من عملة، إلى عملة، السعر، التاريخ، المصدر، ملاحظة | INSERT | exchange_rates.from_currency_id, to_currency_id, rate, rate_date, source |
| 3 | يعتمد السعر أو يوقفه | قائمة أسعار الصرف | مفتاح is_approved | UPDATE | exchange_rates.is_approved |
| 4 | يفتح الإعدادات (التفصيل في S78) | شاشة الإعدادات | قائمة (عام/فرع/مستخدم)، مفتاح، قيمة | UPSERT | settings.scope_type, setting_key, value_text |

**7\. المسارات البديلة (Alternative Flows)**

- السعر اليدوي (source = manual) يتطلب fx.rate.manual وملاحظة غير فارغة؛ أما المصادر الأخرى (system وbank وmarket) فلا تُشترط لها ملاحظة (قرار-49).
- لا يُحذف سعر صرف ولا تُعدَّل قيمته بعد حفظه (ERP06)؛ يُضاف سعر جديد أو يُوقف السعر.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| حذف سعر صرف أو تعديله | ERP06 FX_RATE_IMMUTABLE | أسعار الصرف لا تُحذف ولا تُعدَّل — أضف سعراً جديداً أو أوقف السعر |
| سعر غير موجب | CHECK على rate | السعر يجب أن يكون أكبر من صفر |
| ملاحظة مطلوبة لسعر يدوي فقط | CHECK على note عند source = manual | اكتب سبب السعر اليدوي |

**9\. الصلاحيات (RLS)**

- exchange_rates: القراءة مفتوحة، والكتابة fx.rate.manage أو fx.rate.manual.
- settings: الكتابة settings.manage؛ القراءة: GLOBAL للجميع وBRANCH للفروع المسموحة وUSER لصاحبه.
- تغيّر السعر يُدوَّن عبر audit_rate_change (action RATE_CHANGE).

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا أسعار صرف» مع تنبيه أن البيع بعملة أجنبية سيتعذر. |
| خطأ | على الحقل. |
| نجاح | السعر الجديد يظهر في أعلى القائمة. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- سعر معتمد يُستخدم في المستندات الجديدة.
- سجل RATE_CHANGE في audit_logs (قيد audit_logs_reason_required قائم، والتدقيق يولّد سبباً للمصادر غير اليدوية).

**12\. معايير القبول (Acceptance Criteria)**

- S06-AC1: عندما يُضاف سعر معتمد فإن تستخدمه المستندات بتاريخ بعده.
- S06-AC2: عندما يحاول مستخدم حذف سعر أو تعديله فإن يُعرض خيار الإيقاف بدلاً منه.
- S06-AC3: عندما يُضاف سعر بمصدر غير يدوي فإن يُقبل بلا ملاحظة، وعندما يكون يدوياً بلا ملاحظة فإن يُرفض.

**13\. ملاحظات للمصمم**

- اعرض آخر سعر لكل زوج عملات في أعلى الصفحة.
- مصدر السعر (source) كشارة ملونة.

### S43 — تفضيلات عرض العملة

**المنصة الأساسية:** ويب وموبايل وWindows

**1\. رقم واسم السيناريو**

S43 — تفضيلات عرض العملة

**2\. الدور (Actor)**

جميع المستخدمين (لتفضيلهم الشخصي)

**3\. الهدف**

اختيار العملة الأساسية للعرض والعملة الثانوية وطريقة إظهارها، مع أفضلية عملة المستند: فاتورة الشراء بعملتها أولاً مع مقابلها بالعملة الأساسية، وفاتورة البيع بتفضيل العرض.

**4\. الشروط المسبقة (Preconditions)**

- العملات معرّفة وفعّالة.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| display_preferences | scope_type, branch_id, user_id, primary_currency_id, secondary_currency_id, display_mode, print_mode |
| currencies | code, symbol, is_base, is_active |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح تفضيلات العرض | الإعدادات الشخصية | قسم «عرض المبالغ» | SELECT | display_preferences.primary_currency_id, secondary_currency_id, display_mode |
| 2 | يختار العملة الأساسية والثانوية | الإعدادات الشخصية | قائمتان للعملات | SELECT | currencies.code, symbol |
| 3 | يختار طريقة العرض والطباعة | الإعدادات الشخصية | خيارات: عملة واحدة / مع تلميح / الاثنتان؛ وطباعة مفردة أو مزدوجة | — | display_preferences.display_mode, print_mode |
| 4 | يحفظ | الإعدادات الشخصية | زر حفظ | UPSERT | display_preferences (scope_type = USER) |

**7\. المسارات البديلة (Alternative Flows)**

- المدير يضبط تفضيلاً على مستوى الفرع (BRANCH) أو عام (GLOBAL) (تُكتب بـ settings.manage أو لصاحب التفضيل).
- أفضلية عملة المستند (قرار-03): فاتورة الشراء تُعرض بعملتها أولاً مع مقابلها بالعملة الأساسية؛ وفاتورة البيع تُعرض بتفضيل العرض في الإعدادات.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| عملة غير معرّفة | FK على primary_currency_id | اختر عملة من القائمة |
| عملتان متطابقتان | تحقق واجهة | العملة الثانوية يجب أن تختلف عن الأساسية |

**9\. الصلاحيات (RLS)**

- display_preferences: القراءة والكتابة مرتبطتان بـ auth.uid() ونطاق الفرع، فيدير كل مستخدم تفضيله.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | قيم افتراضية. |
| فارغ | يُستخدم تفضيل الفرع ثم العام. |
| خطأ | رسالة عامة. |
| نجاح | تحديث فوري للمبالغ المعروضة. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- صف تفضيل للمستخدم.

**12\. معايير القبول (Acceptance Criteria)**

- S43-AC1: عندما يختار المستخدم عملتين وعرضاً مزدوجاً فإن تظهر المبالغ بالعملتين.
- S43-AC2: عندما تكون عملة فاتورة الشراء مختلفة عن التفضيل فإن تظهر مبالغها بعملتها أولاً ويظهر مقابلها بالعملة الأساسية؛ ومبالغ فاتورة البيع تتبع تفضيل العرض.

**13\. ملاحظات للمصمم**

- اعرض معاينة فورية لمبلغ نموذجي.
- تُطبَّق نفس المعاينة على الطباعة.

### S58 — ربط المستخدمين ونقاط البيع بقوائم الأسعار

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S58 — ربط المستخدمين ونقاط البيع بقوائم الأسعار

**2\. الدور (Actor)**

SUPER_ADMIN (users.manage) لقوائم المستخدمين، وMANAGER (pos.manage) لقوائم النقاط

**3\. الهدف**

تحديد قوائم الأسعار التي يستطيع كل مستخدم أو نقطة بيع البيع بها (تجزئة، جملة...).

**4\. الشروط المسبقة (Preconditions)**

- قوائم الأسعار موجودة.
- المنفّذ يملك users.manage (للمستخدمين) أو pos.manage (للنقاط).

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| user_price_lists | user_id, price_list_id, is_default |
| pos_terminal_price_lists | pos_terminal_id, price_list_id, is_default |
| price_lists | name, code, currency_id, price_type, is_default |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح ربط القوائم | ربط قوائم الأسعار | تبويبان: المستخدمون، نقاط البيع | SELECT | user_price_lists.user_id, price_list_id; v_user_access |
| 2 | يحدد قوائم المستخدم | ربط قوائم المستخدم | قوائم بمربعات اختيار و«الافتراضية» | INSERT / DELETE | user_price_lists.user_id, price_list_id, is_default |
| 3 | يحدد قوائم النقطة (اختياري) | ربط قوائم النقطة | قوائم بمربعات اختيار و«الافتراضية» | INSERT / DELETE | pos_terminal_price_lists.pos_terminal_id, price_list_id, is_default |
| 4 | يختبر ما يراه الكاشير | معاينة | اختيار مستخدم ونقطة | RPC get_allowed_price_lists(branch, terminal, customer) | — |

**7\. المسارات البديلة (Alternative Flows)**

- قاعدة السماح: المدير (pricing.manage) وSUPER_ADMIN يصلان لكل القوائم؛ غيرهما يحتاج ربطاً، وإن قيّدت النقطة قوائمها فالمسموح التقاطع.
- المستخدم الجديد يُسنَد القائمة الافتراضية تلقائياً (S02).
- الجدولان فارغان حالياً: يُدخلهما المدير قبل التشغيل.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| مستخدم بلا قائمة مسموحة | ERP23 PRICE_LIST_NOT_ALLOWED عند البيع | لا توجد قائمة أسعار مسموحة لك على هذه النقطة. اطلب من المدير ربطك بقائمة أسعار |

**9\. الصلاحيات (RLS)**

- user_price_lists: الكتابة users.manage فقط (المدير لا يملكها)، والقراءة لصاحبها أو users.manage أو pricing.manage.
- pos_terminal_price_lists: الكتابة pos.manage أو users.manage.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا قوائم مربوطة». |
| خطأ | على الحقل. |
| نجاح | الربط يظهر في v_user_access. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- قوائم مسموحة لكل مستخدم ونقطة.

**12\. معايير القبول (Acceptance Criteria)**

- S58-AC1: عندما يُحذف ربط قائمة فإن لا تظهر للكاشير في البيع.

**13\. ملاحظات للمصمم**

- تنبيه: ربط المستخدمين بالقوائم لـ SUPER_ADMIN فقط؛ المدير يربط النقاط.

### S63 — ضبط سقف خصم الكاشير لكل فرع

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S63 — ضبط سقف خصم الكاشير لكل فرع

**2\. الدور (Actor)**

MANAGER (pricing.manage) وSUPER_ADMIN

**3\. الهدف**

تحديد نسبة سقف خصم الكاشير عامة أو لكل فرع، علماً أن ما فوق السقف يُرفض بلا مسار موافقة.

**4\. الشروط المسبقة (Preconditions)**

- المنفّذ يملك pricing.manage ويعمل على الفرع.
- المفتاح DISCOUNT_MAX_PERCENT (القيمة الحالية 10).

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| settings | scope_type, branch_id, setting_key, value_text |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح شاشة سقف الخصم | سقف الخصم | القيمة العامة وجدول الفروع | SELECT | settings.setting_key = DISCOUNT_MAX_PERCENT |
| 2 | يدخل نسبة لفرع أو للعام | سقف الخصم | حقل نسبة (0 إلى 100)، اختيار الفرع | RPC set_discount_cap(branch, percent) | settings.value_text |
| 3 | يزيل سقف فرع | سقف الخصم | زر «استعمال السقف العام» | RPC set_discount_cap(branch, NULL) | settings (حذف صف BRANCH) |

**7\. المسارات البديلة (Alternative Flows)**

- الكاشير يُدخل رقماً أو نسبة وتُحفظ مبلغاً؛ ما زاد عن السقف يُرفض (ERP26) على السطر وعلى الفاتورة.
- من يملك discount.exceptional أو SUPER_ADMIN بلا حدود.
- لا يُحذف السقف العام: يُحدَّد بنسبة.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| نسبة خارج 0–100 | ERP22 INVALID_STATE | نسبة السقف يجب أن تكون بين 0 و100 |
| فرع غير موجود | ERP22 | الفرع غير موجود |
| بلا صلاحية | ERP16 | لا تملك صلاحية إدارة الأسعار |

**9\. الصلاحيات (RLS)**

- set_discount_cap تتطلب pricing.manage وصلاحية الفرع؛ المدير لا يحتاج settings.manage.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | — |
| خطأ | على الحقل. |
| نجاح | السقف الجديد يسري فوراً. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- قيمة DISCOUNT_MAX_PERCENT محدّثة.

**12\. معايير القبول (Acceptance Criteria)**

- S63-AC1: عندما يتجاوز خصم الكاشير السقف فإن يُرفض بـ ERP26.
- S63-AC2: عندما يُحدَّد سقف لفرع فإن يطغى على السقف العام لذلك الفرع.

**13\. ملاحظات للمصمم**

- اعرض السقف الفعلي لكل فرع مع «عام» للفروع بلا قيمة خاصة.

### S77 — ترقيم المستندات التلقائي

**المنصة الأساسية:** النظام (بلا شاشة)

**1\. رقم واسم السيناريو**

S77 — ترقيم المستندات التلقائي

**2\. الدور (Actor)**

النظام (بلا شاشة)

**3\. الهدف**

توليد أرقام الفواتير والسندات تلقائياً ببادئة من رمز الفرع، فلا يتحكم بها المستخدم.

**4\. الشروط المسبقة (Preconditions)**

- الفرع له رمز (code).

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| document_sequences | doc_type, branch_id, fiscal_year, prefix, next_number |
| sales | invoice_number, invoice_code |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | ينشئ مستنداً | أي نموذج مستند | الرقم يظهر بعد الحفظ فقط | RPC next_doc_number (داخلية) | sales.invoice_number |
| 2 | يرى الرقم | تفاصيل المستند | رقم غير قابل للتعديل | SELECT | invoice_number, invoice_code |

**7\. المسارات البديلة (Alternative Flows)**

- الصيغة: رمز الفرع ثم نوع المستند ثم السنة ثم تسلسل (مثل MAIN-SALE-2026-000001).
- الرقم فريد لكل فرع؛ invoice_code عشوائي فريد عالمياً.
- الفواتير الاختبارية القديمة (INV-2026-000X) باقية كما هي.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| رقم مكرر في الفرع | UNIQUE على (branch_id, invoice_number) | تعذّر توليد رقم |

**9\. الصلاحيات (RLS)**

- document_sequences تقني: لا تعامل مباشر للمستخدم.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | — |
| خطأ | على الحقل. |
| نجاح | الرقم يظهر على الإيصال. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- رقم فريد لكل مستند.

**12\. معايير القبول (Acceptance Criteria)**

- S77-AC1: عندما يُنشأ مستند في فرع فإن تحمل رقمه بادئة رمز الفرع.

**13\. ملاحظات للمصمم**

- لا حقل رقم قابل للتعديل في أي نموذج.

### S78 — إدارة مفاتيح الإعدادات

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S78 — إدارة مفاتيح الإعدادات

**2\. الدور (Actor)**

SUPER_ADMIN (settings.manage)

**3\. الهدف**

عرض مفاتيح الإعدادات ونطاقاتها وقيمها وتعديلها.

**4\. الشروط المسبقة (Preconditions)**

- المنفّذ يملك settings.manage.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| settings | scope_type (GLOBAL/BRANCH/USER), branch_id, user_id, setting_key, value_text |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح الإعدادات | شاشة الإعدادات | جدول المفاتيح، شارة النطاق | SELECT | settings.setting_key, scope_type, value_text |
| 2 | يعدّل قيمة | نموذج إعداد | النطاق، الفرع أو المستخدم، القيمة | UPSERT | settings.value_text |
| 3 | يرى الأثر | شاشة الإعدادات | وصف المفتاح وأثره | — | — |

**7\. المسارات البديلة (Alternative Flows)**

- المفاتيح: NEGATIVE_STOCK_POLICY = BLOCK (يمنع البيع بلا رصيد)، COST_METHOD = LAST (أساس تسعير افتراضي فقط؛ الربح من المتوسط)، REQUIRE_COST_ON_SALE = N (يُفعَّل Y بعد S68)، DISCOUNT_MAX_PERCENT = 10 (يُعدَّل بـ S63)، TIMEZONE = Asia/Damascus.
- get_setting تقدّم الأخص: مستخدم ثم فرع ثم عام.
- المنطقة الزمنية تحدد تاريخ القيد قرب منتصف الليل.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| نطاق غير متسق مع الأعمدة | CHECK ck_settings_scope_cols | اختر فرعاً أو مستخدماً بحسب النطاق |

**9\. الصلاحيات (RLS)**

- settings: الكتابة settings.manage (أو لصاحب إعداد USER)؛ القراءة: GLOBAL للجميع وBRANCH للفروع المسموحة.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا إعدادات». |
| خطأ | على الحقل. |
| نجاح | القيمة الجديدة تسري فوراً. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- مفتاح محدّث.

**12\. معايير القبول (Acceptance Criteria)**

- S78-AC1: عندما تُضبط NEGATIVE_STOCK_POLICY على BLOCK فإن يُمنع البيع بلا رصيد (ERP04).

**13\. ملاحظات للمصمم**

- اعرض لكل مفتاح وصفاً وقيمته الحالية والنطاق.

## وحدة 3: الكتالوج والتسعير

### S07 — إنشاء منتج (موديل)

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S07 — إنشاء منتج (موديل)

**2\. الدور (Actor)**

MANAGER وPURCHASER وWAREHOUSE (catalog.manage)

**3\. الهدف**

تعريف موديل جديد وتصنيفه وتعبئة وصفه وخصائصه، ثم نشره بعد اكتمال الإلزامي.

**4\. الشروط المسبقة (Preconditions)**

- المنفّذ يملك catalog.manage.
- product_types معرّفة وفعّالة.
- الماركة والتصنيف ونوع المنتج تُدار بـ masterdata.manage (ممنوحة للأدوار الثلاثة، قرار-06) فالإضافة السريعة تعمل.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| products | name, slug, product_type_id, brand_id, origin_country_id, authenticity_status, model_code, description, status |
| product_types | name, code |
| brands | name, slug |
| categories | parent_id, name, slug |
| product_categories | product_id, category_id, is_primary |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يضغط «منتج جديد» | قائمة المنتجات | بحث، مرشحات (النوع، الماركة، الحالة)، زر «منتج جديد» | SELECT | products.name, model_code, status |
| 2 | يعبّئ البيانات الأساسية | نموذج منتج (خطوة 1) | الاسم، رمز الموديل، الوصف، نوع المنتج، الماركة، بلد المنشأ، حالة الأصالة | SELECT (قوائم) | product_types.name, brands.name, products.authenticity_status |
| 3 | يربط التصنيفات | نموذج منتج (خطوة 2) | شجرة تصنيفات متعددة الاختيار | SELECT / INSERT | categories.name, product_categories (ربط) |
| 4 | يحفظ كمسودة | نموذج منتج | زر «حفظ كمسودة» وزر «متابعة للمتغيرات» (المنتج يُنشأ draft دائماً) | INSERT | products.status = draft, products.slug |
| 5 | يعبّئ الوصف والخصائص (S51 وS53) ثم ينشر عند الجاهزية (S54) | تفاصيل المنتج | تبويبات الوصف والخصائص وزر «نشر» | INSERT / UPDATE | product_attribute_values, products.status |

**7\. المسارات البديلة (Alternative Flows)**

- النشر والأرشفة ← S54؛ النشر مشروط باكتمال الخصائص الإلزامية.
- ماركة أو تصنيف غير موجود: إضافة سريعة من داخل النموذج (S49).
- المنتج يُنشأ دائماً بحالة draft ثم تُحفظ خصائصه ثم يُنشر (آلية إلزامية لكل مسارات الإضافة).

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| اسم أو slug فارغ | NOT NULL | الاسم مطلوب |
| slug مكرر | UNIQUE على products.slug | المعرّف مستخدم لمنتج آخر |
| نوع منتج غير محدد | NOT NULL على product_type_id | اختر نوع المنتج |
| حالة غير صالحة | CHECK على status | الحالة غير مسموحة |
| إنشاء منتج بحالة غير draft | ERP29 PRODUCT_MUST_START_DRAFT | يُنشأ المنتج مسودة أولاً، ثم تُحفظ خصائصه، ثم يُنشر |

**9\. الصلاحيات (RLS)**

- products: الكتابة catalog.manage، والقراءة مفتوحة.
- brands وcategories وproduct_types: الكتابة masterdata.manage والقراءة مفتوحة.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل للنموذج. |
| فارغ | «لا منتجات» مع زر الإنشاء. |
| خطأ | على الحقل. |
| نجاح | الانتقال لإضافة الألوان والمقاسات. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- منتج بحالة draft وبلا متغيرات بعد.

**12\. معايير القبول (Acceptance Criteria)**

- S07-AC1: عندما يحفظ المستخدم بيانات صحيحة فإن ينشأ منتج بحالة draft.
- S07-AC2: عندما يتكرر slug فإن تظهر رسالة على الحقل ولا ينشأ المنتج.
- S07-AC3: عندما يحاول مستخدم إنشاء منتج بحالة published مباشرة فإن يُرفض بـ ERP29.

**13\. ملاحظات للمصمم**

- أنشئ slug تلقائياً من الاسم وقابل للتعديل.
- شارة ملونة لـ status.

### S08 — إضافة الألوان والمقاسات والباركود (المتغيرات)

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S08 — إضافة الألوان والمقاسات والباركود (المتغيرات)

**2\. الدور (Actor)**

MANAGER وPURCHASER وWAREHOUSE

**3\. الهدف**

توليد product_variants من تركيبات اللون والمقاس وإصدار باركود لكل متغير.

**4\. الشروط المسبقة (Preconditions)**

- المنتج موجود.
- المقاسات متاحة للمنتج: يرث مجموعة المقاسات الافتراضية لنوع المنتج (S48) مع إخفاء مقاس أو إضافة مقاس خارجها.
- الألوان معرّفة في colors (S46).

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| product_variants | product_id, sku, variant_key, variant_name, size_id, product_color_id, unit_id, is_default, is_active |
| product_colors | product_id, name, sort_order |
| sizes | size_group_id, name, code, numeric_value |
| barcodes | variant_id, barcode, barcode_type, is_primary, is_active |
| product_color_components | product_color_id, color_id, part_name, percentage, is_primary, sort_order |
| product_sizes | product_id, size_id, is_additional, sort_order |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح المنتج ويختار تبويب المتغيرات | تفاصيل المنتج (تبويب المتغيرات) | جدول المتغيرات، زر «توليد متغيرات» | SELECT | product_variants.sku, variant_name, is_active |
| 2 | يضيف ألوان الموديل | نافذة الألوان | اختيار لون من colors (الافتراضي بسيط)، وزر اختياري «لون مركّب» لإضافة أجزاء (لون + جزء + نسبة) | INSERT | product_colors.name, sort_order; product_color_components.color_id, part_name, percentage |
| 3 | يختار المقاسات | نافذة المقاسات | شبكة مقاسات من المجموعة المرتبطة | SELECT | sizes.name, code |
| 4 | يولّد المتغيرات | معاينة التوليد | جدول (لون × مقاس) بمفاتيح SKU المقترحة، زر «توليد» | INSERT | product_variants.sku, variant_key, size_id, product_color_id |
| 5 | يضيف باركود | نافذة الباركود | حقل باركود يدوي، أو زر «توليد باركود داخلي» (S56)، النوع (EAN13/UPC/CODE128)، «أساسي» | INSERT | barcodes.barcode, barcode_type, is_primary |

**7\. المسارات البديلة (Alternative Flows)**

- إضافة مقاس أو لون بعد إنشاء المنتج: توليد المتغيرات الناقصة فقط.
- إيقاف متغير (is_active = false) بدل حذفه؛ لا حذف لمتغير له حركة.
- إخفاء مقاس عن منتج: بعدم اختياره؛ وإضافة مقاس خارج المجموعة المرثوثة بـ product_sizes.is_additional = true.
- المتغير الافتراضي (is_default): واحد للمنتج (مفروض في القاعدة).
- طباعة ملصقات الباركود ← S56؛ السعر ← S09؛ التكلفة ← S10؛ الكميات ← S21 وS68.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| SKU مكرر | UNIQUE على product_variants.sku | الـ SKU مستخدم لمتغير آخر |
| مفتاح التركيبة مكرر | variant_key (يحسبه compute_variant_key) | هذه التركيبة (لون/مقاس) موجودة |
| باركود مكرر | UNIQUE على barcodes.barcode | الباركود مستخدم لمتغير آخر |
| نوع باركود خاطئ | CHECK على barcode_type | نوع الباركود غير مدعوم |
| مجموع نسب اللون المركّب لا يساوي 100 | تحقق واجهة | مجموع نسب أجزاء اللون يجب أن يساوي 100 |

**9\. الصلاحيات (RLS)**

- product_variants: الكتابة catalog.manage.
- barcodes وproduct_colors وproduct_color_components وproduct_sizes: الكتابة catalog.manage؛ colors وsizes: masterdata.manage.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل للجدول. |
| فارغ | «لا متغيرات» مع زر التوليد. |
| خطأ | تلوين الصف المخالف. |
| نجاح | ظهور المتغيرات الجديدة مع أول باركود. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- متغيرات فعّالة بـ SKU وباركود، بلا تكلفة ولا سعر بعد.

**12\. معايير القبول (Acceptance Criteria)**

- S08-AC1: عندما يختار المستخدم 3 ألوان و4 مقاسات فإن تُعرض 12 تركيبة قبل التوليد.
- S08-AC2: عندما يُوَلَّد متغير فإن يُنشأ له variant_key فريد.
- S08-AC3: عندما يُضاف لون مركّب فإن تُحفظ أجزاؤه ونسبه في product_color_components.

**13\. ملاحظات للمصمم**

- شبكة اللون × المقاس هي الشاشة المركزية.
- أظهر عمود الباركود الأساسي مباشرة في الجدول.
- الموديل قد يحوي خمسة ألوان أحدها مركّب (لونان) والباقي مفرد؛ التركيب على مستوى لون المنتج.

### S09 — تسعير المنتجات

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S09 — تسعير المنتجات

**2\. الدور (Actor)**

MANAGER (pricing.manage)

**3\. الهدف**

تحديد سعر بيع الموديل أو المتغير في قائمة أسعار بعملة وتاريخ صلاحية، علماً أن سعر البيع يُشتق من آخر سعر شراء بنسبة (S57).

**4\. الشروط المسبقة (Preconditions)**

- قائمة أسعار فعّالة وعملات معرّفة.
- المنفّذ يملك pricing.manage.
- قوائم الأسعار الأربع الحالية: RETAIL-SYP (افتراضية) وRETAIL-USD وWHOLESALE-SYP وWHOLESALE-USD.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| price_lists | name, code, currency_id, price_type, is_default, is_active |
| variant_prices | variant_id, price_list_id, currency_id, amount, valid_from, valid_to |
| products | name, model_code |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح تسعير منتج | شاشة التسعير | اختيار المنتج وقائمة الأسعار | SELECT | products.name, price_lists.name, price_type |
| 2 | يرى الأسعار الحالية | شاشة التسعير | جدول متغيرات (SKU، السعر الحالي، العملة، من/إلى) | SELECT | variant_prices.amount, currency_id, valid_from, valid_to |
| 3 | يحدد سعر الموديل لكل المتغيرات (الأسهل) | نافذة «سعر الموديل» | حقل المبلغ، العملة، تاريخ البدء، تحذير مسح الاستثناءات | RPC set_model_price(...) | variant_prices.amount, valid_from |
| 4 | يعدّل سعر لون كامل أو مقاس كامل (متوسط) | شاشة التسعير (شبكة لون × مقاس) | تحديد صف أو عمود في الشبكة وإدخال السعر | INSERT (سعر جديد لكل متغير في التحديد) | variant_prices.variant_id, amount, valid_from |
| 5 | يعدّل سعر متغير بعينه (الأدق) | شاشة التسعير | تحرير داخل الخلية | INSERT (سعر جديد بتاريخ) | variant_prices.variant_id, amount, valid_from |

**7\. المسارات البديلة (Alternative Flows)**

- إنشاء قائمة أسعار جديدة (retail/wholesale/special) بعملتها.
- قواعد التسعير التلقائية (Markup/Margin) ← S57؛ وربط القوائم بالمستخدمين ونقاط البيع ← S58.
- إعادة تعميم سعر الموديل تمسح الاستثناءات الفردية السابقة (set_model_price تغلق الأسعار السابقة).
- الكاشير لا يعدّل سعر السطر في الفاتورة؛ التخفيض بالخصم فقط (ERP24).

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| مبلغ غير موجب | CHECK على variant_prices.amount | السعر يجب أن يكون أكبر من صفر |
| حالة غير صالحة | ERP22 INVALID_STATE من set_model_price | تعذر تحديد السعر |
| بلا صلاحية | سياسة pricing.manage | لا تملك صلاحية التسعير |
| إعادة تعميم سعر الموديل | set_model_price تغلق الأسعار السابقة لكل المتغيرات | تحذير: ستُمسح الاستثناءات الفردية. هل تتابع؟ |

**9\. الصلاحيات (RLS)**

- price_lists وvariant_prices: القراءة مفتوحة، والكتابة pricing.manage.
- الكاشير لا يقرأ price_rules (تُقرأ بـ pricing.manage أو costs.view)؛ يحصل على السعر عبر resolve_price فقط، ويُخفى مصدر السعر عمّن لا يملك pricing.manage أو costs.view.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا سعر» بشارة حمراء على المتغير. |
| خطأ | على الخلية. |
| نجاح | السعر الجديد يظهر مع تاريخ بدء. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- أسعار صالحة من valid_from تُستخدم بـ resolve_price.

**12\. معايير القبول (Acceptance Criteria)**

- S09-AC1: عندما يُحدَّد سعر الموديل فإن ينعكس على كل متغيراته.
- S09-AC2: عندما يُضاف سعر بتاريخ مستقبلي فإن يظل الحالي ساري حتى ذلك التاريخ.
- S09-AC3: عندما يُعمَّم سعر الموديل مجدداً فإن يظهر تحذير بمسح الاستثناءات الفردية قبل التأكيد.

**13\. ملاحظات للمصمم**

- اعرض ملخص التكلفة بجانب السعر لمن يملك costs.view (هامش الربح).
- أبرز المتغيرات بلا سعر أولاً.
- رتّب الأدوات من الأسهل للأصعب: الموديل ثم اللون أو المقاس ثم المتغير الواحد.

### S10 — تحديد تكلفة المنتج وتعديلها

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S10 — تحديد تكلفة المنتج وتعديلها

**2\. الدور (Actor)**

ACCOUNTANT وMANAGER (costs.manage)

**3\. الهدف**

ضبط التكلفة يدوياً عند الحاجة مع سبب مسجّل. تذكير: سعر البيع من آخر سعر شراء، والربح من المتوسط المرجّح (قرار-23)؛ يُعرض العمودان.

**4\. الشروط المسبقة (Preconditions)**

- المنفّذ يملك costs.manage.
- الأصل أن التكلفة تتحدث من ترحيل المشتريات؛ هذا الاستثناء اليدوي.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| variant_costs | variant_id, currency_id, average_cost, last_purchase_cost |
| cost_adjustments | target_type, target_id, old_cost_base, new_cost_base, input_cost, input_currency_id, reason |
| product_variants | sku, variant_name, product_id |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يبحث عن منتج أو متغير | شاشة التكلفة | بحث، جدول (SKU، متوسط التكلفة، آخر شراء) | SELECT | product_variants.sku, variant_costs.average_cost, last_purchase_cost |
| 2 | يختار «تعديل التكلفة» | نافذة تعديل التكلفة | النطاق (متغير/موديل)، التكلفة الجديدة، العملة، السبب | — | cost_adjustments.target_type, input_cost, input_currency_id, reason |
| 3 | يحفظ | نافذة تعديل التكلفة | زر «تأكيد» | RPC set_variant_cost أو set_model_cost | variant_costs.average_cost, cost_adjustments.new_cost_base |
| 4 | يراجع سجل التعديلات | سجل التكلفة | جدول (قديم، جديد، السبب، المستخدم) | SELECT | cost_adjustments.old_cost_base, new_cost_base, reason |

**7\. المسارات البديلة (Alternative Flows)**

- تعديل على مستوى الموديل يطبّق على كل المتغيرات (set_model_cost).
- تُحوَّل التكلفة المدخلة للعملة الأساسية بـ resolve_rate.
- COST_METHOD=LAST يؤثر فقط في أساس قاعدة التسعير الافتراضي؛ تكلفة البضاعة المباعة في post_sale تؤخذ دائماً من المتوسط.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| السبب فارغ | CHECK على cost_adjustments.reason | السبب مطلوب |
| تكلفة سالبة | CHECK على average_cost | التكلفة لا تكون سالبة |
| حالة غير صالحة | ERP22 INVALID_STATE | تعذر تعديل التكلفة |

**9\. الصلاحيات (RLS)**

- variant_costs: القراءة costs.view والكتابة costs.manage (ممنوحة للمحاسب والمدير).
- v_sale_items_costs وv_stock_movements_costs وv_purchase_items_costs وv_transfer_costs: قراءة فقط وتُفلتَر بـ costs.view والفرع/المستودع.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا تكلفة» (لم يُشترَ بعد). |
| خطأ | على الحقل. |
| نجاح | تحديث الخلية وإضافة سطر في السجل. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- تكلفة جديدة وسجل تعديل.

**12\. معايير القبول (Acceptance Criteria)**

- S10-AC1: عندما يعدّل المستخدم التكلفة بسبب فإن يُسجَّل old_cost_base وnew_cost_base.
- S10-AC2: عندما لا يملك المستخدم costs.view فإن يختفي عمود التكلفة.
- S10-AC3: عندما يعدّل المدير (costs.manage) تكلفة صنف فإن تُقبل العملية ويُسجَّل السبب.

**13\. ملاحظات للمصمم**

- السبب حقل إلزامي بقائمة أسباب شائعة.
- قرار-07: AUDITOR يرى التكلفة (قراءة فقط).

### S11 — إدارة الخصومات

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S11 — إدارة الخصومات

**2\. الدور (Actor)**

MANAGER (pricing.manage)

**3\. الهدف**

تعريف خصم (نسبة/مبلغ) ونطاقه وفترته؛ وسقف خصم الكاشير يُضبط في S63.

**4\. الشروط المسبقة (Preconditions)**

- المنفّذ يملك pricing.manage.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| discounts | name, code, discount_type, value, currency_id, min_quantity, start_at, end_at, is_stackable, is_active |
| discount_targets | discount_id, target_type, target_id |
| settings | scope_type, branch_id, setting_key, value_text |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح الخصومات | قائمة الخصومات | جدول (الاسم، النوع، القيمة، الفترة، الحالة) | SELECT | discounts.name, discount_type, value, is_active |
| 2 | ينشئ خصماً | نموذج خصم | الاسم، الرمز، النوع (نسبة/مبلغ)، القيمة، العملة، الحد الأدنى للكمية، من/إلى، «قابل للجمع» | INSERT | discounts.discount_type, value, min_quantity, start_at, end_at, is_stackable |
| 3 | يحدد النطاق | نموذج خصم (النطاق) | اختيار: منتج/متغير/تصنيف/نوع/ماركة | INSERT | discount_targets.target_type, target_id |
| 4 | يضبط سقف خصم الكاشير | شاشة سقف الخصم (S63) | حقل نسبة السقف لكل فرع | RPC set_discount_cap(branch, percent) | settings.setting_key = DISCOUNT_MAX_PERCENT |

**7\. المسارات البديلة (Alternative Flows)**

- تعطيل خصم دون حذف.
- خصم بنطاق فارغ يطبَّق على الكل.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| قيمة غير موجبة | CHECK على value | قيمة الخصم غير صالحة |
| نوع خاطئ | CHECK على discount_type | اختر نسبة أو مبلغاً |
| نسبة أكبر من 100 | تحقق واجهة | النسبة لا تتجاوز 100 |
| تجاوز سقف الكاشير | ERP26 DISCOUNT_CAP_EXCEEDED | الخصم على السطر يتجاوز السقف المسموح (X% من قيمة السطر) |

**9\. الصلاحيات (RLS)**

- discounts: القراءة مفتوحة، والكتابة pricing.manage.
- سقف الخصم يُعدَّل عبر الدالة set_discount_cap بصلاحية pricing.manage (المدير) دون منحه settings.manage.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا خصومات». |
| خطأ | على الحقل. |
| نجاح | ظهور الخصم نشطاً. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- خصم نشط يُرى في الكاشير.

**12\. معايير القبول (Acceptance Criteria)**

- S11-AC1: عندما يُعرَّف خصم لنطاق فإن يظهر للكاشير ضمن الخصومات المتاحة.
- S11-AC2: عندما يتجاوز خصم الكاشير السقف فإن يُرفض بـ ERP26 على السطر (sale_item_guard) وعلى الفاتورة (post_sale)، بلا مسار موافقة؛ ومن يملك discount.exceptional أو SUPER_ADMIN بلا حدود.

**13\. ملاحظات للمصمم**

- سقف الخصم نسبة واحدة عامة مع تخصيص لكل فرع (DISCOUNT_MAX_PERCENT)، والمدير بلا حدود.

### S46 — إدارة الألوان (البسيطة والمركّبة وصور الألوان)

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S46 — إدارة الألوان (البسيطة والمركّبة وصور الألوان)

**2\. الدور (Actor)**

MANAGER وPURCHASER وWAREHOUSE (masterdata.manage)

**3\. الهدف**

تعريف قائمة الألوان المرجعية، واستخدامها كألوان بسيطة أو مركّبة (أجزاء ونسب) في ألوان المنتج، وإرفاق صور اللون.

**4\. الشروط المسبقة (Preconditions)**

- المنفّذ يملك masterdata.manage لإدارة colors، وcatalog.manage لألوان المنتج وصورها.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| colors | name, code, hex_code, is_active, sort_order |
| product_colors | product_id, name, sort_order |
| product_color_components | product_color_id, color_id, part_name, percentage, is_primary, sort_order |
| color_images | product_color_id, image_url, image_type, alt_text, is_primary, sort_order |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح قائمة الألوان | قائمة الألوان | جدول (الاسم، الرمز، عيّنة اللون، الحالة)، زر «لون جديد» | SELECT | colors.name, code, hex_code, is_active |
| 2 | يضيف لوناً | نموذج لون | الاسم، الرمز، منتقي اللون (hex)، الترتيب | INSERT | colors.name, code, hex_code, sort_order |
| 3 | يعطّل لوناً بدل حذفه | قائمة الألوان | مفتاح «فعّال» | UPDATE | colors.is_active |
| 4 | يستخدم اللون في منتج (بسيط افتراضياً) | نافذة الألوان (S08) | اختيار لون واحد للموديل | INSERT | product_colors.name; product_color_components.color_id |
| 5 | يجعله مركّباً (اختياري) | نافذة اللون المركّب | زر «لون مركّب»، أجزاء (اسم الجزء، اللون، النسبة)، «أساسي» | INSERT | product_color_components.part_name, percentage, is_primary |
| 6 | يرفق صور اللون | تبويب صور اللون | رفع صورة (من الجهاز أو الكاميرا)، نوع الصورة، أساسية، ترتيب | RPC attach_color_image بعد الرفع إلى bucket product-images (S55) | color_images.image_url, image_type, is_primary, sort_order |

**7\. المسارات البديلة (Alternative Flows)**

- لون مركّب: مثل 60% أبيض و40% أسود، أو جسم أسود وأكمام بيضاء؛ موديل بخمسة ألوان قد يكون أحدها مركّباً.
- إضافة سريعة للون من نافذة ألوان المنتج.
- لا حذف للون مستخدم: يُعطَّل فقط.
- حذف صورة لون: delete_color_image(p_image_id) ثم يحذف العميل الملف عبر Storage API (S55).

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| اسم أو رمز مكرر | UNIQUE على colors.code | الرمز مستخدم مسبقاً |
| لون hex غير صالح | تحقق واجهة | صيغة اللون غير صحيحة |
| نسب الأجزاء لا تساوي 100 | تحقق واجهة | مجموع النسب يجب أن يساوي 100 |
| صورة بنوع أو حجم غير مدعوم أو مسار غير صالح | ERP22 INVALID_STATE / حدّ bucket product-images | نوع الصورة أو حجمها أو مسارها غير صالح |

**9\. الصلاحيات (RLS)**

- colors: القراءة مفتوحة والكتابة masterdata.manage.
- product_colors وproduct_color_components وcolor_images: الكتابة catalog.manage؛ وصور اللون عبر attach_color_image وdelete_color_image.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا ألوان» مع زر الإضافة. |
| خطأ | على الحقل. |
| نجاح | اللون يظهر في الشبكة وقائمة اختيار ألوان المنتج. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- لون جديد أو معطّل في colors.
- لون منتج بمكوّناته عند الاستخدام.

**12\. معايير القبول (Acceptance Criteria)**

- S46-AC1: عندما يُضاف لون مركّب فإن تُحفظ أجزاؤه ونسبه.
- S46-AC2: عندما يُعطَّل لون فإن لا يظهر في الاختيار الجديد ويبقى في المتغيرات القائمة.
- S46-AC3: عندما تُرفق صورة أساسية للون فإن تُلغى الأساسية السابقة تلقائياً وتظهر في عيّنة اللون بالمنتج.

**13\. ملاحظات للمصمم**

- اعرض عيّنة اللون دائرة بجانب الاسم، وللمركّب دائرة مقسّمة.
- الافتراضي بسيط؛ المركّب خلف زر اختياري.

### S47 — أنظمة المقاسات ومجموعاتها ومقاساتها

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S47 — أنظمة المقاسات ومجموعاتها ومقاساتها

**2\. الدور (Actor)**

MANAGER وPURCHASER وWAREHOUSE (masterdata.manage)

**3\. الهدف**

تعريف أنظمة المقاسات (أوروبي، أمريكي...) ومجموعاتها ومقاساتها ونطاقاتها.

**4\. الشروط المسبقة (Preconditions)**

- المنفّذ يملك masterdata.manage.
- الأجناس (genders) معرّفة إن رُبطت المجموعة بجنس.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| size_systems | name, code, description, is_active |
| size_groups | size_system_id, gender_id, name, code, description, is_active |
| sizes | size_group_id, name, code, numeric_value, sort_order, is_active |
| size_ranges | size_group_id, name, from_size_id, to_size_id, step, is_active |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح أنظمة المقاسات | قائمة أنظمة المقاسات | جدول الأنظمة، «نظام جديد» | SELECT | size_systems.name, code |
| 2 | ينشئ نظاماً | نموذج نظام مقاسات | الاسم، الرمز، الوصف | INSERT | size_systems.name, code |
| 3 | ينشئ مجموعة داخل النظام | نموذج مجموعة مقاسات | الاسم، الرمز، الجنس (اختياري) | INSERT | size_groups.size_system_id, gender_id, name, code |
| 4 | يضيف المقاسات | شبكة المقاسات | صفوف (الاسم، الرمز، القيمة الرقمية، الترتيب) | INSERT | sizes.size_group_id, name, code, numeric_value, sort_order |
| 5 | يعرّف نطاقاً (اختياري) | نموذج نطاق | من مقاس، إلى مقاس، الخطوة | INSERT | size_ranges.from_size_id, to_size_id, step |

**7\. المسارات البديلة (Alternative Flows)**

- توليد مقاسات رقمية بنطاق وخطوة (36 إلى 46 بخطوة 1).
- تعطيل مقاس أو مجموعة بدل الحذف.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| رمز مكرر | UNIQUE | الرمز مستخدم مسبقاً |
| نطاق معكوس | تحقق واجهة | بداية النطاق بعد نهايته |

**9\. الصلاحيات (RLS)**

- size_systems وsize_groups وsizes وsize_ranges: الكتابة masterdata.manage والقراءة مفتوحة.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا أنظمة مقاسات». |
| خطأ | على الحقل. |
| نجاح | المجموعة تظهر في ربط نوع المنتج. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- نظام ومجموعات ومقاسات جاهزة للربط بأنواع المنتجات (S48).

**12\. معايير القبول (Acceptance Criteria)**

- S47-AC1: عندما تُنشأ مجموعة بمقاسات فإن تصبح متاحة للربط بنوع منتج.

**13\. ملاحظات للمصمم**

- شجرة: نظام ← مجموعة ← مقاسات مع إضافة سريعة للصفوف.

### S48 — ربط المقاسات بنوع المنتج وبالمنتج

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S48 — ربط المقاسات بنوع المنتج وبالمنتج

**2\. الدور (Actor)**

MANAGER وPURCHASER وWAREHOUSE (masterdata.manage)

**3\. الهدف**

ربط مجموعة مقاسات افتراضية بنوع المنتج (وبالجنس)، ثم إخفاء مقاس عن منتج أو إضافة مقاس خارج المجموعة.

**4\. الشروط المسبقة (Preconditions)**

- المنفّذ يملك masterdata.manage لربط النوع، وcatalog.manage لتعديل مقاسات المنتج.
- مجموعات المقاسات معرّفة (S47).

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| product_type_size_groups | product_type_id, size_group_id, gender_id, is_default, sort_order |
| product_size_groups | product_id, size_group_id, is_default, sort_order |
| product_sizes | product_id, size_id, is_additional, sort_order |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح نوع منتج | تفاصيل نوع المنتج (S49) | تبويب «مجموعات المقاسات» | SELECT | product_type_size_groups.size_group_id, gender_id, is_default |
| 2 | يربط مجموعة بالنوع | تفاصيل نوع المنتج | قائمة مجموعات، الجنس، «افتراضية»، الترتيب | INSERT | product_type_size_groups.product_type_id, size_group_id, is_default |
| 3 | يفتح منتجاً ويرى المقاسات الموروثة | تفاصيل المنتج (تبويب المقاسات) | شبكة المقاسات الموروثة مع مفتاح إخفاء لكل مقاس | SELECT | product_size_groups.size_group_id; product_sizes.size_id |
| 4 | يخفي مقاساً أو يضيف مقاساً خارج المجموعة | تفاصيل المنتج (المقاسات) | مفتاح «إخفاء»، زر «مقاس إضافي» | INSERT / DELETE | product_sizes.size_id, is_additional |

**7\. المسارات البديلة (Alternative Flows)**

- منتج بلا مجموعة افتراضية لنوعه: يختار المستخدم مجموعة يدوياً (product_size_groups).
- تغيير مجموعة النوع لا يمس متغيرات قائمة.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| مجموعتان افتراضيتان لنوع وجنس | تحقق واجهة | يوجد افتراضي واحد لكل نوع وجنس |
| إخفاء مقاس له متغيرات | تحقق واجهة | المقاس مستخدم في متغيرات فعّالة |

**9\. الصلاحيات (RLS)**

- product_type_size_groups: الكتابة masterdata.manage.
- product_size_groups وproduct_sizes: الكتابة catalog.manage.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا مجموعة مقاسات لهذا النوع». |
| خطأ | على الحقل. |
| نجاح | شبكة المقاسات تعكس الوراثة والتعديلات. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- منتج بمقاسات متاحة جاهزة لتوليد المتغيرات (S08).

**12\. معايير القبول (Acceptance Criteria)**

- S48-AC1: عندما يُنشأ منتج من نوع له مجموعة افتراضية فإن ترثها مقاساته.
- S48-AC2: عندما يُضاف مقاس خارج المجموعة فإن يُعلَّم is_additional = true.

**13\. ملاحظات للمصمم**

- ميّز المقاس الإضافي بشارة، والمخفي بلون خافت.

### S49 — الماركات والتصنيفات وأنواع المنتجات

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S49 — الماركات والتصنيفات وأنواع المنتجات

**2\. الدور (Actor)**

MANAGER وPURCHASER وWAREHOUSE (masterdata.manage)

**3\. الهدف**

إدارة الماركات وشجرة التصنيفات وأنواع المنتجات التي تعتمد عليها نماذج المنتج.

**4\. الشروط المسبقة (Preconditions)**

- المنفّذ يملك masterdata.manage.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| brands | name, slug, logo, description, is_active |
| categories | parent_id, name, slug, description, image, sort_order, is_active |
| product_types | name, code, description, is_active, sort_order |
| countries | name (بلد المنشأ) |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح الماركات أو التصنيفات أو الأنواع | قائمة البيانات الأساسية | تبويبات: ماركات، تصنيفات، أنواع منتجات | SELECT | brands.name; categories.name; product_types.name |
| 2 | يضيف ماركة | نموذج ماركة | الاسم، المعرّف، الوصف، الشعار | INSERT | brands.name, slug, logo |
| 3 | يضيف تصنيفاً تحت أب | نموذج تصنيف | الأب، الاسم، المعرّف، الترتيب | INSERT | categories.parent_id, name, slug, sort_order |
| 4 | يضيف نوع منتج | نموذج نوع منتج | الاسم، الرمز، الوصف | INSERT | product_types.name, code |
| 5 | يربط النوع بمقاساته وخصائصه | تفاصيل النوع | تبويبات المقاسات (S48) والخصائص (S53) | INSERT | product_type_size_groups, product_type_attributes |

**7\. المسارات البديلة (Alternative Flows)**

- إضافة سريعة من نموذج المنتج (S07).
- تعطيل بدل حذف ما استُخدم.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| slug مكرر | UNIQUE | المعرّف مستخدم |
| تصنيف أب لنفسه | تحقق واجهة | لا يكون التصنيف أباً لنفسه |

**9\. الصلاحيات (RLS)**

- brands وcategories وproduct_types وcountries: الكتابة masterdata.manage والقراءة مفتوحة.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا ماركات بعد». |
| خطأ | على الحقل. |
| نجاح | العنصر يظهر في القوائم المنسدلة. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- بيانات أساسية جاهزة لنماذج المنتج.

**12\. معايير القبول (Acceptance Criteria)**

- S49-AC1: عندما يملك المشتري masterdata.manage فإن يستطيع الإضافة السريعة من نموذج المنتج.

**13\. ملاحظات للمصمم**

- شجرة قابلة للطي للتصنيفات.

### S50 — وحدات القياس

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S50 — وحدات القياس

**2\. الدور (Actor)**

MANAGER وPURCHASER وWAREHOUSE (masterdata.manage)

**3\. الهدف**

إدارة وحدات تسمّي طريقة بيع الصنف وشرائه (قطعة، زوج، علبة، طقم) للوصف فقط.

**4\. الشروط المسبقة (Preconditions)**

- المنفّذ يملك masterdata.manage.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| units | name, symbol, unit_type, is_active |
| product_variants | unit_id |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح الوحدات | قائمة الوحدات | جدول (الاسم، الرمز، النوع) | SELECT | units.name, symbol, unit_type |
| 2 | يضيف وحدة | نموذج وحدة | الاسم، الرمز، النوع | INSERT | units.name, symbol, unit_type |
| 3 | يحدد وحدة المتغير | نافذة المتغيرات (S08) | قائمة الوحدات | UPDATE | product_variants.unit_id |

**7\. المسارات البديلة (Alternative Flows)**

- الوحدة للوصف فقط (قرار-26): طريقة بيع الصنف وشرائه.
- تعطيل وحدة بدل حذفها.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| نوع وحدة غير صالح | CHECK على unit_type (weight/length/volume/piece) | اختر نوعاً من القائمة |

**9\. الصلاحيات (RLS)**

- units: القراءة مفتوحة والكتابة masterdata.manage.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا وحدات». |
| خطأ | على الحقل. |
| نجاح | الوحدة تظهر في المتغير والفواتير. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- وحدة معرّفة ومربوطة بالمتغيرات.

**12\. معايير القبول (Acceptance Criteria)**

- S50-AC1: عندما يُباع الصنف بوحدة فإن تظهر في الفاتورة بلا أي تحويل كمية.

**13\. ملاحظات للمصمم**

- أخفِ حقول التحويل لأن القرار بلا تحويل.

### S51 — إكمال وصف المنتج (الجداول الوصفية)

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S51 — إكمال وصف المنتج (الجداول الوصفية)

**2\. الدور (Actor)**

MANAGER وPURCHASER وWAREHOUSE (catalog.manage)

**3\. الهدف**

ربط المنتج بالرياضات والفئات العمرية والأجناس والمواسم والمجموعات والوسوم والخامات والأقمشة وتعليمات العناية.

**4\. الشروط المسبقة (Preconditions)**

- المنتج موجود، والجداول الوصفية معرّفة (S52).

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| product_sports | product_id, sport_id |
| product_age_groups | product_id, age_group_id |
| product_genders | product_id, gender_id |
| product_seasons | product_id, season_id |
| product_collections | product_id, collection_id |
| product_tags | product_id, tag_id |
| product_materials | product_id, material_id, percentage, is_primary |
| product_fabrics | product_id, fabric_type_id, is_primary, notes |
| product_care_instructions | product_id, care_instruction_id, sort_order, notes |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح تبويب الوصف | تفاصيل المنتج (الوصف) | أقسام قابلة للطي لكل مجال | SELECT | product_sports, product_genders ... |
| 2 | يختار القيم لكل مجال | تفاصيل المنتج (الوصف) | اختيار متعدد (رياضات، أعمار، أجناس، مواسم، مجموعات، وسوم) | INSERT / DELETE | product\_&lt;مجال&gt;.product_id, &lt;مجال&gt;\_id |
| 3 | يحدد الخامات والأقمشة | تفاصيل المنتج (الوصف) | خامة + نسبة + «أساسية»، قماش + ملاحظة | INSERT | product_materials.material_id, percentage; product_fabrics.fabric_type_id |
| 4 | يضيف تعليمات العناية | تفاصيل المنتج (الوصف) | قائمة تعليمات مرتبة مع ملاحظات | INSERT | product_care_instructions.care_instruction_id, sort_order |
| 5 | يحفظ | تفاصيل المنتج | زر «حفظ» | — | — |

**7\. المسارات البديلة (Alternative Flows)**

- تعليمات عناية إلزامية بحسب نوع المنتج (product_type_care_instructions.is_required).
- نسخ الوصف من منتج مشابه (واجهة فقط).

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| تكرار الربط | المفتاح المركّب (product_id, القيمة) | القيمة مضافة مسبقاً |
| نسب الخامات لا تساوي 100 | تحقق واجهة | مجموع نسب الخامات يجب أن يساوي 100 |

**9\. الصلاحيات (RLS)**

- كل جداول الربط: الكتابة catalog.manage والقراءة مفتوحة.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لم يُحدَّد وصف بعد». |
| خطأ | على الحقل. |
| نجاح | قيم الوصف تظهر في بطاقة المنتج. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- منتج موصوف بجميع المجالات المطلوبة.

**12\. معايير القبول (Acceptance Criteria)**

- S51-AC1: عندما يُحفظ الوصف فإن تظهر القيم في بطاقة المنتج.

**13\. ملاحظات للمصمم**

- اختيار متعدد بشرائح (chips) لكل مجال.

### S52 — إدارة الجداول المرجعية الوصفية

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S52 — إدارة الجداول المرجعية الوصفية

**2\. الدور (Actor)**

MANAGER وPURCHASER وWAREHOUSE (masterdata.manage)

**3\. الهدف**

تعريف القيم المرجعية التي تُستخدم لوصف المنتجات بقالب عام واحد.

**4\. الشروط المسبقة (Preconditions)**

- المنفّذ يملك masterdata.manage.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| sports | name, code, description, is_active, sort_order |
| age_groups | name, min_age, max_age, is_active, sort_order |
| genders | name, code, is_active, sort_order |
| seasons | name, code, season_type, start_date, end_date, is_active |
| collections | name, code, description, image, start_date, end_date, is_active |
| tags | name, slug, is_active |
| materials | name, code, material_type, description, is_active |
| fabric_types | name, code, fabric_category, is_named_fabric, description, is_active |
| care_instructions | name, code, care_type, description, icon, sort_order, is_active |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يختار الجدول المرجعي | البيانات المرجعية | قائمة بالجداول التسعة | SELECT | sports ... care_instructions |
| 2 | يفتح قائمته | قائمة مرجعية | جدول القيم، بحث، «قيمة جديدة» | SELECT | &lt;الجدول&gt;.name, is_active |
| 3 | يضيف قيمة أو يعدّلها | نموذج قيمة | حقول الجدول المحددة | INSERT / UPDATE | &lt;الجدول&gt;.name, code |
| 4 | يعطّل قيمة | قائمة مرجعية | مفتاح «فعّال» | UPDATE | &lt;الجدول&gt;.is_active |

**7\. المسارات البديلة (Alternative Flows)**

- شاشة عامة واحدة تتغير حقولها حسب الجدول.
- لا حذف لقيمة مستخدمة.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| رمز أو معرّف مكرر | UNIQUE | القيمة موجودة |
| نطاق عمر معكوس | تحقق واجهة | العمر الأدنى أكبر من الأعلى |

**9\. الصلاحيات (RLS)**

- كل الجداول المرجعية: الكتابة masterdata.manage والقراءة مفتوحة.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا قيم». |
| خطأ | على الحقل. |
| نجاح | القيمة تظهر في اختيار الوصف. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- قيم مرجعية جاهزة.

**12\. معايير القبول (Acceptance Criteria)**

- S52-AC1: عندما تُعطَّل قيمة فإن لا تظهر في الاختيار الجديد.

**13\. ملاحظات للمصمم**

- قالب واحد لكل الجداول مع بحث وتعطيل سريع.

### S53 — الخصائص الديناميكية للمنتج

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S53 — الخصائص الديناميكية للمنتج

**2\. الدور (Actor)**

MANAGER وPURCHASER وWAREHOUSE (masterdata.manage لتعريف الخصائص، catalog.manage لتعبئتها)

**3\. الهدف**

تعريف خصائص ومجموعات خيارات وربطها بنوع المنتج وتعبئتها في المنتج، مع إلزامية قبل النشر.

**4\. الشروط المسبقة (Preconditions)**

- المنفّذ يملك masterdata.manage للتعريف وcatalog.manage للتعبئة.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| attributes | name, code, data_type, unit_id, is_filterable, is_required, is_variant_option, is_active, option_set_id |
| option_sets | name, code, selection_type, is_active |
| options | option_set_id, name, code, sort_order, is_active |
| product_type_attributes | product_type_id, attribute_id, is_required, sort_order |
| product_type_option_sets | product_type_id, option_set_id, is_required, sort_order |
| product_attribute_values | product_id, attribute_id, value_text, value_number, value_boolean, value_date, value_json, option_id |
| product_option_values | product_id, option_set_id, option_id, sort_order |
| variant_option_values | variant_id, option_set_id, option_id |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يعرّف مجموعة خيارات | نموذج مجموعة خيارات | الاسم، الرمز، نوع الاختيار (واحد/متعدد)، الخيارات | INSERT | option_sets.selection_type; options.name, code |
| 2 | يعرّف خاصية | نموذج خاصية | الاسم، النوع، الوحدة، «قابلة للتصفية»، مجموعة الخيارات (لنوع option) | INSERT | attributes.data_type, option_set_id, is_filterable |
| 3 | يربطها بنوع المنتج | تفاصيل نوع المنتج (الخصائص) | قائمة خصائص مع «إلزامية» والترتيب | INSERT | product_type_attributes.attribute_id, is_required; product_type_option_sets |
| 4 | يعبّئها في المنتج | تفاصيل المنتج (الخصائص) | نموذج مبني من v_product_type_attribute_defs | INSERT / UPDATE | product*attribute_values.value*\*, option_id; product_option_values |
| 5 | يراجع المنتج | تفاصيل المنتج | قائمة الناقص (product_missing_required) | RPC / SELECT | v_product_attributes.display_value |

**7\. المسارات البديلة (Alternative Flows)**

- الخاصية من نوع option ترتبط بمجموعتها عبر option_set_id (إلزامي لهذا النوع وممنوع لغيره).
- مجموعة single تقبل خياراً واحداً للمنتج؛ لتغييره حدّث الصف لا احذفه ثم أدرجه.
- خيار على مستوى المتغير عبر variant_option_values.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| قيمة لا تطابق نوع الخاصية أو خيار من مجموعة أخرى | ERP27 ATTRIBUTE_VALUE_INVALID | الخيار لا ينتمي لمجموعة الخيارات المرتبطة بهذه الخاصية |
| خاصية أو خيار معطّل | ERP27 | الخاصية معطّلة ولا يمكن إسناد قيمة لها |
| خياران في مجموعة single | ERP27 | مجموعة الخيارات هذه تقبل خياراً واحداً فقط للمنتج |
| نشر بإلزامي ناقص | ERP28 REQUIRED_ATTRIBUTES_MISSING | لا يمكن نشر المنتج قبل تعبئة الخصائص الإلزامية: \[الأسماء\] |

**9\. الصلاحيات (RLS)**

- attributes وoption_sets وoptions وربط الأنواع: الكتابة masterdata.manage.
- قيم المنتج والمتغير: الكتابة catalog.manage؛ الحراس في القاعدة (ERP27 وERP28).

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا خصائص لهذا النوع». |
| خطأ | على الحقل. |
| نجاح | القيم تظهر بتنسيق قابل للقراءة. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- منتج بخصائص صحيحة، جاهز للنشر إن اكتمل الإلزامي.

**12\. معايير القبول (Acceptance Criteria)**

- S53-AC1: عندما تنقص خاصية إلزامية فإن يُرفض النشر ويُعرض اسمها.
- S53-AC2: عندما يُسند خيار من مجموعة أخرى فإن يُرفض بـ ERP27.

**13\. ملاحظات للمصمم**

- النموذج ديناميكي من v_product_type_attribute_defs؛ علّم الإلزامي بنجمة.

### S54 — نشر المنتج وأرشفته وإيقاف المتغير

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S54 — نشر المنتج وأرشفته وإيقاف المتغير

**2\. الدور (Actor)**

MANAGER وPURCHASER وWAREHOUSE (catalog.manage)

**3\. الهدف**

نقل المنتج بين draft وpublished وarchived، وإيقاف المتغير بدل حذفه.

**4\. الشروط المسبقة (Preconditions)**

- المنتج موجود بحالة draft.
- الخصائص الإلزامية مكتملة قبل النشر.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| products | status, slug |
| product_variants | is_active |
| product_attribute_values | product_id, attribute_id |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح المنتج | تفاصيل المنتج | شارة الحالة، قائمة الناقص | RPC product_missing_required(product) | — |
| 2 | يضغط «نشر» | تفاصيل المنتج | زر «نشر» | UPDATE | products.status = published |
| 3 | يؤرشف منتجاً | تفاصيل المنتج | زر «أرشفة» مع تأكيد | UPDATE | products.status = archived |
| 4 | يوقف متغيراً | تبويب المتغيرات | مفتاح «فعّال» | UPDATE | product_variants.is_active = false |

**7\. المسارات البديلة (Alternative Flows)**

- إعادة منتج مؤرشف إلى draft للتعديل.
- المنتج المؤرشف لا يظهر في البحث بنقطة البيع.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| نشر بإلزامي ناقص | ERP28 | لا يمكن نشر المنتج قبل تعبئة الخصائص الإلزامية |
| حالة غير صالحة | CHECK على status | الحالة غير مسموحة |

**9\. الصلاحيات (RLS)**

- products: الكتابة catalog.manage.
- حارس product_publish_guard داخل القاعدة يمنع النشر الناقص.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | — |
| خطأ | على الحقل. |
| نجاح | الحالة الجديدة بشارة. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- منتج published أو archived، ومتغير موقوف.

**12\. معايير القبول (Acceptance Criteria)**

- S54-AC1: عندما يكتمل الإلزامي فإن ينجح النشر.
- S54-AC2: عندما يُوقف متغير فإن لا يُباع ويبقى تاريخه.

**13\. ملاحظات للمصمم**

- اعرض قائمة الناقص بجانب زر النشر.

### S55 — صور المنتج والألوان

**المنصة الأساسية:** ويب وموبايل (الكاميرا)

**1\. رقم واسم السيناريو**

S55 — صور المنتج والألوان

**2\. الدور (Actor)**

MANAGER وPURCHASER وWAREHOUSE (catalog.manage)

**3\. الهدف**

إرفاق صور للمنتج ولألوانه وإدارتها: أساسية، ترتيب، نص بديل، حذف.

**4\. الشروط المسبقة (Preconditions)**

- bucket باسم product-images عام للقراءة (jpeg وpng وwebp، بحد 5 MB للملف)، والرفع والحذف فيه لـ catalog.manage.
- مسار الملف يُتحقق منه بـ validate_image_path.
- المنفّذ يملك catalog.manage.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| product_images | id, product_id, image_url, image_type, alt_text, is_primary, sort_order, updated_at |
| color_images | id, product_color_id, image_url, image_type, alt_text, is_primary, sort_order, updated_at |
| Storage: bucket product-images | المسار (path) والملف |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح تبويب الصور | تبويب صور المنتج | شبكة صور | SELECT | product_images.image_url, is_primary, sort_order |
| 2 | يرفع الملف (من الجهاز أو الكاميرا) | تبويب صور المنتج | زر «رفع صورة» وزر «الكاميرا» على الموبايل | Storage API (العميل) إلى bucket product-images | path |
| 3 | يسجّل الصورة للمنتج | تبويب صور المنتج | النوع، النص البديل، «أساسية»، الترتيب | RPC attach_product_image(p_product_id, p_path, p_image_type, p_alt_text, p_is_primary, p_sort_order) | product_images.image_url, image_type, alt_text, is_primary, sort_order |
| 4 | يربط صورة بلون | تبويب صور اللون | اختيار اللون ثم الرفع والنوع (الافتراضي front)، النص البديل، «أساسية»، الترتيب | RPC attach_color_image(id, p_path, p_image_type = 'front', p_alt_text, p_is_primary = false, p_sort_order) | color_images.product_color_id, image_url, image_type, is_primary |
| 5 | يحذف صورة | تبويب صور المنتج أو تبويب صور اللون | زر «حذف» بتأكيد | RPC delete_product_image(p_image_id) أو delete_color_image(p_image_id)؛ الدالة تحذف الصف وتُرجع المسار، ثم يحذف العميل الملف عبر Storage API | product_images أو color_images (حذف الصف) |

**7\. المسارات البديلة (Alternative Flows)**

- تغيير الصورة الأساسية: عند is_primary = true تُلغى الأساسية السابقة تلقائياً.
- إعادة ترتيب الصور بتعديل sort_order عند الإرفاق.
- حذف الصورة: يحذف الصف أولاً بالدالة ثم الملف بواسطة العميل.
- المنصة: ويب وموبايل (الكاميرا).

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| بلا صلاحية | ERP16 PERMISSION_DENIED | لا تملك الصلاحية المطلوبة لهذه العملية |
| مسار غير صالح أو بيانات غير صالحة | ERP22 INVALID_STATE (validate_image_path) | مسار الصورة غير صالح |
| نوع ملف غير مدعوم أو أكبر من 5 MB | حدّ bucket product-images (jpeg وpng وwebp، 5 MB) | نوع الملف غير مدعوم أو حجمه يتجاوز 5 MB |

**9\. الصلاحيات (RLS)**

- product_images وcolor_images: الكتابة catalog.manage عبر الدوال، ويدخلان سجل التدقيق.
- bucket product-images: القراءة عامة، والرفع والحذف لـ catalog.manage.
- attach_product_image وdelete_product_image وdelete_color_image دوال SECURITY DEFINER في public.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل ومؤشر تقدم الرفع. |
| فارغ | «لا صور». |
| خطأ | على الحقل أو على الملف. |
| نجاح | الصورة تظهر في الشبكة. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- صور مرتبطة بالمنتج أو اللون، وصورة أساسية واحدة نشطة.
- سجل CREATE أو DELETE في audit_logs.

**12\. معايير القبول (Acceptance Criteria)**

- S55-AC1: عندما تُرفع صورة أساسية فإن تظهر في بطاقة المنتج وتُلغى الأساسية السابقة.
- S55-AC2: عندما يُرفع ملف بنوع غير مدعوم أو بحجم فوق 5 MB فإن يُرفض.
- S55-AC3: عندما يُحذف صف الصورة فإن تُرجع الدالة مسار الملف ليحذفه العميل.
- S55-AC4: عندما يحاول مستخدم بلا catalog.manage الإرفاق أو الحذف فإن يُرفض بـ ERP16.

**13\. ملاحظات للمصمم**

- اعرض الصورة الأساسية بشارة واضحة.
- على الموبايل اجعل «الكاميرا» خياراً أول بجانب اختيار ملف.

### S56 — الباركود: إدخال يدوي وتوليد داخلي وطباعة الملصقات

**المنصة الأساسية:** ويب (الطباعة على Windows)

**1\. رقم واسم السيناريو**

S56 — الباركود: إدخال يدوي وتوليد داخلي وطباعة الملصقات

**2\. الدور (Actor)**

MANAGER وPURCHASER وWAREHOUSE (catalog.manage)

**3\. الهدف**

إدخال باركود المصنّع أو المورد يدوياً، أو توليد باركود داخلي فريد عند الغياب، وطباعة ملصقات الباركود.

**4\. الشروط المسبقة (Preconditions)**

- المنفّذ يملك catalog.manage.
- المتغير موجود.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| barcodes | variant_id, barcode, barcode_type, is_primary, is_active |
| product_variants | sku, variant_name |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح باركودات المتغير | نافذة الباركود (S08) | قائمة الباركودات | SELECT | barcodes.barcode, barcode_type, is_primary |
| 2 | يدخل باركوداً يدوياً | نافذة الباركود | حقل باركود، النوع (EAN13/UPC/CODE128)، «أساسي» | INSERT | barcodes.barcode, barcode_type, is_primary |
| 3 | أو يولّد باركوداً داخلياً | نافذة الباركود | زر «توليد باركود داخلي» | RPC assign_internal_barcode(variant) | barcodes.barcode (EAN13 من النطاق الداخلي 2) |
| 4 | يطبع الملصقات | طباعة الملصقات | اختيار متغيرات، عدد النسخ، معاينة | — | واجهة فقط |

**7\. المسارات البديلة (Alternative Flows)**

- المتغير بباركود فعّال: assign_internal_barcode تُعيد الموجود ولا تنشئ آخر.
- أكثر من باركود للمتغير مسموح، مع باركود أساسي واحد فقط (is_primary) لكل متغير.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| باركود مكرر | UNIQUE على barcodes.barcode | الباركود مستخدم لمتغير آخر |
| نوع غير مدعوم | CHECK على barcode_type | نوع الباركود غير مدعوم |
| بلا صلاحية | ERP16 PERMISSION_DENIED | لا تملك صلاحية إدارة المنتجات |

**9\. الصلاحيات (RLS)**

- barcodes: الكتابة catalog.manage.
- generate_internal_barcode وassign_internal_barcode تتطلبان catalog.manage.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا باركود لهذا المتغير». |
| خطأ | على الحقل. |
| نجاح | الباركود يظهر أساسياً في الجدول. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- باركود فعّال للمتغير.

**12\. معايير القبول (Acceptance Criteria)**

- S56-AC1: عندما يُولَّد باركود داخلي فإن يكون EAN13 فريداً.
- S56-AC2: عندما يوجد باركود فعّال فإن لا يُولَّد آخر تلقائياً.

**13\. ملاحظات للمصمم**

- زر الطباعة قرب الباركود الأساسي.

### S57 — قواعد التسعير (Markup / Margin)

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S57 — قواعد التسعير (Markup / Margin)

**2\. الدور (Actor)**

MANAGER (pricing.manage)

**3\. الهدف**

تعريف قواعد تحسب سعر البيع من التكلفة بنسبة، بحسب القائمة والمنتج والتصنيف والماركة ونوع المنتج وبأولوية.

**4\. الشروط المسبقة (Preconditions)**

- المنفّذ يملك pricing.manage.
- قوائم الأسعار موجودة (S09).
- لا قواعد افتراضية: المدير يُدخل القواعد والنسب بنفسه (قرار-33)، وقاعدة TEST-CAP-MU20 تجريبية تُحذف عند أول إدخال حقيقي.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| price_rules | name, code, calculation_method, percentage, price_list_id, product_type_id, category_id, brand_id, product_id, target_currency_id, priority, cost_basis, is_active |
| price_lists | name, code, currency_id, price_type |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح القواعد | قائمة قواعد التسعير | جدول (الاسم، الطريقة، النسبة، النطاق، الأولوية) | SELECT | price_rules.name, calculation_method, percentage, priority |
| 2 | ينشئ قاعدة | نموذج قاعدة | الاسم، الطريقة (Markup/Margin)، النسبة، أساس التكلفة (last_purchase)، قائمة الأسعار، النطاق، الأولوية | INSERT | price_rules.calculation_method, percentage, cost_basis, price_list_id, priority |
| 3 | يعاين النتيجة | معاينة القاعدة | سعر نموذجي لصنف | RPC resolve_price(...) | variant_prices (للمقارنة) |
| 4 | يعطّل قاعدة | قائمة القواعد | مفتاح «فعّال» | UPDATE | price_rules.is_active |

**7\. المسارات البديلة (Alternative Flows)**

- سعر البيع من آخر سعر شراء بنسبة (cost_basis = last_purchase)، والربح من المتوسط (قرار-23).
- قاعدة الجملة: نسبة مخصّصة تُربط بقائمة الجملة، تُستخدم حين لا يوجد سعر جملة صريح للصنف.
- السعر الصريح للمتغير في القائمة يغلب القاعدة.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| نسبة غير صالحة | CHECK على percentage | النسبة غير صالحة |
| تعارض أولويات | تحقق واجهة | قاعدتان بالأولوية نفسها على النطاق نفسه |

**9\. الصلاحيات (RLS)**

- price_rules: القراءة pricing.manage أو costs.view، والكتابة pricing.manage.
- الكاشير لا يرى القواعد؛ يحصل على السعر من resolve_price فقط.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا قواعد تسعير». |
| خطأ | على الحقل. |
| نجاح | القاعدة نشطة وتظهر في المعاينة. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- قاعدة تسعير فعّالة تُستخدم في resolve_price.

**12\. معايير القبول (Acceptance Criteria)**

- S57-AC1: عندما تنطبق قاعدة وليس للصنف سعر صريح فإن يُحسب السعر منها.
- S57-AC2: عندما لا يوجد سعر صريح ولا قاعدة فإن يُمنع بيع الصنف (ERP25).

**13\. ملاحظات للمصمم**

- اعرض معاينة السعر والهامش جنب النسبة (لمن يملك costs.view).

## وحدة 4: الأطراف (زبائن وموردون)

### S12 — إدارة الزبائن

**المنصة الأساسية:** Windows (والموبايل للمسح)

**1\. رقم واسم السيناريو**

S12 — إدارة الزبائن

**2\. الدور (Actor)**

MANAGER وACCOUNTANT وPURCHASER (parties.manage) للإدارة الكاملة، وCASHIER (parties.quick_add) للإضافة السريعة من شاشة البيع

**3\. الهدف**

إضافة زبون وتحديد حد ائتمانه وقائمة أسعاره وعناوينه (لمن يملك parties.manage)، وإضافة زبون سريع بالاسم والهاتف من شاشة البيع (الكاشير).

**4\. الشروط المسبقة (Preconditions)**

- الإدارة الكاملة: المنفّذ يملك parties.manage للكتابة وparties.view للقراءة.
- الإضافة السريعة: المنفّذ يملك parties.quick_add أو parties.manage (الدالة quick_add_customer).

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| parties | party_type, name, phone, whatsapp, email, address, is_active |
| customers | party_id, customer_code, credit_limit, credit_limit_currency_id, default_price_list_id, is_active |
| customer_addresses | customer_id, label, city, address, phone, is_default |
| price_lists | name, code, price_type |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح قائمة الزبائن | قائمة الزبائن | بحث بالاسم/الهاتف، جدول (الاسم، الهاتف، الرصيد، الحالة) | SELECT | parties.name, phone, customers.customer_code |
| 2 | يضغط «زبون جديد» (MANAGER وACCOUNTANT وPURCHASER) | نموذج زبون | النوع (شخص/شركة)، الاسم، الهاتف، واتساب، البريد | — | parties.party_type, name, phone, whatsapp, email |
| 3 | يحدد الائتمان والتسعير (parties.manage فقط) | نموذج زبون (قسم الائتمان) | حد الائتمان، عملته، قائمة أسعار مقترحة للزبون (مثل الجملة؛ تُختار تلقائياً في البيع إن كانت مسموحة للمستخدم ← S64) | SELECT (قوائم) | customers.credit_limit, credit_limit_currency_id, default_price_list_id |
| 4 | يضيف عناوين | نموذج زبون (العناوين) | التسمية، المدينة، العنوان، الهاتف، «افتراضي» | INSERT | customer_addresses.label, city, address, is_default |
| 5 | يحفظ | نموذج زبون | زر «حفظ» | INSERT (طرف ثم زبون) | parties, customers |
| 6 | الكاشير يضغط «زبون سريع» من شاشة البيع | نافذة إضافة زبون سريع | الاسم، الهاتف، واتساب (اختياري)، زر «إضافة» | RPC quick_add_customer(p_name, p_phone, p_whatsapp) ← {customer_id, party_id, existing} | parties.name, phone, whatsapp; customers.credit_limit = 0 |
| 7 | يعود الزبون إلى الفاتورة | شاشة البيع | الزبون المضاف أو الموجود محدد في الفاتورة | — | sales.customer_id |

**7\. المسارات البديلة (Alternative Flows)**

- طرف موجود (مورد مثلاً) يصبح زبوناً أيضاً دون تكرار الطرف، لمن يملك parties.manage.
- تعطيل زبون (is_active = false): لمن يملك parties.manage.
- الإضافة السريعة: الاسم والهاتف فقط؛ سقف الائتمان 0 بالعملة الأساسية وبلا قائمة أسعار افتراضية.
- الهاتف المكرر في الإضافة السريعة يعيد الزبون الموجود (existing = true) دون إنشاء سجل جديد.
- الكاشير لا يكتب في parties وcustomers مباشرة (يُرفض)، بل عبر quick_add_customer، ولا يعدّل الائتمان ولا قائمة الأسعار ولا يعطّل طرفاً؛ ذلك لمن يملك parties.manage (المدير والمحاسب والمشتري).

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| اسم فارغ | NOT NULL على parties.name؛ وفي الإضافة السريعة ERP22 INVALID_STATE | الاسم مطلوب |
| هاتف فارغ (إضافة سريعة) | ERP22 INVALID_STATE | الهاتف مطلوب |
| هاتف يخص طرفاً ليس زبوناً (مورد أو موظف) | ERP22 INVALID_STATE | هذا الهاتف مسجّل لطرف آخر غير زبون |
| كتابة مباشرة في parties أو customers من الكاشير | سياسة RLS (الكتابة parties.manage) | استخدم «زبون سريع» |
| نوع طرف غير صالح | CHECK على party_type | اختر شخصاً أو شركة |
| حد ائتمان سالب | CHECK على credit_limit | الحد لا يكون سالباً |
| عنوان فارغ | NOT NULL على customer_addresses.address | العنوان مطلوب |
| بلا صلاحية | ERP16 PERMISSION_DENIED | لا تملك الصلاحية المطلوبة لهذه العملية |

**9\. الصلاحيات (RLS)**

- parties: القراءة parties.view والكتابة المباشرة parties.manage.
- customers: القراءة (parties.view,sales.view,sales.create,accounting.view) والكتابة المباشرة parties.manage.
- customer_addresses: الكتابة parties.manage.
- quick_add_customer: تتحقق الدالة من parties.quick_add أو parties.manage؛ ويحملها الكاشير (parties.quick_add وparties.view) ولا يحمل parties.manage.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا زبائن». |
| خطأ | على الحقل. |
| نجاح | العودة للقائمة أو للفاتورة مع الزبون المختار. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- طرف وزبون (وعناوين) جاهزون للبيع.
- في الإضافة السريعة: زبون بسقف ائتمان 0 بالعملة الأساسية وبلا قائمة أسعار افتراضية، أو الزبون الموجود نفسه عند تكرار الهاتف.
- سجل العملية في audit_logs.

**12\. معايير القبول (Acceptance Criteria)**

- S12-AC1: عندما يُحفظ زبون بالنموذج الكامل فإن ينشأ سجل في parties وسجل مرتبط في customers.
- S12-AC2: عندما يضيف الكاشير زبوناً سريعاً بهاتف جديد فإن يُنشأ طرف وزبون بسقف ائتمان 0 وبلا قائمة أسعار افتراضية، ويُختار تلقائياً في الفاتورة.
- S12-AC3: عندما يضيف الكاشير زبوناً بهاتف مسجّل لزبون فإن تعود الدالة بالزبون الموجود (existing = true) ولا يتكرر.
- S12-AC4: عندما يكون الهاتف لطرف ليس زبوناً (مورد أو موظف) أو يكون الاسم أو الهاتف فارغاً فإن تُرفض الإضافة السريعة بـ ERP22.
- S12-AC5: عندما يحاول الكاشير الكتابة مباشرة في parties أو customers فإن يُرفض.
- S12-AC6: عندما يفتح الكاشير شاشة الزبون فإن لا تظهر له أدوات الائتمان أو قائمة الأسعار أو التعطيل.

**13\. ملاحظات للمصمم**

- الهاتف هو مفتاح البحث الأول.
- أظهر الرصيد الحالي وحد الائتمان بجانب الاسم.
- نافذة الكاشير مختصرة بحقلي الاسم والهاتف وحقل واتساب اختياري؛ لا تعرض له الائتمان ولا قائمة الأسعار.

### S13 — إدارة الموردين

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S13 — إدارة الموردين

**2\. الدور (Actor)**

PURCHASER

**3\. الهدف**

إضافة مورد وشروط دفعه وعملته الافتراضية.

**4\. الشروط المسبقة (Preconditions)**

- المنفّذ يملك parties.manage أو purchasing.create.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| parties | party_type, name, phone, whatsapp, email, address, is_active |
| suppliers | party_id, company_name, supplier_code, payment_terms_days, default_currency_id, is_active |
| currencies | code, symbol |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح قائمة الموردين | قائمة الموردين | بحث، جدول (الشركة، الهاتف، الرصيد) | SELECT | suppliers.company_name, supplier_code, parties.phone |
| 2 | يضغط «مورد جديد» | نموذج مورد | النوع، الاسم، اسم الشركة، الهاتف، البريد | — | parties.name, suppliers.company_name |
| 3 | يحدد شروط الدفع والعملة | نموذج مورد | أيام السداد، العملة الافتراضية | SELECT (قوائم) | suppliers.payment_terms_days, default_currency_id |
| 4 | يحفظ | نموذج مورد | زر «حفظ» | INSERT | parties, suppliers |

**7\. المسارات البديلة (Alternative Flows)**

- تحويل طرف قائم إلى مورد.
- تعطيل مورد.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| اسم فارغ | NOT NULL | الاسم مطلوب |
| مدة سداد سالبة | CHECK على payment_terms_days | عدد الأيام غير صالح |
| رمز مورد مكرر | UNIQUE على supplier_code | رمز المورد مستخدم |

**9\. الصلاحيات (RLS)**

- suppliers: القراءة (parties.view,purchasing.view,accounting.view) والكتابة (parties.manage,purchasing.create).

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا موردين». |
| خطأ | على الحقل. |
| نجاح | العودة للقائمة. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- مورد فعّال بشروط الدفع.

**12\. معايير القبول (Acceptance Criteria)**

- S13-AC1: عندما يُحدَّد مورد في فاتورة شراء فإن تُقترح عملته وتاريخ الاستحقاق من شروطه.

**13\. ملاحظات للمصمم**

- أظهر الرصيد المستحق للمورد في رأس الصفحة.

## وحدة 5: المبيعات ونقطة البيع

### S14 — فتح جلسة صندوق

**المنصة الأساسية:** Windows (والموبايل للمسح)

**1\. رقم واسم السيناريو**

S14 — فتح جلسة صندوق

**2\. الدور (Actor)**

CASHIER

**3\. الهدف**

بدء وردية بيع على نقطة بيع برصيد افتتاحي لكل عملة.

**4\. الشروط المسبقة (Preconditions)**

- الكاشير معيّن على نقطة بيع (user_pos_terminals) ويملك pos.session وصلاحية تشغيل على الفرع.
- لا جلسة OPEN أخرى للكاشير نفسه: فهرس فريد على cashier_user_id للجلسات المفتوحة (قرار-48). ويجوز لعدة كاشيرين فتح جلسات على النقطة نفسها.
- للمستخدم قائمة أسعار مسموحة (تُسنَد الافتراضية تلقائياً عند إنشائه، S58)، وإلا رُفض البيع بـ ERP23.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| pos_sessions | pos_terminal_id, cashier_user_id, opened_at, closed_at, status, notes |
| pos_session_balances | pos_session_id, currency_id, opening_amount |
| pos_terminals | name, code, cashbox_id, default_warehouse_id |
| user_pos_terminals | user_id, pos_terminal_id, is_default |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يختار «بدء وردية» | لوحة الكاشير | زر «بدء وردية جديدة» | SELECT | user_pos_terminals.pos_terminal_id, is_default |
| 2 | يختار نقطة البيع (إن تعددت) | شاشة فتح جلسة | قائمة النقاط المعيّنة له، النقطة الافتراضية محددة | SELECT | pos_terminals.name, code |
| 3 | يدخل الرصيد الافتتاحي لكل عملة | شاشة فتح جلسة | حقل مبلغ لكل عملة فعّالة في الصندوق | — | pos_session_balances.currency_id, opening_amount |
| 4 | يؤكد الفتح | شاشة فتح جلسة | حقل ملاحظات، زر «فتح الجلسة» | INSERT | pos_sessions.status = OPEN, opened_at, notes; pos_session_balances |
| 5 | يدخل شاشة البيع | شاشة البيع | — | — | — |

**7\. المسارات البديلة (Alternative Flows)**

- الكاشير بجلسة مفتوحة مسبقاً: يُعرض خيار «متابعة الجلسة الحالية».
- لا نقطة معيّنة: رسالة «لم تُعيَّن على نقطة بيع».
- المدير يفتح جلسة ويبيع بصلاحياته (pos.session وsales.create وsales.post) بشرط can_operate وربطه بنقطة بيع؛ لا يحتاج دوراً ثانياً.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| جلسة مفتوحة مسبقاً للكاشير | فهرس فريد على cashier_user_id (الجلسات OPEN) | لديك جلسة مفتوحة، تابعها أو أغلقها قبل فتح جلسة جديدة |
| نقطة بيع غير مسندة للمستخدم | ERP16 PERMISSION_DENIED | هذه النقطة غير مسندة إليك |
| رصيد سالب | CHECK على opening_amount | الرصيد الافتتاحي لا يكون سالباً |
| حالة غير صالحة | CHECK على status | حالة الجلسة غير صالحة |
| بلا صلاحية | ERP16 PERMISSION_DENIED | لا تملك صلاحية فتح الجلسات |
| استعمال جلسة كاشير آخر بلا pos.manage | ERP16 PERMISSION_DENIED (assert_session_owner) | هذه الوردية تخص كاشيراً آخر ولا يجوز استعمالها |
| جلسة من نقطة بيع فرع مختلف عن فرع الفاتورة أو الدفعة (لمن يملك pos.manage) | ERP16 PERMISSION_DENIED (assert_session_owner) | لا تملك الصلاحية المطلوبة لهذه العملية |

**9\. الصلاحيات (RLS)**

- pos_sessions: القراءة والكتابة (pos.session,pos.manage) مع can_access_branch.
- pos_session_balances: الكتابة pos.session أو pos.manage.
- user_pos_terminals: القراءة لصفوف المستخدم نفسه.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل لبطاقة النقطة. |
| فارغ | لا نقاط معيّنة. |
| خطأ | تحت الحقل المخالف. |
| نجاح | انتقال لشاشة البيع وشريط «جلسة مفتوحة منذ \[الوقت\]». |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- جلسة OPEN بأرصدة افتتاحية.
- لا يتم أي بيع قبل جلسة مفتوحة (assert_session_open)، والجلسة تخص من فتحها: sale_header_guard وpost_payment يستدعيان assert_session_owner(p_session, p_branch)؛ فمن يستعمل جلسة كاشير آخر بلا pos.manage يُرفض بـ ERP16، ومن يملك pos.manage يُشترط أن تعود الجلسة لنقطة بيع من فرع الفاتورة أو الدفعة نفسه وإلا ERP16 (قرار-48).

**12\. معايير القبول (Acceptance Criteria)**

- S14-AC1: عندما يؤكد الكاشير فإن تُنشأ جلسة OPEN بصف رصيد لكل عملة.
- S14-AC2: عندما يملك الكاشير جلسة مفتوحة فإن لا يستطيع فتح ثانية على أي نقطة.
- S14-AC3: عندما يفتح كاشير ثانٍ جلسة على النقطة نفسها فإن تُقبل بجلسة مستقلة وجرد نقدي مستقل.
- S14-AC4: عندما يحاول مستخدم بلا pos.manage استعمال جلسة غيره في بيع أو دفع فإن يُرفض بـ ERP16 «هذه الوردية تخص كاشيراً آخر ولا يجوز استعمالها».
- S14-AC5: عندما يملك مستخدم pos.manage ويستعمل جلسة كاشير آخر تعود لنقطة بيع من فرع الفاتورة أو الدفعة نفسه فإن تُقبل العملية.
- S14-AC6: عندما يملك مستخدم pos.manage ويستعمل جلسة تعود لنقطة بيع من فرع مختلف عن فرع الفاتورة أو الدفعة فإن يُرفض بـ ERP16.

**13\. ملاحظات للمصمم**

- اجعل الرصيد الافتتاحي حقلاً كبيراً بأرقام ضخمة (شاشة لمس).
- عملة الصندوق الأساسية أولاً.

### S15 — البحث عن صنف وإضافته للسلة

**المنصة الأساسية:** Windows (والموبايل للمسح)

**1\. رقم واسم السيناريو**

S15 — البحث عن صنف وإضافته للسلة

**2\. الدور (Actor)**

CASHIER

**3\. الهدف**

إيجاد المتغير بالباركود أو الاسم ورؤية سعره ورصيده في مستودع فرع الفاتورة (البيع من مستودع فرع آخر ممنوع)، وإضافته للسلة بسعر مثبَّت.

**4\. الشروط المسبقة (Preconditions)**

- جلسة صندوق مفتوحة.
- للمتغير سعر في قائمة الأسعار المستخدمة.
- للفاتورة قائمة أسعار مسموحة (sales.price_list_id) يختارها الكاشير أو تُقترح له (S64).

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| product_variants | sku, variant_name, product_id, size_id, product_color_id, is_active |
| barcodes | variant_id, barcode, is_primary, is_active |
| variant_prices | variant_id, price_list_id, currency_id, amount, valid_from, valid_to |
| inventory_balances | variant_id, warehouse_id, quantity_on_hand, quantity_reserved |
| sales | price_list_id, doc_status (مسودة السلة) |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يمسح الباركود أو يكتب للبحث | شاشة البيع | حقل بحث دائم التركيز، زر ماسح الكاميرا (موبايل). مسح الباركود نفسه مجدداً يزيد كمية السطر نفسه | SELECT | barcodes.barcode, variant_id |
| 2 | يظهر المتغير مع سعره | شاشة البيع | بطاقة (اسم، لون، مقاس، السعر، العملة) | RPC resolve_price(variant, price_list, currency, at) | variant_prices.amount, currency_id |
| 3 | يرى الرصيد المتاح | شاشة البيع | شارة الكمية المتاحة في فرعه، وعند الصفر زر «مخزون الفروع الأخرى» (S66) | SELECT (v_stock_available) | inventory_balances.quantity_on_hand, quantity_reserved |
| 4 | يضيف للسلة ويحدد الكمية | شاشة البيع (السلة) | أزرار +/-، الكمية؛ السعر يُثبَّت لحظة الإضافة | INSERT (sale_items في فاتورة DRAFT) | sale_items.variant_id, quantity, list_price, unit_price |
| 5 | يعلّق الفاتورة أو يستأنف معلّقة | شاشة البيع | زر «تعليق»، قائمة «الفواتير المعلّقة» | INSERT / SELECT (sales بحالة DRAFT) | sales.doc_status = DRAFT |

**7\. المسارات البديلة (Alternative Flows)**

- بحث بالاسم أو الـ SKU عند غياب الباركود.
- باركود غير معروف: رسالة وإمكانية بحث يدوي.
- متغير بلا سعر: يُرفض عند الإضافة بـ ERP25.
- الاستئناف: اختيار فاتورة معلّقة من القائمة فتعود إلى السلة (S20).
- الرصيد صفر في فرعي: يظهر الصنف مع توقيف البيع ويُعرض مخزون الفروع الأخرى مع الفرع والمستودع (S66، S67)؛ البيع من فرع آخر يتطلب تحويلاً أولاً.
- لا يُعدَّل سعر السطر لأحد (حتى المدير)؛ التخفيض بالخصم فقط.
- البيع بلا تكلفة معروفة يُمنع حين يكون REQUIRE_COST_ON_SALE = Y (حالياً N حتى اكتمال الأرصدة الافتتاحية).

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| باركود غير معروف | لا صف في barcodes | لم يُعثر على الصنف |
| رصيد صفر | ERP04 INSUFFICIENT_STOCK عند الترحيل | الرصيد غير كافٍ للصنف |
| بلا سعر | ERP25 PRICE_NOT_FOUND | لا يوجد سعر لهذا الصنف في قائمة الأسعار المحددة، ولا يمكن بيعه قبل تحديد سعره |
| متغير غير نشط | product_variants.is_active = false | هذا الصنف موقوف |
| مستودع فرع آخر | ERP11 WAREHOUSE_NOT_SELLABLE | لا يمكن البيع إلا من مستودع تابع لفرع الفاتورة |
| مستودع غير قابل للبيع | ERP11 | المستودع غير قابل للبيع (تالف/مرتجعات/مركزي) أو غير فعّال |

**9\. الصلاحيات (RLS)**

- product_variants barcodes variant_prices: القراءة مفتوحة.
- inventory_balances: القراءة (inventory.view وaccounting.view وreports.view) مع can_access_warehouse؛ الكاشير يملك inventory.view. ومخزون الفروع الأخرى عبر branch_stock_lookup بصلاحية inventory.view_other_branches.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | دوّار صغير بجانب حقل البحث. |
| فارغ | «السلة فارغة — امسح صنفاً». |
| خطأ | وميض أحمر مع صوت عند باركود مجهول. |
| نجاح | الصنف يضاف مع وميض أخضر. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- سلة جاهزة للإتمام (في الذاكرة) أو فاتورة DRAFT معلّقة.

**12\. معايير القبول (Acceptance Criteria)**

- S15-AC1: عندما يُمسح باركود صالح فإن يُضاف الصنف للسلة بسعره الحالي.
- S15-AC2: عندما يُعلَّق الفاتورة فإن تظهر في قائمة المعلّقة ويمكن استئنافها.
- S15-AC3: عندما يمسح الكاشير باركوداً مكرراً فإن تزيد كمية السطر نفسه ولا يُنشأ سطر جديد.
- S15-AC4: عندما يضيف صنفاً بلا سعر في القائمة فإن يُرفض بـ ERP25.
- S15-AC5: عندما يكون الرصيد صفراً في فرعه فإن يُمنع البيع ويُعرض مخزون الفروع الأخرى بلا بيع منها.

**13\. ملاحظات للمصمم**

- الباركود هو المسار الأسرع: لا تضع النقرات في طريقه.
- أزرار كبيرة للمس.

### S16 — إتمام البيع (دفع نقدي/متعدد)

**المنصة الأساسية:** Windows (والموبايل للمسح)

**1\. رقم واسم السيناريو**

S16 — إتمام البيع (دفع نقدي/متعدد)

**2\. الدور (Actor)**

CASHIER

**3\. الهدف**

ترحيل الفاتورة واستلام الدفع بوسائل وعملات متعددة مع إرجاع الباقي.

**4\. الشروط المسبقة (Preconditions)**

- جلسة OPEN وسلة فيها بنود.
- الكاشير يملك sales.create وsales.post وsales.discount وfinance.payments (ممنوحة).
- مستودع البيع قابل للبيع (is_sellable).
- للفاتورة قائمة أسعار مسموحة (S64) وإلا رُفضت بـ ERP23.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| sales | branch_id, pos_terminal_id, pos_session_id, customer_id, channel, invoice_number, sale_date, currency_id, exchange_rate, subtotal, discount, rounding_amount, total_amount, doc_status, payment_status |
| sale_items | sale_id, variant_id, warehouse_id, quantity, list_price, unit_price, discount, total_price |
| payments | party_id, branch_id, pos_session_id, payment_type, payment_context, status, payment_date |
| payment_lines | payment_id, financial_account_id, currency_id, amount, direction, line_type, parent_line_id, payment_method, exchange_rate |
| sales (إضافة) | price_list_id (إلزامي لفواتير POS وPHONE الجديدة) |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يراجع السلة ويضيف خصماً (ضمن السقف) | شاشة البيع (السلة) | الإجمالي، حقل خصم (رقم أو نسبة تُحفظ مبلغاً)، اختيار قائمة الأسعار، زر اختيار زبون | — | sales.discount, sale_items.discount, sales.customer_id |
| 2 | يضغط «دفع» | شاشة الدفع | الإجمالي المطلوب بعملة الفاتورة، أزرار وسائل الدفع (نقد، بطاقة، تحويل، محفظة) | INSERT | sales (DRAFT), sale_items |
| 3 | يضيف أسطر دفع | شاشة الدفع | سطر لكل (وسيلة، عملة، مبلغ، سعر صرف)، المتبقي يتحدث لحظياً | INSERT | payment_lines.payment_method, currency_id, amount, exchange_rate |
| 4 | يرى الباقي ويحدد عملته | شاشة الدفع | حقل «الباقي» بعملة قابلة للاختيار | INSERT | payment_lines.line_type = CHANGE_GIVEN, direction = OUT, parent_line_id |
| 5 | يؤكد الدفع | شاشة الدفع | زر «إتمام البيع» | RPC post_sale(sale_id) ثم post_payment(payment_id) | sales.doc_status = POSTED, payments.status = POSTED |
| 6 | يطبع أو يرسل الإيصال | شاشة الإيصال | زر طباعة، مشاركة واتساب، «بيع جديد» | SELECT | sales.invoice_number, invoice_code, total_amount |

**7\. المسارات البديلة (Alternative Flows)**

- دفع جزئي ← S17.
- فاتورة بلا زبون (customer_id فارغ) للبيع النقدي المباشر.
- عملة الفاتورة مختلفة عن عملة السعر: يُطلب price_exchange_rate.
- إلغاء قبل الترحيل: الفاتورة تبقى DRAFT أو تُحذف (S20).
- الخصم فوق سقف الكاشير: يُرفض بلا مسار موافقة (ERP26)، ولا يتجاوز إلا من يملك discount.exceptional أو SUPER_ADMIN.
- تغيّر سعر القائمة بعد إضافة السطر: لا يُفشل الترحيل، لكن يظهر تنبيه بالأسطر المتغيرة (get_draft_price_warnings) ويستطيع الكاشير حذف السطر وإضافته أو «تحديث السعر» (refresh_draft_line_prices) ← S20.
- البيع بلا تكلفة معروفة يُرفض حين REQUIRE_COST_ON_SALE = Y؛ وتُحسب تكلفة السطر عند الترحيل من المتوسط (يُفرَّغ unit_cost القادم من العميل).

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| جلسة غير مفتوحة | assert_session_open (ERP22) | لا توجد جلسة مفتوحة |
| جلسة تخص كاشيراً آخر (بلا pos.manage) | ERP16 PERMISSION_DENIED (assert_session_owner) | هذه الوردية تخص كاشيراً آخر ولا يجوز استعمالها |
| جلسة من نقطة بيع فرع مختلف عن فرع الفاتورة (لمن يملك pos.manage) | ERP16 PERMISSION_DENIED (assert_session_owner) | لا تملك الصلاحية المطلوبة لهذه العملية |
| رصيد غير كافٍ | ERP04 INSUFFICIENT_STOCK | الرصيد غير كافٍ للصنف \[الاسم\] |
| مستودع غير قابل للبيع | ERP11 WAREHOUSE_NOT_SELLABLE | المستودع غير قابل للبيع |
| فاتورة بلا بنود | ERP22 | الفاتورة بلا بنود |
| سعر صرف السعر مفقود | ERP19 PRICE_RATE_REQUIRED | يلزم سعر الصرف لهذه العملة |
| بلا صلاحية ترحيل | ERP16 PERMISSION_DENIED | لا تملك صلاحية ترحيل المبيعات |
| فترة مغلقة | ERP08/ERP13 | الفترة المحاسبية مغلقة |
| قائمة أسعار غير مسموحة | ERP23 PRICE_LIST_NOT_ALLOWED | قائمة الأسعار المحددة غير مسموحة لك أو لنقطة البيع |
| سعر السطر مخالف للقائمة | ERP24 PRICE_MISMATCH | سعر السطر لا يطابق سعر القائمة. لا يجوز تعديل السعر، استخدم الخصم |
| صنف بلا سعر | ERP25 PRICE_NOT_FOUND | لا يوجد سعر لهذا الصنف في قائمة الأسعار المحددة، ولا يمكن بيعه قبل تحديد سعره |
| خصم فوق السقف | ERP26 DISCOUNT_CAP_EXCEEDED | الخصم على السطر (أو إجمالي خصم الفاتورة) يتجاوز السقف المسموح |
| بيع بلا تكلفة | ERP22 INVALID_STATE (REQUIRE_COST_ON_SALE = Y) | لا توجد تكلفة للصنف ولا يُسمح بالبيع بدونها |
| خصم بلا صلاحية | ERP16 PERMISSION_DENIED (sales.discount) | لا تملك صلاحية منح الخصم |

**9\. الصلاحيات (RLS)**

- sales: القراءة (sales.view,sales.create,sales.post,...) والكتابة (sales.create,sales.post) مع can_access_branch(branch_id, true).
- payments وpayment_lines: الكتابة (finance.payments,payment.cancel) مع صلاحية تشغيل على الفرع.
- الترحيل عبر post_sale (SECURITY DEFINER) يتحقق من sales.post.
- sale_header_guard وsale_item_guard وpost_sale تفرض داخل القاعدة: القائمة المسموحة، مطابقة السعر، سقف الخصم، فرع المستودع؛ فلا يكفي إخفاء الأزرار.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | زر «إتمام» معطّل بدوّار أثناء الترحيل. |
| فارغ | لا يمكن فتح الدفع بسلة فارغة. |
| خطأ | رسالة بالسبب مع بقاء السلة محفوظة. |
| نجاح | شاشة إيصال خضراء ورقم الفاتورة. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- فاتورة POSTED وحالة سداد PAID (أو PARTIAL).
- حركة مخزون SALE_OUT، ودفعة POSTED، وقيد محاسبي، وحركة صندوق (توليد تلقائي).

**12\. معايير القبول (Acceptance Criteria)**

- S16-AC1: عندما يؤكد الكاشير دفعاً يغطي الإجمالي فإن ترحَّل الفاتورة وتصبح payment_status = PAID.
- S16-AC2: عندما يزيد المدفوع عن الإجمالي فإن يُسجَّل الباقي كسطر CHANGE_GIVEN بالعملة المختارة.
- S16-AC3: عندما لا يتوفر رصيد فإن لا ترحَّل الفاتورة وتبقى السلة.
- S16-AC4: عندما يُغيَّر سعر السطر عن سعر القائمة فإن يُرفض بـ ERP24 وتُعرض رسالة «استخدم الخصم».
- S16-AC5: عندما يتجاوز الخصم السقف فإن يُرفض بـ ERP26 للكاشير ويُقبل للمدير.
- S16-AC6: عندما يُفعَّل REQUIRE_COST_ON_SALE ويُباع صنف بلا تكلفة فإن يُرفض الترحيل.
- S16-AC7: عندما يبيع مستخدم بلا pos.manage على جلسة كاشير آخر فإن يُرفض بـ ERP16 «هذه الوردية تخص كاشيراً آخر ولا يجوز استعمالها».
- S16-AC8: عندما يملك المدير pos.manage ويبيع على جلسة تعود لنقطة بيع من فرع غير فرع الفاتورة فإن يُرفض بـ ERP16.

**13\. ملاحظات للمصمم**

- شاشة الدفع: المتبقي بخط ضخم ملوّن (أحمر ثم أخضر عند الصفر).
- وسائل الدفع كأزرار بأيقونات؛ العملة كشريحة تبديل.
- قرار-09: الكاشير ينشئ ويرحّل بنفسه، فلا مرحلة موافقة.
- اعرض سبب الرفض بالنص الصادر من القاعدة (الملحق و).

### S17 — بيع آجل أو بدفعة جزئية

**المنصة الأساسية:** Windows (والموبايل للمسح)

**1\. رقم واسم السيناريو**

S17 — بيع آجل أو بدفعة جزئية

**2\. الدور (Actor)**

CASHIER وMANAGER

**3\. الهدف**

تسجيل فاتورة لا تُسدَّد كلياً وإنشاء دين على زبون.

**4\. الشروط المسبقة (Preconditions)**

- زبون محدد (customer_id) في الفاتورة: يختاره الكاشير من الزبائن الموجودين، أو يضيفه سريعاً عبر quick_add_customer (parties.quick_add) ← S12.
- جلسة مفتوحة.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| sales | customer_id, total_amount, due_date, doc_status, payment_status |
| customers | party_id, credit_limit, credit_limit_currency_id |
| payment_allocations | payment_id, sale_id, debt_currency_id, source_currency_id, settled_amount, source_amount, allocation_type |
| party_ledger_entries | party_id, currency_id, entry_date, entry_type, debit, credit, source_type, source_id |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يختار زبوناً (أو يضيفه سريعاً ← S12) | شاشة البيع | بحث الزبون، زر «زبون سريع»، عرض الرصيد وحد الائتمان | SELECT | customers.credit_limit, party_ledger_entries (الرصيد الحالي) |
| 2 | يرى تحذير الائتمان إن تجاوز الحد | شاشة البيع | شريط تحذير أصفر (لا يمنع) | SELECT | customers.credit_limit مقابل الرصيد + الإجمالي |
| 3 | يدخل دفعة جزئية أو لا شيء، ويحدد تاريخ الاستحقاق | شاشة الدفع | المبلغ المدفوع، due_date | INSERT | sales.due_date, payment_lines.amount |
| 4 | يؤكد | شاشة الدفع | زر «ترحيل كآجل/جزئي» | RPC post_sale | sales.payment_status = UNPAID أو PARTIAL |
| 5 | يظهر الدين في كشف حساب الزبون | كشف حساب الزبون | سطر بيع مدين | SELECT | party_ledger_entries.entry_type = SALE, debit |

**7\. المسارات البديلة (Alternative Flows)**

- التسديد بسند قبض بعد البيع ← S30.
- فاتورة بلا زبون لا يجوز أن تبقى بلا سداد كامل.
- زبون أُضيف سريعاً: حد ائتمانه 0 فيظهر تحذير الائتمان عند أي بيع آجل (لا يمنع)، ويرفع الحد من يملك parties.manage (S12).
- زبون مربوط بقائمة جملة: تُقترح القائمة تلقائياً إن كانت مسموحة للمستخدم، وإلا تُستخدم قائمته الافتراضية مع رسالة (S64).

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| زبون غير محدد لبيع آجل | تحقق واجهة | حدّد زبوناً للبيع الآجل |
| تجاوز الائتمان | تحذير فقط (قرار-11) | تنبيه: تجاوز حد الائتمان |
| فاتورة بلا بنود | ERP22 | الفاتورة بلا بنود |

**9\. الصلاحيات (RLS)**

- customers: القراءة (parties.view,sales.view,sales.create,accounting.view).
- party_ledger_entries: القراءة (parties.view وaccounting.view وfinance.view وreports.view)؛ الكاشير يملك parties.view فيرى الرصيد (ويمكن عرضه عبر v_party_balances).
- الكاشير يضيف الزبون بـ quick_add_customer (parties.quick_add) ولا يكتب في customers مباشرة.
- payment_allocations: الكتابة (finance.payments,payment.cancel).

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | دوّار قرب الرصيد. |
| فارغ | زبون جديد برصيد صفر. |
| خطأ | على الحقل. |
| نجاح | إيصال يوضح المتبقي وتاريخ الاستحقاق. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- دين على الزبون في party_ledger_entries.
- payment_status يعكس الجزئي أو غير المسدّد.

**12\. معايير القبول (Acceptance Criteria)**

- S17-AC1: عندما يُرحَّل بيع بدفعة أقل من الإجمالي فإن يصبح payment_status = PARTIAL ويظهر الدين بكشف الحساب.
- S17-AC2: عندما يتجاوز الدين حد الائتمان فإن يظهر تحذير ولا يُمنع البيع.
- S17-AC3: عندما يضيف الكاشير زبوناً سريعاً ويبيع له آجلاً فإن يظهر تحذير الائتمان (الحد 0) ولا يُمنع البيع.

**13\. ملاحظات للمصمم**

- اعرض: الرصيد السابق + الفاتورة = الرصيد الجديد.
- التحذير أصفر وليس أحمر.

### S18 — إغلاق جلسة الصندوق والجرد النقدي

**المنصة الأساسية:** Windows (والموبايل للمسح)

**1\. رقم واسم السيناريو**

S18 — إغلاق جلسة الصندوق والجرد النقدي

**2\. الدور (Actor)**

CASHIER أو MANAGER (أيهما) للإغلاق؛ والعكس لمن يملك accounting.post أو (reconcile.cash وpos.manage)

**3\. الهدف**

مطابقة النقد الفعلي مع المتوقع لكل عملة ثم إغلاق الجلسة.

**4\. الشروط المسبقة (Preconditions)**

- جلسة OPEN.
- المنفّذ يملك reconcile.cash (ممنوحة للكاشير والمدير والمحاسب).

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| pos_sessions | status, closed_at, closed_by, notes |
| cash_reconciliations | financial_account_id, pos_session_id, count_date, expected_amount, counted_amount, difference_amount, reason, status, posted_at |
| financial_transactions | financial_account_id, transaction_type, direction, amount, currency_id, pos_session_id, source_cash_reconciliation_id |
| pos_session_balances | pos_session_id, currency_id, opening_amount |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يضغط «إغلاق الوردية» | شاشة البيع | زر «إغلاق الوردية» | SELECT | pos_sessions.status |
| 2 | يرى ملخص الجلسة | ملخص الوردية | الافتتاحي، المبيعات، المقبوضات، المتوقع لكل عملة | SELECT (v_pos_session_summary) | pos_session_balances.opening_amount, financial_transactions.amount |
| 3 | يدخل العدّ الفعلي لكل عملة | شاشة الجرد النقدي | حقل مبلغ مُعدّ لكل عملة، يظهر الفرق لحظياً | INSERT | cash_reconciliations.counted_amount, expected_amount, difference_amount |
| 4 | يدخل سبب الفرق إن وُجد | شاشة الجرد النقدي | حقل reason | — | cash_reconciliations.reason |
| 5 | يؤكد الجرد | شاشة الجرد النقدي | زر «ترحيل الجرد» | RPC post_cash_reconciliation(id) | cash_reconciliations.status, posted_at؛ تولّد حركة CASH_DIFFERENCE بقيد على CASH_OVER أو CASH_SHORT (قرار-13) |
| 6 | يغلق الجلسة | ملخص الوردية | زر «إغلاق نهائي» | UPDATE | pos_sessions.status = CLOSED, closed_at, closed_by |
| 7 | يعكس جرداً مرحّلاً عند الحاجة | شاشة الجرد النقدي | زر «عكس» (لمن يملك الصلاحية) وحقل سبب | RPC reverse_cash_reconciliation(p_id, p_reason) | cash_reconciliations.status = REVERSED |

**7\. المسارات البديلة (Alternative Flows)**

- فرق صفر: لا حركة فرق.
- المدير يغلق جلسة كاشير نسي إغلاقها (قرار-13: أيهما يغلق).
- تعدد العملات: جرد لكل عملة، لا إغلاق قبل ترحيلها كلها.
- لا ترحيل للجرد بـ UPDATE مباشر (قرار-43).
- عكس الجرد النقدي: reverse_cash_reconciliation(p_id, p_reason) لمن يملك accounting.post أو (reconcile.cash وpos.manage) (قرار-44)، فيصير الأصل REVERSED.
- سلوك الجلسة عند العكس: لا إعادة فتح لجلسة مغلقة؛ إن كانت الجلسة OPEN تُنسب الحركة العكسية إليها ويصير الأصل REVERSED فيلزم جرد جديد قبل الإغلاق (ERP12)، وإن كانت CLOSED تُسجَّل الحركة بلا جلسة.
- ERP12 يعدّ الجرد POSTED غير المعكوس فقط.
- المصروف الصغير الذي سجّله الكاشير من صندوق جلسته ينعكس في المتوقع (S32).

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| إغلاق قبل الجرد | ERP12 POS_SESSION_NOT_RECONCILED | لا تُغلق الوردية قبل وجود جرد مُرحَّل لكل عملة |
| مبلغ مُعدّ سالب | CHECK على counted_amount | المبلغ المعدّ غير صالح |
| إغلاق جلسة مغلقة | ERP02 DOC_BAD_TRANSITION | الجلسة مغلقة مسبقاً |
| بلا صلاحية | ERP16 | لا تملك صلاحية الجرد النقدي |
| عكس جرد غير مرحّل أو معكوس مسبقاً | ERP02 DOC_BAD_TRANSITION | انتقال حالة غير مسموح للمستند |
| عكس بلا صلاحية | ERP16 PERMISSION_DENIED | لا تملك الصلاحية المطلوبة لهذه العملية |
| عكس بيانات أو حالة غير صالحة | ERP22 INVALID_STATE | حالة أو بيانات غير صالحة للعملية |
| عكس في فترة مغلقة أو مقفلة | ERP08 / ERP13 | الفترة المحاسبية مغلقة أو مقفلة |

**9\. الصلاحيات (RLS)**

- cash_reconciliations: القراءة (accounting.view,finance.view,reconcile.cash) والكتابة reconcile.cash.
- pos_sessions: الكتابة (pos.session,pos.manage) مع الفرع.
- financial_transactions: قراءة فقط (accounting.view,finance.view,reconcile.cash,reports.view)؛ تُنشأ بالتريغر.
- reverse_cash_reconciliation: صلاحيتها accounting.post أو (reconcile.cash وpos.manage).

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | دوّار على الملخص. |
| فارغ | جلسة بلا مبيعات (الافتتاحي فقط). |
| خطأ | شريط يذكر العملة التي ينقصها جرد. |
| نجاح | ملخص نهائي قابل للطباعة. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- جلسة CLOSED وجرد POSTED لكل عملة.
- حركة CASH_DIFFERENCE إن وُجد فرق.
- بعد العكس: الجرد الأصلي REVERSED وحركة عكسية مقابلة، وتعود الجلسة OPEN بحاجة إلى جرد جديد قبل الإغلاق.

**12\. معايير القبول (Acceptance Criteria)**

- S18-AC1: عندما يدخل الكاشير مبلغاً مُعدّاً يخالف المتوقع فإن يظهر الفرق فوراً ويُطلب سبب.
- S18-AC2: عندما يُرحَّل الجرد بفرق فإن تُنشأ حركة CASH_DIFFERENCE تلقائياً.
- S18-AC3: عندما تبقى عملة بلا جرد فإن لا تُغلق الجلسة.
- S18-AC4: عندما يُحاول ترحيل الجرد بتغيير الحالة مباشرة فإن يُرفض (forbid_direct_post).
- S18-AC5: عندما يُعكس جرد نقدي لجلسة OPEN فإن تُنسب الحركة العكسية إليها ويصير الأصل REVERSED ولا تُغلق الجلسة قبل جرد جديد (ERP12).
- S18-AC6: عندما يُعكس جرد نقدي لجلسة CLOSED فإن تُسجَّل الحركة العكسية بلا جلسة ولا تُعاد الجلسة للفتح.
- S18-AC7: عندما يحاول من لا يملك الصلاحية العكس فإن لا يظهر له زر «عكس» وتُرفض الدالة بـ ERP16.

**13\. ملاحظات للمصمم**

- اعرض الأوراق النقدية كعدّادات (فئات) تجمع المبلغ تلقائياً (اختياري).
- الفرق: أخضر عند الصفر وأحمر غير ذلك.

### S19 — مرتجع مبيعات

**المنصة الأساسية:** Windows (والموبايل للمسح)

**1\. رقم واسم السيناريو**

S19 — مرتجع مبيعات

**2\. الدور (Actor)**

CASHIER وMANAGER

**3\. الهدف**

إرجاع أصناف من فاتورة مرحّلة واستردادها نقداً أو رصيداً للزبون.

**4\. الشروط المسبقة (Preconditions)**

- فاتورة بيع POSTED.
- المنفّذ يملك sales.return (ممنوحة للكاشير والمدير).

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| sales_returns | return_number, sale_id, customer_id, branch_id, warehouse_id, currency_id, return_date, status, refund_method, refund_payment_id, subtotal, notes |
| sales_return_items | sales_return_id, sale_item_id, variant_id, quantity, unit_refund_price, total_refund, condition_type, return_reason, restock |
| sales | invoice_number, doc_status, total_amount, customer_id |
| payments | payment_type, status, payment_date |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يبحث عن الفاتورة | شاشة المرتجعات | بحث برقم الفاتورة/الباركود/الزبون | SELECT | sales.invoice_number, sale_date, customer_id |
| 2 | يختار البنود والكميات | شاشة المرتجع (البنود) | جدول بنود الفاتورة مع المباع/المرتجع سابقاً وحقل كمية الإرجاع | SELECT | sale_items.quantity, sales_return_items.quantity |
| 3 | يحدد الحالة والسبب | شاشة المرتجع (البنود) | قائمة الحالة (قابل للبيع/تالف/معيب)، السبب، مفتاح «إعادة للمخزون» | INSERT | sales_return_items.condition_type, return_reason, restock |
| 4 | يختار طريقة الاسترداد (الكاشير يقرر) | شاشة المرتجع (الاسترداد) | خياران: نقداً أو رصيد للزبون | INSERT | sales_returns.refund_method |
| 5 | يؤكد | شاشة المرتجع | زر «ترحيل المرتجع» | RPC post_sales_return، ومع النقد دفعة REFUND مُرحَّلة | sales_returns.status = POSTED, refund_payment_id |
| 6 | يطبع إيصال المرتجع | إيصال المرتجع | طباعة/مشاركة | SELECT | sales_returns.return_number, subtotal |

**7\. المسارات البديلة (Alternative Flows)**

- لا توجد طريقة إلغاء لفاتورة مرحّلة: المرتجع هو الطريق الوحيد (قرار-15).
- البند بحالة DAMAGED أو DEFECTIVE مع restock = true يدخل آلياً مستودع DAMAGED في فرع المرتجع (post_sales_return)، بغض النظر عن مستودع المرتجع المحدد، ولا يدخل المخزون القابل للبيع أبداً (قرار-45). فإن لم يوجد مستودع تالف فعّال للفرع رُفض الترحيل بـ ERP22. والبند التالف مع restock = false يبقى بلا حركة مخزون لأنه لم يرجع فعلياً. ومصيره بعد ذلك ← S71.
- رصيد الزبون (CUSTOMER_CREDIT) يتطلب زبوناً محدداً.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| فاتورة أصل غير مرحّلة | ERP18 DOC_LINK_MISMATCH | فاتورة البيع الأصلية غير مُرحَّلة |
| كمية أكبر من المباع | فحص في post_sales_return (ERP22) | الكمية المرتجعة تتجاوز المباع |
| استرداد نقدي بلا دفعة | ERP18 | الاسترداد النقدي يتطلب دفعة REFUND مُرحَّلة |
| مرتجع بلا بنود | ERP22 | المرتجع بلا بنود |
| تالف في فرع بلا مستودع تالف فعّال | ERP22 INVALID_STATE | لا يوجد مستودع تالف فعّال لاستقبال التالف |

**9\. الصلاحيات (RLS)**

- sales_returns: القراءة (sales.view,sales.return,...) والكتابة sales.return مع الفرع.
- payments: الكتابة finance.payments لدفعة الاسترداد.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل البنود. |
| فارغ | لا نتائج للبحث. |
| خطأ | تلوين البند المخالف. |
| نجاح | إيصال مرتجع وشارة الطريقة. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- مرتجع POSTED، حركة SALES_RETURN للمخزون (إن restock)، وقيد/دفعة استرداد.

**12\. معايير القبول (Acceptance Criteria)**

- S19-AC1: عندما يُرجَع صنف قابل للبيع مع restock فإن يزداد رصيد المستودع.
- S19-AC2: عندما يُختار الاسترداد النقدي فإن لا يرحَّل المرتجع قبل ترحيل دفعة الاسترداد.
- S19-AC3: عندما يكون الصنف المرتجع تالفاً فإن لا يعود للمخزون القابل للبيع بل إلى مستودع التالف.

**13\. ملاحظات للمصمم**

- اعرض بنود الفاتورة كبطاقات قابلة للتحديد بنقرة.
- أبرز خيار طريقة الاسترداد كمفتاح من خيارين كبيرين.

### S20 — إدارة الفواتير المعلّقة والمسودات

**المنصة الأساسية:** Windows (والموبايل للمسح)

**1\. رقم واسم السيناريو**

S20 — إدارة الفواتير المعلّقة والمسودات

**2\. الدور (Actor)**

CASHIER وMANAGER

**3\. الهدف**

استئناف أو حذف فاتورة بيع لم تُرحَّل (المعلّقة)، علماً أن المرحَّلة لا تُلغى.

**4\. الشروط المسبقة (Preconditions)**

- فاتورة DRAFT من جلسة الكاشير نفسه.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| sales | invoice_number, sale_date, customer_id, total_amount, doc_status, pos_session_id |
| sale_items | sale_id, variant_id, quantity, unit_price, total_price |
| sales (إضافة) | price_list_id |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح «الفواتير المعلّقة» | قائمة الفواتير المعلّقة | جدول (الرقم، الوقت، الزبون، الإجمالي) | SELECT | sales.invoice_number, sale_date, total_amount, doc_status |
| 2 | يعاين فاتورة | تفاصيل فاتورة معلّقة | بنود الفاتورة | SELECT | sale_items.variant_id, quantity, total_price |
| 3 | يرى تنبيه تغيّر الأسعار | تفاصيل فاتورة معلّقة | شريط تنبيه بالأسطر التي تغيّر سعرها (السعر المثبَّت والسعر الحالي) | RPC get_draft_price_warnings(sale_id) | sale_items.list_price (الحالة: CHANGED أو NOT_FOUND) |
| 4 | يحدّث الأسعار أو يعدّل السطور | تفاصيل فاتورة معلّقة | زر «تحديث السعر» لسطر أو لكل الأسطر؛ أو حذف السطر وإضافته من جديد | RPC refresh_draft_line_prices(sale_id, line_ids) | sale_items.list_price, unit_price |
| 5 | يستأنفها | شاشة البيع | زر «استئناف» | — | — |
| 6 | أو يحذفها | تفاصيل فاتورة معلّقة | زر «حذف المسودة» مع تأكيد | DELETE (أو CANCELLED) | sales.doc_status |

**7\. المسارات البديلة (Alternative Flows)**

- فاتورة مرحّلة: لا يظهر زر إلغاء؛ يُحال المستخدم إلى المرتجع (S19) (قرار-15).
- المسودة لا تحجز مخزوناً؛ يُفحص المخزون والأسعار عند الترحيل، والأسعار تنبيه لا يُفشل الترحيل.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| تعديل بنود مرحّلة | ERP03 DOC_ITEMS_LOCKED | لا يجوز تعديل بنود مستند مرحّل |
| انتقال حالة غير مسموح | ERP02 | انتقال غير مسموح |
| تحديث أسعار فاتورة ليست مسودة | ERP03 DOC_ITEMS_LOCKED | لا يمكن تحديث أسعار فاتورة ليست مسودة |
| فاتورة بلا قائمة أسعار | ERP22 INVALID_STATE | الفاتورة بلا قائمة أسعار |

**9\. الصلاحيات (RLS)**

- sales وsale_items: الكتابة sales.create مع صلاحية تشغيل على الفرع.
- protect_posted_doc يمنع تعديل المرحّل.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا فواتير معلّقة». |
| خطأ | رسالة. |
| نجاح | اختفاء الفاتورة من القائمة. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- مسودة محذوفة أو مستأنفة؛ لا أثر على المخزون أو الحسابات.

**12\. معايير القبول (Acceptance Criteria)**

- S20-AC1: عندما تُحذف مسودة فإن لا يتغير مخزون ولا ينشأ قيد.
- S20-AC2: عندما تكون الفاتورة POSTED فإن لا يظهر زر الإلغاء.
- S20-AC3: عندما يتغيّر سعر صنف في القائمة بعد إضافته للمسودة فإن يظهر تنبيه ولا يُفشل الترحيل، ويستطيع الكاشير تحديث السعر.

**13\. ملاحظات للمصمم**

- اعرض مدة التعليق وفاتورة قديمة بلون تحذيري.

### S64 — اختيار قائمة الأسعار في نقطة البيع (جملة وتجزئة)

**المنصة الأساسية:** Windows (والموبايل للمسح)

**1\. رقم واسم السيناريو**

S64 — اختيار قائمة الأسعار في نقطة البيع (جملة وتجزئة)

**2\. الدور (Actor)**

CASHIER وMANAGER

**3\. الهدف**

اختيار قائمة أسعار مسموحة للفاتورة، واقتراح قائمة الزبون تلقائياً (جملة) إن كانت مسموحة.

**4\. الشروط المسبقة (Preconditions)**

- جلسة مفتوحة، وللمستخدم قائمة مسموحة واحدة على الأقل (S58).

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| sales | price_list_id, customer_id |
| customers | default_price_list_id |
| price_lists | name, code, currency_id, price_type |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يبدأ فاتورة | شاشة البيع | قائمة الأسعار الافتراضية للمستخدم محددة | RPC get_allowed_price_lists(branch, terminal, customer) | price_lists.name, price_type |
| 2 | يختار زبوناً مربوطاً بقائمة جملة | شاشة البيع | اقتراح «سعر الجملة» تلقائياً | SELECT | customers.default_price_list_id |
| 3 | يغيّر القائمة يدوياً (إن كان مخوَّلاً) | شاشة البيع | قائمة منسدلة بالقوائم المسموحة | UPDATE (فاتورة DRAFT) | sales.price_list_id |
| 4 | تُعاد تسعيرة السلة | شاشة البيع | تحديث الأسعار | RPC resolve_price / refresh_draft_line_prices | sale_items.list_price, unit_price |

**7\. المسارات البديلة (Alternative Flows)**

- قائمة الزبون اقتراح فقط: تُختار إن كانت مسموحة للمستخدم، وإلا تُستخدم قائمته الافتراضية مع رسالة.
- صنف بلا سعر جملة خاص: يُحسب بقاعدة نسبة الجملة (S57).
- المدير يصل لكل القوائم.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| قائمة غير مسموحة | ERP23 PRICE_LIST_NOT_ALLOWED | قائمة الأسعار المحددة غير مسموحة لك أو لنقطة البيع |
| صنف بلا سعر في القائمة | ERP25 PRICE_NOT_FOUND | لا يوجد سعر لهذا الصنف في قائمة الأسعار المحددة |

**9\. الصلاحيات (RLS)**

- get_allowed_price_lists تُرجع القوائم المسموحة بحسب المستخدم والنقطة؛ sale_header_guard يفرضها.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا قوائم مسموحة لك». |
| خطأ | على الحقل. |
| نجاح | القائمة المختارة بشارة على الفاتورة. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- فاتورة بقائمة مسموحة وأسعار مطابقة.

**12\. معايير القبول (Acceptance Criteria)**

- S64-AC1: عندما يُختار زبون جملة فإن تُقترح قائمة الجملة إن كانت مسموحة.
- S64-AC2: عندما يختار قائمة غير مسموحة فإن يُرفض بـ ERP23.

**13\. ملاحظات للمصمم**

- شارة واضحة لنوع القائمة (تجزئة/جملة) على السلة.

### S67 — زبون يطلب صنفاً غير متوفر في فرعي

**المنصة الأساسية:** Windows (والموبايل للمسح)

**1\. رقم واسم السيناريو**

S67 — زبون يطلب صنفاً غير متوفر في فرعي

**2\. الدور (Actor)**

CASHIER ثم WAREHOUSE وMANAGER

**3\. الهدف**

عرض الفروع التي فيها الصنف، ثم طلب تحويل، ثم البيع بعد وصوله.

**4\. الشروط المسبقة (Preconditions)**

- الرصيد في فرع الفاتورة غير كافٍ.
- صلاحية inventory.view_other_branches.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| stock_transfers | from_warehouse_id, to_warehouse_id, status |
| stock_transfer_items | variant_id, quantity_requested |
| inventory_balances | variant_id, warehouse_id, quantity_on_hand |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يرى توقيف البيع لنقص الرصيد | شاشة البيع | شارة «غير متوفر» | — | — |
| 2 | يعرض الفروع الأخرى | نافذة مخزون الفروع (S66) | الفرع والمستودع والكمية | RPC branch_stock_lookup | — |
| 3 | يطلب تحويلاً | نموذج تحويل (S26) | من مستودع الفرع الآخر إلى مستودع فرعي | INSERT | stock_transfers.from_warehouse_id, to_warehouse_id |
| 4 | بعد الاستلام يبيع | شاشة البيع (S16) | الصنف متاح | RPC post_sale | sales.doc_status = POSTED |

**7\. المسارات البديلة (Alternative Flows)**

- لا بيع من مستودع فرع آخر، بل تحويل أولاً (قرار-36).
- الإبلاغ للزبون بمدة الوصول (واجهة).

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| بيع من مستودع فرع آخر | ERP11 WAREHOUSE_NOT_SELLABLE | لا يمكن البيع إلا من مستودع تابع لفرع الفاتورة |

**9\. الصلاحيات (RLS)**

- inventory.transfer للتحويل، inventory.transfer.approve لاعتماد المرسل (S26).

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | — |
| خطأ | على الحقل. |
| نجاح | الطلب يظهر في قائمة التحويلات. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- تحويل مطلوب، ثم بيع بعد الاستلام.

**12\. معايير القبول (Acceptance Criteria)**

- S67-AC1: عندما لا يتوفر الصنف في الفرع فإن يمكن عرض الفروع الأخرى وطلب تحويل.

**13\. ملاحظات للمصمم**

- اربط زر «اطلب تحويلاً» مباشرة بنافذة الفروع.

### S80 — قائمة المبيعات وإعادة الطباعة والمشاركة

**المنصة الأساسية:** Windows (والموبايل للمسح)

**1\. رقم واسم السيناريو**

S80 — قائمة المبيعات وإعادة الطباعة والمشاركة

**2\. الدور (Actor)**

CASHIER وMANAGER (sales.view)، والاطلاع للمحاسب والمدقق

**3\. الهدف**

البحث في الفواتير السابقة وفتح تفاصيلها وإعادة طباعة الإيصال أو مشاركته، والانتقال إلى المرتجع.

**4\. الشروط المسبقة (Preconditions)**

- المنفّذ يملك sales.view وصلاحية على الفرع.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| sales | invoice_number, sale_date, customer_id, branch_id, pos_session_id, total_amount, doc_status, payment_status |
| sale_items | sale_id, variant_id, quantity, unit_price, discount, total_price |
| payments / payment_lines | payment_id, amount, currency_id, payment_method, line_type |
| customers | party_id, customer_code |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح قائمة المبيعات | قائمة المبيعات | جدول (الرقم، الوقت، الزبون، الإجمالي، حالة السداد)، مرشحات (التاريخ، الزبون، الحالة، الكاشير، الجلسة)، بحث برقم الفاتورة | SELECT | sales.invoice_number, sale_date, total_amount, doc_status, payment_status |
| 2 | يفتح فاتورة | تفاصيل فاتورة البيع | البنود والمدفوعات والزبون | SELECT | sale_items.variant_id, quantity, total_price; payment_lines.amount |
| 3 | يعيد الطباعة أو يشارك | شاشة الإيصال | أزرار «إعادة طباعة» و«واتساب» و«PDF» | — | sales.invoice_number, invoice_code (واجهة) |
| 4 | يبدأ مرتجعاً | تفاصيل فاتورة البيع | زر «مرتجع» (للفاتورة POSTED) | ← | S19 |

**7\. المسارات البديلة (Alternative Flows)**

- الفواتير المعلّقة (DRAFT) تُدار من S20 لا من هذه القائمة.
- لا زر إلغاء لفاتورة مرحّلة؛ المرتجع هو الطريق (قرار-15).
- يرى المستخدم فواتير فروعه المسموحة فقط.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| بلا صلاحية | سياسات sales | لا تملك صلاحية عرض المبيعات |

**9\. الصلاحيات (RLS)**

- sales وsale_items: القراءة (sales.view, sales.create, sales.post, ...) مع can_access_branch.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل للجدول. |
| فارغ | «لا فواتير في النطاق». |
| خطأ | رسالة مع إعادة محاولة. |
| نجاح | القائمة مرتبة بالأحدث. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- لا تغيّر في البيانات (استعلام وطباعة).

**12\. معايير القبول (Acceptance Criteria)**

- S80-AC1: عندما يبحث المستخدم برقم فاتورة فإن تظهر في القائمة.
- S80-AC2: عندما يعيد الطباعة فإن يخرج إيصال بالبيانات نفسها دون أي أثر على المخزون أو الحسابات.
- S80-AC3: عندما تكون الفاتورة POSTED فإن يظهر زر المرتجع ولا يظهر زر إلغاء.

**13\. ملاحظات للمصمم**

- إعادة الطباعة والمشاركة واجهة فقط ولا أثر لها في القاعدة (لا تدوين في audit_logs).
- اعرض شارة «نسخة» على الإيصال المعاد طباعته.

## وحدة 6: المشتريات

### S21 — إنشاء فاتورة شراء (مسودة)

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S21 — إنشاء فاتورة شراء (مسودة)

**2\. الدور (Actor)**

PURCHASER

**3\. الهدف**

إدخال أصناف مورد وكلفها ومستودع الاستلام قبل الترحيل.

**4\. الشروط المسبقة (Preconditions)**

- مورد فعّال وأصناف (متغيرات) فعّالة.
- المنفّذ يملك purchasing.create وصلاحية تشغيل على الفرع.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| purchase_invoices | supplier_id, branch_id, currency_id, exchange_rate, invoice_number, invoice_date, due_date, subtotal, discount, total_amount, doc_status, payment_status, notes |
| purchase_invoice_items | purchase_invoice_id, variant_id, warehouse_id, quantity, unit_cost, discount, total_cost, notes |
| suppliers | party_id, company_name, payment_terms_days, default_currency_id |
| product_variants | sku, variant_name, product_id |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يضغط «فاتورة شراء جديدة» | قائمة فواتير الشراء | جدول (الرقم، المورد، التاريخ، الحالة)، مرشحات | SELECT | purchase_invoices.invoice_number, invoice_date, doc_status, payment_status |
| 2 | يختار المورد | نموذج فاتورة شراء (الرأس) | بحث مورد، التاريخ، رقم فاتورة المورد، العملة، سعر الصرف، تاريخ الاستحقاق | SELECT | suppliers.company_name, payment_terms_days, default_currency_id |
| 3 | يضيف الأصناف | نموذج فاتورة شراء (البنود) | بحث/باركود، شبكة لون × مقاس للكميات والتكلفة مع «املأ الكل بـ N»، المستودع، الخصم | SELECT / INSERT | product_variants.sku; purchase_invoice_items.quantity, unit_cost, warehouse_id, discount |
| 4 | يراجع الإجماليات | نموذج فاتورة شراء (الملخص) | الإجمالي الفرعي، الخصم، الإجمالي | — | purchase_invoices.subtotal, discount, total_amount |
| 5 | يحفظ كمسودة | نموذج فاتورة شراء | زر «حفظ كمسودة» | INSERT | purchase_invoices.doc_status = DRAFT |

**7\. المسارات البديلة (Alternative Flows)**

- تعديل المسودة بحرية قبل الترحيل.
- حذف مسودة.
- نسخ فاتورة سابقة لمورد نفسه: واجهة فقط.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| كمية أو تكلفة غير صالحة | CHECK على البنود | الكمية والتكلفة يجب أن تكونا موجبتين |
| مورد أو مستودع فارغ | NOT NULL | أكمل بيانات الفاتورة |
| تعديل فاتورة مرحّلة | ERP03 DOC_ITEMS_LOCKED | لا يجوز تعديل بنود مستند مرحّل |
| سعر صرف غير صالح | CHECK على exchange_rate | سعر الصرف غير صالح |

**9\. الصلاحيات (RLS)**

- purchase_invoices: القراءة (purchasing.view,...) والكتابة (purchasing.create,purchasing.post) مع can_access_branch(branch_id, true).

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا بنود — أضف صنفاً». |
| خطأ | على الحقل/البند. |
| نجاح | الفاتورة بحالة «مسودة». |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- فاتورة DRAFT بلا أثر على المخزون أو الحسابات.

**12\. معايير القبول (Acceptance Criteria)**

- S21-AC1: عندما يُحفظ نموذج صحيح فإن تنشأ فاتورة بحالة DRAFT ولا يتغير المخزون.
- S21-AC2: عندما يختار المستخدم مورداً فإن تُملأ عملته وتاريخ استحقاقه من شروطه.

**13\. ملاحظات للمصمم**

- البنود جدول قابل للتحرير بسرعة (لوحة المفاتيح).
- أظهر مجموع التكلفة بعملة الفاتورة والأساسية.
- الكميات والتكلفة تُدخل من الأسهل للأصعب: «املأ الكل بـ N» ثم تعديل لون أو مقاس ثم خلية واحدة.

### S22 — ترحيل فاتورة شراء واستلام البضاعة

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S22 — ترحيل فاتورة شراء واستلام البضاعة

**2\. الدور (Actor)**

PURCHASER (يرحّل بنفسه، قرار-16)

**3\. الهدف**

اعتماد الفاتورة لزيادة المخزون وتحديث التكلفة وتسجيل الدين أو الدفع.

**4\. الشروط المسبقة (Preconditions)**

- فاتورة شراء DRAFT ببنود.
- المنفّذ يملك purchasing.post.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| purchase_invoices | doc_status, payment_status, total_amount, total_base, posted_at |
| stock_movements | variant_id, warehouse_id, movement_type, direction, quantity, unit_cost, reference_type, reference_id |
| inventory_balances | variant_id, warehouse_id, quantity_on_hand |
| variant_costs | variant_id, currency_id, average_cost, last_purchase_cost |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح المسودة ويراجعها | تفاصيل فاتورة الشراء | بنود وإجماليات، زر «ترحيل» | SELECT | purchase_invoices.doc_status, total_amount |
| 2 | يختار طريقة السداد | نافذة الترحيل | خياران: «دفع عند الاستلام» أو «آجل (يُسدَّد بعد الاستلام)» (يُختار عند كل فاتورة) | — | payments.payment_context = ON_PURCHASE_RECEIPT (عند الدفع) |
| 3 | يؤكد الترحيل | نافذة الترحيل | زر «تأكيد الترحيل» | RPC post_purchase_invoice(invoice_id) (+ post_payment عند الدفع) | purchase_invoices.doc_status = POSTED, posted_at |
| 4 | يرى النتيجة | تفاصيل الفاتورة (مرحّلة) | شارة «مرحّلة»، رابط «حركات المخزون» | SELECT | stock_movements.movement_type = PURCHASE_IN; inventory_balances.quantity_on_hand; variant_costs.average_cost |

**7\. المسارات البديلة (Alternative Flows)**

- آجل: يُسجَّل دين على المورد ويُسدَّد بسند دفع (S31).
- دفع عند الاستلام: تُنشأ دفعة بسياق ON_PURCHASE_RECEIPT؛ finance.payments ممنوحة للمشتري كاملة (قرار-16) وتتيح له كتابة سندات الدفع عموماً.
- تعديل فاتورة مرحّلة: ممنوع؛ العلاج مرتجع (S23).

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| ترحيل غير DRAFT | ERP02 DOC_BAD_TRANSITION | لا يمكن ترحيل فاتورة حالتها \[الحالة\] |
| فاتورة بلا بنود | ERP22 | الفاتورة بلا بنود |
| فترة مغلقة/مقفلة | ERP08 / ERP13 | الفترة المحاسبية مغلقة |
| بلا صلاحية | ERP16 | لا تملك صلاحية ترحيل المشتريات |
| قيد غير متوازن | ERP07 JOURNAL_UNBALANCED | القيد المولَّد غير متوازن (خطأ إعداد حسابات) |

**9\. الصلاحيات (RLS)**

- purchase_invoices: الكتابة (purchasing.create,purchasing.post) مع الفرع.
- stock_movements وinventory_balances: قراءة فقط؛ الكتابة عبر apply_stock_movement (SECURITY DEFINER).
- variant_costs: تتحدث من apply_purchase_cost فقط.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | زر الترحيل معطّل بدوّار. |
| فارغ | — |
| خطأ | رسالة بالسبب مع بقاء المسودة. |
| نجاح | الفاتورة مرحّلة مع أثرها على المخزون. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- فاتورة POSTED.
- حركة PURCHASE_IN لكل بند، ورصيد مزداد، وتكلفة بالمتوسط المرجّح، وقيد محاسبي وسطر في سجل المورد.

**12\. معايير القبول (Acceptance Criteria)**

- S22-AC1: عندما يُرحَّل فاتورة شراء فإن يزداد quantity_on_hand بكمية كل بند في مستودعه.
- S22-AC2: عندما يُرحَّل فإن يتحدث average_cost بالمتوسط المرجّح.
- S22-AC3: عندما تكون الفاتورة مرحّلة فإن لا يمكن تعديل بنودها.

**13\. ملاحظات للمصمم**

- نافذة الترحيل تلخّص الأثر: «سيزداد المخزون بـ X صنفاً، وسيُسجَّل دين Y».
- لا تُعرض التكلفة لمن لا يملك costs.view.

### S23 — مرتجع مشتريات

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S23 — مرتجع مشتريات

**2\. الدور (Actor)**

PURCHASER (purchasing.return)

**3\. الهدف**

إرجاع بضاعة لمورد من فاتورة شراء مرحّلة وتسوية القيمة.

**4\. الشروط المسبقة (Preconditions)**

- فاتورة شراء POSTED.
- رصيد كافٍ في المستودع.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| purchase_returns | return_number, purchase_invoice_id, supplier_id, branch_id, warehouse_id, currency_id, return_date, status, settlement_method, return_reason, refund_payment_id, subtotal |
| purchase_return_items | purchase_return_id, purchase_invoice_item_id, variant_id, quantity, unit_cost, total_cost |
| purchase_invoices | invoice_number, supplier_id, doc_status |
| suppliers | party_id, company_name |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يبحث عن الفاتورة | شاشة مرتجعات المشتريات | بحث برقم الفاتورة أو المورد | SELECT | purchase_invoices.invoice_number, supplier_id |
| 2 | يختار البنود والكميات | نموذج مرتجع شراء | بنود الفاتورة بالكمية المشتراة/المرتجعة سابقاً وحقل كمية الإرجاع | SELECT / INSERT | purchase_return_items.quantity, unit_cost |
| 3 | يحدد السبب والتسوية | نموذج مرتجع شراء | السبب، التسوية (رصيد دائن لدى المورد / استرداد نقدي) | INSERT | purchase_returns.return_reason, settlement_method |
| 4 | يرحّل | نموذج مرتجع شراء | زر «ترحيل المرتجع» | RPC post_purchase_return | purchase_returns.status = POSTED |

**7\. المسارات البديلة (Alternative Flows)**

- الاسترداد النقدي يتطلب دفعة REFUND مرحّلة قبل الترحيل.
- مرتجع جزئي على عدة دفعات.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| فاتورة أصل غير مرحّلة | ERP18 DOC_LINK_MISMATCH | فاتورة الشراء الأصلية غير مرحّلة |
| رصيد غير كافٍ | ERP04 INSUFFICIENT_STOCK | الرصيد لا يكفي للإرجاع |
| كمية فوق المشتراة | purchase_return_item_guard | الكمية تتجاوز المشتراة |
| استرداد نقدي بلا دفعة | ERP18 | الاسترداد النقدي يتطلب دفعة REFUND مرحّلة |

**9\. الصلاحيات (RLS)**

- purchase_returns: القراءة (purchasing.view,purchasing.return,...) والكتابة purchasing.return مع الفرع.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | لا فواتير مطابقة. |
| خطأ | تلوين البند. |
| نجاح | مرتجع مرحّل ورقمه. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- مرتجع POSTED، حركة PURCHASE_RETURN تنقص المخزون، وتسوية عند المورد.

**12\. معايير القبول (Acceptance Criteria)**

- S23-AC1: عندما يُرحَّل مرتجع شراء فإن ينقص الرصيد بالكمية ويتغير حساب المورد.
- S23-AC2: عندما تتجاوز الكمية المشتراة فإن يُرفض البند.

**13\. ملاحظات للمصمم**

- اعرض بنود الفاتورة الأصلية كمرجع ثابت على جانب الشاشة.

### S24 — ملاحظات المورد

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S24 — ملاحظات المورد

**2\. الدور (Actor)**

PURCHASER (كتابة) وWAREHOUSE (قراءة فقط)

**3\. الهدف**

تسجيل مشكلة مع مورد (نقص، لون خاطئ، خطأ فاتورة) ومتابعتها حتى الحل.

**4\. الشروط المسبقة (Preconditions)**

- مورد موجود (وفاتورة اختيارياً).
- purchasing.create أو parties.manage للكتابة؛ الأمين يملك purchasing.view فقط فيقرأ ولا يكتب.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| supplier_notes | supplier_id, purchase_invoice_id, type, note, status, resolved_at |
| suppliers | company_name, supplier_code |
| purchase_invoices | invoice_number, invoice_date |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح ملاحظات المورد | ملف المورد (تبويب الملاحظات) | قائمة بحالة OPEN/RESOLVED | SELECT | supplier_notes.type, note, status |
| 2 | يضيف ملاحظة | نموذج ملاحظة | النوع، الفاتورة (اختياري)، النص | INSERT | supplier_notes.supplier_id, purchase_invoice_id, type, note |
| 3 | يغلق ملاحظة | قائمة الملاحظات | زر «تم الحل» | UPDATE | supplier_notes.status = RESOLVED, resolved_at |

**7\. المسارات البديلة (Alternative Flows)**

- تصفية بحسب الحالة.
- إعادة فتح ملاحظة.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| نص فارغ | NOT NULL على note | اكتب نص الملاحظة |
| نوع غير صالح | CHECK على type | اختر نوعاً صحيحاً |

**9\. الصلاحيات (RLS)**

- supplier_notes: القراءة (purchasing.view,parties.view) والكتابة (purchasing.create,parties.manage).

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا ملاحظات». |
| خطأ | على الحقل. |
| نجاح | الملاحظة تظهر بحالة مفتوحة. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- ملاحظة مسجّلة بحالة OPEN أو RESOLVED.

**12\. معايير القبول (Acceptance Criteria)**

- S24-AC1: عندما تُحلّ ملاحظة فإن يُسجَّل resolved_at وتنتقل لحالة RESOLVED.

**13\. ملاحظات للمصمم**

- شارة ملوّنة للنوع (نقص/لون/فاتورة).

## وحدة 7: المخزون

### S25 — عرض أرصدة المخزون وحركته

**المنصة الأساسية:** موبايل وويب

**1\. رقم واسم السيناريو**

S25 — عرض أرصدة المخزون وحركته

**2\. الدور (Actor)**

WAREHOUSE وMANAGER وAUDITOR (ويطّلع الكاشير والمحاسب والمشتري بحسب inventory.view)

**3\. الهدف**

الاستعلام عن الكميات المتاحة والمحجوزة وتتبع حركة صنف.

**4\. الشروط المسبقة (Preconditions)**

- صلاحية inventory.view أو accounting.view أو reports.view مع صلاحية على المستودع.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| inventory_balances | variant_id, warehouse_id, quantity_on_hand, quantity_reserved |
| stock_movements | variant_id, warehouse_id, movement_type, direction, quantity, unit_cost, reference_type, reference_id, movement_date, notes |
| warehouses | code, name, warehouse_type, branch_id |
| product_variants | sku, variant_name, product_id |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح أرصدة المخزون | شاشة أرصدة المخزون | مرشحات (المستودع، المنتج، المتغير)، جدول (SKU، المستودع، المتوفر، المحجوز) | SELECT (v_stock_available) | inventory_balances.quantity_on_hand, quantity_reserved; warehouses.name; product_variants.sku |
| 2 | يرى الأصناف المنخفضة | شاشة أرصدة المخزون (تبويب «منخفض») | قائمة بالأصناف تحت الحد الأدنى | SELECT (v_low_stock) | inventory_balances.quantity_on_hand مقابل variant_reorder_levels.min_quantity |
| 3 | يفتح بطاقة صنف | بطاقة حركة الصنف | سجل زمني: النوع، الاتجاه، الكمية، المرجع | SELECT | stock_movements.movement_type, direction, quantity, reference_type, reference_id, movement_date |
| 4 | ينتقل للمستند المصدر | المستند المصدر | رابط من reference_type/reference_id | SELECT | stock_movements.reference_type, reference_id |

**7\. المسارات البديلة (Alternative Flows)**

- المخزون في الطريق: v_stock_in_transit للتحويلات المشحونة غير المستلمة.
- تصدير إلى Excel: واجهة.
- مخزون الفروع الأخرى (الفرع والمستودع والكمية) عبر branch_stock_lookup ← S66.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| مستودع خارج الصلاحية | can_access_warehouse | لا تملك صلاحية على هذا المستودع |
| محاولة تعديل حركة | ERP05 APPEND_ONLY | الجدول للإضافة فقط — صحّح بحركة معاكسة |

**9\. الصلاحيات (RLS)**

- inventory_balances وstock_movements: قراءة فقط (inventory.view,accounting.view,reports.view) مع can_access_warehouse.
- المستودع المركزي (بلا فرع) يتطلب warehouse.central.access.
- مستخدم المستودعات يرى مستودعات فروعه فقط؛ والاطلاع على الفروع الأخرى يلزمه inventory.view_other_branches.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا حركات في الفترة». |
| خطأ | رسالة مع إعادة المحاولة. |
| نجاح | — |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- لا تغيّر (استعلام).

**12\. معايير القبول (Acceptance Criteria)**

- S25-AC1: عندما يختار المستخدم مستودعاً فإن تُعرض أرصدته المسموحة فقط.
- S25-AC2: عندما يفتح بطاقة صنف فإن تظهر الحركات مرتبة زمنياً مع روابط للمستندات.

**13\. ملاحظات للمصمم**

- شارة حمراء على أصناف تحت الحد الأدنى.
- التكلفة تظهر فقط لمن يملك costs.view عبر v_stock_movements_costs.

### S26 — إنشاء تحويل مخزون والموافقة عليه

**المنصة الأساسية:** موبايل وويب

**1\. رقم واسم السيناريو**

S26 — إنشاء تحويل مخزون والموافقة عليه

**2\. الدور (Actor)**

WAREHOUSE (المرسل يوافق، قرار-17) وMANAGER

**3\. الهدف**

طلب نقل أصناف من مستودع إلى آخر وإقراره قبل الشحن.

**4\. الشروط المسبقة (Preconditions)**

- مستودعان فعّالان مختلفان.
- المنفّذ يملك inventory.transfer وللموافقة inventory.transfer.approve على المستودع المرسل.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| stock_transfers | transfer_number, from_warehouse_id, to_warehouse_id, status, requested_at, approved_at, notes |
| stock_transfer_items | stock_transfer_id, variant_id, quantity_requested, unit_cost, notes |
| warehouses | code, name, warehouse_type |
| product_variants | sku, variant_name |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يضغط «تحويل جديد» | قائمة التحويلات | جدول (الرقم، من، إلى، الحالة)، مرشحات | SELECT | stock_transfers.transfer_number, status |
| 2 | يختار المستودعين | نموذج تحويل | من مستودع، إلى مستودع، ملاحظات | SELECT | warehouses.name, from_warehouse_id, to_warehouse_id |
| 3 | يضيف الأصناف والكميات | نموذج تحويل (البنود) | بحث/باركود، الكمية المطلوبة، عرض المتاح بالمرسل | INSERT | stock_transfer_items.variant_id, quantity_requested |
| 4 | يحفظ مسودة | نموذج تحويل | زر حفظ | INSERT | stock_transfers.status = DRAFT |
| 5 | أمين المستودع المرسل يوافق | تفاصيل التحويل | زر «موافقة» أو «إلغاء» | RPC approve_transfer / cancel_transfer | stock_transfers.status = APPROVED, approved_at |

**7\. المسارات البديلة (Alternative Flows)**

- إلغاء التحويل قبل الشحن (cancel_transfer).
- التحويل المطلوب من مستودع آخر: طلب يوافق عليه أمين المرسل.
- approve_transfer تفحص require_warehouse على المستودع المرسل (from_warehouse_id) كما تفعل ship_transfer وcancel_transfer، فلا يوافق من لا صلاحية له على المرسل (قرار-17).
- الحصول على صنف متوفر في فرع آخر: تحويل ثم بيع ← S67.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| المصدر = الوجهة | CHECK/transfer_guard | المستودعان يجب أن يختلفا |
| انتقال غير مسموح | ERP02 DOC_BAD_TRANSITION | انتقال غير مسموح للتحويل: \[من\] ← \[إلى\] |
| بلا صلاحية موافقة | ERP16 | لا تملك صلاحية الموافقة على التحويل |
| موافقة من غير أمين المستودع المرسل | ERP16 PERMISSION_DENIED (require_warehouse) | لا تملك صلاحية التشغيل على هذا المستودع |
| كمية غير موجبة | CHECK | الكمية يجب أن تكون موجبة |

**9\. الصلاحيات (RLS)**

- stock_transfers: القراءة (inventory.transfer,inventory.transfer.approve,inventory.view,reports.view) والكتابة (inventory.transfer,inventory.transfer.approve) مع can_access_warehouse.
- stock_transfer_items: تتبع can_access_warehouse.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا تحويلات». |
| خطأ | على البند. |
| نجاح | الحالة APPROVED بشارة خضراء. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- تحويل APPROVED جاهز للشحن، بلا أثر مخزني بعد.

**12\. معايير القبول (Acceptance Criteria)**

- S26-AC1: عندما يوافق أمين المرسل فإن تصبح الحالة APPROVED ويُسجَّل approved_at.
- S26-AC2: عندما يُلغى التحويل قبل الشحن فإن لا يتأثر المخزون.
- S26-AC3: عندما يحاول من لا صلاحية له على المستودع المرسل الموافقة فإن يُرفض بـ ERP16 «لا تملك صلاحية التشغيل على هذا المستودع».

**13\. ملاحظات للمصمم**

- مخطط خطوات علوي: مسودة ← موافق ← بالطريق ← مستلم.

### S27 — شحن التحويل واستلامه

**المنصة الأساسية:** موبايل وويب

**1\. رقم واسم السيناريو**

S27 — شحن التحويل واستلامه

**2\. الدور (Actor)**

WAREHOUSE (المرسل يشحن والمستلم يستلم)

**3\. الهدف**

تسجيل الكميات المشحونة والمستلمة والتالفة والناقصة.

**4\. الشروط المسبقة (Preconditions)**

- تحويل APPROVED للشحن، أو IN_TRANSIT للاستلام.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| stock_transfers | status, shipped_at, shipped_by, received_at, received_by |
| stock_transfer_items | stock_transfer_id, variant_id, quantity_requested, quantity_shipped, quantity_received, quantity_damaged, quantity_missing |
| stock_movements | variant_id, warehouse_id, movement_type, direction, quantity |
| inventory_balances | variant_id, warehouse_id, quantity_on_hand |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | أمين المرسل يفتح تحويلاً موافقاً عليه | تفاصيل التحويل | قائمة البنود، زر «شحن» | SELECT | stock_transfer_items.quantity_requested |
| 2 | يدخل الكميات المشحونة | نافذة الشحن | حقل quantity_shipped لكل بند (افتراضي = المطلوب) | RPC ship_transfer(id, items) | stock_transfer_items.quantity_shipped, stock_transfers.status = IN_TRANSIT |
| 3 | أمين المستلم يفتح التحويل بالطريق | قائمة الواردات | تحويلات IN_TRANSIT إلى مستودعه | SELECT (v_stock_in_transit) | stock_transfers.status |
| 4 | يدخل المستلم والتالف والناقص | نافذة الاستلام | لكل بند: المستلم، التالف، الناقص (المجموع = المشحون) | RPC receive_transfer(id, items) | quantity_received, quantity_damaged, quantity_missing |
| 5 | يراجع الأثر | تفاصيل التحويل (مستلم) | حالة RECEIVED، الفروقات | SELECT (v_transfer_discrepancies) | stock_movements.movement_type = TRANSFER_OUT/TRANSFER_IN |

**7\. المسارات البديلة (Alternative Flows)**

- receive_transfer صارمة (قرار-42): التالف يُسجَّل في مستودع DAMAGED الفعّال للفرع المستلم حصراً (مثل WH2-DAMAGED)؛ فإن وُجدت كمية تالفة ولا مستودع تالف فعّال في الفرع المستلم رُفض الاستلام بـ ERP22 دون رجوع إلى مستودع تالف في فرع آخر. والناقص (quantity_missing) خسارة فورية لا تُوضع في أي مستودع (قرار-17).
- استلام جزئي: الناقص يُسجَّل ويظهر في تقرير الفروقات.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| شحن أكثر من المطلوب | ERP22 INVALID_STATE | الكمية المشحونة تتجاوز المطلوبة |
| رصيد غير كافٍ عند الشحن | ERP04 | الرصيد غير كافٍ في المستودع المرسل |
| مجموع الاستلام لا يطابق | ERP22 | المستلم + التالف + المفقود يجب أن يساوي المشحون |
| انتقال غير مسموح | ERP02 | انتقال غير مسموح للتحويل |
| فرع مستلم بلا مستودع تالف فعّال وفي الاستلام كمية تالفة | ERP22 INVALID_STATE | لا يوجد مستودع تالف فعّال لاستقبال التالف |

**9\. الصلاحيات (RLS)**

- stock_transfers: التحديث (inventory.transfer,inventory.transfer.approve) مع can_access_warehouse للمستودعين.
- حركات المخزون تُكتب عبر الدوال فقط.
- v_stock_in_transit وv_transfer_discrepancies فيهما العمودان unit_cost وloss_value وقيمتهما NULL دائماً (أعمدة التكلفة فارغة دائماً)؛ التكلفة وقيمة الخسارة في v_transfer_costs لمن يملك costs.view.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | دوّار على الزر. |
| فارغ | «لا تحويلات بالطريق». |
| خطأ | شريط فوق الجدول. |
| نجاح | الحالة RECEIVED وملخص الفروقات. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- خصم من المرسل عند الشحن، وزيادة عند الاستلام (للمستلم)، والتالف إلى مستودع DAMAGED، والناقص خسارة فورية، وفروقات مسجّلة.

**12\. معايير القبول (Acceptance Criteria)**

- S27-AC1: عندما يُشحن تحويل فإن تصبح حالته IN_TRANSIT ويظهر في «واردات» المستلم.
- S27-AC2: عندما يُستلم بتالف فإن تُسجَّل quantity_damaged ولا تُحسب ضمن المتوفر للبيع.
- S27-AC3: عندما يُسجَّل ناقص في الاستلام فإن يُعدّ خسارة فورية ويظهر في تقرير الفروقات بلا إضافته لأي مستودع.

**13\. ملاحظات للمصمم**

- شاشة الاستلام: جدول بحقول رقمية كبيرة ومجموع ثابت أسفلها يتلوّن عند الاختلال.

### S28 — تسوية الجرد

**المنصة الأساسية:** موبايل وويب

**1\. رقم واسم السيناريو**

S28 — تسوية الجرد

**2\. الدور (Actor)**

WAREHOUSE وMANAGER

**3\. الهدف**

تصحيح الكميات بعد العدّ الفعلي، دون موافقة إضافية (قرار-18).

**4\. الشروط المسبقة (Preconditions)**

- المنفّذ يملك inventory.adjust على المستودع.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| stock_adjustments | adjustment_number, warehouse_id, adjustment_date, status, reason, posted_at, notes |
| stock_adjustment_items | stock_adjustment_id, variant_id, system_quantity, counted_quantity, difference_quantity, unit_cost, notes |
| inventory_balances | variant_id, warehouse_id, quantity_on_hand |
| stock_movements | variant_id, warehouse_id, movement_type, direction, quantity |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يضغط «تسوية جديدة» | قائمة التسويات | جدول (الرقم، المستودع، السبب، الحالة) | SELECT | stock_adjustments.adjustment_number, reason, status |
| 2 | يختار المستودع والسبب | نموذج تسوية | المستودع، التاريخ، السبب (تصحيح عدّ/تلف/فقد/موجود/أخرى) | INSERT | stock_adjustments.warehouse_id, adjustment_date, reason |
| 3 | يدخل الكميات المعدودة | نموذج تسوية (البنود) | بحث/باركود، المتوقع (من النظام)، المعدود، الفرق المحسوب | SELECT / INSERT | inventory_balances.quantity_on_hand; stock_adjustment_items.system_quantity, counted_quantity, difference_quantity |
| 4 | يرحّل التسوية | نموذج تسوية | زر «ترحيل» | RPC post_stock_adjustment(id) | stock_adjustments.status, posted_at |
| 5 | يراجع الأثر | تفاصيل التسوية | الحركات الناتجة | SELECT | stock_movements.movement_type = ADJUSTMENT_IN/ADJUSTMENT_OUT |
| 6 | يعكس تسوية مرحّلة عند الحاجة | تفاصيل التسوية | زر «عكس» (لمن يملك inventory.adjust على المستودع) وحقل سبب | RPC reverse_stock_adjustment(p_adjustment_id, p_reason) | stock_adjustments.status = REVERSED؛ stock_movements (حركات عكسية) |

**7\. المسارات البديلة (Alternative Flows)**

- جرد جزئي لتصنيف أو رف.
- إلغاء مسودة قبل الترحيل.
- لا موافقة إلزامية (قرار-18): الأمين أو المدير يرحّل التسوية مباشرة.
- لا ترحيل بـ UPDATE مباشر (قرار-43).
- عكس التسوية المرحّلة: reverse_stock_adjustment(p_adjustment_id, p_reason) لمن يملك inventory.adjust مع صلاحية المستودع (قرار-44)؛ فتصير التسوية الأصلية REVERSED وتُنشأ حركات مقابلة، ولا يُعكس المستند العكسي ولا تُعكس التسوية مرتين.
- إتلاف أو تصريف صنف تالف: تسوية بسبب DAMAGE ← S71.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| سبب غير صالح | CHECK على reason | اختر سبباً من القائمة |
| رصيد سلبي بعد التسوية | ERP04 INSUFFICIENT_STOCK | الرصيد بعد التسوية سالب |
| انتقال حالة غير مسموح | ERP02 | انتقال غير مسموح |
| عكس تسوية غير POSTED أو مستند عكسي أو معكوس مسبقاً | ERP02 DOC_BAD_TRANSITION | انتقال حالة غير مسموح للمستند |
| عكس زيادة والرصيد الحالي لا يسمح | ERP04 INSUFFICIENT_STOCK | الرصيد الحالي لا يسمح بعكس الزيادة |
| عكس بلا صلاحية أو بلا صلاحية المستودع | ERP16 PERMISSION_DENIED | لا تملك الصلاحية المطلوبة لهذه العملية |
| عكس ببيانات أو حالة غير صالحة | ERP22 INVALID_STATE | حالة أو بيانات غير صالحة للعملية |
| فترة مغلقة (ترحيل أو عكس) | ERP08 / ERP13 | الفترة المحاسبية مغلقة |

**9\. الصلاحيات (RLS)**

- stock_adjustments: القراءة (accounting.view,inventory.adjust,inventory.view) والكتابة inventory.adjust مع can_access_warehouse.
- stock_adjustment_items: تتبع can_access_warehouse.
- reverse_stock_adjustment: صلاحيتها inventory.adjust مع صلاحية المستودع.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا تسويات». |
| خطأ | على البند. |
| نجاح | الفرق الصافي بعد الترحيل. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- حركات ADJUSTMENT_IN/OUT تعادل الفرق، والرصيد = المعدود، وقيد محاسبي (بحسب الإعداد).

**12\. معايير القبول (Acceptance Criteria)**

- S28-AC1: عندما يُدخل المعدود فإن يُحسب الفرق = المعدود − المتوقع ويظهر ملوّناً.
- S28-AC2: عندما تُرحَّل التسوية فإن يصبح رصيد الصنف مساوياً للمعدود.
- S28-AC3: عندما لا يوجد قيد وحركة مقابلة فإن لا تصير التسوية POSTED.
- S28-AC4: عندما تُعكس تسوية مرحّلة فإن تصير حالتها REVERSED وتُنشأ حركات مقابلة ويعود الرصيد.
- S28-AC5: عندما يكون الرصيد الحالي لا يسمح بعكس زيادة فإن يُرفض العكس بـ ERP04.
- S28-AC6: عندما يحاول من لا يملك inventory.adjust على المستودع العكس فإن لا يظهر له زر «عكس» وتُرفض الدالة بـ ERP16.

**13\. ملاحظات للمصمم**

- شاشة العدّ بالباركود: كل مسح يزيد المعدود بواحد.
- الأصناف بفرق مقارنة بالمتوقع في أعلى القائمة.

### S29 — مستويات إعادة الطلب

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S29 — مستويات إعادة الطلب

**2\. الدور (Actor)**

MANAGER وPURCHASER وWAREHOUSE (catalog.manage)

**3\. الهدف**

تحديد الحد الأدنى وكمية الطلب لكل صنف ومستودع لتغذية تنبيهات المخزون المنخفض.

**4\. الشروط المسبقة (Preconditions)**

- متغيرات ومستودعات فعّالة.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| variant_reorder_levels | variant_id, warehouse_id, min_quantity, reorder_quantity |
| product_variants | sku, variant_name |
| inventory_balances | variant_id, warehouse_id, quantity_on_hand |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح مستويات إعادة الطلب | شاشة مستويات الطلب | مرشح المستودع، جدول (SKU، المتوفر، الحد الأدنى، كمية الطلب) | SELECT | variant_reorder_levels.min_quantity, reorder_quantity; inventory_balances.quantity_on_hand |
| 2 | يعدّل الحد لصنف أو مجموعة | شاشة مستويات الطلب | تحرير داخل الخلية أو تعبئة جماعية | UPSERT | variant_reorder_levels.variant_id, warehouse_id, min_quantity, reorder_quantity |
| 3 | يحفظ | شاشة مستويات الطلب | زر «حفظ» | UPSERT | variant_reorder_levels |

**7\. المسارات البديلة (Alternative Flows)**

- نسخ الحدود من مستودع إلى آخر.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| قيمة سالبة | CHECK على min_quantity/reorder_quantity | القيمة لا تكون سالبة |
| تكرار (متغير، مستودع) | UNIQUE على (variant_id, warehouse_id) | الحد موجود مسبقاً لهذا الصنف والمستودع |

**9\. الصلاحيات (RLS)**

- variant_reorder_levels: الكتابة catalog.manage (المدير والمشتري والأمين).

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لم تُحدَّد حدود». |
| خطأ | على الخلية. |
| نجاح | تظهر في v_low_stock عند النقص. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- حدود محدّثة تغذّي التنبيهات.

**12\. معايير القبول (Acceptance Criteria)**

- S29-AC1: عندما ينخفض المتوفر عن min_quantity فإن يظهر الصنف في قائمة المنخفض.

**13\. ملاحظات للمصمم**

- تحرير مباشر في الجدول مع تلوين ما هو تحت الحد.

### S66 — الاطلاع على مخزون الفروع الأخرى

**المنصة الأساسية:** موبايل وويب

**1\. رقم واسم السيناريو**

S66 — الاطلاع على مخزون الفروع الأخرى

**2\. الدور (Actor)**

CASHIER وMANAGER وWAREHOUSE وPURCHASER (inventory.view_other_branches)

**3\. الهدف**

رؤية كمية صنف في مستودعات الفروع الأخرى (الفرع والمستودع والكمية) دون القدرة على البيع منها.

**4\. الشروط المسبقة (Preconditions)**

- المنفّذ يملك inventory.view_other_branches.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| warehouses | branch_id, code, name, is_sellable |
| inventory_balances | variant_id, warehouse_id, quantity_on_hand, quantity_reserved |
| branches | code, name |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يضغط «مخزون الفروع الأخرى» على صنف | شاشة البيع أو بطاقة الصنف | زر | RPC branch_stock_lookup(variant, current_branch) | — |
| 2 | يرى الجدول | نافذة مخزون الفروع | الفرع، المستودع، الكمية، المتاح | — | inventory_balances.quantity_on_hand, quantity_reserved (عبر الدالة) |

**7\. المسارات البديلة (Alternative Flows)**

- تُعرض المستودعات القابلة للبيع في الفروع الأخرى فقط.
- الاطلاع بلا بيع: البيع من مستودع فرع آخر ممنوع (ERP11)؛ الحل تحويل ثم بيع (S67).

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| بلا صلاحية | ERP16 | لا تملك صلاحية الاطلاع على مخزون الفروع الأخرى |

**9\. الصلاحيات (RLS)**

- الدالة SECURITY DEFINER تتطلب inventory.view_other_branches؛ لا تُستخدم user_branch_access.can_view كي لا يرى الكاشير فواتير فرع آخر.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا مخزون في الفروع الأخرى». |
| خطأ | على الحقل. |
| نجاح | الجدول مع اسم الفرع والمستودع. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- لا تغيّر (استعلام).

**12\. معايير القبول (Acceptance Criteria)**

- S66-AC1: عندما يطلب الكاشير الاطلاع فإن يرى الفرع والمستودع والكمية فقط.

**13\. ملاحظات للمصمم**

- اعرض «لا يمكن البيع من هنا» بجانب الأرقام.

### S71 — معالجة المخزون التالف

**المنصة الأساسية:** موبايل وويب

**1\. رقم واسم السيناريو**

S71 — معالجة المخزون التالف

**2\. الدور (Actor)**

WAREHOUSE وMANAGER (inventory.adjust وinventory.transfer)

**3\. الهدف**

تقرير مصير الأصناف التي دخلت مستودع التالف: إتلاف، أو إرجاع للمورد، أو إعادتها لمستودع قابل للبيع بعد الإصلاح.

**4\. الشروط المسبقة (Preconditions)**

- أصناف في مستودع DAMAGED للفرع (من مرتجع مبيعات S19 أو استلام تحويل S27).

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| inventory_balances | variant_id, warehouse_id, quantity_on_hand |
| stock_adjustments | warehouse_id, reason, status |
| stock_transfers | from_warehouse_id, to_warehouse_id |
| purchase_returns | purchase_invoice_id, warehouse_id, return_reason |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح مخزون التالف | شاشة أرصدة المخزون (مرشح التالف) | أصناف مستودع DAMAGED | SELECT (v_stock_available) | inventory_balances.quantity_on_hand |
| 2 | يختار المصير لكل صنف | نافذة معالجة التالف | إتلاف / إرجاع للمورد / إعادة للبيع | — | — |
| 3 | إتلاف: تسوية | نموذج تسوية (S28) | سبب DAMAGE | INSERT / UPDATE status = POSTED | stock_adjustments.reason = DAMAGE |
| 4 | إرجاع للمورد: مرتجع شراء | نموذج مرتجع شراء (S23) | بنود التالف | RPC post_purchase_return | purchase_returns |
| 5 | إعادة للبيع: تحويل | نموذج تحويل (S26) | من DAMAGED إلى مستودع قابل للبيع | INSERT | stock_transfers.from_warehouse_id, to_warehouse_id |

**7\. المسارات البديلة (Alternative Flows)**

- التوجيه إلى مستودع DAMAGED آلي في الحالتين (مرتجع المبيعات قرار-45، واستلام التحويل قرار-42) ولا يحتاج تدخلاً.
- الناقص في التحويل لا يدخل التالف: هو خسارة فورية (قرار-17).

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| رصيد غير كافٍ | ERP04 INSUFFICIENT_STOCK | الرصيد غير كافٍ |

**9\. الصلاحيات (RLS)**

- حسب الإجراء المنفَّذ: inventory.adjust أو inventory.transfer أو purchasing.return.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا تالف». |
| خطأ | على الحقل. |
| نجاح | الرصيد ينقص من مستودع التالف. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- مصير كل صنف تالف مسجّل بمستند.

**12\. معايير القبول (Acceptance Criteria)**

- S71-AC1: عندما يُعاد صنف للبيع فإن ينتقل من DAMAGED إلى مستودع قابل للبيع بتحويل.

**13\. ملاحظات للمصمم**

- اعرض المصير كثلاثة أزرار كبيرة.

## وحدة 8: المالية

### S30 — سند قبض من زبون وتخصيصه

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S30 — سند قبض من زبون وتخصيصه

**2\. الدور (Actor)**

ACCOUNTANT وCASHIER وMANAGER (finance.payments)

**3\. الهدف**

استلام مبلغ من زبون وتخصيصه على فواتير مدينة أو كسلفة.

**4\. الشروط المسبقة (Preconditions)**

- زبون عليه رصيد أو يريد دفع سلفة.
- حساب مالي فعّال بعملة الدفع.
- المنفّذ يملك finance.payments.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| payments | party_id, branch_id, pos_session_id, payment_type, payment_context, reason_id, status, payment_date, reference_number, reversal_of_payment_id |
| payment_lines | payment_id, financial_account_id, currency_id, amount, direction, line_type, payment_method, exchange_rate, reference_number |
| payment_allocations | payment_id, payment_line_id, party_id, sale_id, debt_currency_id, source_currency_id, settled_amount, source_amount, exchange_rate, allocation_type |
| financial_accounts | name, type, currency_id, branch_id, is_active |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يضغط «سند قبض جديد» | قائمة السندات | جدول السندات، زر «سند قبض» | SELECT | payments.payment_date, payment_type, status |
| 2 | يختار الزبون | نموذج سند قبض | بحث زبون، عرض رصيده والفواتير المفتوحة | SELECT (v_open_documents) | payments.party_id; فواتير sales المفتوحة |
| 3 | يدخل أسطر القبض | نموذج سند قبض (الأسطر) | وسيلة الدفع، الحساب المالي، العملة، المبلغ، سعر الصرف | INSERT | payment_lines.payment_method, financial_account_id, currency_id, amount, exchange_rate |
| 4 | يخصص المبلغ | نموذج سند قبض (التخصيص) | قائمة الفواتير بمبلغ التخصيص لكل فاتورة، والباقي سلفة | INSERT | payment_allocations.sale_id, settled_amount, source_amount, allocation_type (DEBT/ADVANCE) |
| 5 | يرحّل | نموذج سند قبض | زر «ترحيل» | RPC post_payment(id) | payments.status = POSTED |

**7\. المسارات البديلة (Alternative Flows)**

- سلفة بلا فواتير (ADVANCE_PAYMENT).
- قبض بعملة تختلف عن عملة الدين: يُطلب سعر الصرف وحقلا settled_amount/source_amount.
- عكس السند: RPC reverse_payment ينشئ دفعة معاكسة مرتبطة بالأصل (reversal_of_payment_id) ويتطلب payment.cancel، ويصير الأصل REVERSED؛ ولا إلغاء مباشر لسند مرحّل (قرار-44).
- تطبيق سلفة قائمة على فاتورة ← S79.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| اتجاه السطر لا يناسب النوع | ERP22 INVALID_STATE | اتجاه السطر لا يناسب نوع الدفعة |
| عملة السلفة مختلفة | ERP10 CURRENCY_MISMATCH | السلفة تُسجَّل بعملة الدفع نفسها |
| حساب غير فعّال | ERP20 ACCOUNT_TYPE_INVALID | الحساب المالي غير فعّال |
| سبب لا يصلح | ERP17 REASON_MISMATCH | السبب المختار لا يصلح لهذه العملية |
| فترة مغلقة | ERP08/ERP13 | الفترة المحاسبية مغلقة |
| بلا صلاحية | ERP16 | لا تملك صلاحية ترحيل الدفعات |

**9\. الصلاحيات (RLS)**

- payments: الكتابة (finance.payments,payment.cancel) مع صلاحية تشغيل على branch_id.
- payment_lines وpayment_allocations: نفس الصلاحيتين مع الفرع.
- financial_accounts: القراءة (finance.view,finance.payments,pos.session,...) مع الفرع.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا فواتير مفتوحة — يُسجَّل كسلفة». |
| خطأ | على السطر. |
| نجاح | السند مرحّل وانخفاض ظاهر في رصيد الزبون. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- سند POSTED، حركات في financial_transactions، وتحديث payment_status للفواتير المخصَّصة وسجل الزبون.

**12\. معايير القبول (Acceptance Criteria)**

- S30-AC1: عندما يُخصَّص قبض كامل على فاتورة فإن تصبح payment_status = PAID.
- S30-AC2: عندما يزيد القبض عن الديون فإن يُسجَّل الباقي سلفة.
- S30-AC3: عندما يُعكس سند فإن يُنشأ سند عكسي مرتبط بالأصل.

**13\. ملاحظات للمصمم**

- وزّع المبلغ تلقائياً من الأقدم للأحدث مع إمكانية التعديل.
- اعرض الرصيد قبل وبعد.

### S31 — سند دفع لمورد

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S31 — سند دفع لمورد

**2\. الدور (Actor)**

ACCOUNTANT وPURCHASER (finance.payments، قرار-16)

**3\. الهدف**

تسديد مبلغ لمورد وتخصيصه على فواتير الشراء المستحقة أو كسلفة.

**4\. الشروط المسبقة (Preconditions)**

- مورد عليه رصيد.
- حساب مالي فعّال بالعملة وبرصيد كافٍ.
- المنفّذ يملك finance.payments.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| payments | party_id, branch_id, payment_type, payment_context, reason_id, status, payment_date, reference_number |
| payment_lines | payment_id, financial_account_id, currency_id, amount, direction, payment_method, exchange_rate |
| payment_allocations | payment_id, purchase_invoice_id, party_id, debt_currency_id, source_currency_id, settled_amount, source_amount, allocation_type |
| financial_accounts | name, type, currency_id, branch_id |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يضغط «سند دفع جديد» | قائمة السندات | زر «سند دفع» | SELECT | payments.payment_type = SUPPLIER_PAYMENT |
| 2 | يختار المورد | نموذج سند دفع | بحث مورد، الفواتير المستحقة وتواريخ استحقاقها | SELECT (v_open_documents) | purchase_invoices.due_date, payment_status |
| 3 | يدخل أسطر الدفع | نموذج سند دفع (الأسطر) | وسيلة، حساب مالي (صندوق/بنك)، عملة، مبلغ، سعر صرف | INSERT | payment_lines.direction = OUT, financial_account_id, amount |
| 4 | يخصص على الفواتير | نموذج سند دفع (التخصيص) | مبلغ التخصيص لكل فاتورة شراء | INSERT | payment_allocations.purchase_invoice_id, settled_amount |
| 5 | يرحّل | نموذج سند دفع | زر «ترحيل» | RPC post_payment(id) | payments.status = POSTED |

**7\. المسارات البديلة (Alternative Flows)**

- دفعة مقدّمة للمورد (ADVANCE_PAYMENT).
- عملة الدفع تختلف عن عملة الفاتورة: يُحسب سعر الصرف.
- عكس الدفعة: RPC reverse_payment (payment.cancel) (قرار-44)، ويصير الأصل REVERSED.
- المشتري يدفع للمورد عند الترحيل (S22) أو بسند دفع بعد الترحيل بصلاحيته finance.payments؛ ولا يرحّل دفعات المالك أو الموظف (قرار-46).

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| اتجاه السطر | ERP22 | اتجاه السطر لا يناسب نوع الدفعة |
| تخصيص يتجاوز المستحق | payment_allocation_guard | المبلغ المخصَّص يتجاوز المستحق |
| حساب غير فعّال | ERP20 | الحساب المالي غير فعّال |
| فترة مغلقة | ERP08/ERP13 | الفترة المحاسبية مغلقة |

**9\. الصلاحيات (RLS)**

- payments/payment_lines/payment_allocations: الكتابة (finance.payments,payment.cancel) مع صلاحية الفرع.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا فواتير مستحقة». |
| خطأ | على السطر. |
| نجاح | تحديث payment_status للفواتير. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- سند POSTED، صرف من الحساب المالي، فواتير مسدّدة جزئياً أو كلياً.

**12\. معايير القبول (Acceptance Criteria)**

- S31-AC1: عندما يُخصَّص دفع على فاتورة فإن ينخفض المستحق وتتحدث payment_status.
- S31-AC2: عندما لا يغطي الدفع الفاتورة فإن تصبح PARTIAL.

**13\. ملاحظات للمصمم**

- رتّب الفواتير بحسب الاستحقاق وأبرز المتأخرة.

### S32 — تسجيل مصروف

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S32 — تسجيل مصروف

**2\. الدور (Actor)**

ACCOUNTANT (ينشئ ويرحّل) وCASHIER (مصروف صغير من الصندوق)

**3\. الهدف**

تسجيل مصروف تشغيلي من حساب مالي مع تصنيفه.

**4\. الشروط المسبقة (Preconditions)**

- فئة مصروف وحساب مالي فعّالان.
- المنفّذ يملك finance.expenses ويعمل على الفرع.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| expenses | branch_id, expense_category_id, payee_party_id, reference_number, amount, currency_id, exchange_rate, amount_base, financial_account_id, status, expense_date, notes, reviewed_by, reviewed_at, review_note, receipt_image_path |
| expense_categories | name, code, gl_account_id, is_active |
| financial_accounts | name, type, currency_id, branch_id |
| financial_transactions | financial_account_id, transaction_type, direction, amount, currency_id, source_expense_id, transaction_date |
| Storage: bucket expense-receipts (خاص) | المسار يبدأ برقم الفرع |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يضغط «مصروف جديد» | قائمة المصروفات | جدول (التاريخ، الفئة، المبلغ، الحالة) | SELECT | expenses.expense_date, amount, status |
| 2 | يعبّئ البيانات | نموذج مصروف | الفئة، المستفيد (اختياري)، المبلغ، العملة، الحساب المالي، رقم المرجع، الملاحظات | SELECT (قوائم) | expense_categories.name; expenses.amount, currency_id, financial_account_id, reference_number |
| 3 | يحفظ ويرحّل | نموذج مصروف | زر «حفظ» وزر «ترحيل» | INSERT ثم RPC post_expense(id) | expenses.status |
| 4 | يرى أثره | تفاصيل المصروف | رابط الحركة المالية | SELECT | financial_transactions.source_expense_id, direction = OUT |
| 5 | يرفق صورة الإيصال (اختياري) | نموذج المصروف أو تفاصيله | زر «إرفاق صورة الإيصال» | رفع الملف إلى bucket expense-receipts (Storage API) ثم RPC attach_expense_receipt(p_expense_id, p_path) | expenses.receipt_image_path |

**7\. المسارات البديلة (Alternative Flows)**

- مصروف الكاشير: الحساب المالي = صندوق جلسته ويظهر في جرد الإغلاق، بلا سقف مبلغ (قرار-19)، وكل مصروف يسجّله الكاشير يظهر للمحاسب في قائمة مراجعة (S65).
- عكس مصروف مرحّل: RPC reverse_expense ينشئ مستنداً معاكساً مرتبطاً بالأصل عبر reversal_of ويتطلب accounting.post (قرار-44)، ويصير الأصل REVERSED؛ ولا إلغاء مباشر. لا ترحيل بـ UPDATE مباشر (قرار-43).
- فئة EXP-SAL: لمصروفات أجور لا ترتبط بموظف مسجّل (عمالة مؤقتة، وكالات). أما راتب موظف مسجّل فبدفعة S69 بسبب EMP_SAL. وكلاهما على الحساب 6101 بلا تضارب (قرار-50).
- إيصال المصروف اختياري: attach_expense_receipt تسمح بالإرفاق أو الاستبدال حتى بعد الترحيل ما لم يُراجَع المصروف (S65)، لمن أنشأه أو يملك finance.expenses، ولا تُرفق لمستند عكسي.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| مبلغ غير موجب | تحقق واجهة | المبلغ يجب أن يكون موجباً |
| حساب غير فعّال | ERP20 | الحساب المالي غير فعّال |
| فترة مغلقة | ERP08/ERP13 | الفترة المحاسبية مغلقة |
| بلا صلاحية | ERP16 | لا تملك صلاحية ترحيل المصروفات |
| إرفاق إيصال بلا صلاحية أو بلا تسجيل دخول صالح | ERP16 PERMISSION_DENIED (attach_expense_receipt) | لا تملك الصلاحية المطلوبة لهذه العملية |
| إرفاق إيصال لمصروف غير موجود | ERP22 INVALID_STATE | المصروف غير موجود |
| إرفاق إيصال لمصروف ليس POSTED (أو مستند عكسي) | ERP22 INVALID_STATE | لا يُرفق إيصال إلا لمصروف مرحّل |
| إرفاق أو استبدال إيصال لمصروف مراجَع | ERP22 INVALID_STATE | المصروف مراجَع ولا يُستبدل إيصاله |
| مسار الإيصال غير صالح أو لا يبدأ برقم فرع المصروف | ERP22 INVALID_STATE | مسار الإيصال غير صالح |
| الملف غير موجود في bucket expense-receipts | ERP22 INVALID_STATE | لم يُعثر على ملف الإيصال |

**9\. الصلاحيات (RLS)**

- expenses: القراءة (finance.view,finance.expenses,accounting.view,reports.view) والكتابة finance.expenses مع can_access_branch(branch_id, true).
- expense_categories: الكتابة (accounting.manage,finance.manage).
- attach_expense_receipt: لمن أنشأ المصروف أو يملك finance.expenses؛ وbucket expense-receipts خاص ويبدأ المسار فيه برقم الفرع.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا مصروفات». |
| خطأ | على الحقل. |
| نجاح | ظهور المصروف بحالة «مرحّل». |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- مصروف POSTED، حركة EXPENSE صادرة، وقيد مرتبط بحساب الفئة.

**12\. معايير القبول (Acceptance Criteria)**

- S32-AC1: عندما يُرحَّل مصروف فإن ينقص رصيد الحساب المالي بالمبلغ.
- S32-AC2: عندما يسجّل الكاشير مصروفاً من صندوقه فإن ينعكس في المتوقع بجرد الإغلاق.
- S32-AC3: عندما يسجّل الكاشير مصروفاً فإن يظهر في قائمة مراجعة المحاسب (S65).
- S32-AC4: عندما يُعكس مصروف فإن يُنشأ مستند معاكس مرتبط بالأصل، ويصير الأصل REVERSED، ويعود رصيد الحساب المالي.
- S32-AC5: عندما يرفق المنشئ أو من يملك finance.expenses صورة إيصال لمصروف مرحّل غير مراجَع فإن يُحفظ المسار في receipt_image_path ويجوز استبدالها.
- S32-AC6: عندما يُراجَع المصروف أو يكون مستنداً عكسياً فإن يُرفض إرفاق الإيصال أو استبداله بـ ERP22.

**13\. ملاحظات للمصمم**

- لا سقف لمبلغ مصروف الكاشير بحسب قرار-19؛ الضبط بالمراجعة (S65).
- زر «إرفاق صورة الإيصال» اختياري في نموذج المصروف، ويُخفى زر الاستبدال بعد المراجعة.

### S33 — تحويل أموال بين الحسابات

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S33 — تحويل أموال بين الحسابات

**2\. الدور (Actor)**

ACCOUNTANT (finance.manage)

**3\. الهدف**

نقل مبلغ بين صندوق وبنك أو بين عملتين مع سعر صرف فعلي.

**4\. الشروط المسبقة (Preconditions)**

- حسابان ماليان فعّالان مختلفان.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| money_transfers | from_account_id, to_account_id, from_amount, to_amount, exchange_rate, transfer_date, status, reason_type, reason_id, related_party_id, notes |
| financial_accounts | name, type, currency_id |
| financial_transactions | financial_account_id, transaction_type, direction, amount, currency_id, source_money_transfer_id |
| payment_reasons | code, name, applies_to |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يضغط «تحويل جديد» | قائمة التحويلات المالية | جدول (من، إلى، المبلغ، الحالة) | SELECT | money_transfers.transfer_date, from_amount, to_amount, status |
| 2 | يختار الحسابين | نموذج تحويل مالي | حساب المصدر وحساب الوجهة مع أرصدتهما | SELECT | financial_accounts.name, type, currency_id |
| 3 | يدخل المبالغ | نموذج تحويل مالي | مبلغ الخروج، مبلغ الدخول، سعر الصرف (مطلوب عند اختلاف العملتين) | — | money_transfers.from_amount, to_amount, exchange_rate |
| 4 | يحدد السبب | نموذج تحويل مالي | قائمة الأسباب، الطرف المرتبط (اختياري)، ملاحظات | SELECT | payment_reasons.name; money_transfers.reason_id, related_party_id |
| 5 | يرحّل | نموذج تحويل مالي | زر «ترحيل» | RPC post_money_transfer(id) | money_transfers.status |

**7\. المسارات البديلة (Alternative Flows)**

- تحويل بنفس العملة: يُخفى سعر الصرف ويتساوى المبلغان.
- إلغاء مسودة.
- عكس تحويل مرحّل: RPC reverse_money_transfer (accounting.post) بمستند معاكس مرتبط بالأصل (قرار-44)، ويصير الأصل REVERSED.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| عملتان مختلفتان بلا سعر | ERP15 TRANSFER_RATE_INVALID | الحسابان بعملتين مختلفتين: سعر الصرف الفعلي مطلوب |
| حساب المصدر = الوجهة | money_transfer_guard | الحسابان يجب أن يختلفا |
| سبب لا يناسب | ERP17 | السبب المختار لا يصلح لهذه العملية |
| فترة مغلقة | ERP08/ERP13 | الفترة المحاسبية مغلقة |

**9\. الصلاحيات (RLS)**

- money_transfers: القراءة (accounting.view,finance.manage,finance.view) والكتابة finance.manage.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا تحويلات». |
| خطأ | على الحقل. |
| نجاح | حركتان (خروج ودخول). |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- حركتا TRANSFER في financial_transactions، وقيد محاسبي.

**12\. معايير القبول (Acceptance Criteria)**

- S33-AC1: عندما يُرحَّل تحويل فإن ينقص حساب المصدر بـ from_amount ويزيد الوجهة بـ to_amount.
- S33-AC2: عندما تختلف العملتان بلا سعر فإن يُمنع الترحيل.

**13\. ملاحظات للمصمم**

- اعرض المبلغ المكافئ بالعملة الثانية فور إدخال السعر.

### S34 — كشف حساب طرف وأرصدته

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S34 — كشف حساب طرف وأرصدته

**2\. الدور (Actor)**

ACCOUNTANT وAUDITOR

**3\. الهدف**

عرض حركة مديونية زبون أو مورد ورصيده بكل عملة.

**4\. الشروط المسبقة (Preconditions)**

- صلاحية parties.view أو accounting.view أو finance.view أو reports.view.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| party_ledger_entries | party_id, currency_id, entry_date, entry_type, debit, credit, source_type, source_id |
| parties | party_type, name, phone |
| currencies | code, symbol, decimal_places |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح الأرصدة | شاشة الأرصدة | تبويبات زبائن/موردين، جدول (الطرف، العملة، الرصيد) | SELECT (v_party_balances) | party_ledger_entries.party_id, currency_id, debit, credit |
| 2 | يختار طرفاً | كشف حساب | الفترة، العملة، الأرصدة الافتتاحي/الختامي | SELECT | party_ledger_entries.entry_date, entry_type, debit, credit |
| 3 | يتتبع سطراً | كشف حساب | رابط من source_type/source_id للمستند | SELECT | party_ledger_entries.source_type, source_id |
| 4 | يرى المستندات المفتوحة | كشف حساب (مفتوحة) | فواتير غير مسدّدة | SELECT (v_open_documents) | sales/purchase_invoices المفتوحة |
| 5 | يصدّر/يطبع | كشف حساب | أزرار PDF/Excel | — | — |

**7\. المسارات البديلة (Alternative Flows)**

- رصيد بعدة عملات: تبويب لكل عملة.
- تصفية نوع القيد (OPENING SALE PAYMENT ADJUSTMENT...).

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| بلا صلاحية | سياسة party_ledger_entries | لا تملك صلاحية عرض الأرصدة |
| فترة بلا حركات | نتيجة فارغة | لا حركات في الفترة |

**9\. الصلاحيات (RLS)**

- party_ledger_entries: قراءة فقط (parties.view,accounting.view,finance.view,reports.view)؛ تُكتب بالدوال.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل للجدول. |
| فارغ | «لا حركات». |
| خطأ | رسالة مع إعادة محاولة. |
| نجاح | — |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- لا تغيّر (استعلام).

**12\. معايير القبول (Acceptance Criteria)**

- S34-AC1: عندما يختار المستخدم طرفاً وفترة فإن يظهر رصيد افتتاحي وحركات ورصيد ختامي بالعملة.
- S34-AC2: عندما يضغط سطراً فإن يُفتح مستنده المصدر.

**13\. ملاحظات للمصمم**

- الرصيد الجاري عمود ثابت؛ مدين/دائن بلونين هادئين.

### S35 — تسوية رصيد طرف

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S35 — تسوية رصيد طرف

**2\. الدور (Actor)**

ACCOUNTANT (balance.adjust)

**3\. الهدف**

تعديل رصيد زبون أو مورد (إعفاء/تصحيح/افتتاحي) بسبب موثّق.

**4\. الشروط المسبقة (Preconditions)**

- المنفّذ يملك balance.adjust.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| balance_adjustments | adjustment_number, party_id, currency_id, side, amount, reason_id, adjustment_date, status, reversal_of_id, posted_at, notes |
| party_ledger_entries | party_id, currency_id, entry_type, debit, credit |
| payment_reasons | code, name, applies_to |
| parties | name, party_type |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يضغط «تسوية جديدة» | قائمة تسويات الأرصدة | جدول (الرقم، الطرف، الجانب، المبلغ، الحالة) | SELECT | balance_adjustments.adjustment_number, side, amount, status |
| 2 | يختار الطرف والعملة | نموذج تسوية رصيد | بحث طرف، العملة، رصيده الحالي | SELECT | party_ledger_entries (الرصيد) |
| 3 | يحدد الجانب والمبلغ والسبب | نموذج تسوية رصيد | مدين/دائن، المبلغ، السبب (أسباب نوع تسوية)، ملاحظات | SELECT / INSERT | balance_adjustments.side, amount, reason_id, notes |
| 4 | يرحّل | نموذج تسوية رصيد | زر «ترحيل» | RPC post_balance_adjustment(id) | balance_adjustments.status, posted_at |
| 5 | يعكس تسوية (اختياري) | تفاصيل تسوية | زر «عكس» | RPC reverse_balance_adjustment(id) | balance_adjustments.reversal_of_id |

**7\. المسارات البديلة (Alternative Flows)**

- العكس (reverse_balance_adjustment) يُنشئ تسوية جديدة مرتبطة ولا يحذف الأصل، ويتطلب accounting.post (قرار-44)، ويصير الأصل REVERSED.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| مبلغ غير موجب | CHECK على amount | المبلغ يجب أن يكون موجباً |
| سبب غير مناسب | ERP17 | السبب المختار لا يصلح لهذه العملية |
| فترة مغلقة | ERP08/ERP13 | الفترة المحاسبية مغلقة |
| بلا صلاحية | ERP16 | لا تملك صلاحية تسوية الأرصدة |

**9\. الصلاحيات (RLS)**

- balance_adjustments: القراءة (accounting.view,parties.view,balance.adjust,finance.view) والكتابة balance.adjust.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا تسويات». |
| خطأ | على الحقل. |
| نجاح | تحديث رصيد الطرف. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- تسوية POSTED وسطر ADJUSTMENT في سجل الطرف وقيد.

**12\. معايير القبول (Acceptance Criteria)**

- S35-AC1: عندما تُرحَّل تسوية مدينة فإن يزداد مدين الطرف بالمبلغ.
- S35-AC2: عندما تُعكس فإن تُنشأ تسوية مضادة مرتبطة.

**13\. ملاحظات للمصمم**

- اعرض الرصيد قبل/بعد في ملخص ثابت.

### S36 — سحوبات ومساهمات الملاك

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S36 — سحوبات ومساهمات الملاك

**2\. الدور (Actor)**

ACCOUNTANT (owner.transactions وfinance.payments)

**3\. الهدف**

تسجيل سحب مالك أو إيداعه برأس المال.

**4\. الشروط المسبقة (Preconditions)**

- مالك معرّف في owners (طرف + نسبة).
- حساب مالي وسبب نوع OWNER_WITHDRAWAL أو OWNER_CONTRIBUTION.
- post_payment يشترط owner.transactions لهذين النوعين (قرار-46).

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| owners | party_id, ownership_percentage, is_active |
| payments | party_id, branch_id, payment_type, reason_id, status, payment_date |
| payment_lines | payment_id, financial_account_id, currency_id, amount, direction, payment_method |
| payment_reasons | code, name, payment_type, gl_account_id |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح الملاك | قائمة الملاك | جدول (الاسم، النسبة، الحالة) | SELECT | owners.ownership_percentage, parties.name |
| 2 | يضغط «سحب» أو «مساهمة» | نموذج حركة مالك | النوع، المالك، السبب | INSERT | payments.payment_type, party_id, reason_id |
| 3 | يدخل المبلغ والحساب | نموذج حركة مالك | المبلغ، العملة، الحساب المالي، وسيلة الدفع | INSERT | payment_lines.amount, direction, financial_account_id |
| 4 | يرحّل | نموذج حركة مالك | زر «ترحيل» | RPC post_payment | payments.status = POSTED |

**7\. المسارات البديلة (Alternative Flows)**

- إضافة مالك جديد ← S72.
- تعديل النسبة.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| نسبة خارج 0–100 | CHECK على ownership_percentage | النسبة غير صالحة |
| سبب لا يناسب | ERP17 | السبب المختار لا يصلح لهذه العملية |
| اتجاه خاطئ | ERP22 | اتجاه السطر لا يناسب نوع الدفعة |
| ترحيل بلا owner.transactions | ERP16 | لا تملك صلاحية حركات الملاك |

**9\. الصلاحيات (RLS)**

- owners: القراءة (owner.transactions,accounting.view) والكتابة owner.transactions.
- payments: finance.payments.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا ملاك». |
| خطأ | على الحقل. |
| نجاح | الحركة مرحّلة. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- حركة مالك مرحّلة وقيد مرتبط بحساب السبب.

**12\. معايير القبول (Acceptance Criteria)**

- S36-AC1: عندما يُرحَّل سحب مالك فإن ينقص الحساب المالي ويُقيَّد على حساب الملاك.

**13\. ملاحظات للمصمم**

- شاشة حساسة: اطلب تأكيداً بصيغة واضحة قبل الترحيل.

### S37 — إدارة البنوك والحسابات المالية

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S37 — إدارة البنوك والحسابات المالية

**2\. الدور (Actor)**

ACCOUNTANT (finance.manage)

**3\. الهدف**

تعريف بنك وحسابه وحسابات مالية (صندوق/بنك) بعملاتها.

**4\. الشروط المسبقة (Preconditions)**

- العملات معرّفة.
- صناديق معرّفة (S05).

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| banks | name, code, is_active |
| bank_accounts | bank_id, branch_id, currency_id, account_name, account_number, is_active |
| financial_accounts | name, type, currency_id, branch_id, cashbox_account_id, bank_account_id, gl_account_id, is_active |
| cashbox_accounts | cashbox_id, currency_id, is_active |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح الحسابات المالية | قائمة الحسابات المالية | جدول (الاسم، النوع، العملة، الفرع، الرصيد) | SELECT (v_financial_account_balances) | financial_accounts.name, type, currency_id |
| 2 | يضيف بنكاً | نموذج بنك | الاسم، الرمز | INSERT | banks.name, code |
| 3 | يضيف حساباً بنكياً | نموذج حساب بنكي | البنك، الفرع، العملة، اسم الحساب، رقمه | INSERT | bank_accounts.bank_id, currency_id, account_name, account_number |
| 4 | ينشئ حساباً مالياً | نموذج حساب مالي | النوع (CASH/BANK)، الربط بحساب صندوق أو حساب بنكي، حساب دفتر الأستاذ | INSERT | financial_accounts.type, cashbox_account_id, bank_account_id, gl_account_id |

**7\. المسارات البديلة (Alternative Flows)**

- تعطيل حساب بدل حذفه.
- كل حساب مالي مرتبط بمصدر واحد فقط: صندوق أو بنك.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| نوع حساب لا يطابق الربط | ERP20 ACCOUNT_TYPE_INVALID | نوع الحساب لا يطابق الصندوق/البنك المرتبط |
| عملة مختلفة | account_currency_guard | عملة الحساب المالي يجب أن تطابق عملة مصدره |
| رقم حساب مكرر | UNIQUE | رقم الحساب مستخدم |

**9\. الصلاحيات (RLS)**

- banks: الكتابة (finance.manage,masterdata.manage).
- bank_accounts وfinancial_accounts: الكتابة finance.manage مع الفرع.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا حسابات». |
| خطأ | على الحقل. |
| نجاح | الحساب يظهر برصيد صفر. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- حسابات مالية جاهزة للسندات والمصروفات.

**12\. معايير القبول (Acceptance Criteria)**

- S37-AC1: عندما يُنشأ حساب مالي فإن يظهر في قوائم السندات والمصروفات للفرع المعني.

**13\. ملاحظات للمصمم**

- اعرض الرصيد الحالي لكل حساب بطاقة (عملة وفرع).

### S65 — مراجعة المصروفات الصغيرة للكاشير

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S65 — مراجعة المصروفات الصغيرة للكاشير

**2\. الدور (Actor)**

ACCOUNTANT (accounting.manage) وMANAGER (finance.view وfinance.expenses) وSUPER_ADMIN؛ المدقق لا يعلّم والكاشير لا يراجع مصروفاته

**3\. الهدف**

مراجعة المصروفات التي سجّلها الكاشير من صندوقه (بلا سقف مبلغ) وتعليمها «تمت المراجعة» مع اسم المراجِع والوقت وملاحظة اختيارية.

**4\. الشروط المسبقة (Preconditions)**

- المنفّذ يملك accounting.manage، أو يملك finance.view وfinance.expenses مع صلاحية تشغيل على الفرع.
- المصروف POSTED وليس مستنداً عكسياً.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| expenses | branch_id, expense_category_id, amount, currency_id, financial_account_id, status, expense_date, created_by, notes, reviewed_by, reviewed_at, review_note |
| pos_sessions | cashier_user_id, status |
| list_expenses_for_review (دالة) | expense_id, reference_number, branch_id, cashier_user_id, cashier_name, pos_session_id, category_id, category_name, amount, currency_id, currency_code, expense_date, review_status, notes |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح قائمة المراجعة | مراجعة مصروفات الكاشير | جدول (الكاشير، الجلسة، الفئة، المبلغ، التاريخ، حالة المراجعة)، مرشح «مراجَع / غير مراجَع»، مرشح الفرع | RPC list_expenses_for_review(p_branch_id) | expense_id, reference_number, cashier_name, pos_session_id, category_name, amount, currency_code, expense_date, review_status |
| 2 | يفتح مصروفاً | تفاصيل المصروف | المبلغ، الفئة، الملاحظات، المراجِع والوقت إن وُجدا | SELECT | expenses.expense_category_id, notes, reviewed_by, reviewed_at, review_note |
| 3 | يعلّمه مراجَعاً مع ملاحظة اختيارية | تفاصيل المصروف | حقل ملاحظة، زر «تمت المراجعة» | RPC mark_expense_reviewed(p_expense_id, p_note) | expenses.reviewed_by, reviewed_at, review_note |
| 4 | يرى حالة المراجعة | مراجعة مصروفات الكاشير | شارة «مراجَع» مع اسم المراجِع والوقت، وتبقى الأسطر غير المراجَعة ظاهرة بالمرشح | RPC list_expenses_for_review | review_status |

**7\. المسارات البديلة (Alternative Flows)**

- تصحيح مصروف خاطئ: عكسه بـ reverse_expense (accounting.post) ثم إعادة قيده (قرار-44)؛ المصروف المعكوس حالته REVERSED ولا يُعلَّم مراجَعاً.
- المصروف المراجَع لا يُستبدل إيصاله (S32).
- المدقق لا يعلّم، والكاشير لا يراجع مصروفاته.
- المرشح «غير مراجَع» يعرض ما ينتظر المراجعة، و«مراجَع» يعرض ما راجعه المحاسب مع المراجِع والوقت.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| بلا صلاحية | ERP16 PERMISSION_DENIED | لا تملك الصلاحية المطلوبة لهذه العملية |
| مصروف غير موجود | ERP22 INVALID_STATE | المصروف غير موجود |
| مصروف ليس POSTED | ERP22 INVALID_STATE | لا تُراجَع إلا المصروفات المرحّلة |
| مستند عكسي | ERP22 INVALID_STATE | لا تُراجَع المستندات العكسية |
| مصروف مراجَع مسبقاً | ERP22 INVALID_STATE | هذا المصروف مراجَع مسبقاً |

**9\. الصلاحيات (RLS)**

- mark_expense_reviewed: صلاحيتها accounting.manage أو (finance.view وfinance.expenses) مع تشغيل على الفرع.
- list_expenses_for_review: دالة (لا View) تقبل p_branch_id اختيارياً.
- expenses: القراءة (finance.view وfinance.expenses وaccounting.view وreports.view) مع الفرع.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا مصروفات للمراجعة». |
| خطأ | رسالة على الزر بالسبب. |
| نجاح | تتحول الشارة إلى «مراجَع» مع المراجِع والوقت. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- مصروف مراجَع: reviewed_by وreviewed_at وreview_note (إن وُجدت) محفوظة.
- سجل العملية في audit_logs.

**12\. معايير القبول (Acceptance Criteria)**

- S65-AC1: عندما يسجّل الكاشير مصروفاً فإن يظهر في القائمة بحالة غير مراجَع.
- S65-AC2: عندما يعلّم المحاسب مصروفاً مراجَعاً فإن تُسجَّل reviewed_by وreviewed_at وreview_note وتصير حالته مراجَع.
- S65-AC3: عندما يُعلَّم مصروف مراجَع مرة ثانية فإن يُرفض بـ ERP22.
- S65-AC4: عندما يحاول المدقق أو الكاشير التعليم فإن يُرفض بـ ERP16 ولا يظهر الزر.
- S65-AC5: عندما يكون المصروف غير POSTED أو عكسياً فإن يُرفض التعليم بـ ERP22.

**13\. ملاحظات للمصمم**

- أبرز المصروفات الكبيرة بلون تحذيري.
- اعرض المراجِع والوقت بجانب شارة «مراجَع».

### S68 — الأرصدة الافتتاحية وبدء التشغيل

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S68 — الأرصدة الافتتاحية وبدء التشغيل

**2\. الدور (Actor)**

ACCOUNTANT وSUPER_ADMIN (accounting.manage)

**3\. الهدف**

إدخال المخزون بتكلفته وأرصدة الصناديق والبنوك وأرصدة الزبائن والموردين عبر معالج، والتأكد من الجاهزية قبل تفعيل منع البيع بلا تكلفة.

**4\. الشروط المسبقة (Preconditions)**

- المنفّذ يملك accounting.manage (أو finance.manage للصناديق).
- الحسابات المالية مربوطة بحسابات الدليل، والمنتجات ومتغيراتها والأطراف موجودة.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| stock_movements | variant_id, warehouse_id, movement_type = OPENING, quantity, unit_cost |
| variant_costs | variant_id, average_cost, last_purchase_cost |
| financial_transactions | financial_account_id, transaction_type = OPENING, amount |
| party_ledger_entries | party_id, currency_id, entry_type = OPENING, debit, credit, source_type |
| journal_entries | source_type (OPENING_STOCK, OPENING_CASH, OPENING_PARTY) |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح المعالج | معالج بدء التشغيل | خطوات: مخزون، صناديق وبنوك، زبائن، موردون، الجاهزية | RPC opening_readiness() | — |
| 2 | يدخل المخزون الافتتاحي لمستودع | خطوة المخزون | شبكة لون × مقاس بالكمية والتكلفة والعملة مع «املأ الكل بـ N» | RPC post_opening_stock(warehouse, date, items) | stock_movements, inventory_balances, variant_costs |
| 3 | يدخل رصيد كل صندوق وبنك | خطوة الصناديق والبنوك | حساب مالي، مبلغ، تاريخ | RPC post_opening_cash(account, amount, date, notes) | financial_transactions |
| 4 | يدخل أرصدة الأطراف | خطوة الزبائن والموردين | طرف، النوع (ذمة أو دفعة مقدمة)، العملة، المبلغ | RPC post_opening_party_balance(party, kind, currency, amount, date) | party_ledger_entries |
| 5 | يراجع الجاهزية | خطوة الجاهزية | أعداد: متغيرات بلا تكلفة، أصناف بمخزون بلا تكلفة، حسابات بلا افتتاحي | RPC opening_readiness() | — |
| 6 | يفعّل منع البيع بلا تكلفة | الإعدادات (S78) | REQUIRE_COST_ON_SALE = Y عند اكتمال الجاهزية | UPSERT | settings.value_text |

**7\. المسارات البديلة (Alternative Flows)**

- أنواع رصيد الأطراف: CUSTOMER_RECEIVABLE وCUSTOMER_ADVANCE وSUPPLIER_PAYABLE وSUPPLIER_ADVANCE.
- كل صنف في مستودع، وكل حساب مالي، وكل (طرف، عملة، نوع) يُدخل مرة واحدة؛ التصحيح بتسوية (S28 وS35) لا بإعادة الإدخال.
- التكلفة إلزامية للمخزون الافتتاحي (شرط REQUIRE_COST_ON_SALE).
- كل خطوة تولّد قيداً مقابل حساب الأرصدة الافتتاحية (OPENING_BALANCE_EQUITY).

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| رصيد افتتاحي مكرر | ERP22 INVALID_STATE | رصيد افتتاحي مسجّل مسبقاً. التصحيح بتسوية لا بإعادة الإدخال |
| كمية أو مبلغ غير موجب | ERP22 | الكمية (أو المبلغ) الافتتاحية يجب أن تكون أكبر من صفر |
| بلا تكلفة | ERP22 | التكلفة مطلوبة للرصيد الافتتاحي ولا تكون سالبة |
| حساب مالي بلا ربط محاسبي | ERP22 | الحساب المالي غير مربوط بحساب في الدليل المحاسبي |
| طرف ليس زبوناً أو مورداً | ERP22 | الطرف ليس زبوناً / ليس مورداً |
| فترة مغلقة | ERP08/ERP13 | الفترة المحاسبية مغلقة |

**9\. الصلاحيات (RLS)**

- post_opening_stock وpost_opening_party_balance تتطلبان accounting.manage؛ post_opening_cash تتطلب accounting.manage أو finance.manage؛ opening_readiness تتطلب accounting.manage أو accounting.view.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لم يُدخل أي رصيد بعد». |
| خطأ | على الحقل. |
| نجاح | عدّادات الجاهزية تتحول إلى أصفر ثم أخضر. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- مخزون بتكلفته وأرصدة مالية وأرصدة أطراف وقيود افتتاحية.

**12\. معايير القبول (Acceptance Criteria)**

- S68-AC1: عندما يُدخل رصيد مخزون فإن يتحدث average_cost وتُسجَّل حركة OPENING.
- S68-AC2: عندما يكرر المستخدم رصيداً لصنف في المستودع نفسه فإن يُرفض.
- S68-AC3: عندما تظهر الجاهزية كاملة فإن يُسمح بتفعيل منع البيع بلا تكلفة.

**13\. ملاحظات للمصمم**

- معالج بخطوات مرقّمة وشريط تقدم، وتأكيد قبل كل ترحيل لأنه لا يُعاد.

### S69 — دفعة راتب أو سلفة لموظف

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S69 — دفعة راتب أو سلفة لموظف

**2\. الدور (Actor)**

ACCOUNTANT (finance.payments)

**3\. الهدف**

تسجيل دفعة راتب أو سلفة لموظف من شاشة الدفعات؛ الرواتب في v1 دفعات فقط.

**4\. الشروط المسبقة (Preconditions)**

- موظف فعّال، وحساب مالي فعّال، وأسباب دفع «راتب» و«سلفة» (EMP_SAL وEMP_ADV).

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| payments | party_id, branch_id, payment_type = EMPLOYEE_PAYMENT, reason_id, status, payment_date |
| payment_lines | payment_id, financial_account_id, currency_id, amount, direction |
| payment_reasons | code, name, payment_type, gl_account_id |
| employees | party_id, employee_code |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يضغط «دفعة موظف» | قائمة السندات | زر «راتب/سلفة» | SELECT | payments.payment_type |
| 2 | يختار الموظف والسبب | نموذج دفعة موظف | الموظف، السبب (راتب/سلفة) | SELECT | payment_reasons.code, name |
| 3 | يدخل المبلغ والحساب | نموذج دفعة موظف | المبلغ، العملة، الحساب المالي | INSERT | payment_lines.amount, financial_account_id, direction = OUT |
| 4 | يرحّل | نموذج دفعة موظف | زر «ترحيل» | RPC post_payment(id) | payments.status = POSTED |

**7\. المسارات البديلة (Alternative Flows)**

- سبب EMP_SAL لراتب موظف مسجّل وEMP_ADV لسلفته؛ أما أجور غير المسجّلين (عمالة مؤقتة، وكالات) فمصروف بفئة EXP-SAL (S32). كلاهما على 6101 بلا تضارب (قرار-50).
- post_payment يشترط لنوع EMPLOYEE_PAYMENT صلاحية finance.payments مع accounting.manage أو finance.manage، فلا يرحّله المشتري ولا الكاشير (قرار-46).
- القيد: الراتب يُدين الرواتب والأجور (6101) والسلفة تُدين سلف الموظفين (1203) مقابل الصندوق أو البنك.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| سبب لا يناسب | ERP17 REASON_MISMATCH | السبب المختار لا يصلح لهذه العملية |
| ترحيل بلا accounting.manage أو finance.manage | ERP16 | لا تملك صلاحية دفعات الموظفين |
| فترة مغلقة | ERP08/ERP13 | الفترة المحاسبية مغلقة |

**9\. الصلاحيات (RLS)**

- payments: الكتابة finance.payments أو payment.cancel مع الفرع.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا دفعات». |
| خطأ | على الحقل. |
| نجاح | الدفعة تظهر مرحّلة. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- دفعة موظف مرحّلة وقيد مناسب.

**12\. معايير القبول (Acceptance Criteria)**

- S69-AC1: عندما يُرحَّل راتب فإن ينقص الحساب المالي ويُقيَّد على الرواتب والأجور.

**13\. ملاحظات للمصمم**

- لا جدول رواتب ولا حضور في هذه النسخة؛ سجّلها كدفعات فقط.

### S70 — فئات المصروف وأسباب الدفع

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S70 — فئات المصروف وأسباب الدفع

**2\. الدور (Actor)**

ACCOUNTANT (accounting.manage أو finance.manage)

**3\. الهدف**

تعريف فئات المصروف وأسباب الدفع وربط كل منها بحساب الدليل.

**4\. الشروط المسبقة (Preconditions)**

- المنفّذ يملك accounting.manage أو finance.manage.
- حسابات الدليل موجودة.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| expense_categories | name, code, gl_account_id, is_active |
| payment_reasons | code, name, applies_to, payment_type, gl_account_id, is_active |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح الفئات والأسباب | الفئات والأسباب | تبويبان | SELECT | expense_categories.name; payment_reasons.name |
| 2 | يضيف فئة مصروف | نموذج فئة | الاسم، الرمز، حساب الدليل | INSERT | expense_categories.gl_account_id |
| 3 | يضيف سبب دفع | نموذج سبب | الاسم، الرمز، ينطبق على، نوع الدفعة، الحساب | INSERT | payment_reasons.applies_to, payment_type, gl_account_id |
| 4 | يعطّل بدل الحذف | القوائم | مفتاح «فعّال» | UPDATE | is_active |

**7\. المسارات البديلة (Alternative Flows)**

- السبب يحدد نوع العمليات التي يصلح لها (ERP17).
- فئة EXP-SAL لمصروفات أجور لا ترتبط بموظف مسجّل؛ وسبب EMP_SAL لراتب موظف مسجّل (S69) وEMP_ADV لسلفته؛ وكلاهما على 6101 بلا تضارب (قرار-50).

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| رمز مكرر | UNIQUE | الرمز مستخدم |
| حساب غير قابل للترحيل | ERP09 | الحساب غير قابل للترحيل أو غير فعّال |

**9\. الصلاحيات (RLS)**

- expense_categories وpayment_reasons: الكتابة accounting.manage أو finance.manage.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا فئات». |
| خطأ | على الحقل. |
| نجاح | الفئة تظهر في نموذج المصروف. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- فئات وأسباب جاهزة.

**12\. معايير القبول (Acceptance Criteria)**

- S70-AC1: عندما تُربط فئة بحساب فإن يستخدمه قيد المصروف.

**13\. ملاحظات للمصمم**

- اعرض الحساب المرتبط بجانب كل فئة.

### S72 — إدارة الملاك

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S72 — إدارة الملاك

**2\. الدور (Actor)**

ACCOUNTANT وSUPER_ADMIN (owner.transactions)

**3\. الهدف**

تعريف الملاك ونسب ملكيتهم وربطهم بأطراف، وبحساب دخول إن عملوا بالنظام.

**4\. الشروط المسبقة (Preconditions)**

- المنفّذ يملك owner.transactions.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| owners | party_id, ownership_percentage, is_active |
| parties | name, party_type |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح الملاك | قائمة الملاك | جدول (الاسم، النسبة، الحالة) | SELECT | owners.ownership_percentage |
| 2 | يضيف مالكاً | نموذج مالك | الطرف (جديد أو قائم)، النسبة | INSERT | parties; owners.party_id, ownership_percentage |
| 3 | يعدّل النسبة أو يعطّل | قائمة الملاك | تحرير، مفتاح «فعّال» | UPDATE | owners.ownership_percentage, is_active |
| 4 | يمنحه حساب دخول (اختياري) | ← | S60 | — | — |

**7\. المسارات البديلة (Alternative Flows)**

- مالك لا يعمل بالنظام: سجل owners فقط.
- حركات المالك ← S36.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| نسبة خارج 0–100 | CHECK على ownership_percentage | النسبة غير صالحة |

**9\. الصلاحيات (RLS)**

- owners: القراءة (owner.transactions وaccounting.view) والكتابة owner.transactions.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا ملاك». |
| خطأ | على الحقل. |
| نجاح | المالك يظهر في القائمة. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- مالك مسجّل.

**12\. معايير القبول (Acceptance Criteria)**

- S72-AC1: عندما تُدخل نسبة فإن تُحفظ بين 0 و100.

**13\. ملاحظات للمصمم**

- اعرض مجموع النسب بتنبيه إن لم يساوِ 100.

### S79 — تطبيق سلفة على فاتورة

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S79 — تطبيق سلفة على فاتورة

**2\. الدور (Actor)**

ACCOUNTANT وMANAGER وCASHIER وPURCHASER (finance.payments)

**3\. الهدف**

استعمال رصيد سلف قائم لزبون أو لمورد في تسديد فواتير مرحّلة للطرف نفسه، دون قبض أو صرف نقدي جديد.

**4\. الشروط المسبقة (Preconditions)**

- للطرف رصيد سلف متبقٍّ بالعملة المطلوبة (list_party_advances): من سند قبض أو دفع كسلفة (S30 وS31) أو رصيد افتتاحي من نوع CUSTOMER_ADVANCE أو SUPPLIER_ADVANCE (S68).
- فواتير بيع أو شراء مرحّلة تخص الطرف نفسه، من فرع واحد، وبالعملة نفسها (ERP10).
- المنفّذ يملك finance.payments وصلاحية تشغيل على الفرع.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| payment_allocations | payment_id, party_id, sale_id, purchase_invoice_id, debt_currency_id, source_currency_id, settled_amount, source_amount, allocation_type (ADVANCE_APPLICATION) |
| party_ledger_entries | party_id, currency_id, entry_type, debit, credit, source_type, source_id |
| list_party_advances (دالة) | advance_allocation_id, payment_id, payment_number, payment_date, currency_id, currency_code, original_amount, applied_amount, remaining_amount, branch_id, payment_type |
| v_open_documents (View) | doc_type, doc_id, doc_number, branch_id, party_id, currency_id, remaining_amount, payment_status |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح كشف حساب الطرف ويرى رصيد السلف | كشف حساب | بطاقة «رصيد السلف» (لكل سلفة: الرقم، التاريخ، الأصلي، المطبَّق، المتبقي) وزر «تطبيق سلفة» | RPC list_party_advances(p_party_id, p_currency_id) | payment_number, payment_date, original_amount, applied_amount, remaining_amount, currency_code |
| 2 | يختار الفواتير المرحّلة المفتوحة | نموذج تطبيق سلفة | قائمة الفواتير المفتوحة (الرقم، المتبقي، الاستحقاق) من فرع واحد | SELECT (v_open_documents) | v_open_documents.doc_number, remaining_amount, branch_id |
| 3 | يوزّع المبلغ المطبَّق | نموذج تطبيق سلفة | مبلغ لكل فاتورة (حتى أربع منازل عشرية؛ لا يتجاوز رصيد السلف ولا المتبقي)، الرصيد قبل وبعد | — | p_allocations: عناصر {sale_id أو purchase_invoice_id، amount} |
| 4 | يؤكد | نموذج تطبيق سلفة | زر «تطبيق» | RPC apply_advance(p_party_id, p_currency_id, p_allocations, p_date): تختار السلف الأقدم أولاً وتبني المستند داخلياً عبر post_payment | payment_allocations.allocation_type = ADVANCE_APPLICATION |
| 5 | يرى الأثر | كشف حساب | انخفاض رصيد السلف وتحديث حالة الفاتورة | SELECT | sales.payment_status, purchase_invoices.payment_status |

**7\. المسارات البديلة (Alternative Flows)**

- مثال p_allocations لزبون: [{"sale_id": 17, "amount": 6}, {"sale_id": 22, "amount": 4}]؛ ولمورد: [{"purchase_invoice_id": 3, "amount": 10}].
- تطبيق سلفة مورد على فاتورة شراء بالآلية نفسها (SUPPLIER_ADVANCE).
- تطبيق جزئي: تبقى الفاتورة PARTIAL ويبقى باقي السلف.
- لا يُخلط sale_id وpurchase_invoice_id في استدعاء واحد، ولا تُجمع فواتير من فروع مختلفة؛ والتطبيق بالعملة نفسها فقط.
- لا حركة نقدية: التطبيق تخصيص بين السلفة والفاتورة.
- عكس تطبيق خاطئ: reverse_payment (payment.cancel) على المستند الناتج (قرار-44)، فتصير حالته REVERSED ويعود رصيد السلف.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| بلا صلاحية finance.payments أو صلاحية الفرع | ERP16 PERMISSION_DENIED | لا تملك الصلاحية المطلوبة لهذه العملية |
| قائمة فارغة أو غير صالحة | ERP22 INVALID_STATE | أدخل فاتورة واحدة على الأقل |
| الطرف أو العملة غير موجودين | ERP22 INVALID_STATE | الطرف أو العملة غير موجودين |
| مبلغ صفر أو سالب | ERP22 INVALID_STATE | المبلغ يجب أن يكون موجباً |
| صيغة رقم الفاتورة أو المبلغ غير صحيحة (أكثر من أربع منازل عشرية مثلاً) | ERP22 INVALID_STATE | صيغة الفاتورة أو المبلغ غير صحيحة |
| خلط sale_id وpurchase_invoice_id | ERP22 INVALID_STATE | لا يجوز الجمع بين فواتير بيع وفواتير شراء |
| فواتير من فروع مختلفة | ERP22 INVALID_STATE | الفواتير يجب أن تكون من فرع واحد |
| رصيد السلف المتاح أقل من المطلوب | ERP22 INVALID_STATE (تفاصيل الخطأ: available وrequested وcurrency_id) | رصيد السلف المتاح أقل من المبلغ المطلوب |
| تجاوز المتبقي من الفاتورة | ERP22 INVALID_STATE | المبلغ يتجاوز المتبقي من الفاتورة |
| الفاتورة غير مرحّلة أو لا تخص الطرف | ERP18 DOC_LINK_MISMATCH | الفاتورة غير مرحّلة أو لا تخص هذا الطرف |
| اختلاف عملة الفاتورة عن عملة التطبيق | ERP10 CURRENCY_MISMATCH | التطبيق بعملة السلفة نفسها فقط |
| فترة مغلقة | ERP08 PERIOD_CLOSED | الفترة المحاسبية مغلقة |
| فترة مقفلة | ERP13 PERIOD_LOCKED | الفترة المحاسبية مقفلة نهائياً |

**9\. الصلاحيات (RLS)**

- apply_advance: تتحقق من finance.payments وصلاحية التشغيل على الفرع.
- list_party_advances: دالة STABLE SECURITY DEFINER.
- payment_allocations: الكتابة (finance.payments, payment.cancel) مع صلاحية الفرع.
- party_ledger_entries: قراءة فقط؛ تُكتب بالدوال.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا رصيد سلف لهذا الطرف». |
| خطأ | رسالة على الحقل، وعند نقص الرصيد تُعرض قيمتا المتاح والمطلوب والعملة. |
| نجاح | رصيد السلف والمتبقي محدَّثان. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- فاتورة مسدّدة كلياً أو جزئياً من رصيد السلف، ورصيد سلف منخفض بالمبلغ نفسه.
- مستند دفعة ناتج عن التطبيق بلا أي حركة نقدية.
- سجل العملية في audit_logs.

**12\. معايير القبول (Acceptance Criteria)**

- S79-AC1: عندما تُطبَّق سلفة تغطي الفاتورة فإن تصبح payment_status = PAID وينخفض رصيد السلف.
- S79-AC2: عندما يتجاوز المبلغ رصيد السلف أو المتبقي فإن يُرفض بـ ERP22 مع تفاصيل المتاح والمطلوب والعملة.
- S79-AC3: عندما تُطبَّق سلفة فإن لا تُنشأ حركة نقدية جديدة.
- S79-AC4: عندما تتوفر عدة سلف للطرف فإن تُستعمل الأقدم أولاً.
- S79-AC5: عندما تختلف عملة الفاتورة عن عملة التطبيق فإن يُرفض بـ ERP10.
- S79-AC6: عندما يُعكس المستند الناتج بـ reverse_payment فإن تصير حالته REVERSED ويعود رصيد السلف.

**13\. ملاحظات للمصمم**

- اعرض الرصيد قبل وبعد في ملخص ثابت.
- اعرض رسالة نقص الرصيد بالمتاح والمطلوب والعملة.

## وحدة 9: المحاسبة والتقارير والرقابة

### S38 — دليل الحسابات المحاسبي

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S38 — دليل الحسابات المحاسبي

**2\. الدور (Actor)**

ACCOUNTANT (accounting.manage)

**3\. الهدف**

بناء شجرة الحسابات وربط أحداث النظام بحساباتها.

**4\. الشروط المسبقة (Preconditions)**

- المنفّذ يملك accounting.manage.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| gl_accounts | parent_id, code, name, account_type, normal_balance, is_postable, is_system, is_active |
| gl_account_mappings | mapping_key, branch_id, gl_account_id |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح شجرة الحسابات | دليل الحسابات | شجرة قابلة للطي (الرمز، الاسم، النوع، الرصيد) | SELECT (v_account_balances) | gl_accounts.code, name, account_type, parent_id |
| 2 | يضيف حساباً | نموذج حساب | الأب، الرمز، الاسم، النوع، الطبيعة، «قابل للترحيل» | INSERT | gl_accounts.parent_id, code, account_type, normal_balance, is_postable |
| 3 | يربط الأحداث بالحسابات | شاشة الربط المحاسبي | جدول (المفتاح، الفرع، الحساب) | UPSERT | gl_account_mappings.mapping_key, branch_id, gl_account_id |

**7\. المسارات البديلة (Alternative Flows)**

- تعطيل حساب بلا حركة.
- حسابات النظام (is_system) لا تُحذف.
- مفاتيح الربط المستخدمة في الأرصدة الافتتاحية: OPENING_BALANCE_EQUITY وAR_CUSTOMERS وCUSTOMER_ADVANCES وAP_SUPPLIERS وSUPPLIER_ADVANCES (S68).

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| أب قابل للترحيل | ERP14 GL_PARENT_POSTABLE | الحساب الأب يجب أن يكون تجميعياً |
| رمز مكرر | UNIQUE على code | الرمز مستخدم |
| حساب غير قابل للترحيل في قيد | ERP09 | القيد يحوي حساباً غير قابل للترحيل أو غير فعّال |

**9\. الصلاحيات (RLS)**

- gl_accounts وgl_account_mappings: القراءة (accounting.view,accounting.manage,finance.view,finance.manage) والكتابة accounting.manage.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل الشجرة. |
| فارغ | «لا حسابات» مع زر الاستيراد. |
| خطأ | على الحقل. |
| نجاح | الحساب يظهر تحت أبيه. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- شجرة وربط جاهزان لتوليد القيود.

**12\. معايير القبول (Acceptance Criteria)**

- S38-AC1: عندما يُنشأ حساب فرعي فإن يكون أبوه تجميعياً.
- S38-AC2: عندما يغيب ربط حدث فإن يفشل توليد قيده (ERP07/ERP21).

**13\. ملاحظات للمصمم**

- شجرة بالسحب والإفلات لتغيير الأب (اختياري).

### S39 — عرض قيود اليومية وعكسها

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S39 — عرض قيود اليومية وعكسها

**2\. الدور (Actor)**

ACCOUNTANT وAUDITOR

**3\. الهدف**

مراجعة القيود المولَّدة تلقائياً وعكس قيد عند الحاجة، دون قيد يدوي عادي (قرار-20)، والاستثناء الوحيد قيد إقفال السنة (S75).

**4\. الشروط المسبقة (Preconditions)**

- صلاحية accounting.view للعرض وaccounting.post للعكس.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| journal_entries | entry_number, entry_date, fiscal_period_id, branch_id, description, source_type, source_id, status, reversal_of_id, posted_by, posted_at |
| journal_entry_lines | journal_entry_id, gl_account_id, party_id, currency_id, debit, credit, exchange_rate, debit_base, credit_base, description |
| gl_accounts | code, name, account_type |
| fiscal_periods | name, start_date, end_date, status |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح القيود | قائمة القيود | مرشحات (الفترة، الفرع، المصدر، الحالة)، جدول | SELECT | journal_entries.entry_number, entry_date, status, source_type |
| 2 | يفتح قيداً | تفاصيل القيد | رأس القيد وأسطره (الحساب، الطرف، مدين، دائن)، رابط المصدر | SELECT | journal_entry_lines.gl_account_id, debit, credit, debit_base, credit_base |
| 3 | يتتبع المصدر | المستند المصدر | رابط من source_type/source_id | SELECT | journal_entries.source_type, source_id |
| 4 | يعكس القيد | نافذة العكس | السبب، زر «عكس القيد» | RPC reverse_journal_entry | journal_entries.reversal_of_id, status = REVERSED |

**7\. المسارات البديلة (Alternative Flows)**

- لا شاشة قيد يدوي عادي (قرار-20)؛ الاستثناء قيد إقفال السنة (S75).
- عكس قيد في فترة مقفلة مرفوض.
- العكس بقيد معاكس مرتبط بالأصل عبر reversal_of، ويصير الأصل REVERSED فلا عكس مزدوج (قرار-44).

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| عكس بلا صلاحية | ERP16 | لا تملك صلاحية عكس القيود |
| فترة مغلقة/مقفلة | ERP08 / ERP13 | الفترة المحاسبية مغلقة |
| قيد غير متوازن | ERP07 | القيد غير متوازن |
| قيد بسطر واحد | ERP21 JOURNAL_TOO_FEW_LINES | القيد يحتاج سطرين على الأقل |

**9\. الصلاحيات (RLS)**

- journal_entries: القراءة (accounting.view,accounting.manage,accounting.post) مع can_access_branch.
- journal_entry_lines: الكتابة (accounting.manage,accounting.post).

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا قيود في الفترة». |
| خطأ | رسالة. |
| نجاح | ظهور قيد عكسي مرتبط. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- قيد عكسي مرحّل والأصل REVERSED.

**12\. معايير القبول (Acceptance Criteria)**

- S39-AC1: عندما يُعكس قيد فإن يُنشأ قيد معاكس بالقيم نفسها ويُربط بالأصل.
- S39-AC2: عندما يفتح مستخدم قيداً فإن يرى رابط مستند المصدر.

**13\. ملاحظات للمصمم**

- reverse_journal_entry ترفض القيد المرتبط بمستند (source_type)؛ يُعكس المستند نفسه بدالة عكسه (S18 وS28 وS30 وS32 وS33 وS35). ولا يُعكس القيد العكسي.

### S40 — إدارة الفترات المحاسبية

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S40 — إدارة الفترات المحاسبية

**2\. الدور (Actor)**

ACCOUNTANT (يغلق ويقفل، قرار-20)

**3\. الهدف**

مراجعة الفترات المحاسبية وإغلاقها ثم قفلها نهائياً. الفترات تُولَّد تلقائياً عند الطلب، ويبقى الإغلاق والقفل يدويين (قرار-47)؛ وإقفال نهاية السنة في S75.

**4\. الشروط المسبقة (Preconditions)**

- المنفّذ يملك accounting.manage.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| fiscal_periods | name, start_date, end_date, status, closed_by, closed_at |
| journal_entries | entry_number, fiscal_period_id, status |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح الفترات | قائمة الفترات المحاسبية | جدول (الاسم، من، إلى، الحالة) | SELECT | fiscal_periods.name, start_date, end_date, status |
| 2 | يولّد سنة مسبقاً (اختياري) | نموذج فترة | السنة | RPC generate_fiscal_year(year) (accounting.manage) | fiscal_periods.name, start_date, end_date |
| 3 | يراجع قيود الفترة غير المرحلة | تفاصيل الفترة | عدد القيود حسب الحالة | SELECT | journal_entries.status, fiscal_period_id |
| 4 | يغلق الفترة | تفاصيل الفترة | زر «إغلاق» بتأكيد | UPDATE | fiscal_periods.status = CLOSED, closed_by, closed_at |
| 5 | يقفلها نهائياً | تفاصيل الفترة | زر «قفل نهائي» بتأكيد مضاعف | UPDATE | fiscal_periods.status = LOCKED |

**7\. المسارات البديلة (Alternative Flows)**

- التوليد التلقائي: عند ترحيل مستند بتاريخ لا فترة له تستدعي erp.period_for الدالة erp.ensure_fiscal_year فتُنشأ 12 فترة شهرية بحالة OPEN للسنة، ضمن نافذة سنة سابقة إلى سنتين قادمتين (2025 إلى 2028 حالياً)، وخارجها يبقى ERP08 فلا تُولَّد فترات بخطأ تاريخ (قرار-47). والمبذور 24 فترة من يناير 2026 إلى ديسمبر 2027.
- إعادة فتح فترة مغلقة (CLOSED فقط) لمن يملك الصلاحية.
- المقفلة لا تُفتح.
- إقفال نهاية السنة: بعد قفل الفترات يُرحَّل الربح للأرباح المحتجزة بقيد يدوي (S75).

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| تاريخ قيد خارج الفترة أو خارج نافذة التوليد التلقائي | ERP08 PERIOD_CLOSED | تاريخ القيد خارج الفترة المحاسبية المحددة |
| فترة مقفلة | ERP13 PERIOD_LOCKED | الفترة المحاسبية مقفلة نهائياً |
| تداخل فترات | fiscal_period_guard | الفترة تتداخل مع أخرى |

**9\. الصلاحيات (RLS)**

- fiscal_periods: القراءة (accounting.view,accounting.manage,finance.view,finance.manage) والكتابة accounting.manage.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا فترات». |
| خطأ | شريط. |
| نجاح | الحالة الجديدة بشارة. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- فترة بالحالة الجديدة؛ المستندات الجديدة بتاريخ الفترة تُرفض.

**12\. معايير القبول (Acceptance Criteria)**

- S40-AC1: عندما تُغلق فترة فإن ترحيل أي مستند بتاريخ ضمنها يُرفض.
- S40-AC2: عندما تُقفل فإن لا يمكن إعادة فتحها.
- S40-AC3: عندما يُرحَّل مستند بتاريخ 2028 بلا فترة فإن تُولَّد فترات السنة تلقائياً وينجح الترحيل، وعندما يكون التاريخ 2035 فإن يُرفض بـ ERP08.

**13\. ملاحظات للمصمم**

- قفل نهائي: نافذة تأكيد باللون الأحمر واسم الفترة.

### S41 — تقارير المبيعات والمخزون

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S41 — تقارير المبيعات والمخزون

**2\. الدور (Actor)**

MANAGER وACCOUNTANT وAUDITOR

**3\. الهدف**

عرض ملخصات المبيعات اليومية والمخزون المتاح والمنخفض وملخص الورديات.

**4\. الشروط المسبقة (Preconditions)**

- صلاحية reports.view (أو ما تقتضيه الـ View).

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| v_sales_daily (View) | sale_day, branch_id, channel, currency_id, currency_code, invoices_count, total... |
| v_stock_available (View) | warehouse_id, warehouse_code, warehouse_name, branch_id, is_sellable, variant_id, sku, variant_name, product_name |
| v_low_stock (View) | warehouse_id, warehouse_name, variant_id, sku, product_name, quantity_on_hand |
| v_pos_session_summary (View) | pos_session_id, terminal_code, branch_id, cashier_username, status |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح التقارير | قائمة التقارير | بطاقات التقارير | — | — |
| 2 | يختار مبيعات يومية | تقرير المبيعات اليومية | نطاق التاريخ، الفرع، القناة، العملة؛ رسم + جدول | SELECT | v_sales_daily.sale_day, invoices_count, الإجمالي |
| 3 | يختار المخزون المتاح/المنخفض | تقرير المخزون | المستودع، المنتج؛ تبويب «منخفض» | SELECT | v_stock_available, v_low_stock |
| 4 | يختار ملخص الورديات | تقرير الورديات | فرع/كاشير/تاريخ | SELECT | v_pos_session_summary |
| 5 | يصدّر | أي تقرير | PDF/Excel | — | — |

**7\. المسارات البديلة (Alternative Flows)**

- تصفية بالفرع المسموح فقط.
- لا يرى التكلفة إلا من يملك costs.view.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| بلا صلاحية | سياسات الجداول الأصلية | لا تملك صلاحية هذا التقرير |
| نطاق كبير جداً | تحقق واجهة | قلّص نطاق التاريخ |

**9\. الصلاحيات (RLS)**

- الـ Views تقرأ من جداول ذات can_access_branch/can_access_warehouse، فتظهر للمستخدم أفرعه فقط.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل للرسم والجدول. |
| فارغ | «لا بيانات في النطاق». |
| خطأ | رسالة مع إعادة المحاولة. |
| نجاح | — |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- لا تغيّر (استعلام).

**12\. معايير القبول (Acceptance Criteria)**

- S41-AC1: عندما يحدد المستخدم فرعاً وفترة فإن تُعرض إجماليات الفاتورة بحسب القناة والعملة.
- S41-AC2: عندما لا يملك reports.view فإن لا يظهر التقرير.

**13\. ملاحظات للمصمم**

- الأعمدة الفعلية لكل View في الملحق ح؛ الربحية في S73 والتقارير الإضافية في S74.

### S45 — تقارير الحسابات والأرصدة

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S45 — تقارير الحسابات والأرصدة

**2\. الدور (Actor)**

ACCOUNTANT وAUDITOR

**3\. الهدف**

عرض أرصدة الحسابات والأطراف والحسابات المالية والمستندات المفتوحة.

**4\. الشروط المسبقة (Preconditions)**

- صلاحية accounting.view أو finance.view أو reports.view.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| v_account_balances (View) | gl_account_id, code, name, account_type, normal_balance, parent_id, is_postable, debit/credit totals |
| v_party_balances (View) | party_id, party_name, party_type, is_customer, ... |
| v_financial_account_balances (View) | financial_account_id, name, type, branch_id, currency_id, currency_code, ... |
| v_open_documents (View) | doc_type, doc_id, doc_number, branch_id, party_id, party_name, currency_id, ... |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح تقارير الحسابات | قائمة التقارير | بطاقات | — | — |
| 2 | ميزان المراجعة | تقرير أرصدة الحسابات | شجرة بالأرصدة (مدين/دائن) ونطاق تاريخ | SELECT | v_account_balances.code, name, account_type |
| 3 | أرصدة الأطراف | تقرير أرصدة الأطراف | تبويبات زبائن/موردين، العملة | SELECT | v_party_balances.party_name, is_customer |
| 4 | أرصدة الصناديق والبنوك | تقرير أرصدة الحسابات المالية | بطاقات لكل حساب | SELECT | v_financial_account_balances.name, currency_code |
| 5 | المستندات المفتوحة والمتأخرة | تقرير المستندات المفتوحة | فواتير مفتوحة بتاريخ الاستحقاق | SELECT | v_open_documents.doc_type, doc_number, party_name |

**7\. المسارات البديلة (Alternative Flows)**

- فلترة بالفرع.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| بلا صلاحية | سياسات الجداول | لا تملك صلاحية هذا التقرير |

**9\. الصلاحيات (RLS)**

- كل View تخضع لصلاحيات جداولها: accounting.view وfinance.view وreports.view مع الفرع.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا بيانات». |
| خطأ | رسالة. |
| نجاح | — |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- لا تغيّر (استعلام).

**12\. معايير القبول (Acceptance Criteria)**

- S45-AC1: عندما يُعرض ميزان المراجعة فإن مجموع المدين يساوي مجموع الدائن بالعملة الأساسية.

**13\. ملاحظات للمصمم**

- جدول ميزان المراجعة بشجرة قابلة للطي مع مجاميع ثابتة.

### S42 — سجل التدقيق

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S42 — سجل التدقيق

**2\. الدور (Actor)**

AUDITOR وSUPER_ADMIN، والاطلاع للمدير والمحاسب (audit.view)

**3\. الهدف**

تتبع من فعل ماذا ومتى، مع القيم قبل وبعد.

**4\. الشروط المسبقة (Preconditions)**

- المنفّذ يملك audit.view.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| audit_logs | user_id, action, entity_type, entity_id, old_values, new_values, ip_address, reason, created_at |
| users | username, email |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح سجل التدقيق | سجل التدقيق | مرشحات (المستخدم، الإجراء، نوع الكيان، التاريخ)، جدول | SELECT | audit_logs.action, entity_type, entity_id, created_at |
| 2 | يرشّح بإجراء | سجل التدقيق | قائمة الإجراءات (CREATE, UPDATE, DELETE, POST, CANCEL, APPROVE, RATE_CHANGE, MANUAL_OVERRIDE) | SELECT | audit_logs.action |
| 3 | يفتح سجلاً | تفاصيل سجل | مقارنة old_values / new_values، الـ IP، السبب | SELECT | audit_logs.old_values, new_values, ip_address, reason |
| 4 | ينتقل للكيان | الكيان المعني | رابط من entity_type/entity_id | SELECT | audit_logs.entity_type, entity_id |

**7\. المسارات البديلة (Alternative Flows)**

- تصدير نتائج التصفية.
- تدخل في السجل عمليات مراجعة المصروف وعكس المستندات وإرفاق إيصال المصروف وصور المنتج والألوان كباقي الدوال.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| بلا صلاحية | audit.view | لا تملك صلاحية سجل التدقيق |
| محاولة تعديل | لا سياسات كتابة (قراءة فقط) | السجل للقراءة فقط |

**9\. الصلاحيات (RLS)**

- audit_logs: SELECT فقط بـ audit.view؛ لا INSERT/UPDATE/DELETE للمستخدم (يُكتب بالتريغر).

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا سجلات». |
| خطأ | رسالة. |
| نجاح | — |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- لا تغيّر (استعلام).

**12\. معايير القبول (Acceptance Criteria)**

- S42-AC1: عندما يفتح المدقق سجل تعديل فإن يرى القيم قبل وبعد جنباً إلى جنب.
- S42-AC2: عندما يحاول تعديل سجل فإن لا يتوفر أي زر تعديل.

**13\. ملاحظات للمصمم**

- اعرض فرقاً ملوّناً بين القيم.
- نقطة: AUDITOR بلا أي صلاحية كتابة في أي شاشة.

### S73 — تقرير الربحية وتكلفة البضاعة المباعة

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S73 — تقرير الربحية وتكلفة البضاعة المباعة

**2\. الدور (Actor)**

MANAGER وACCOUNTANT وAUDITOR (costs.view)

**3\. الهدف**

عرض الربح وتكلفة البضاعة المباعة بحسب المنتج أو الفترة، من المتوسط المرجّح مع عرض عمودي آخر سعر شراء والمتوسط.

**4\. الشروط المسبقة (Preconditions)**

- المنفّذ يملك costs.view وreports.view.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| v_sale_items_costs (View) | id, sale_id, variant_id, unit_cost, unit_cost_currency_id |
| sale_items | variant_id, quantity, unit_price, discount, total_price |
| variant_costs | average_cost, last_purchase_cost |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح تقرير الربحية | قائمة التقارير | بطاقة «الربحية» | — | — |
| 2 | يحدد النطاق | تقرير الربحية | الفترة، الفرع، المنتج/التصنيف | SELECT | sales.sale_date, branch_id |
| 3 | يرى الأعمدة | تقرير الربحية | المبيعات، التكلفة (متوسط)، الربح، وعمود آخر سعر شراء للمقارنة | SELECT | v_sale_items_costs.unit_cost; variant_costs.last_purchase_cost |
| 4 | يصدّر | تقرير الربحية | PDF/Excel | — | — |

**7\. المسارات البديلة (Alternative Flows)**

- الربح من المتوسط المرجّح دائماً (post_sale)، وسعر البيع من آخر شراء (S57).
- الأصناف المباعة قبل ضبط التكلفة تُعلَّم بلا تكلفة.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| بلا costs.view | الـ View تُرجع صفراً صفوف | لا تملك صلاحية عرض التكاليف |

**9\. الصلاحيات (RLS)**

- v_sale_items_costs للقراءة فقط وتُفلتَر بـ costs.view والفرع (security_barrier).

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا مبيعات في النطاق». |
| خطأ | على الحقل. |
| نجاح | الجدول والرسم. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- لا تغيّر (استعلام).

**12\. معايير القبول (Acceptance Criteria)**

- S73-AC1: عندما يملك المستخدم costs.view فإن يرى التكلفة والربح؛ وغيره لا يرى التقرير.

**13\. ملاحظات للمصمم**

- اعرض العمودين متجاورين بلونين مختلفين.

### S74 — تقارير إدارية إضافية

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S74 — تقارير إدارية إضافية

**2\. الدور (Actor)**

ACCOUNTANT وMANAGER وSUPER_ADMIN وAUDITOR

**3\. الهدف**

عرض أسعار القوائم لكل متغير، وصلاحيات المستخدمين ونقاطهم وفروعهم، وخصائص المتغيرات.

**4\. الشروط المسبقة (Preconditions)**

- المنفّذ يملك reports.view أو users.manage بحسب الـ View.

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| v_variant_list_prices (View) | variant_id, product_id, sku, variant_name, price_list_id, price_list_code, price_type, currency_id, currency_code, amount, valid_from, valid_to, is_current |
| v_user_access (View) | user_id, username, email, is_active, full_name, job_title, role_codes, branch_codes, terminal_codes |
| v_variant_attributes (View) | variant_id, product_id, sku, variant_name, size_name, color_name, color_components |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح التقارير الإدارية | قائمة التقارير | بطاقات | — | — |
| 2 | يعرض أسعار القوائم | تقرير أسعار المتغيرات | جدول بأسعار القوائم | SELECT | v_variant_list_prices |
| 3 | يعرض صلاحيات المستخدمين | تقرير الوصول | المستخدم، الأدوار، الفروع، النقاط | SELECT | v_user_access |
| 4 | يعرض خصائص المتغيرات | تقرير المتغيرات | اللون والمقاس والمركّبات | SELECT | v_variant_attributes |

**7\. المسارات البديلة (Alternative Flows)**

- v_variant_list_prices: صف واحد لكل (متغير، قائمة أسعار) هو السعر الساري (الأحدث valid_from مع valid_from <= الآن وvalid_to فارغ أو بعد الآن)، للمتغيرات الفعّالة وقوائم الأسعار الفعّالة فقط. وإن لم يكن للزوج سعر ساري وله سعر مستقبلي ظهر أقربه بـ is_current = false؛ والسعر المستقبلي لزوج له سعر ساري لا يظهر. security_invoker = true وبلا أي عمود تكلفة.
- الأسعار المحسوبة بقواعد التسعير (price_rules) لا تدخل هذا التقرير، وتُعرض بمعاينة resolve_price (S57).
- تصدير Excel (واجهة).

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| بلا صلاحية | سياسات الجداول | لا تملك صلاحية هذا التقرير |

**9\. الصلاحيات (RLS)**

- كل View تخضع لصلاحيات جداولها.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | «لا بيانات». |
| خطأ | على الحقل. |
| نجاح | الجدول يظهر. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- لا تغيّر (استعلام).

**12\. معايير القبول (Acceptance Criteria)**

- S74-AC1: عندما يفتح المدير تقرير الوصول فإن يرى أدوار كل مستخدم وفروعه ونقاطه.
- S74-AC2: عندما يفتح مستخدم تقرير أسعار المتغيرات فإن يرى لكل متغير وقائمة سعراً ساري المفعول واحداً بلا أي عمود تكلفة.

**13\. ملاحظات للمصمم**

- v_variant_list_prices بأعمدتها الفعلية في الملحق ح.

### S75 — إقفال السنة المالية وترحيل الأرباح المحتجزة

**المنصة الأساسية:** ويب

**1\. رقم واسم السيناريو**

S75 — إقفال السنة المالية وترحيل الأرباح المحتجزة

**2\. الدور (Actor)**

ACCOUNTANT (accounting.post وaccounting.manage)

**3\. الهدف**

بعد قفل فترات السنة يُرحَّل الربح إلى حساب الأرباح المحتجزة بقيد يدوي واحد (تصميم v1).

**4\. الشروط المسبقة (Preconditions)**

- فترات السنة مقفلة (S40).
- المنفّذ يملك accounting.post (قيود يدوية وإغلاق فترات).

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| journal_entries | entry_date, fiscal_period_id, branch_id, description, source_type, status |
| journal_entry_lines | journal_entry_id, gl_account_id, debit, credit, description |
| gl_accounts | code, name, account_type |
| fiscal_periods | status |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يراجع ميزان المراجعة | تقرير أرصدة الحسابات (S45) | أرصدة الإيرادات والمصروفات | SELECT (v_account_balances) | v_account_balances.balance_base |
| 2 | ينشئ قيد الإقفال | نموذج قيد إقفال | أسطر: إقفال الإيرادات والمصروفات إلى الأرباح المحتجزة | INSERT | journal_entries; journal_entry_lines.gl_account_id, debit, credit |
| 3 | يرحّله | نموذج قيد إقفال | زر «ترحيل» بتأكيد | UPDATE status = POSTED | journal_entries.status |
| 4 | يتأكد من الميزان | تقرير أرصدة الحسابات | مجموع المدين = مجموع الدائن | SELECT | v_account_balances |

**7\. المسارات البديلة (Alternative Flows)**

- هذا القيد اليدوي هو الاستثناء الوحيد من قرار «لا قيد يدوي».
- توليد الفترات تلقائي (S40) فلا حاجة لإنشائها قبل الإقفال.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| قيد غير متوازن | ERP07 JOURNAL_UNBALANCED | القيد غير متوازن |
| قيد بسطر واحد | ERP21 | القيد يحتاج سطرين على الأقل |
| حساب غير قابل للترحيل | ERP09 | القيد يحوي حساباً غير قابل للترحيل |
| فترة مقفلة | ERP13 PERIOD_LOCKED | الفترة المحاسبية مقفلة نهائياً |

**9\. الصلاحيات (RLS)**

- journal_entries وjournal_entry_lines: الكتابة accounting.manage أو accounting.post.

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | هيكل. |
| فارغ | — |
| خطأ | على الحقل. |
| نجاح | القيد يظهر مرحّلاً في S39. |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- قيد إقفال مرحّل ورصيد الأرباح المحتجزة محدّث.

**12\. معايير القبول (Acceptance Criteria)**

- S75-AC1: عندما يُرحَّل قيد الإقفال فإن ترصد الإيرادات والمصروفات إلى الأرباح المحتجزة.

**13\. ملاحظات للمصمم**

- أظهر مجموع المدين والدائن بلون يتحول للأخضر عند التوازن.

## وحدة 10: الإشعارات

### S44 — مركز الإشعارات داخل التطبيق

**المنصة الأساسية:** ويب وموبايل وWindows

**1\. رقم واسم السيناريو**

S44 — مركز الإشعارات داخل التطبيق

**2\. الدور (Actor)**

جميع الأدوار (كل دور يرى ما يعنيه)

**3\. الهدف**

تنبيه المستخدم داخل التطبيق: مخزون منخفض، تحويل ينتظر موافقة، فاتورة مستحقة (قرار-21).

**4\. الشروط المسبقة (Preconditions)**

- تُحسب الإشعارات حياً من البيانات الحالية (تصميم v1).

**5\. الجداول المستخدمة**

| **الجدول** | **الأعمدة المهمة** |
| --- | --- |
| variant_reorder_levels | variant_id, warehouse_id, min_quantity |
| inventory_balances | variant_id, warehouse_id, quantity_on_hand |
| stock_transfers | status, to_warehouse_id, from_warehouse_id |
| purchase_invoices | supplier_id, due_date, payment_status, doc_status |

**6\. المسار الأساسي (Main Flow)**

| **الخطوة** | **ما يفعله المستخدم** | **الشاشة / الواجهة** | **عناصر الواجهة** | **العملية على القاعدة** | **الجدول والأعمدة** |
| --- | --- | --- | --- | --- | --- |
| 1 | يفتح التطبيق أو يضغط جرس الإشعارات | الشريط العلوي | أيقونة جرس بعدّاد | SELECT (v_low_stock) | inventory_balances.quantity_on_hand, variant_reorder_levels.min_quantity |
| 2 | يرى القائمة المجمّعة | لوحة الإشعارات | مجموعات: مخزون منخفض، تحويلات بانتظار الموافقة، فواتير مستحقة | SELECT | stock_transfers.status = DRAFT/APPROVED; purchase_invoices.due_date, payment_status |
| 3 | يضغط إشعاراً | لوحة الإشعارات | رابط للشاشة المعنية (S25/S26/S22/S31) | — | — |

**7\. المسارات البديلة (Alternative Flows)**

- كل دور يرى مجموعاته فقط بحسب الصلاحيات (الكاشير يرى مخزون الصالة فقط).
- حالة «مقروء» تُحفظ محلياً في الجهاز ولا تُخزَّن في القاعدة.

**8\. حالات الخطأ والتحقق (Validations & Errors)**

| **الحالة** | **القيد / القاعدة** | **رسالة للمستخدم** |
| --- | --- | --- |
| فشل التحميل | انقطاع الاتصال | تعذر تحميل الإشعارات |

**9\. الصلاحيات (RLS)**

- كل مجموعة تخضع لسياسة جدولها: inventory_balances (inventory.view...)، stock_transfers (inventory.transfer...)، purchase_invoices (purchasing.view...).

**10\. حالات الواجهة (UI States)**

| **الحالة** | **السلوك** |
| --- | --- |
| تحميل | دوّار على الجرس. |
| فارغ | «لا إشعارات». |
| خطأ | رسالة صغيرة مع إعادة محاولة. |
| نجاح | — |

**11\. النتيجة بعد التنفيذ (Postconditions)**

- لا تغيّر (قراءة).

**12\. معايير القبول (Acceptance Criteria)**

- S44-AC1: عندما ينخفض الرصيد عن الحد الأدنى فإن يظهر إشعار «مخزون منخفض» لمن يملك صلاحية العرض.
- S44-AC2: عندما يُنشأ تحويل بانتظار الموافقة فإن يظهر لأمين المستودع المرسل.

**13\. ملاحظات للمصمم**


# 4\. الملحقات

## الملحق أ: مصفوفة الأدوار والسيناريوهات

● منفّذ رئيسي، ○ مطّلع أو منفّذ ثانوي. الأعمدة بالترتيب: SUPER_ADMIN MANAGER CASHIER WAREHOUSE ACCOUNTANT PURCHASER AUDITOR.

| **السيناريو** | **SUPER_ADMIN** | **MANAGER** | **CASHIER** | **WAREHOUSE** | **ACCOUNTANT** | **PURCHASER** | **AUDITOR** |
| --- | --- | --- | --- | --- | --- | --- | --- |
| S01 تسجيل الدخول وتحميل الصلاحيات | ● | ● | ● | ● | ● | ● | ● |
| S02 إنشاء مستخدم وتعيين دوره وفروعه | ● | | | | | | |
| S03 إدارة الأدوار وصلاحياتها | ● | | | | | | ○ |
| S59 إعادة تعيين كلمة المرور وتعطيل الحساب | ● | | | | | | |
| S60 ربط مالك أو طرف قائم بحساب دخول | ● | | | | ○ | | |
| S61 تبديل الفرع وتقارير كل الفروع | ● | ● | ○ | ○ | ○ | ○ | ○ |
| S62 إدارة الموظفين | ● | ● | | | ○ | | ○ |
| S81 لوحة التحكم حسب الدور | ● | ● | ● | ● | ● | ● | ● |
| S82 تغيير كلمة المرور الاختياري وتسجيل الخروج | ● | ● | ● | ● | ● | ● | ● |
| S04 إدارة الفروع والمستودعات | ● | ○ | | | | | |
| S05 إعداد نقاط البيع والصناديق | ● | ● | | | | | |
| S06 العملات وأسعار الصرف والإعدادات | ● | | | | ● | | ○ |
| S43 تفضيلات عرض العملة | ● | ● | ● | ● | ● | ● | ● |
| S58 ربط المستخدمين ونقاط البيع بقوائم الأسعار | ● | ● | | | | | |
| S63 ضبط سقف خصم الكاشير لكل فرع | ● | ● | ○ | | | | |
| S77 ترقيم المستندات التلقائي | ○ | | | | | | |
| S78 إدارة مفاتيح الإعدادات | ● | | | | | | |
| S07 إنشاء منتج (موديل) | | ● | | ● | | ● | ○ |
| S08 إضافة الألوان والمقاسات والباركود (المتغيرات) | | ● | | ● | | ● | |
| S09 تسعير المنتجات | | ● | | | ○ | | ○ |
| S10 تحديد تكلفة المنتج وتعديلها | | ● | | | ● | | ○ |
| S11 إدارة الخصومات | | ● | ○ | | | | |
| S46 إدارة الألوان (البسيطة والمركّبة وصور الألوان) | | ● | | ● | | ● | ○ |
| S47 أنظمة المقاسات ومجموعاتها ومقاساتها | | ● | | ● | | ● | ○ |
| S48 ربط المقاسات بنوع المنتج وبالمنتج | | ● | | ● | | ● | ○ |
| S49 الماركات والتصنيفات وأنواع المنتجات | | ● | | ● | | ● | ○ |
| S50 وحدات القياس | | ● | | ● | | ● | ○ |
| S51 إكمال وصف المنتج (الجداول الوصفية) | | ● | | ● | | ● | ○ |
| S52 إدارة الجداول المرجعية الوصفية | | ● | | ● | | ● | ○ |
| S53 الخصائص الديناميكية للمنتج | | ● | | ● | | ● | ○ |
| S54 نشر المنتج وأرشفته وإيقاف المتغير | | ● | | ● | | ● | ○ |
| S55 صور المنتج والألوان | | ● | | ● | | ● | |
| S56 الباركود: إدخال يدوي وتوليد داخلي وطباعة الملصقات | | ● | | ● | | ● | |
| S57 قواعد التسعير (Markup / Margin) | | ● | | | | | ○ |
| S12 إدارة الزبائن | | ● | ● | | ● | ● | ○ |
| S13 إدارة الموردين | | | | | ○ | ● | ○ |
| S14 فتح جلسة صندوق | | ● | ● | | | | |
| S15 البحث عن صنف وإضافته للسلة | | ● | ● | | | | |
| S16 إتمام البيع (دفع نقدي/متعدد) | | ● | ● | | | | ○ |
| S17 بيع آجل أو بدفعة جزئية | | ● | ● | | ○ | | |
| S18 إغلاق جلسة الصندوق والجرد النقدي | | ● | ● | | ○ | | ○ |
| S19 مرتجع مبيعات | | ● | ● | | ○ | | ○ |
| S20 إدارة الفواتير المعلّقة والمسودات | | ● | ● | | | | |
| S64 اختيار قائمة الأسعار في نقطة البيع (جملة وتجزئة) | | ● | ● | | | | |
| S67 زبون يطلب صنفاً غير متوفر في فرعي | | ● | ● | ○ | | | |
| S80 قائمة المبيعات وإعادة الطباعة والمشاركة | | ● | ● | | ○ | | ○ |
| S21 إنشاء فاتورة شراء (مسودة) | | ○ | | | ○ | ● | ○ |
| S22 ترحيل فاتورة شراء واستلام البضاعة | | | | ○ | ○ | ● | ○ |
| S23 مرتجع مشتريات | | | | | ○ | ● | ○ |
| S24 ملاحظات المورد | | | | ○ | | ● | ○ |
| S25 عرض أرصدة المخزون وحركته | | ● | ○ | ● | ○ | ○ | ● |
| S26 إنشاء تحويل مخزون والموافقة عليه | | ○ | | ● | | | ○ |
| S27 شحن التحويل واستلامه | | ○ | | ● | | | ○ |
| S28 تسوية الجرد | | ● | | ● | ○ | | ○ |
| S29 مستويات إعادة الطلب | | ● | | ○ | | ● | |
| S66 الاطلاع على مخزون الفروع الأخرى | | ● | ● | ● | | ● | |
| S71 معالجة المخزون التالف | | ● | | ● | | ○ | |
| S30 سند قبض من زبون وتخصيصه | | ○ | ● | | ● | | ○ |
| S31 سند دفع لمورد | | | | | ● | ○ | ○ |
| S32 تسجيل مصروف | | ○ | ● | | ● | | ○ |
| S33 تحويل أموال بين الحسابات | | | | | ● | | ○ |
| S34 كشف حساب طرف وأرصدته | | ○ | | | ● | ○ | ● |
| S35 تسوية رصيد طرف | | | | | ● | | ○ |
| S36 سحوبات ومساهمات الملاك | ○ | | | | ● | | ○ |
| S37 إدارة البنوك والحسابات المالية | | | | | ● | | ○ |
| S65 مراجعة المصروفات الصغيرة للكاشير | ○ | ○ | | | ● | | |
| S68 الأرصدة الافتتاحية وبدء التشغيل | ● | ○ | | | ● | | |
| S69 دفعة راتب أو سلفة لموظف | | ○ | | | ● | | ○ |
| S70 فئات المصروف وأسباب الدفع | | | | | ● | | ○ |
| S72 إدارة الملاك | ● | | | | ● | | ○ |
| S79 تطبيق سلفة على فاتورة | | ○ | ○ | | ● | ○ | |
| S38 دليل الحسابات المحاسبي | | | | | ● | | ○ |
| S39 عرض قيود اليومية وعكسها | ○ | | | | ● | | ● |
| S40 إدارة الفترات المحاسبية | | | | | ● | | ○ |
| S41 تقارير المبيعات والمخزون | | ● | | ○ | ● | | ● |
| S45 تقارير الحسابات والأرصدة | | ○ | | | ● | | ● |
| S42 سجل التدقيق | ● | ○ | | | ○ | | ● |
| S73 تقرير الربحية وتكلفة البضاعة المباعة | | ● | | | ● | | ● |
| S74 تقارير إدارية إضافية | ● | ○ | | | ● | | ● |
| S75 إقفال السنة المالية وترحيل الأرباح المحتجزة | | | | | ● | | ○ |
| S44 مركز الإشعارات داخل التطبيق | ○ | ● | ○ | ● | ● | ● | ○ |

## الملحق ب: ربط السيناريوهات بالجداول

| **السيناريو** | **الجداول** |
| --- | --- |
| S01 تسجيل الدخول وتحميل الصلاحيات | users user_roles user_branch_access |
| S02 إنشاء مستخدم وتعيين دوره وفروعه | users employees user_roles user_branch_access user_price_lists user_pos_terminals |
| S03 إدارة الأدوار وصلاحياتها | roles permissions role_permissions |
| S59 إعادة تعيين كلمة المرور وتعطيل الحساب | users |
| S60 ربط مالك أو طرف قائم بحساب دخول | owners parties employees users |
| S61 تبديل الفرع وتقارير كل الفروع | user_branch_access branches |
| S62 إدارة الموظفين | employees parties |
| S81 لوحة التحكم حسب الدور | v_sales_daily v_low_stock v_pos_session_summary v_financial_account_balances v_open_documents stock_transfers |
| S82 تغيير كلمة المرور الاختياري وتسجيل الخروج | users (وSupabase Auth) |
| S04 إدارة الفروع والمستودعات | branches warehouses |
| S05 إعداد نقاط البيع والصناديق | pos_terminals cashboxes cashbox_accounts user_pos_terminals pos_terminal_price_lists |
| S06 العملات وأسعار الصرف والإعدادات | currencies exchange_rates settings |
| S43 تفضيلات عرض العملة | display_preferences currencies |
| S58 ربط المستخدمين ونقاط البيع بقوائم الأسعار | user_price_lists pos_terminal_price_lists price_lists |
| S63 ضبط سقف خصم الكاشير لكل فرع | settings |
| S77 ترقيم المستندات التلقائي | document_sequences sales |
| S78 إدارة مفاتيح الإعدادات | settings |
| S07 إنشاء منتج (موديل) | products product_types brands categories product_categories |
| S08 إضافة الألوان والمقاسات والباركود (المتغيرات) | product_variants product_colors sizes barcodes product_color_components product_sizes |
| S09 تسعير المنتجات | price_lists variant_prices products |
| S10 تحديد تكلفة المنتج وتعديلها | variant_costs cost_adjustments product_variants |
| S11 إدارة الخصومات | discounts discount_targets settings |
| S46 إدارة الألوان (البسيطة والمركّبة وصور الألوان) | colors product_colors product_color_components color_images |
| S47 أنظمة المقاسات ومجموعاتها ومقاساتها | size_systems size_groups sizes size_ranges |
| S48 ربط المقاسات بنوع المنتج وبالمنتج | product_type_size_groups product_size_groups product_sizes |
| S49 الماركات والتصنيفات وأنواع المنتجات | brands categories product_types countries |
| S50 وحدات القياس | units product_variants |
| S51 إكمال وصف المنتج (الجداول الوصفية) | product_sports product_age_groups product_genders product_seasons product_collections product_tags product_materials product_fabrics product_care_instructions |
| S52 إدارة الجداول المرجعية الوصفية | sports age_groups genders seasons collections tags materials fabric_types care_instructions |
| S53 الخصائص الديناميكية للمنتج | attributes option_sets options product_type_attributes product_type_option_sets product_attribute_values product_option_values variant_option_values |
| S54 نشر المنتج وأرشفته وإيقاف المتغير | products product_variants product_attribute_values |
| S55 صور المنتج والألوان | product_images color_images (Storage: product-images) |
| S56 الباركود: إدخال يدوي وتوليد داخلي وطباعة الملصقات | barcodes product_variants |
| S57 قواعد التسعير (Markup / Margin) | price_rules price_lists |
| S12 إدارة الزبائن | parties customers customer_addresses price_lists |
| S13 إدارة الموردين | parties suppliers currencies |
| S14 فتح جلسة صندوق | pos_sessions pos_session_balances pos_terminals user_pos_terminals |
| S15 البحث عن صنف وإضافته للسلة | product_variants barcodes variant_prices inventory_balances sales |
| S16 إتمام البيع (دفع نقدي/متعدد) | sales sale_items payments payment_lines |
| S17 بيع آجل أو بدفعة جزئية | sales customers payment_allocations party_ledger_entries |
| S18 إغلاق جلسة الصندوق والجرد النقدي | pos_sessions cash_reconciliations financial_transactions pos_session_balances |
| S19 مرتجع مبيعات | sales_returns sales_return_items sales payments |
| S20 إدارة الفواتير المعلّقة والمسودات | sales sale_items |
| S64 اختيار قائمة الأسعار في نقطة البيع (جملة وتجزئة) | sales customers price_lists |
| S67 زبون يطلب صنفاً غير متوفر في فرعي | stock_transfers stock_transfer_items inventory_balances |
| S80 قائمة المبيعات وإعادة الطباعة والمشاركة | sales sale_items payments payment_lines customers |
| S21 إنشاء فاتورة شراء (مسودة) | purchase_invoices purchase_invoice_items suppliers product_variants |
| S22 ترحيل فاتورة شراء واستلام البضاعة | purchase_invoices stock_movements inventory_balances variant_costs |
| S23 مرتجع مشتريات | purchase_returns purchase_return_items purchase_invoices suppliers |
| S24 ملاحظات المورد | supplier_notes suppliers purchase_invoices |
| S25 عرض أرصدة المخزون وحركته | inventory_balances stock_movements warehouses product_variants |
| S26 إنشاء تحويل مخزون والموافقة عليه | stock_transfers stock_transfer_items warehouses product_variants |
| S27 شحن التحويل واستلامه | stock_transfers stock_transfer_items stock_movements inventory_balances |
| S28 تسوية الجرد | stock_adjustments stock_adjustment_items inventory_balances stock_movements |
| S29 مستويات إعادة الطلب | variant_reorder_levels product_variants inventory_balances |
| S66 الاطلاع على مخزون الفروع الأخرى | warehouses inventory_balances branches |
| S71 معالجة المخزون التالف | inventory_balances stock_adjustments stock_transfers purchase_returns |
| S30 سند قبض من زبون وتخصيصه | payments payment_lines payment_allocations financial_accounts |
| S31 سند دفع لمورد | payments payment_lines payment_allocations financial_accounts |
| S32 تسجيل مصروف | expenses expense_categories financial_accounts financial_transactions (Storage: expense-receipts) |
| S33 تحويل أموال بين الحسابات | money_transfers financial_accounts financial_transactions payment_reasons |
| S34 كشف حساب طرف وأرصدته | party_ledger_entries parties currencies |
| S35 تسوية رصيد طرف | balance_adjustments party_ledger_entries payment_reasons parties |
| S36 سحوبات ومساهمات الملاك | owners payments payment_lines payment_reasons |
| S37 إدارة البنوك والحسابات المالية | banks bank_accounts financial_accounts cashbox_accounts |
| S65 مراجعة المصروفات الصغيرة للكاشير | expenses pos_sessions |
| S68 الأرصدة الافتتاحية وبدء التشغيل | stock_movements variant_costs financial_transactions party_ledger_entries journal_entries |
| S69 دفعة راتب أو سلفة لموظف | payments payment_lines payment_reasons employees |
| S70 فئات المصروف وأسباب الدفع | expense_categories payment_reasons |
| S72 إدارة الملاك | owners parties |
| S79 تطبيق سلفة على فاتورة | payment_allocations party_ledger_entries payments sales purchase_invoices |
| S38 دليل الحسابات المحاسبي | gl_accounts gl_account_mappings |
| S39 عرض قيود اليومية وعكسها | journal_entries journal_entry_lines gl_accounts fiscal_periods |
| S40 إدارة الفترات المحاسبية | fiscal_periods journal_entries |
| S41 تقارير المبيعات والمخزون | v_sales_daily v_stock_available v_low_stock v_pos_session_summary |
| S45 تقارير الحسابات والأرصدة | v_account_balances v_party_balances v_financial_account_balances v_open_documents |
| S42 سجل التدقيق | audit_logs users |
| S73 تقرير الربحية وتكلفة البضاعة المباعة | v_sale_items_costs sale_items variant_costs |
| S74 تقارير إدارية إضافية | v_variant_list_prices v_user_access v_variant_attributes |
| S75 إقفال السنة المالية وترحيل الأرباح المحتجزة | journal_entries journal_entry_lines gl_accounts fiscal_periods |
| S44 مركز الإشعارات داخل التطبيق | variant_reorder_levels inventory_balances stock_transfers purchase_invoices |

## الملحق ج: قائمة الشاشات (بدون تكرار)

| **#** | **الشاشة** | **السيناريوهات** |
| --- | --- | --- |
| 1 | شاشة تسجيل الدخول | S01 |
| 2 | شاشة التحميل | S01 |
| 3 | شاشة اختيار الفرع | S01 |
| 4 | شاشة تغيير كلمة المرور | S01 S82 |
| 5 | لوحة التحكم | S01 S81 |
| 6 | قائمة المستخدمين | S02 |
| 7 | نموذج مستخدم جديد | S02 S60 |
| 8 | شاشة تأكيد الإنشاء | S02 |
| 9 | قائمة الأدوار | S03 |
| 10 | تفاصيل الدور | S03 |
| 11 | مصفوفة الصلاحيات | S03 |
| 12 | تفاصيل المستخدم | S59 |
| 13 | نافذة إعادة التعيين | S59 |
| 14 | قائمة الملاك | S36 S60 S72 |
| 15 | قائمة التقارير | S41 S45 S61 S73 S74 |
| 16 | قائمة الموظفين | S62 |
| 17 | نموذج موظف | S62 |
| 18 | قائمة الفروع | S04 |
| 19 | نموذج فرع | S04 |
| 20 | نموذج مستودع | S04 |
| 21 | قائمة نقاط البيع | S05 |
| 22 | نموذج صندوق | S05 |
| 23 | نموذج نقطة بيع | S05 |
| 24 | تعيين المستخدمين | S05 |
| 25 | تعيين قوائم الأسعار | S05 |
| 26 | قائمة العملات | S06 |
| 27 | نموذج سعر صرف | S06 |
| 28 | قائمة أسعار الصرف | S06 |
| 29 | شاشة الإعدادات | S06 S68 S78 |
| 30 | الإعدادات الشخصية | S43 S82 |
| 31 | ربط قوائم الأسعار | S58 |
| 32 | ربط قوائم المستخدم | S58 |
| 33 | ربط قوائم النقطة | S58 |
| 34 | معاينة قوائم الأسعار المسموحة | S58 |
| 35 | سقف الخصم | S11 S63 |
| 36 | نموذج إعداد | S78 |
| 37 | قائمة المنتجات | S07 |
| 38 | نموذج منتج | S07 |
| 39 | تفاصيل المنتج | S07 S08 S48 S51 S53 S54 |
| 40 | تبويب صور المنتج | S55 |
| 41 | نافذة الألوان | S08 S46 |
| 42 | نافذة المقاسات | S08 |
| 43 | معاينة التوليد | S08 |
| 44 | نافذة الباركود | S08 S56 |
| 45 | شاشة التسعير | S09 |
| 46 | نافذة «سعر الموديل» | S09 |
| 47 | شاشة التكلفة | S10 |
| 48 | نافذة تعديل التكلفة | S10 |
| 49 | سجل التكلفة | S10 |
| 50 | قائمة الخصومات | S11 |
| 51 | نموذج خصم | S11 |
| 52 | قائمة الألوان | S46 |
| 53 | نموذج لون | S46 |
| 54 | نافذة اللون المركّب | S46 |
| 55 | تبويب صور اللون | S46 S55 |
| 56 | قائمة أنظمة المقاسات | S47 |
| 57 | نموذج نظام مقاسات | S47 |
| 58 | نموذج مجموعة مقاسات | S47 |
| 59 | شبكة المقاسات | S47 |
| 60 | نموذج نطاق | S47 |
| 61 | تفاصيل نوع المنتج | S48 S49 S53 |
| 62 | قائمة البيانات الأساسية | S49 |
| 63 | نموذج ماركة | S49 |
| 64 | نموذج تصنيف | S49 |
| 65 | نموذج نوع منتج | S49 |
| 66 | قائمة الوحدات | S50 |
| 67 | نموذج وحدة | S50 |
| 68 | تبويب المتغيرات | S50 S54 |
| 69 | البيانات المرجعية | S52 |
| 70 | قائمة مرجعية | S52 |
| 71 | نموذج قيمة | S52 |
| 72 | نموذج مجموعة خيارات | S53 |
| 73 | نموذج خاصية | S53 |
| 74 | طباعة الملصقات | S56 |
| 75 | قائمة قواعد التسعير | S57 |
| 76 | نموذج قاعدة | S57 |
| 77 | معاينة القاعدة | S57 |
| 78 | قائمة الزبائن | S12 |
| 79 | نموذج زبون | S12 |
| 80 | نافذة إضافة زبون سريع | S12 S17 |
| 81 | قائمة الموردين | S13 |
| 82 | نموذج مورد | S13 |
| 83 | لوحة الكاشير | S14 |
| 84 | شاشة فتح جلسة | S14 |
| 85 | شاشة البيع | S14 S15 S16 S17 S18 S20 S64 S67 |
| 86 | شاشة الدفع | S16 S17 |
| 87 | شاشة الإيصال | S16 S80 |
| 88 | كشف حساب الزبون | S17 |
| 89 | ملخص الوردية | S18 |
| 90 | شاشة الجرد النقدي | S18 |
| 91 | شاشة المرتجعات | S19 |
| 92 | شاشة المرتجع | S19 |
| 93 | إيصال المرتجع | S19 |
| 94 | قائمة الفواتير المعلّقة | S20 |
| 95 | تفاصيل فاتورة معلّقة | S20 |
| 96 | نافذة مخزون الفروع | S66 S67 |
| 97 | نموذج تحويل | S26 S67 S71 |
| 98 | قائمة فواتير الشراء | S21 |
| 99 | نموذج فاتورة شراء | S21 |
| 100 | تفاصيل فاتورة الشراء | S22 |
| 101 | نافذة الترحيل | S22 |
| 102 | شاشة مرتجعات المشتريات | S23 |
| 103 | نموذج مرتجع شراء | S23 S71 |
| 104 | ملف المورد | S24 |
| 105 | نموذج ملاحظة | S24 |
| 106 | قائمة الملاحظات | S24 |
| 107 | شاشة أرصدة المخزون | S25 S71 |
| 108 | بطاقة حركة الصنف | S25 |
| 109 | قائمة التحويلات | S26 |
| 110 | تفاصيل التحويل | S26 S27 |
| 111 | نافذة الشحن | S27 |
| 112 | قائمة الواردات | S27 |
| 113 | نافذة الاستلام | S27 |
| 114 | قائمة التسويات | S28 |
| 115 | نموذج تسوية | S28 S71 |
| 116 | تفاصيل التسوية | S28 |
| 117 | شاشة مستويات الطلب | S29 |
| 118 | نافذة معالجة التالف | S71 |
| 119 | قائمة السندات | S30 S31 S69 |
| 120 | نموذج سند قبض | S30 |
| 121 | نموذج سند دفع | S31 |
| 122 | قائمة المصروفات | S32 |
| 123 | نموذج مصروف | S32 |
| 124 | تفاصيل المصروف | S32 S65 |
| 125 | قائمة التحويلات المالية | S33 |
| 126 | نموذج تحويل مالي | S33 |
| 127 | شاشة الأرصدة | S34 |
| 128 | كشف حساب | S34 S79 |
| 129 | قائمة تسويات الأرصدة | S35 |
| 130 | نموذج تسوية رصيد | S35 |
| 131 | تفاصيل تسوية | S35 |
| 132 | نموذج حركة مالك | S36 |
| 133 | قائمة الحسابات المالية | S37 |
| 134 | نموذج بنك | S37 |
| 135 | نموذج حساب بنكي | S37 |
| 136 | نموذج حساب مالي | S37 |
| 137 | مراجعة مصروفات الكاشير | S65 |
| 138 | معالج بدء التشغيل | S68 |
| 139 | خطوة المخزون | S68 |
| 140 | خطوة الصناديق والبنوك | S68 |
| 141 | خطوة الزبائن والموردين | S68 |
| 142 | خطوة الجاهزية | S68 |
| 143 | نموذج دفعة موظف | S69 |
| 144 | الفئات والأسباب | S70 |
| 145 | نموذج فئة | S70 |
| 146 | نموذج سبب | S70 |
| 147 | نموذج مالك | S72 |
| 148 | دليل الحسابات | S38 |
| 149 | نموذج حساب | S38 |
| 150 | شاشة الربط المحاسبي | S38 |
| 151 | قائمة القيود | S39 |
| 152 | تفاصيل القيد | S39 |
| 153 | نافذة العكس | S39 |
| 154 | قائمة الفترات المحاسبية | S40 |
| 155 | نموذج فترة | S40 |
| 156 | تفاصيل الفترة | S40 |
| 157 | تقرير المبيعات اليومية | S41 |
| 158 | تقرير المخزون | S41 |
| 159 | تقرير الورديات | S41 |
| 160 | تقرير أرصدة الحسابات | S45 S75 |
| 161 | تقرير أرصدة الأطراف | S45 |
| 162 | تقرير أرصدة الحسابات المالية | S45 |
| 163 | تقرير المستندات المفتوحة | S45 |
| 164 | سجل التدقيق | S42 |
| 165 | تفاصيل سجل | S42 |
| 166 | تقرير الربحية | S73 |
| 167 | تقرير أسعار المتغيرات | S74 |
| 168 | تقرير الوصول | S74 |
| 169 | تقرير المتغيرات | S74 |
| 170 | نموذج قيد إقفال | S75 |
| 171 | لوحة الإشعارات | S44 |
| 172 | نموذج تطبيق سلفة | S79 |
| 173 | قائمة المبيعات | S80 |
| 174 | تفاصيل فاتورة البيع | S80 |

عدد الشاشات الفريدة: 174.

## الملحق د: جداول غير مستخدمة كجداول رئيسية

4 جداول من أصل 121 لا يظهر كجدول رئيسي في أي سيناريو.

| **الجدول** | **السبب** |
| --- | --- |
| error_codes | جدول تقني فيه 29 صفاً (ERP01 إلى ERP29)؛ مرجع للأكواد ولا شاشة له. |
| product_type_care_instructions | ربط تعليمات العناية بنوع المنتج (يُذكر في S51 دون أن يكون جدولاً رئيسياً). |
| sync_nodes | جدول تقني للمزامنة، خارج نطاق v1 (العمل متصل بالإنترنت، قرار-02). |
| tax_rates | لا ضريبة في v1 (قرار-35). |

## الملحق هـ: أكواد الأخطاء الموحدة (ERP)

جدول error_codes في القاعدة فيه 29 صفاً (ERP01 إلى ERP29)، والرسائل أدناه كما هي في عمود الرسالة. الدوال الجديدة لا تضيف أكواداً: تستعمل ERP16 وERP22 وERP18 وERP10 وERP08 وERP13 وERP02 وERP04 القائمة.

| **الكود** | **الاسم** | **الرسالة** |
| --- | --- | --- |
| ERP01 | DOC_LOCKED | مستند مُرحَّل أو ملغى لا يُعدَّل ولا يُحذف |
| ERP02 | DOC_BAD_TRANSITION | انتقال حالة غير مسموح للمستند — الإلغاء (CANCELLED) للمسودات فقط، والمستند المرحّل يُعكس بمستند معاكس فتصبح حالته REVERSED |
| ERP03 | DOC_ITEMS_LOCKED | لا يجوز تعديل بنود مستند ليس في حالة مسودة |
| ERP04 | INSUFFICIENT_STOCK | الرصيد غير كافٍ والسياسة تمنع الرصيد السالب |
| ERP05 | APPEND_ONLY | جدول للإضافة فقط، التصحيح بحركة معاكسة |
| ERP06 | FX_RATE_IMMUTABLE | أسعار الصرف لا تُعدَّل ولا تُحذف، تُضاف أسعار جديدة |
| ERP07 | JOURNAL_UNBALANCED | القيد غير متوازن (مجموع المدين لا يساوي الدائن) |
| ERP08 | PERIOD_CLOSED | الفترة المحاسبية مغلقة أو التاريخ خارج الفترة |
| ERP09 | GL_ACCOUNT_NOT_POSTABLE | حساب غير قابل للترحيل أو غير فعّال |
| ERP10 | CURRENCY_MISMATCH | عدم تطابق العملات |
| ERP11 | WAREHOUSE_NOT_SELLABLE | المستودع غير قابل للبيع |
| ERP12 | POS_SESSION_NOT_RECONCILED | لا تُغلق الوردية قبل جرد POSTED لكل عملة |
| ERP13 | PERIOD_LOCKED | الفترة المحاسبية مقفلة نهائياً |
| ERP14 | GL_PARENT_POSTABLE | الحساب الأب يجب أن يكون تجميعياً وغير قابل للترحيل |
| ERP15 | TRANSFER_RATE_INVALID | بيانات سعر الصرف أو المبالغ في تحويل الأموال غير صحيحة |
| ERP16 | PERMISSION_DENIED | لا تملك الصلاحية المطلوبة لهذه العملية |
| ERP17 | REASON_MISMATCH | سبب الدفع/التسوية لا يطابق نوع العملية |
| ERP18 | DOC_LINK_MISMATCH | عدم تطابق بين المستند ومرجعه (فاتورة/بند/دفعة) |
| ERP19 | PRICE_RATE_REQUIRED | يلزم سعر صرف السعر عند اختلاف عملة السعر عن عملة الفاتورة |
| ERP20 | ACCOUNT_TYPE_INVALID | نوع الحساب المالي غير مناسب للعملية |
| ERP21 | JOURNAL_TOO_FEW_LINES | القيد يحتاج سطرين على الأقل |
| ERP22 | INVALID_STATE | حالة أو بيانات غير صالحة للعملية |
| ERP23 | PRICE_LIST_NOT_ALLOWED | قائمة الأسعار غير مسموحة لهذا المستخدم أو نقطة البيع |
| ERP24 | PRICE_MISMATCH | السعر لا يطابق سعر القائمة المعتمد ولا يجوز تعديل سعر السطر |
| ERP25 | PRICE_NOT_FOUND | لا يوجد سعر قابل للحل للصنف في قائمة الأسعار |
| ERP26 | DISCOUNT_CAP_EXCEEDED | الخصم يتجاوز السقف المسموح |
| ERP27 | ATTRIBUTE_VALUE_INVALID | قيمة الخاصية لا تطابق نوعها أو خياراتها |
| ERP28 | REQUIRED_ATTRIBUTES_MISSING | خصائص إلزامية ناقصة، لا يمكن نشر المنتج |
| ERP29 | PRODUCT_MUST_START_DRAFT | يُنشأ المنتج مسودة أولاً ثم تُحفظ خصائصه ثم يُنشر |

## الملحق و: رسائل المنع الموحّدة

الرسائل الصادرة من القاعدة كما هي؛ اعرضها للمستخدم بنصها.

| **الحالة** | **الكود** | **الرسالة** |
| --- | --- | --- |
| رصيد غير كافٍ | ERP04 INSUFFICIENT_STOCK | الرصيد غير كافٍ للصنف \[الاسم\] |
| تكلفة غير معرّفة | ERP22 (REQUIRE_COST_ON_SALE = Y) | لا توجد تكلفة للصنف ولا يُسمح بالبيع بدونها |
| خصم فوق السقف على السطر | ERP26 | الخصم على السطر يتجاوز السقف المسموح (X% من قيمة السطر) |
| خصم فوق السقف على الفاتورة | ERP26 (post_sale) | إجمالي خصم الفاتورة يتجاوز السقف المسموح (X% من قيمة الفاتورة) |
| سعر مخالف | ERP24 | سعر السطر لا يطابق سعر القائمة (المعتمد X). لا يجوز تعديل السعر، استخدم الخصم |
| سعر غير موجود | ERP25 | لا يوجد سعر لهذا الصنف في قائمة الأسعار المحددة، ولا يمكن بيعه قبل تحديد سعره |
| قائمة أسعار غير مسموحة | ERP23 | قائمة الأسعار المحددة غير مسموحة لك أو لنقطة البيع |
| لا قائمة مسموحة | ERP23 | لا توجد قائمة أسعار مسموحة لك على هذه النقطة. اطلب من المدير ربطك بقائمة أسعار |
| مستودع فرع آخر أو غير قابل للبيع | ERP11 | لا يمكن البيع إلا من مستودع تابع لفرع الفاتورة |
| بلا صلاحية خصم | ERP16 | لا تملك صلاحية منح الخصم |
| نشر بخصائص ناقصة | ERP28 | لا يمكن نشر المنتج قبل تعبئة الخصائص الإلزامية: \[الأسماء\] |
| وردية كاشير آخر بلا pos.manage، أو بـ pos.manage من فرع مختلف | ERP16 PERMISSION_DENIED (assert_session_owner) | هذه الوردية تخص كاشيراً آخر ولا يجوز استعمالها |
| موافقة على تحويل أو تشغيل على مستودع بلا صلاحية (require_warehouse) | ERP16 PERMISSION_DENIED | لا تملك صلاحية التشغيل على هذا المستودع |
| انتقال حالة غير مسموح | ERP02 DOC_BAD_TRANSITION | انتقال حالة غير مسموح للمستند — الإلغاء (CANCELLED) للمسودات فقط، والمستند المرحّل يُعكس بمستند معاكس فتصبح حالته REVERSED |

### أخطاء الدوال الجديدة (الحالة والكود)

تُعرض رسالة الدالة كما تصدر. وعند نقص رصيد السلف في apply_advance تحمل تفاصيل الخطأ الحقول available وrequested وcurrency_id.

| **الدالة** | **الحالة** | **الكود** |
| --- | --- | --- |
| quick_add_customer | اسم أو هاتف فارغ؛ هاتف لطرف ليس زبوناً (مورد أو موظف) | ERP22 |
| admin_provision_user | بلا فرع لغير SUPER_ADMIN؛ فروع مكررة أو غير موجودة أو غير فعّالة؛ تشغيل بلا عرض | ERP22 |
| mark_expense_reviewed | بلا صلاحية؛ مصروف غير موجود أو غير POSTED أو مستند عكسي أو مراجَع مسبقاً | ERP16؛ ERP22 |
| attach_expense_receipt | بلا صلاحية أو بلا تسجيل دخول؛ مصروف غير موجود أو غير POSTED أو مراجَع؛ مسار غير صالح أو لا يبدأ برقم فرع المصروف؛ ملف غير موجود في bucket | ERP16؛ ERP22 |
| apply_advance | بلا finance.payments أو صلاحية الفرع | ERP16 |
| apply_advance | قائمة فارغة أو غير صالحة؛ طرف أو عملة غير موجودين؛ مبلغ صفر أو سالب؛ صيغة غير صحيحة؛ خلط بيع وشراء؛ فروع مختلفة؛ رصيد سلف أقل من المطلوب؛ تجاوز المتبقي | ERP22 |
| apply_advance | فاتورة غير مرحّلة أو لا تخص الطرف | ERP18 |
| apply_advance | اختلاف عملة الفاتورة عن عملة التطبيق | ERP10 |
| apply_advance | فترة مغلقة أو مقفلة | ERP08؛ ERP13 |
| reverse_stock_adjustment | تسوية غير POSTED أو مستند عكسي أو معكوس مسبقاً | ERP02 |
| reverse_stock_adjustment | الرصيد الحالي لا يسمح بعكس زيادة | ERP04 |
| reverse_stock_adjustment | فترة مغلقة أو مقفلة؛ بيانات غير صالحة | ERP08؛ ERP13؛ ERP22 |
| reverse_cash_reconciliation | جرد غير POSTED أو معكوس مسبقاً | ERP02 |
| reverse_cash_reconciliation | بلا صلاحية | ERP16 |
| reverse_cash_reconciliation | فترة مغلقة أو مقفلة؛ بيانات غير صالحة | ERP08؛ ERP13؛ ERP22 |
| attach_product_image / attach_color_image / delete_product_image / delete_color_image | بلا صلاحية catalog.manage | ERP16 |
| attach_product_image / attach_color_image | مسار أو بيانات صورة غير صالحة (validate_image_path) | ERP22 |

## الملحق ز: قاموس الصلاحيات

46 صلاحية، و151 رابطاً في role_permissions. الأدوار الحاملة من الجدول الفعلي.

| **الوحدة** | **الكود** | **المعنى** | **الأدوار الحاملة** |
| --- | --- | --- | --- |
| accounting | accounting.manage | إدارة دليل الحسابات وربط الحسابات | SUPER_ADMIN ACCOUNTANT |
| accounting | accounting.post | قيود يدوية وإغلاق فترات | SUPER_ADMIN ACCOUNTANT |
| accounting | accounting.view | عرض المحاسبة | SUPER_ADMIN MANAGER ACCOUNTANT AUDITOR |
| accounting | balance.adjust | تسويات أرصدة الأطراف | SUPER_ADMIN ACCOUNTANT |
| catalog | catalog.manage | إدارة المنتجات | SUPER_ADMIN MANAGER WAREHOUSE PURCHASER |
| catalog | costs.manage | تعديل التكاليف | SUPER_ADMIN MANAGER ACCOUNTANT |
| catalog | costs.view | عرض التكاليف | SUPER_ADMIN MANAGER ACCOUNTANT PURCHASER AUDITOR |
| core | audit.view | عرض سجل التدقيق | SUPER_ADMIN MANAGER ACCOUNTANT AUDITOR |
| core | settings.manage | إدارة الإعدادات | SUPER_ADMIN |
| core | users.manage | إدارة المستخدمين والصلاحيات | SUPER_ADMIN |
| finance | finance.expenses | المصاريف | SUPER_ADMIN MANAGER CASHIER ACCOUNTANT |
| finance | finance.manage | إدارة العملات والصناديق | SUPER_ADMIN ACCOUNTANT |
| finance | finance.payments | سندات القبض والدفع | SUPER_ADMIN MANAGER CASHIER ACCOUNTANT PURCHASER |
| finance | finance.view | عرض الحسابات المالية والأرصدة | SUPER_ADMIN MANAGER ACCOUNTANT AUDITOR |
| finance | fx.rate.manage | إدارة أسعار الصرف | SUPER_ADMIN ACCOUNTANT |
| finance | fx.rate.manual | استخدام سعر صرف يدوي في مستند | SUPER_ADMIN MANAGER ACCOUNTANT |
| finance | owner.transactions | سحوبات ومساهمات المالك | SUPER_ADMIN ACCOUNTANT |
| finance | payment.cancel | إلغاء/عكس دفعة | SUPER_ADMIN MANAGER ACCOUNTANT |
| finance | reconcile.cash | جرد الصندوق وتسوية فروقاته | SUPER_ADMIN MANAGER CASHIER ACCOUNTANT |
| hr | hr.manage | إدارة الموظفين | SUPER_ADMIN MANAGER |
| hr | hr.view | عرض الموظفين | SUPER_ADMIN MANAGER ACCOUNTANT AUDITOR |
| inventory | inventory.adjust | جرد وتسويات | SUPER_ADMIN MANAGER WAREHOUSE |
| inventory | inventory.transfer | تحويل مخزون | SUPER_ADMIN MANAGER WAREHOUSE |
| inventory | inventory.transfer.approve | اعتماد التحويلات | SUPER_ADMIN MANAGER WAREHOUSE |
| inventory | inventory.view | عرض المخزون | SUPER_ADMIN MANAGER CASHIER WAREHOUSE ACCOUNTANT PURCHASER AUDITOR |
| inventory | inventory.view_other_branches | الاطلاع على مخزون الفروع الأخرى | SUPER_ADMIN MANAGER CASHIER WAREHOUSE PURCHASER |
| inventory | warehouse.central.access | الوصول للمستودع المركزي | SUPER_ADMIN MANAGER WAREHOUSE PURCHASER AUDITOR |
| masterdata | masterdata.manage | إدارة البيانات الأساسية | SUPER_ADMIN MANAGER WAREHOUSE PURCHASER |
| org | org.manage | إدارة الفروع والمستودعات | SUPER_ADMIN |
| parties | parties.manage | إدارة الأطراف | SUPER_ADMIN MANAGER ACCOUNTANT PURCHASER |
| parties | parties.quick_add | إضافة سريعة لزبون | CASHIER |
| parties | parties.view | عرض الأطراف | SUPER_ADMIN MANAGER CASHIER ACCOUNTANT PURCHASER AUDITOR |
| pos | pos.manage | إدارة أجهزة نقاط البيع وكل الورديات | SUPER_ADMIN MANAGER |
| pos | pos.session | فتح/إغلاق وردية | SUPER_ADMIN MANAGER CASHIER |
| pricing | pricing.manage | إدارة الأسعار والخصومات | SUPER_ADMIN MANAGER |
| purchasing | purchasing.create | إنشاء فواتير شراء | SUPER_ADMIN MANAGER PURCHASER |
| purchasing | purchasing.post | ترحيل فواتير شراء | SUPER_ADMIN MANAGER PURCHASER |
| purchasing | purchasing.return | مرتجع مشتريات وإلغاء فواتير الشراء | SUPER_ADMIN MANAGER PURCHASER |
| purchasing | purchasing.view | عرض المشتريات | SUPER_ADMIN MANAGER WAREHOUSE ACCOUNTANT PURCHASER AUDITOR |
| reports | reports.view | عرض التقارير | SUPER_ADMIN MANAGER ACCOUNTANT PURCHASER AUDITOR |
| sales | discount.exceptional | خصم استثنائي | SUPER_ADMIN MANAGER |
| sales | sales.create | إنشاء مبيعات | SUPER_ADMIN MANAGER CASHIER |
| sales | sales.discount | منح خصم | SUPER_ADMIN MANAGER CASHIER |
| sales | sales.post | ترحيل مبيعات | SUPER_ADMIN MANAGER CASHIER |
| sales | sales.return | مرتجع مبيعات | SUPER_ADMIN MANAGER CASHIER |
| sales | sales.view | عرض المبيعات | SUPER_ADMIN MANAGER CASHIER ACCOUNTANT AUDITOR |

## الملحق ح: Views وأعمدتها الفعلية

19 View في public، أعمدتها وترتيبها كما في القاعدة.

| **الـ View** | **الأعمدة** |
| --- | --- |
| v_account_balances | gl_account_id, code, name, account_type, normal_balance, parent_id, is_postable, debit_base, credit_base, balance_base |
| v_financial_account_balances | financial_account_id, name, type, branch_id, currency_id, currency_code, balance, total_in, total_out, last_transaction_date, is_active |
| v_low_stock | warehouse_id, warehouse_code, warehouse_name, branch_id, is_sellable, variant_id, sku, variant_name, product_id, product_name, quantity_on_hand, quantity_reserved, quantity_available, quantity_incoming, min_quantity, reorder_quantity, below_min |
| v_open_documents | doc_type, doc_id, doc_number, branch_id, party_id, party_name, currency_id, doc_date, due_date, total_amount, paid_amount, remaining_amount, payment_status, days_overdue |
| v_party_balances | party_id, party_name, party_type, is_customer, is_supplier, currency_id, currency_code, total_debit, total_credit, balance, last_entry_date |
| v_pos_session_summary | pos_session_id, pos_terminal_id, terminal_code, branch_id, cashier_user_id, cashier_username, status, opened_at, closed_at, invoices_count |
| v_product_attributes | product_id, kind, item_id, code, name, data_type, is_filterable, option_id, display_value |
| v_product_type_attribute_defs | product_type_id, kind, item_id, code, name, data_type, option_set_id, unit_id, is_filterable, is_required, sort_order, is_active |
| v_purchase_items_costs | id, purchase_invoice_id, variant_id, unit_cost, total_cost |
| v_sale_items_costs | id, sale_id, variant_id, unit_cost, unit_cost_currency_id |
| v_sales_daily | sale_day, branch_id, channel, currency_id, currency_code, invoices_count, total_amount, total_base, total_discount |
| v_stock_available | warehouse_id, warehouse_code, warehouse_name, branch_id, is_sellable, variant_id, sku, variant_name, product_id, product_name, quantity_on_hand, quantity_reserved, quantity_available, quantity_incoming, min_quantity, reorder_quantity, below_min |
| v_stock_in_transit | transfer_id, transfer_number, from_warehouse_id, to_warehouse_id, transfer_item_id, variant_id, sku, variant_name, quantity_shipped, quantity_received, quantity_damaged, quantity_missing, quantity_in_transit, unit_cost, shipped_at, days_in_transit |
| v_stock_movements_costs | id, variant_id, warehouse_id, movement_type, quantity, unit_cost, currency_id, movement_date |
| v_transfer_costs | transfer_item_id, transfer_id, variant_id, unit_cost, loss_value |
| v_transfer_discrepancies | transfer_id, transfer_number, from_warehouse_id, to_warehouse_id, received_at, transfer_item_id, variant_id, sku, variant_name, quantity_shipped, quantity_received, quantity_damaged, quantity_missing, unaccounted_quantity, discrepancy_type, unit_cost, loss_value |
| v_user_access | user_id, username, email, is_active, full_name, job_title, role_codes, branch_codes, terminal_codes |
| v_variant_attributes | variant_id, product_id, sku, variant_name, is_active, size_id, size_name, size_code, product_color_id, color_name, color_components |
| v_variant_list_prices | variant_id, product_id, sku, variant_name, price_list_id, price_list_code, price_type, currency_id, currency_code, amount, valid_from, valid_to, is_current |

التكلفة وقيمة الخسارة تُقرآن من v_transfer_costs (costs.view). v_variant_list_prices بصف واحد لكل (متغير، قائمة) هو السعر الساري، وسعر مستقبلي (is_current = false) يظهر فقط عند غياب سعر ساري، وبلا أعمدة تكلفة.

## الملحق ط: سجل القرارات

ترقيم واحد (قرار-01 إلى قرار-63).

| **رقم** | **نص القرار** | **الأثر** | **السيناريوهات المرتبطة** |
| --- | --- | --- | --- |
| قرار-01 | ربط الأدوار بالصلاحيات | يُعتمد الجدول في 1.3 وهو الآن مكتوب فعلياً في role_permissions. | عام |
| قرار-02 | العمل متصل بالإنترنت | لا حالة «مزامنة» في الواجهات؛ والعمل بلا اتصال خارج نطاق v1. | عام |
| قرار-03 | العرض حسب display_preferences مع أفضلية عملة الفاتورة | السيناريو S43؛ فاتورة الشراء بعملتها أولاً، والبيع بحسب التفضيل. | S43 |
| قرار-04 | اختيار الفرع في كل دخول | شاشة اختيار الفرع في S01؛ التبديل في S61. | S01 S61 |
| قرار-05 | المدير يعيد تعيين كلمة المرور | لا رابط «نسيت كلمة المرور»؛ S59. | S59 |
| قرار-06 | إدارة الكتالوج: MANAGER وPURCHASER وWAREHOUSE | S07 وS08 وS46 إلى S56؛ masterdata.manage وcatalog.manage ممنوحتان للثلاثة. | S07 S08 S46 S47 S48 S49 S50 S51 S52 S53 S54 S55 S56 |
| قرار-07 | التكلفة يراها حتى AUDITOR | أعمدة التكلفة مخفية عن بقية الأدوار (costs.view). | عام |
| قرار-08 | تعليق الفاتورة في نقطة البيع | فواتير DRAFT معلّقة بلا حجز مخزون (S15، S20). | S15 S20 |
| قرار-09 | الكاشير ينشئ ويرحّل بنفسه | لا موافقة على البيع. | عام |
| قرار-10 | دفع بوسائل وعملات متعددة مع باقٍ بعملة أخرى | payment_lines بنوع CHANGE_GIVEN (S16). | S16 |
| قرار-11 | تجاوز حد الائتمان تحذير فقط | لا منع (S17). | S17 |
| قرار-12 | خصم الكاشير حتى سقف يحدده المدير | نسبة واحدة عامة مع تخصيص لكل فرع؛ ما زاد يُرفض بلا موافقة والمدير بلا حدود (S63، S16). | S16 S63 |
| قرار-13 | إغلاق الجلسة بيد الكاشير أو المدير والفرق يُرحَّل تلقائياً | S18. | S18 |
| قرار-14 | الكاشير يختار طريقة الاسترداد | S19. | S19 |
| قرار-15 | لا إلغاء لفاتورة مرحّلة، المرتجع فقط | S19 وS20؛ تُخفى أزرار الإلغاء في الواجهة. | S19 S20 |
| قرار-16 | شراء: الدفع عند الترحيل أو بسند دفع بعد الترحيل، وPURCHASER يرحّل بنفسه | S22؛ finance.payments ممنوحة للمشتري كاملة. | S22 S31 |
| قرار-17 | أمين المستودع المرسل يوافق على التحويل ، والتالف لمستودع تالف | S26 وS27؛ المفقود خسارة فورية، والتالف إلى DAMAGED للفرع المستلم، ثم S71. | S26 S27 S71 |
| قرار-18 | تسوية الجرد بلا موافقة | S28. | S28 |
| قرار-19 | المصروف ينشئه ويرحّله المحاسب ، والكاشير مصروف صغير بلا سقف مع مراجعة | S32 وS65. | S32 S65 |
| قرار-20 | القيود عرض وعكس فقط ، والمحاسب يغلق الفترة ويقفلها ، وإقفال السنة يدوي | S39 وS40 وS75. | S39 S40 S75 |
| قرار-21 | إشعارات داخل التطبيق | S44. | S44 |
| قرار-22 | المخزون السالب ممنوع | NEGATIVE_STOCK_POLICY = BLOCK (S78)؛ الاطلاع على الفروع الأخرى بلا بيع (S66). | S66 S78 |
| قرار-23 | السعر من آخر شراء بنسبة، والربح من المتوسط، ويُعرض العمودان | S09 وS10 وS57 وS73. | S09 S10 S57 S73 |
| قرار-24 | لا بيع بلا تكلفة | REQUIRE_COST_ON_SALE يبقى N حتى اكتمال الأرصدة الافتتاحية ثم Y (S68، S78). | S68 S78 |
| قرار-25 | المنطقة الزمنية Asia/Damascus | TIMEZONE في S78. | S78 |
| قرار-26 | وحدات القياس وصفية بلا تحويل | S50. | S50 |
| قرار-27 | اللون بسيط افتراضياً ومركّب اختيارياً | S46 وS08. | S08 S46 |
| قرار-28 | المقاسات موروثة من نوع المنتج مع إخفاء أو إضافة | S47 وS48. | S47 S48 |
| قرار-29 | الخصائص الديناميكية ضمن النسخة الأولى | S53؛ المنتج يُنشأ draft ثم تُحفظ خصائصه ثم يُنشر (ERP28 وERP29). | S53 |
| قرار-30 | الباركود يدوي أو داخلي مع طباعة | S56. | S56 |
| قرار-31 | الأرصدة الافتتاحية عبر معالج داخل التطبيق | S68. | S68 |
| قرار-32 | الرواتب والسلف: تسجيل دفعات فقط في v1 | S69. | S69 |
| قرار-33 | قوائم الأسعار: ربط المستخدم ونقطة البيع مع فرض داخل القاعدة | S58 وS64؛ لا نسبة جملة افتراضية، والمدير يُدخلها (S57). | S57 S58 S64 |
| قرار-34 | ترقيم المستندات ببادئة رمز الفرع | S77. | S77 |
| قرار-35 | لا ضريبة ولا شيكات في v1 | لا حقول ضريبة ولا طريقة شيك في السيناريوهات. | S16 S21 |
| قرار-36 | الشراء من مستودع فرع آخر ممنوع، والحل تحويل ثم بيع | S67. | S67 |
| قرار-37 | حساب المستخدم: اسم مستخدم بإيميل داخلي مخفي، وكلمة مؤقتة بتغيير إجباري | S01 وS02 وS59. | S01 S02 S59 |
| قرار-38 | مالك يعمل بالنظام على الطرف نفسه | S60 وS72. | S60 S72 |
| قرار-39 | مدير بعدة فروع: تبديل فرع في العمليات وكل الفروع في التقارير | S61. | S61 |
| قرار-40 | تعدد الأدوار مدعوم والمدير يبيع بلا دور ثانٍ | S02 وS14. | S02 S14 |
| قرار-41 | تكرار مسح الباركود يزيد الكمية في السطر نفسه | S15. | S15 |
| قرار-42 | الاستلام صارم للتالف: لا يُوجَّه التالف إلا إلى مستودع DAMAGED الفعّال في الفرع المستلم، ويُرفض الاستلام بـ ERP22 إن لم يوجد | لا رجوع إلى مستودع تالف في فرع آخر (عزل الفروع). S04 وS27 وS71. | S04 S27 S71 |
| قرار-43 | لا ترحيل بـ UPDATE مباشر لمستندات المصروف والتحويل المالي وتسوية الرصيد وتسوية الجرد والجرد النقدي؛ الترحيل بالدوال فقط | trigger forbid_direct_post؛ لا مستند POSTED بلا قيد وحركة مقابلة. ويشمل الجرد النقدي والتسوية المخزنية دالتي العكس reverse_cash_reconciliation وreverse_stock_adjustment. S18 وS28 وS32 وS33 وS35. | S18 S28 S32 S33 S35 |
| قرار-44 | العكس بمستند معاكس مرتبط بالأصل عبر reversal_of، ولا إلغاء مباشر لمستند مرحّل | reverse_payment وreverse_expense وreverse_balance_adjustment وreverse_money_transfer وreverse_journal_entry وreverse_stock_adjustment وreverse_cash_reconciliation. S18 وS28 وS30 وS31 وS32 وS33 وS35 وS39 وS79. | S18 S28 S30 S31 S32 S33 S35 S39 S79 |
| قرار-45 | المرتجع التالف (DAMAGED أو DEFECTIVE مع restock) يدخل مستودع DAMAGED في فرع المرتجع آلياً | لا يدخل مخزوناً قابلاً للبيع؛ يُرفض الترحيل بـ ERP22 إن لم يوجد مستودع تالف فعّال للفرع. S19 وS71. | S19 S71 |
| قرار-46 | أنواع الدفعات مقيَّدة بالصلاحيات: OWNER_WITHDRAWAL وOWNER_CONTRIBUTION تتطلبان owner.transactions، وEMPLOYEE_PAYMENT يتطلب finance.payments مع accounting.manage أو finance.manage | لا يرحّل المشتري ولا الكاشير دفعات المالك أو الموظف. S31 وS36 وS69. | S31 S36 S69 |
| قرار-47 | الفترات المحاسبية تُولَّد عند الطلب ضمن نافذة سنة سابقة إلى سنتين قادمتين، والإغلاق والقفل يدويان | ensure_fiscal_year وgenerate_fiscal_year؛ خارج النافذة يُرفض ERP08. S40 وS75. | S40 S75 |
| قرار-48 | جلسة OPEN واحدة لكل كاشير، ويجوز لعدة كاشيرين فتح جلسات على النقطة نفسها؛ ولا يستعمل الجلسة غير صاحبها إلا من يملك pos.manage، بشرط أن تعود الجلسة لنقطة بيع من فرع الفاتورة أو الدفعة نفسه وإلا ERP16 | فهرس فريد على cashier_user_id للجلسات المفتوحة، وassert_session_owner(p_session, p_branch) في sale_header_guard وpost_payment؛ الرسالة: «هذه الوردية تخص كاشيراً آخر ولا يجوز استعمالها». S14 وS16. | S14 S16 |
| قرار-49 | ملاحظة سعر الصرف إلزامية عند source = manual فقط | مصادر السعر: system وmanual وbank وmarket. S06. | S06 |
| قرار-50 | فئات الرواتب: EXP-SAL لأجور لا ترتبط بموظف مسجّل (عمالة مؤقتة، وكالات)، وEMP_SAL وEMP_ADV لراتب وسلفة موظف مسجّل؛ وكلاها على حساب 6101 | لا تضارب بين الفئة والسبب. S32 وS69 وS70. | S32 S69 S70 |
| قرار-51 | عند أي اختلاف بين هذه الوثيقة والقاعدة فالقاعدة هي المرجع، وتُعدَّل الوثيقة بعد استقرار القاعدة | يسري على كل السيناريوهات. | عام |
| قرار-52 | الكاشير يحمل parties.quick_add ولا يحمل parties.manage | تُضاف الزبائن عبر quick_add_customer (سقف ائتمان 0 وبلا قائمة أسعار)؛ لا كتابة مباشرة في parties وcustomers؛ parties.manage للمدير والمحاسب والمشتري. | S12 S17 |
| قرار-53 | فرع واحد على الأقل إلزامي عند إنشاء مستخدم غير SUPER_ADMIN | p_branches بمفتاحي can_view وcan_operate لكل فرع، وتفرضه الدالة بـ ERP22؛ provision-user تقبل branches. | S01 S02 S60 |
| قرار-54 | hr.manage للمدير وSUPER_ADMIN | المحاسب والمدقق hr.view؛ المدير لا يملك users.manage فلا يمنح حسابات. | S02 S62 |
| قرار-55 | مراجعة المصروفات بأعمدة reviewed_by وreviewed_at وreview_note | mark_expense_reviewed وlist_expenses_for_review؛ المدقق لا يعلّم والكاشير لا يراجع مصروفاته. | S32 S65 S81 |
| قرار-56 | صورة إيصال المصروف اختيارية في v1 | expenses.receipt_image_path وbucket خاص expense-receipts وattach_expense_receipt؛ الاستبدال ممكن ما لم يُراجَع المصروف. | S32 S65 |
| قرار-57 | تطبيق السلف بـ apply_advance | السلف الأقدم أولاً بالعملة نفسها وفي فرع واحد وبلا حركة نقدية؛ العكس بـ reverse_payment؛ وlist_party_advances لعرض الرصيد. | S79 S30 S31 |
| قرار-58 | توحيد حالة المعكوس REVERSED | كل مستند مرحّل جرى عكسه حالته REVERSED؛ CANCELLED للمسودات فقط والتحويل المخزني الملغى قبل الشحن. | عام |
| قرار-59 | عكس الجرد المخزني والنقدي | reverse_stock_adjustment وreverse_cash_reconciliation؛ لا إعادة فتح لجلسة مغلقة، والجلسة OPEN تحتاج جرداً جديداً قبل الإغلاق (ERP12 يعدّ الجرد POSTED غير المعكوس). | S18 S28 |
| قرار-60 | فحص فرع الجلسة عند استعمال جلسة غير صاحبها | assert_session_owner(p_session, p_branch) في sale_header_guard وpost_payment؛ ERP16 عند اختلاف الفرع. | S14 S16 |
| قرار-61 | قفل الحساب وتحديث last_login_at وتدقيق LOGIN خارج v1 | لا أعمدة ولا حالات في الواجهات لها. | S01 S42 S59 |
| قرار-62 | الضرائب والشيك خارج v1 | حُذف سيناريو إدارة الضرائب والشيك، ولا تظهر حقولهما في السيناريوهات. | S16 S21 |
| قرار-63 | صور المنتج والألوان داخل v1 | bucket عام product-images، والرفع والحذف لـ catalog.manage، وattach_product_image وattach_color_image وdelete_product_image وdelete_color_image؛ وتدخل صور المنتج والألوان ومراجعة المصروف والعكس والإيصال في سجل التدقيق. | S07 S46 S55 |

# 5\. خارج نطاق v1

| **البند** | **الوصف** |
| --- | --- |
| قفل الحساب بعد المحاولات الفاشلة | غير مدرج في v1. |
| last_login_at | لا يُحدَّث في v1. |
| تدقيق LOGIN | لا يُسجَّل الدخول في audit_logs في v1. |
| الإقفال الآلي للسنة | يبقى S75 قيداً يدوياً في v1. |
| الرواتب الكاملة | يبقى S69 دفعات راتب وسلف في v1. |
| جدول الإشعارات | تبقى S44 إشعارات محسوبة حياً في v1. |
| العمل بلا اتصال | العمل متصل بالإنترنت في v1 (قرار-02). |

# 6\. قائمة التشغيل قبل الإطلاق

- [ ] تفعيل حماية كلمات المرور المسرَّبة من لوحة Supabase Auth.
- [ ] حذف Edge Function باسم quick-service (موجودة بالنسخة 1 بحسب تقرير القاعدة الأخير).
- [ ] إدخال قواعد التسعير ونسبة الجملة (S57) وحذف قاعدة TEST-CAP-MU20.
- [ ] ربط المستخدمين ونقاط البيع بقوائم الأسعار (S58).
- [ ] إدخال الأرصدة الافتتاحية (S68) ثم ضبط REQUIRE_COST_ON_SALE = Y.
- [ ] إنشاء مستودع DAMAGED لكل فرع جديد.
- [ ] حذف بيانات الاختبار (4 منتجات و4 فواتير).
- [ ] الاختبارات السلوكية بمستخدم حقيقي لكل دور، بحسب جدول القبول التالي (المسارات الحرجة أولاً).

## جدول القبول

| **الدور** | **السيناريو** | **المتوقع** | **النتيجة** |
| --- | --- | --- | --- |
| CASHIER | S14 S16 | بيع كامل بخصم ضمن السقف ودفع متعدد الوسائل والعملات مع باقٍ: فاتورة POSTED وPAID ودفعة POSTED وحركة SALE_OUT | ☐ |
| CASHIER | S16 | خصم فوق سقف الكاشير يُرفض بـ ERP26 | ☐ |
| CASHIER | S19 | مرتجع قابل للبيع يعود إلى مخزون قابل للبيع | ☐ |
| CASHIER | S19 S71 | مرتجع تالف يدخل مستودع DAMAGED في فرع المرتجع | ☐ |
| CASHIER | S18 | جرد نقدي لكل عملة ثم إغلاق الجلسة؛ الإغلاق قبل الجرد يُرفض بـ ERP12 | ☐ |
| CASHIER | S14 S16 | استعمال جلسة كاشير آخر يُرفض بـ ERP16 «هذه الوردية تخص كاشيراً آخر ولا يجوز استعمالها» | ☐ |
| MANAGER | S14 S16 | جلسة كاشير من فرع آخر بـ pos.manage تُرفض بـ ERP16، ومن الفرع نفسه تُقبل | ☐ |
| CASHIER | S12 S17 | زبون سريع بهاتف جديد ينشأ بسقف 0؛ بهاتف مكرر يعيد الموجود (existing = true)؛ بهاتف مورد ERP22؛ والكتابة المباشرة في parties تُرفض | ☐ |
| PURCHASER | S21 S22 S23 | فاتورة شراء ثم ترحيل بالدفع عند الاستلام ومرتجع مشتريات | ☐ |
| PURCHASER | S31 S36 S69 | دفعة مورد تُرحَّل، ودفعة المالك والموظف تُرفض بـ ERP16 | ☐ |
| ACCOUNTANT | S30 S31 | قبض ودفع ثم عكسهما بـ reverse_payment فيصير الأصل REVERSED | ☐ |
| ACCOUNTANT | S32 S33 | مصروف وتحويل مالي ثم عكسهما فيصير الأصل REVERSED | ☐ |
| ACCOUNTANT | S65 | mark_expense_reviewed يعلّم المصروف مراجَعاً وتكراره يُرفض بـ ERP22 | ☐ |
| ACCOUNTANT | S79 | apply_advance تغطي فاتورة بالسلف الأقدم أولاً بلا حركة نقدية، وعكسها بـ reverse_payment | ☐ |
| ACCOUNTANT | S32 | إرفاق إيصال واستبداله قبل المراجعة، ورفض ذلك بعد المراجعة بـ ERP22 | ☐ |
| WAREHOUSE | S26 S27 | تحويل: إنشاء وموافقة المرسل وشحن واستلام بتالف يذهب إلى DAMAGED في الفرع المستلم | ☐ |
| WAREHOUSE | S26 | موافقة من غير أمين المستودع المرسل تُرفض بـ ERP16 «لا تملك صلاحية التشغيل على هذا المستودع» | ☐ |
| WAREHOUSE | S28 | تسوية جرد وترحيلها ثم عكسها بـ reverse_stock_adjustment | ☐ |
| MANAGER | S18 | عكس الجرد النقدي لجلسة OPEN (جرد جديد قبل الإغلاق) ولجلسة CLOSED (حركة بلا جلسة) | ☐ |
| MANAGER | S55 S46 | رفع صورة منتج ولون وتسجيلها، الأساسية تُلغي السابقة، حذف الصف والملف، ورفض النوع غير المدعوم | ☐ |
| MANAGER | S62 | يضيف الموظفين ويعدّلهم ولا يمنحهم حسابات | ☐ |
| SUPER_ADMIN | S02 | إنشاء مستخدم بفروع (يعرض/ينفّذ)، ورفض الإنشاء بلا فرع بـ ERP22 | ☐ |
| AUDITOR | S34 S39 S42 S65 | قراءة فقط: لا أزرار إنشاء أو ترحيل أو عكس أو تعليم مراجعة | ☐ |
