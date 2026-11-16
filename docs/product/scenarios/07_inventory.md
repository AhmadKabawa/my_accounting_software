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

