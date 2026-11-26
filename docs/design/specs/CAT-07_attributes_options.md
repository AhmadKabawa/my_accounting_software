# CAT-07 — الخصائص ومجموعات الخيارات (التعريف)

| البند | القيمة |
|---|---|
| الرمز | CAT-07 / الخصائص والخيارات |
| الحالة | **مسودة منقّحة — 2026-11-26؛ غير منفذة** |
| المسارات المعتمدة | `/catalog/option-sets` و`/catalog/attributes` (يُفحصان مقابل `route_registry`) |
| المنصة | ويب متجاوب |
| يرث من | `CAT-07_master_data_common.md` (المشتركة) |
| المراجع | S53 (الخطوتان 1–2) · DATA_MODEL §8 و§4.3 و§13 · ERP27 وERP28 |

## 0. الملخص

تعريف **مجموعات الخيارات** وخياراتها، و**الخصائص** بأنواع بيانات. هذا هو نصف S53 الذي يملكه `masterdata.manage`. **خارج هذه الشاشة:** ربط الخاصية بنوع المنتج (S53 الخطوة 3) في `CAT-07_product_types` (المرحلة ب)، وتعبئتها في المنتج (الخطوة 4) في CAT-02. جدولا `attributes` و`product_type_attributes` **فارغان حالياً**، فلا يوجد إلزامي يمنع النشر بعد (DATA_MODEL §13).

## 1. معلومات الشاشة
- **لماذا وحدة مفهومة؟** كيانان مترابطان (الخاصية من نوع `option` تشير إلى مجموعة خيارات) يُعرَّفان معاً قبل أي ربط.
- **لماذا صفحتان؟** مجموعة الخيارات لها خيارات متعددة تُحرَّر معاً؛ الخاصية سجل مسطح. نمطان مختلفان.

## 2. الهدف والنتيجة
- مخوَّل يعرّف مجموعة خيارات (واحد/متعدد) بخياراتها، وخاصية من نوع معلوم، فتصلح للربط بنوع منتج.
- **اكتمال المهمة:** خاصية `option` لا تُحفظ بلا مجموعة خيارات؛ وخاصية غير `option` لا تُحفظ بمجموعة (قيد القاعدة).

## 3. المرجع ومصدر الحقيقة
| القرار/المعلومة | المصدر |
|---|---|
| الحقول والأنواع | S53 §5 + DATA_MODEL |
| `data_type` ∈ text, number, boolean, date, json, option | DATA_MODEL §4.3 |
| `option_sets.selection_type` ∈ single, multiple (افتراض single) | DATA_MODEL §4.3 |
| **خاصية `option` ⇔ `option_set_id` غير فارغ** | `ck_attributes_option_set: (data_type='option') = (option_set_id IS NOT NULL)` |
| فرادة | `attributes.code` · `option_sets.code` · `(option_set_id, code)` للخيارات |
| قرار سابق | «الخصائص الديناميكية تبقى إن كانت القاعدة تدعمها» (سجل القرارات المرفوع في المحادثة) |
| ما لم يرد | معنى `attributes.is_required` مقابل `product_type_attributes.is_required` · معنى `is_variant_option` · أثر تغيير `data_type` بعد وجود قيم |

## 4. المستخدمون والصلاحيات
كما في المشتركة C2. (تعبئة القيم في المنتج `catalog.manage` — خارج الشاشة.)

## 5. السيناريو (S53 الخطوتان 1–2)
1. **مجموعة خيارات:** الاسم، الرمز، نوع الاختيار (واحد/متعدد)، **الخيارات** (اسم، رمز، ترتيب).
2. **خاصية:** الاسم، الرمز، النوع، الوحدة (اختياري)، «قابلة للتصفية»، ومجموعة الخيارات (لنوع `option` فقط).
- **أخطاء:** رمز مكرر · نوع `option` بلا مجموعة · مجموعة لنوع غير `option`.

## 6. البيانات
| الجدول | الحقول | العلاقة |
|---|---|---|
| `option_sets` | `name` v100!, `code` v50! فريد, `selection_type`='single', `is_active` | — |
| `options` | `option_set_id`!, `name` v100!, `code` v50!, `sort_order`, `is_active` | `(option_set_id, code)` فريد؛ `(id, option_set_id)` فريد (لمفتاح مركّب مستهلَك) |
| `attributes` | `name` v150!, `code` v80! فريد, `data_type` v20!, `unit_id`, `is_filterable`=false, `is_required`=false, `is_variant_option`=false, `is_active`, `option_set_id` | → `units`، → `option_sets` |
| الاستهلاك | `product_type_attributes`, `product_type_option_sets`, `product_attribute_values` (`option_id`), `product_option_values`, `variant_option_values` | بلا cascade → استخدام يمنع الحذف |
- الاستخدام: للمجموعة `product_type_option_sets(count)`؛ للخاصية `product_type_attributes(count)`. عدّ الخيارات المستخدمة في قيم المنتج ممكن (القراءة مفتوحة) لكنه ثقيل، ويقرره D-C3.
- كلفة الاستعلام: المجموعات والخصائص بأعداد صغيرة؛ الخيارات تُحمَّل عند فتح المجموعة.

