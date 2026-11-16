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

