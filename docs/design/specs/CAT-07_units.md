# CAT-07 — وحدات القياس

| البند | القيمة |
|---|---|
| الرمز | CAT-07 / الوحدات |
| الحالة | **منفذة على الفرع `feat/cat08-units-attributes`؛ الاختبارات الآلية موجودة، ولم يُتحقق من Supabase الحي** |
| المسار المعتمد | `/catalog/units` (يُفحص مقابل `route_registry`) |
| المنصة | ويب متجاوب |
| يرث من | `CAT-07_master_data_common.md` (المشتركة) |
| المراجع | S50 · قرار-26 · S08 · S53 · DATA_MODEL §8 (`units`) · وصفة البناء `docs/ui/new_crud_feature_recipe.md` |
| ترتيب التنفيذ | بعد التصنيفات؛ **قبل الخصائص** لأن `attributes.unit_id` يحتاجها (انظر §23) |

## 0. الملخص

وحدات **وصفية فقط** (قطعة، زوج، علبة، طقم) تسمّي طريقة بيع الصنف وشرائه. **قرار-26: لا تحويل بين الوحدات**؛ لذلك تُخفى حقول `base_unit_id` و`conversion_factor` من الواجهة كلياً ولا تُرسل (القيم الافتراضية تحقق قيد القاعدة). أصغر شاشة في CAT-07.

## 1. معلومات الشاشة
- **لماذا وحدة مفهومة؟** كيان مرجعي مستقل بحقول قليلة، يستهلكه `product_variants.unit_id` و`attributes.unit_id`.

## 2. الهدف والنتيجة
- مخوَّل يعرّف وحدة (اسم، رمز، نوع) فتظهر في اختيار وحدة المتغير.
- **اكتمال المهمة:** S50-AC1 (الوحدة تظهر في الفاتورة بلا أي تحويل كمية) — يُتحقق منه في شاشات المتغيرات والفواتير لا هنا.

## 3. المرجع ومصدر الحقيقة
| القرار/المعلومة | المصدر |
|---|---|
| الحقول | S50 §5 + DATA_MODEL: `units` |
| `symbol` فريد، `name` غير فريد | DATA_MODEL: `uq (symbol)` |
| `unit_type` ∈ weight, length, volume, piece | DATA_MODEL §4.3 + S50 §8 |
| بلا تحويل | قرار-26 + S50 §13 («أخفِ حقول التحويل») |
| قيد القاعدة | `ck_units_base: (base_unit_id IS NOT NULL) OR (conversion_factor = 1)` و`conversion_factor > 0` |
| ما لم يرد | الوحدات المبذورة الافتراضية · ترجمة أسماء الوحدات |

## 4. المستخدمون والصلاحيات
كما في المشتركة C2.

## 5. السيناريو (S50 الخطوات 1–2)
يفتح الوحدات ← «وحدة جديدة» ← الاسم، الرمز، النوع ← حفظ. الخطوة 3 (وحدة المتغير) خارج الشاشة.
- **الأخطاء:** رمز مكرر · نوع غير صالح (يُمنع بقائمة اختيار لا إدخال حر).
- **بديل:** إيقاف وحدة بدل حذفها.

## 6. البيانات
| الجدول | الحقول | العلاقة |
|---|---|---|
| `units` | `id`, `name` v(100)!, `symbol` v(20)! فريد, `unit_type` v(30)!, `base_unit_id`, `conversion_factor`=1, `is_active` | `base_unit_id → units` (ذاتي) |
| `product_variants` | `unit_id` | FK → حذف وحدة مستخدمة يفشل |
| `attributes` | `unit_id` | FK → كذلك |
- **قاعدة الإرسال:** لا يُرسل `base_unit_id` ولا `conversion_factor` في `POST` أو `PATCH`؛ تبقى الافتراضات (فارغ و1) وتحقق القيد.
- **سجلات قائمة بقيم تحويل غير افتراضية** (إن وُجدت): لا تُعدَّل ولا تُعرض؛ يُتحقق منها على الخدمة (D-UN-2).
- الاستخدام: `product_variants(count)` و`attributes(count)`.

