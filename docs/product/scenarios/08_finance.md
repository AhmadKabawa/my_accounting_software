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

