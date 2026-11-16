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