## 7. المعلومات المعروضة
| الكيان | أساسي | ثانوي |
|---|---|---|
| مجموعة | الاسم، الرمز، نوع الاختيار، الحالة | عدد الخيارات، عدد أنواع المنتجات المرتبطة |
| خيار | الاسم، الرمز، الترتيب | الحالة |
| خاصية | الاسم، الرمز، النوع (مترجم)، الحالة | الوحدة، المجموعة، «قابلة للتصفية»، عدد الأنواع المرتبطة |
- **لا تُعرض (حتى يُحسم المعنى):** `attributes.is_required` و`is_variant_option` — D-AT-1 وD-AT-2.

## 8. الإجراءات
كما في المشتركة C5، مع:
- **خيارات المجموعة:** إضافة/تعديل/إيقاف خيار داخل صفحة المجموعة (جدول داخلي بنمط S47: إضافة سريعة للصفوف).
- **الحذف:** لا يظهر لمجموعة أو خاصية أو خيار مستخدم؛ الإيقاف هو البديل. **إيقاف خاصية أو خيار** يُرفض عند إسناد قيمة جديدة بـ ERP27 («الخاصية معطّلة...»).
- **قفل بعد الاستخدام (قرار معتمد D-AT-3):** `data_type` و`selection_type` للقراءة فقط بعد أول استخدام، لأن تغييرهما يُبطل قيماً محفوظة؛ القاعدة تتحقق من القيمة عند الكتابة فقط (`product_attribute_value_guard`)، لا من القيم القديمة.

## 9. المكوّنات
| الحاجة | المكوّن |
|---|---|
| قائمتان | `CrudListScreen` + `CrudListConfig` لكل منهما (صُحّح) |
| الخيارات داخل المجموعة | **`EditableGrid` غير موجود**؛ المعتمد صفحة فرعية للمجموعة بقائمة خيارات على المحرك نفسه (انظر §23 A-1) |
| نوع البيانات/نوع الاختيار | `SearchableDropdown` بقيم مترجمة |
| ربط الخاصية بالمجموعة | `SearchableDropdown` يظهر **فقط** عند `data_type=option` ويُمسح عند تغيير النوع |

## 10. البحث والفلاتر والفرز
- **البحث:** `name` و`code` (في المجموعات والخصائص)، وللخيارات داخل المجموعة `name` و`code`.
- **فلاتر الخصائص:** الحالة · **نوع البيانات** · «قابلة للتصفية» (لأنها حقل تشغيلي معنونٌ في S53 ويقابل تصفية المنتجات لاحقاً).
- **الفرز:** المجموعات والخصائص بالاسم؛ الخيارات بـ `sort_order` ثم `name`.

## 11. القوائم
- المجموعات: الاسم + الرمز، نوع الاختيار، عدد الخيارات، الحالة.
- الخصائص: الاسم + الرمز، النوع، المجموعة/الوحدة، الحالة.
- الهاتف: بطاقات.

## 12. النماذج
| الكيان | قواعد |
|---|---|
| مجموعة | الاسم ≤ 100؛ الرمز ≤ 50 فريد؛ نوع الاختيار إلزامي (افتراض واحد) |
| خيار | الاسم ≤ 100؛ الرمز ≤ 50 فريد **داخل المجموعة** |
| خاصية | الاسم ≤ 150؛ الرمز ≤ 80 فريد؛ النوع إلزامي؛ `option` ⇒ المجموعة إلزامية، وغيره ⇒ المجموعة ممنوعة (واجهة وقاعدة)؛ الوحدة اختيارية (مفيدة لنوع `number` — لم يُشترط في المصدر) |
- `is_filterable` مفتاح منطقي.

## 13–18. الحالات وResponsive وRTL وCore
كما في المشتركة.