## 7. المعلومات المعروضة
| العنصر | الأولوية | المصدر |
|---|---|---|
| الاسم + الرمز | أساسي | `name`, `symbol` |
| النوع (مترجم) | أساسي | `unit_type` |
| الحالة | أساسي | `is_active` |
| عدد الاستخدام | ثانوي (D-C3) | `product_variants(count)` |
- **لا تُعرض:** حقول التحويل (قرار-26).

## 8. الإجراءات
كما في المشتركة C5 (بما فيها النسخ والإجراءات الجماعية). **قرار D-UN-4:** تُعطَّل الإجراءات الجماعية (`capabilities.bulkSelection: false`) لأن الوحدات عشرات الصفوف على الأكثر.

## 9. المكوّنات
كما في المشتركة C8؛ النوع بـ `SearchableDropdown` بأربع قيم مترجمة (مفاتيح ar/en لكل قيمة، لا نص القاعدة الخام).

## 10. البحث والفلاتر والفرز
- **البحث:** `name` و`symbol`.
- **الفلاتر:** الحالة، **والنوع** (4 قيم؛ له معنى تشغيلي لفصل وحدات الوزن عن القطعة).
- **الفرز:** الاسم.

## 11. القائمة
1. الاسم + الرمز. 2. النوع. 3. الحالة. 4. الإجراءات.
- الهاتف: بطاقة بالاسم والرمز والنوع.

## 12. النموذج
| الحقل | التحقق |
|---|---|
| الاسم | إلزامي، ≤ 100 |
| الرمز | إلزامي، ≤ 20، فريد |
| النوع | إلزامي، قائمة من 4 قيم |
- **صُحّح:** مفتاح «نشط» في المحرر (قرار المالك D2: الإنشاء يرسل الحالة، وPATCH يرسلها فقط عند التغيّر)، بدل «لا حقل حالة». لا حقول تحويل.

## 13–18. الحالات وResponsive وRTL وCore
كما في المشتركة. الرمز (قد يكون لاتينياً أو عربياً، مثل «kg» أو «قطعة») يُعرض باتجاه نصه.

## 19. API
| العملية | Endpoint |
|---|---|
| GET | `/rest/v1/units?select=id,name,symbol,unit_type,is_active&order=name.asc` |
| POST | `/rest/v1/units` (`name,symbol,unit_type`) |
| PATCH/DELETE | المشتركة C9 |
- **صُحّح:** DATA_MODEL لا يعرّف CHECK على `unit_type` (القيم الأربع موثقة في §4.3 كقائمة فقط)، وبالتالي لا رفض 23514 من القاعدة؛ القائمة المغلقة في الواجهة هي الضمان الوحيد → طلب باك إند B-30 (انظر §23). كان النص السابق: رفض `unit_type` من CHECK = 23514 (غير مذكور في خريطة Core؛ يُمنع أصلاً بقائمة الاختيار).

## 20. القرارات
| # | القرار | الخيارات | القرار المعتمد | أثر التأجيل |
|---|---|---|---|---|
| D-UN-1 | الوحدات الافتراضية المبذورة | (أ) تُدخل يدوياً (ب) تُبذر بقرار | (أ) — معتمد؛ لم يرد في المصادر قائمة مبذورة | قوائم فارغة عند أول استخدام |
| D-UN-2 | سجلات وحدات فيها تحويل غير افتراضي | (أ) تجاهل (ب) فحص وتصفير | (أ) — معتمد، بعد التحقق من الخدمة | تناقض مع قرار-26 |
| D-UN-3 | تعديل `symbol` لوحدة مستخدمة | مسموح / للقراءة فقط | مسموح — معتمد (الرمز عرض فقط؛ المرجع `id`) | — |

خارج النطاق: ترجمة أسماء الوحدات المبذورة.

## 21. التنفيذ والاختبار
- اختبارات خاصة: عدم إرسال حقول التحويل في الجسم · ترجمة قيم `unit_type` · الرمز المكرر.

## 22. معايير القبول
- [ ] CAT07-UN-AC1: وحدة بالاسم والرمز والنوع تُحفظ وتظهر في القائمة.
- [ ] CAT07-UN-AC2: رمز مكرر يعرض رسالة واحدة.
- [ ] CAT07-UN-AC3: جسم الطلب لا يحوي `base_unit_id` ولا `conversion_factor` (اختبار Repository).
- [ ] CAT07-UN-AC4: لا حقل تحويل في أي نموذج أو عمود.
- [ ] CAT07-UN-AC5: وحدة مستخدمة لا تعرض «حذف».
## 23. المراجعة النقدية (2026-11-26)

