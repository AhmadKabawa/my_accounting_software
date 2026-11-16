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
| الملاحق | الملحق ط: سجل القرارات (قرار-01 إلى قرار-81). وفي آخر الوثيقة: خارج نطاق v1، وقائمة التشغيل قبل الإطلاق. |

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

سجل القرارات في الملحق ط بترقيم واحد (قرار-01 إلى قرار-81)، وتشير إليه السيناريوهات برقم القرار. عند تعارض أي قرار مع القاعدة فالقاعدة هي المرجع (قرار-51).

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

