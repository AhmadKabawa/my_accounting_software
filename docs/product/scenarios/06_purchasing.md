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