## 19. API
| العملية | Endpoint |
|---|---|
| GET مجموعات | `/rest/v1/option_sets?select=id,name,code,selection_type,is_active,options(count)&order=name.asc` |
| GET خيارات | `/rest/v1/options?option_set_id=eq.<id>&order=sort_order.asc,name.asc` |
| GET خصائص | `/rest/v1/attributes?select=id,name,code,data_type,is_filterable,is_active,units(id,name),option_sets(id,name)&order=name.asc` |
| CRUD | المشتركة C9 لكل جدول |
- **أخطاء خاصة:** 23514 (قيد `ck_attributes_option_set`) يُمنع بمنطق الواجهة؛ 23503 عند حذف مستخدم؛ 23505 للرمز.
- **يحتاج تحققاً فعلياً:** `options(count)` بالتجميع · حذف خيار مستخدم بمفتاح مركّب (`product_option_values`).

## 20. القرارات
| # | القرار | الخيارات | القرار المعتمد | أثر التأجيل |
|---|---|---|---|---|
| D-AT-1 | معنى `attributes.is_required` (مع `product_type_attributes.is_required`) | (أ) الأخير هو الحَكَم (ب) الأول افتراضي ينسخ للنوع | (أ) — معتمد: S53 يضع الإلزام على مستوى النوع؛ لا يُعرض `attributes.is_required` | تناقض إلزامين |
| D-AT-2 | معنى `is_variant_option` | المعنى غير موثق في المصادر | **يُخفى — معتمد**؛ لا يظهر في أي شاشة حتى يوثَّق معناه في مصدر | حقل غامض |
| D-AT-3 | قفل `data_type` و`selection_type` بعد الاستخدام | (أ) قفل (ب) مسموح مع تحذير | (أ) — معتمد | قيم قديمة غير صالحة النوع |
| D-AT-4 | ترتيب التنفيذ | المجموعات ← الخصائص ← ربط النوع (المرحلة ب) | كما كتب — معتمد | — |

خارج النطاق: نسخ مجموعة خيارات · استيراد الخيارات من ملف.

## 21. التنفيذ والاختبار
- اختبارات خاصة: ظهور/اختفاء حقل المجموعة بحسب `data_type` · مسح المجموعة عند تغيير النوع · فرادة رمز الخيار داخل المجموعة فقط · إخفاء `is_required` و`is_variant_option`.

## 22. معايير القبول
- [ ] CAT07-AT-AC1: مجموعة بخيارات تُحفظ ويظهر عدد خياراتها.
- [ ] CAT07-AT-AC2: خاصية `option` بلا مجموعة لا تُرسل (تحقق واجهة)، وخاصية غير `option` لا ترسل `option_set_id`.
- [ ] CAT07-AT-AC3: رمز خاصية أو مجموعة مكرر يعرض رسالة واحدة؛ رمز خيار مكرر داخل مجموعة يُرفض وفي مجموعة أخرى يُقبل.
- [ ] CAT07-AT-AC4: عنصر مستخدم (مجموعة/خاصية/خيار) لا يعرض «حذف».
- [ ] CAT07-AT-AC5: إيقاف خيار يخرجه من الاختيار الجديد (يُتحقق منه في CAT-02 مع ERP27).
- [ ] CAT07-AT-AC6: لا يظهر `is_required` ولا `is_variant_option` في أي نموذج.
## 23. المراجعة النقدية (2026-11-26)

### 23.1 فجوات وتحسينات
| # | البند | الدليل | القرار المعتمد |
|---|---|---|---|
| A-1 | تحرير خيارات المجموعة | لا `EditableGrid` في Core | مسار `/catalog/option-sets/:setId` بقائمة خيارات (`CrudListScreen` بـ`optionSetId` في الاستعلام)، كالمقاسات داخل المجموعة |
| A-2 | الخصائص تعتمد على الوحدات ومجموعات الخيارات | `attributes.unit_id`, `attributes.option_set_id` | الترتيب: الوحدات ← مجموعات الخيارات ← الخصائص؛ منتقيا الوحدة والمجموعة يحتاجان عقد قراءة مشتركاً (ADR-0004) |
| A-3 | قيد `ck_attributes_option_set` | `(data_type='option') = (option_set_id IS NOT NULL)` | الواجهة تجعل الحقل ظاهراً فقط لـ`option` وتمسحه عند تغيير النوع؛ الخطأ 23514 احتياطي برسالة عامة |
| A-4 | قفل `data_type` | D-AT-3 | يحتاج معرفة الاستخدام الفعلي: `product_attribute_values` يحوي `attribute_id` وبقراءة مفتوحة، لكن `product_type_attributes(count)` وحده **لا يكفي** (لا يغطي القيم المحفوظة). عدّ `product_attribute_values` ثقيل ← **المعتمد:** قفل بمجرد وجود أي ربط بنوع **أو** قيمة، والمجهول يُقفل |
| A-5 | `is_filterable` | حقل تشغيلي | يُعرض كمفتاح وكفلتر؛ لا أثر حتى يُبنى فلتر المنتجات (يُوثَّق لئلا يُنتظر منه سلوك) |
| A-6 | حذف خيار مستخدم | `product_attribute_values.option_id → options`، و`product_option_values` | 23503 → «أوقِف بدلاً من الحذف»؛ إيقاف الخيار لا يؤثر على القيم القديمة (ERP27 يمنع القيمة الجديدة فقط) |
| A-7 | نوع `json` | `data_type` يشمل json | يُعرض كقيمة مقبولة في القائمة؛ تحرير قيمته في CAT-02 لا هنا؛ لا مبرر لاستثنائه (قرار معتمد: يبقى ظاهراً كما هو) |
| A-8 | الجداول فارغة حالياً | §0 | حالة «فارغ» حقيقية ومتوقعة؛ نص يشرح الترتيب (أنشئ مجموعة خيارات ثم خاصية) |