| # | الملاحظة | الدليل | القرار/المطلوب |
|---|---|---|---|
| U-1 | لا CHECK على `unit_type` في القاعدة | `DATA_MODEL.md` سطر `units` يحوي `ck_units_base` و`units_conversion_factor_check` فقط؛ القيم الأربع في §4.3 | تحقق الواجهة وحده يحمي؛ طلب CHECK مسجَّل في `BACKEND_REQUESTS` (B-30؛ لا يُنفَّذ من هنا) |
| U-2 | إدراج «الوحدات» قبل «الخصائص» ضروري | `attributes.unit_id → units` (FK اختياري) و`product_variants.unit_id` | ترتيب التنفيذ: الوحدات ثم الخصائص؛ منتقي الوحدة في الخصائص يحتاج عقد قراءة مشتركاً (ADR-0004) |
| U-3 | عدد الاستخدام يُجمع من جدولين | `product_variants(count)` و`attributes(count)` | تضمينان في الطلب نفسه؛ مجموعهما = الاستخدام؛ المجهول يمنع الحذف كما في الماركات |
| U-4 | لا بذر وحدات افتراضية | D-UN-1 | حالة «فارغ» ترشد المخوَّل لإضافة «قطعة» و«زوج» (نص الحالة الفارغة يذكر المثالين) — **معتمد** |
| U-5 | الرمز يُعرض بحسب اتجاه نصه | §13–18 | `AppText` بـ`textDirection` تلقائي؛ يُختبر برمز عربي ولاتيني |
| U-6 | المسار والمركز | لا مسار حالي | `UnitsRoutes` ← `route_registry` ← `protectedRoutes` ← بطاقة في `CatalogHubScreen` ← عنصر فرعي في `appDestinations` (مثل الماركات) |
| U-7 | الإحصاءات | غير محددة | بطاقات: الكل/نشطة/موقوفة (مثل الماركات)، لا عدّ حسب النوع (مبالغة لجدول صغير) |

**قرارات جديدة:** D-UN-4 (تعطيل التحديد الجماعي) — **معتمد: تعطيل**. D-UN-5 (فلتر النوع): **معتمد** كما في §10، ويُعدّ المرجع.
**لا يمكن إثباته من المستودع:** القيم الفعلية الموجودة في `units` على Supabase الحي، ووجود سجلات بتحويل غير افتراضي (D-UN-2).
**معيار قبول جديد:** CAT07-UN-AC6 — جسم `POST` عند إنشاء وحدة يحمل `is_active` المختار، و`PATCH` لا يحمله إلا إذا تغيّر.


## 24. تفاصيل التنفيذ الفعلي (CAT-08)

### تفاصيل التنفيذ كما وثّقها فرع CAT-08

- **Composition:** `CrudListScreen` + feature-owned `units_list_config.dart`; the config is capped at 250 lines and delegates filters, statistics, identity and card layout to feature widgets.
- **Columns:** name + symbol, translated type, usage count, status, `updated_at`, actions. `updated_at` is selected and rendered using the shared date/time presentation component.
- **Filters/sort:** status and four-value unit type are server filters; search uses name/symbol with escaped PostgREST values and 300 ms debounce; server order is name then id.
- **Statistics:** all/active/inactive from lightweight server count queries; tapping a card applies the matching status filter; stats failure does not block the list.
- **Capabilities:** no details panel, no bulk selection, no duplicate, no seed data.
- **Editor/payload:** `CrudEditorDialog` in `showAppFormDialog`; name/symbol are trimmed; `is_active=true` is sent on create; PATCH includes `is_active` only if the value changed. Dirty comparison uses the same trimmed values as serialization.
- **Deletion:** delete is offered only when both usage counts are known and sum to zero. Unknown usage blocks delete. A database 23503 response offers deactivation instead; 23505 maps to a translated duplicate-symbol failure.
- **Localization/states:** all labels, four type values, validation and failure messages have Arabic/English `AppKey`s. Loading, empty, no-results, failed and read-only states are explicit.
- **Decision-26 remains binding:** `base_unit_id` and `conversion_factor` are not selected for UI, displayed, or sent in POST/PATCH; existing non-default conversion rows are not edited or exposed.