### 23.2 قرار جديد
**D-AT-5 — صفحة الخيارات (معتمد): (أ) مسار فرعي للمجموعة.** البديل المرفوض: (ب) لوحة جانبية بقائمة خيارات وحوار لكل خيار. السبب: أن اللوحة تضيق بإضافة/ترتيب خيارات كثيرة (ألوان/مقاسات نصية).

### 23.3 معايير قبول جديدة
- [ ] CAT07-AT-AC7: خيارات المجموعة تُدار من صفحتها الفرعية دون شبكة قابلة للتحرير.
- [ ] CAT07-AT-AC8: تغيير `data_type` من `option` إلى غيره يمسح المجموعة المختارة قبل الإرسال.
- [ ] CAT07-AT-AC9: `data_type` للقراءة فقط عند أي ربط/قيمة أو عند جهل الاستخدام.

**لا يمكن إثباته من المستودع:** سلوك `product_attribute_value_guard` مع تغيير النوع، وعدد القيم المحفوظة فعلاً.


## 24. تفاصيل التنفيذ الفعلي (CAT-08)

### تفاصيل التنفيذ كما وثّقها فرع CAT-08

### Option Sets
- **Composition:** `CrudListScreen` + `CrudListConfig`; feature-owned filters, stats, editor and `OptionSetDetailsPanel`.
- **Statistics:** all/active/inactive are server-derived; a stats failure does not prevent list loading.
- **Capabilities:** bulk=false and duplicate=false. The list does not embed every option row; it requests `options(count)` and loads ordered option rows only when a group is opened.
- **Details:** desktop `AppDetailsPanel`; narrower layouts use a bottom sheet. Options are ordered by `sort_order`, then `name`, then `id`; add/edit/deactivate use compact dialogs. Individual options are never deleted.
- **Locks/deletion:** `selection_type` is read-only when `attributes(count)` or `product_type_option_sets(count)` is positive or unknown. Group delete is hidden unless option, attribute and product-type-link counts are all known zero. FK 23503 offers deactivate instead.
- **Editor/payload:** name/code are trimmed; create sends `is_active=true`; PATCH sends `is_active` only when changed; dirty compares normalized values. 23505/409 duplicate code and 23514/ERP28 are mapped to translated failure keys.

### Attributes
- **Composition:** `CrudListScreen` + `CrudListConfig`; no details panel; feature-owned list, filters, stats, editor and duplicate seed.
- **Statistics:** all/active/inactive/filterable from server count queries; no page-derived counts.
- **Capabilities:** duplicate=true; bulk=false. Duplicate copies data_type, unit_id, option_set_id and is_filterable, resets active=true, and generates a unique candidate code ending `-copy` within 80 characters.
- **Editor/payload:** `is_required` and `is_variant_option` remain hidden and are never selected or sent. `option_set_id` is present iff data_type is option; changing data type clears incompatible IDs. `unit_id` is only sent for number. Create sends active=true; PATCH includes status only when changed. Dirty compares trimmed values.
- **Lookups:** Attributes owns lightweight reads from units and option_sets (id/name/symbol-or-code/is_active); new assignment shows active records, while edit includes the current inactive value. No imports from sibling CAT-08 features.
- **Locks/deletion:** data_type and option_set_id lock when product_type_attributes or product_attribute_values usage is positive or unknown. Delete is hidden while used/unknown; FK 23503 offers deactivate. Deactivation warns that ERP27 rejects new values.
- **Localization/states:** every UI, validation and failure message is an Arabic/English feature AppKey; 23505/409, 23514, ERP27 and ERP28 are translated without showing raw server text.