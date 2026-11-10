لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

# **وثيقة سيناريوهات الستخدام** 

نظام محاسبة وإدارة مخزون وحسابات مالية لمتجر 

،: ويب، موبايلWindows ) علىFlutter( مرجع لتصميم الواجهاتWireframes / UI 

|**التفصيل**|**البند**|
|---|---|
|مخطط قاعدة بياناتSupabase<br>: المشروعtest vaude store with claude(schemapublic)|المصدر|
|119<br>،<sup>,</sup>جدوًال452<br>سياسةRLS، 275 Trigger، 16<br>، دالة عامة87<br>دالة داخلية فيerp، 16 View|حجم القاعدة|
|Flutter: ويب وتطبيق موبايل وWindows<br>(. متصل باإلنترنت حاليا<sup>,</sup>)قرارك|المنصة|
|SUPER_ADMIN MANAGER CASHIER WAREHOUSE ACCOUNTANT PURCHASER<br>AUDITOR|األدوار|
|45<br>سيناريو، كل<sup>^</sup>بهدف واحد وحتى4 جداول رئيسية|عدد السيناريوهات|
|إ8<br>نوفمبر2026|تاريخ اإلعداد|
|ا.»أسماء الجداول واألعمدة باإلنجليزية داخل خط أحادي. كل ما لم تؤكده القاعدة موسوم بكلمة «افتراض|اصطالحات  أ إ|



صفحة1 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**<u>م1. الفه</u>** 

- **1.1 ملخص النظام** 

- ، لمتجر مالبس ومستلزمات رياضية متعدد الفروع والمستودعات: كتالوج بموديالت وألوان ومقاسات، نقطة بيع بجلسات صندوق  نظامERP .مشتريات، مخزون وتحويالت وجرد، سندات مالية متعددة العمالت، ومحاسبة بقيود يومية وفترات مالية، وسجل تدقيق • 

- .) doc_status : DRAFT / POSTED / CANCELLED (مثل CHECK : الح لت قيود **ا** ال توجدEnums • 

- post_payment و post_purchase_invoice و اإلجراءات الحرجة دوالRPC: post_sale 

- ship_transfer و approve_transfer و post_purchase_return و post_sales_return و . cancel_transfer و receive_transfer و 

• أرصدة المخزون وسجل األطراف والقيود المحاسبية والحركات المالية ت .ل من الواجهةMعد<sup>N</sup> عند الترحيل، وال ت<sup>P</sup> د تلقائيا<sup>M</sup> ول<sup>N</sup> 

.) ERP05 (  لإلضافة فقط stock_movements 

.) protect_posted_doc ، ERP03 ( ل محمي من التعديلXالمستند المرح • 

• ، فالربط بين األدوار والصالحيات يحتاج role_permissions و permissions و roles ، بما فيها<sup>P</sup> كل الجداول فارغة حاليا .)( بيانات أوليةseed 

**1.2 القرارات المعتمدة من إجاباتك** 

|**أثره على التصميم**|**القرار**|
|---|---|
|عتمد الجدول فيsي1.3<br>كتب فيs ويrole_permissions<br>.|ربط األدوار بالصالحيات كما اقترحته )ع1<br>(|
|.ًال حالة «مزامنة» في الواجهات. ًالحقا<sup>,</sup>: قاعدة محلية لكل فرع وقاعدة مركزية|العمل متصل باإلنترنت حاليا<sup>,</sup>)ع2<br>(|
|السيناريوS43<br>.<sup>,</sup>؛ مبالغ المستند تظهر بعملته أوًال|العرض حسبdisplay_preferencesمع<br>أفضلية عملة الفاتورة )ع3<br>(|
|شاشة اختيار الفرع فيS01<br>.|اختيار الفرع في كل دخول )س1<br>(|
|.»ًال رابط «نسيت كلمة المرور|المدير يعيد تعيين كلمة المرور )س2<br>(|
|S07 وS08<br>.|:إدارة الكتالوجMANAGERوPURCHASER<br>وWAREHOUSE)س3<br>(|
|.أعمدة التكلفة مخفية عن بقية األدوار|التكلفة يراها حتىAUDITOR)س4<br>(|
|فواتيرDRAFT<br>)  معل<sup>•</sup>قةS15، S20<br>.(|تعليق الفاتورة في نقطة البيع )س5<br>(|
|.ًال موافقة على البيع|الكاشير ينشئ ويرح•ل بنفسه )س6<br>(|
|payment_lines<br>بنوعCHANGE_GIVEN(S16)<br>.|دفع بوسائل وعمالت متعددة مع باٍق„ بعملة أخرى<br>)س7<br>(|
|) ًال منعS17<br>.(|تجاوز حد ً**ا**لئتمان تحذير فقط )س8<br>(|
|) يلزم إعداد للسقفS11<br>.(، نقطة مفتوحة|خصم الكاشير حتى سقف يحدده المدير )س9<br>(|
|S18<br>.|إغالٍق الجلسة بيد الكاشير أو المدير )س10( والفرٍق<br>رح‹ل تلقائيا<sup>,</sup>)سsي11<br>(|
|S19<br>.|الكاشير يختار طريقة ً**ا**لسترداد )س12<br>(|
|S19 وS20<br>.|ًال إلغاء لفاتورة مرح•لة، المرتجع فقط )س13<br>(|
|S22<br>.|شراء: الدفع عند الترحيل أو ًالحقا<sup>,</sup>بحسب الفاتورة<br>)س14(، وPURCHASERيرح•ل بنفسه )س15<br>(|
|S26 وS27<br>.|أمين المستودع المرسل يوافق على التحويل )س16<br>،(<br>والتالف/الناقص لمستودع تالف/مرتجعات )س17<br>(|
|S28<br>.|تسوية الجرد بال موافقة )س18<br>(|
|S32<br>.|المصروف ينشئه ويرح•له المحاسب )س19(، ويستطيع<br>الكاشير تسجيل مصروف صغير )س20<br>(|
|S39 وS40<br>.|القيود عرض وعكس فقط )س21(، والمحاسب يغلق<br>الفترة ويقفلها )س22<br>(|



صفحة2 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**أثره على التصميم القرار** .S44 (إشعارات داخل التطبيق )س23 

**) األدوار والصالحيات (مقترح معتمد، كله افتراض ما لم ُي"ذكر1.3** 

) وليست أسماء أدوار. الجدول يربط كل دور باألكواد المنطقية له. عند غياب الصالحية has_permission ( الصالحيات في القاعدة أكواد يتجاوز فحوص الفروع، وغيره SUPER_ADMIN :. قاعدتان تنطبقان على الجميع ERP16 PERMISSION_DENIED ترمي الدوال .) للتنفيذ can_operate للقراءة و can_view ( user_branch_access في<sup>P</sup> يحتاج صفا 

|**ال يستطيع**|**)يستطيع (األكواد**|**الدور أ**|
|---|---|---|
|.(ًال شيء )لكن يلزم سبب عند اإللغاء|كل شيء عبرis_super_admin<br>`)(`<br>، ويشملusers.manage<br>وorg.manageوsettings.manage<br>.|SUPER_ADMIN|
|users.manage org.manage<br>settings.manage)افتراض: سقف الخصم يحتاج<br>(,استثناء|sales.* sales.return pos.manage pos.session<br>reconcile.cash inventory.view inventory.transfer<br>purchasing.view finance.view reports.view<br>costs.view catalog.manage pricing.manage<br>parties.manage|MANAGER|
|costs.view inventory.adjust purchasing.*<br>accounting<br>`*.`|sales.view sales.create sales.post sales.return<br>pos.session reconcile.cash finance.payments<br>finance.expenses parties.view|CASHIER|
|المبيعات والمالية والمحاسبة|inventory.view inventory.transfer<br>inventory.transfer.approve inventory.adjust<br>warehouse.central.access catalog.manage|WAREHOUSE|
|إنشاء مبيعات أو تحويالت مخزون|accounting.view accounting.manage<br>accounting.post finance.* finance.payments<br>finance.expenses payment.cancel reconcile.cash<br>balance.adjust fx.rate.manage owner.transactions<br>costs.view costs.manage reports.view|ACCOUNTANT|
|المبيعات والمحاسبة وسندات الدفع|purchasing.view purchasing.create purchasing.post<br>purchasing.return parties.manage catalog.manage<br>costs.view)وfinance.payments<br>( للدفع عند ً**ا**لستالم، افتراض|PURCHASER|
|<sup>أي إنشاء أو ترحيل أو إلغاء أو تعديل</sup>|كل`.*`<br>viewوaudit.viewوcosts.viewوreports.view|AUDITOR|



### **1.4 الكيانات الرئيسية والعالقات** 

|**الجداول والعالقات**|**المجال**|
|---|---|
|branches←warehouses<br>: )أنواعGENERAL SHOP_FLOOR CENTRAL RETURNS DAMAGED<br>،(<br>employees←parties<br>.|التنظيم|
|users←user_roles←roles←role_permissions←permissions، وuser_branch_access<br>.|األمان|
|parties(PERSON/COMPANY)<br>والطرف نفسه قد يكون فيcustomersوsuppliersوemployees<br>وowners<br>.|األطراف|
|products←product_variants<br>← ( )لون × مقاسbarcodes<br>.، وجداول مرجعية كثيرة|الكتالوج|
|price_lists←variant_prices،discounts←discount_targets،variant_costs<br>.( )متوسط مرج•ح|التسعير والتكلفة|
|sales←sale_items،sales_returns←sales_return_items<br>، مرتبطة بـpos_sessions←<br>pos_terminals<br>.|المبيعات|
|purchase_invoices←purchase_invoice_items،purchase_returns←<br>purchase_return_items،supplier_notes<br>.|المشتريات|



صفحة3 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

|**الجداول والعالقات**|**المجال**|
|---|---|
|inventory_balances،stock_movements<br>،( )لإلضافة فقطstock_transfers←<br>stock_transfer_items،stock_adjustments←stock_adjustment_items<br>.|المخزون|
|payments←payment_lines←payment_allocations،expenses،money_transfers،<br>financial_accounts<br>،( )صندوٍق/بنكfinancial_transactions،party_ledger_entries،<br>balance_adjustments<br>.|المالية|
|gl_accountsوgl_account_mappingsوfiscal_periodsوjournal_entries←<br>journal_entry_lines<br>.|المحاسبة|
|audit_logs<br>.|الرقابة|



### **1.5 نقاط مفتوحة وفجوات في القاعدة** 

. منك قبل التصميم النهائي<sup>P</sup> على القاعدة أو قراراهذه أمور اكتشفتها أثناء الربط بين قراراتك والقاعدة. بعضها يحتاج تعديال<sup>P</sup> 

|**المقترح**|**المالحظة**|**#ا**|
|---|---|---|
|مفتاح فيsettings<br>لكل فرع، مع منحMANAGER<br>. تعديله|ًال عمود أو إعداد لسقف خصم الكاشير )س9<br>.(|1ًا|
|.تحديد السقف في إعداد أو قاعدة واجهة|ًال سقف لمبلغ مصروف الكاشير الصغير )س20<br>.(|2ًا|
|.إخفاء الزر في الواجهة وحجب الصالحية عن األدوار|القاعدة تسمح ب ً**ا**لنتقال إلىCANCELLEDلمن يملك الصالحية، بينما قرارك منع<br>إلغاء المرح•ل )س13<br>.(|3|
|تضمينها في الـseed<br>. للدور|الكاشير يحتاجreconcile.cash<br>، )إغالٍق الجلسةERP12<br>(<br>وfinance.paymentsوfinance.expenses، وعرض رصيد المخزون<br>عبرinventory.view<br>أوv_stock_available<br>.|4|
|.قصر الدفع على المحاسبsمنح، أو يsقرار: ي|PURCHASER<br>يحتاجfinance.paymentsليدفع عند الترحيل )س14<br>،(<br>.وهذه تمنحه أيضا<sup>,</sup>كتابة سندات الدفع|5|
|<sup>) إضافة دالة عامة تلف•هاS39</sup><br>.(|) ًال دالة عامة لعكس القيدerp.reverse_journal<br>.( داخلية|6|
|ًا  ) حسب حيا<sup>,</sup>من الجداول<sup>s</sup>اإلشعارات تS44<br>.<sup>,</sup>(، ويمكن إضافة جدول ًالحقا|.ًال جدول إشعارات|7|
|مراجعة الدالة قبل تصميمS27<br>.|آلية نقل التالف/الناقص إلى مستودع تالف/مرتجعات )س17( غير مؤكدة في<br>receive_transfer<br>.|8|
|<sup>.ستخدم كما هي، والملحق هـ يلخ•ص األكوادsت</sup>|error_codes<br>. فارغ؛ رسائل األخطاء الحالية عربية داخل الدوال|9|
|.ًالحقا<sup>,</sup>عند الحاجة|ًال حقل إلرفاٍق صورة اإليصال فيexpenses<br>.|10|
|.ستكمل عند تصميم شاشات التقارير<sup>s</sup>ت|أعمدة الـViews<br>. ظاهرة جزئيا<sup>,</sup>في وثيقتي|11|



صفحة4 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

## **2. فهرس السيناريوهات** 

||||أ1<br>، أساسي2<br>، مهم3<br>. الحق|:األولوية|
|---|---|---|---|---|
|**أولوية**|**الوحدة**|**الدور**|**السيناريو**|**الرقم**|
|1|الدخول والمستخدمون<br>والصالحيات|ا( جميع المستخدمينSUPER_ADMIN MANAGER<br>CASHIER WAREHOUSE ACCOUNTANT<br>PURCHASER AUDITOR<br>)|تسجيل الدخول وتحميل الصالحيات|S01   ا|
|1|الدخول والمستخدمون<br>والصالحيات|SUPER_ADMIN|إنشاء مستخدم وتعيين دوره وفروعه|S02|
|1|الدخول والمستخدمون<br>والصالحيات|SUPER_ADMIN|إدارة األدوار وصالحياتها|S03 أ ا|
|<sup>إ2</sup>|<sup>الهيكل واإلعدادات</sup>|SUPER_ADMIN<br>(ألنorg.manage<br>)|إدارة الفروع والمستودعات|S04|
|إ2|الهيكل واإلعدادات|MANAGER)pos.manage(<br>وSUPER_ADMIN|إعداد نقاط البيع والصناديق|S05|
|إ2|الهيكل واإلعدادات|ACCOUNTANTوSUPER_ADMIN|العمالت وأسعار الصرف واإلعدادات|S06ا   إ|
|إ2|الهيكل واإلعدادات|ا  )جميع المستخدمين (لتفضيلهم الشخصي|تفضيالت عرض العملة|S43ا|
|1|الكتالوج والتسعير|MANAGERوPURCHASERوWAREHOUSE<br>(حسب قرارك؛catalog.manage<br>)|)إنشاء منتج (موديل|S07|
|1|الكتالوج والتسعير|MANAGERوPURCHASERوWAREHOUSE|)إضافة األلوان والمقاسات والباركود (المتغيرات|S08|
|2|الكتالوج والتسعير|MANAGER)pricing.manage(|تسعير المنتجات|S09|
|2|الكتالوج والتسعير|ACCOUNTANTوMANAGER<br>)costs.manage(|تحديد تكلفة المنتج وتعديلها|S10|
|3|الكتالوج والتسعير|MANAGER)pricing.manage(|إدارة الخصومات|S11|
|أ  2|)األطراف (زبائن وموردون|MANAGERوCASHIER<br>: (إضافة سريعة، افتراض<br>يحتاجparties.manage<br>)|إدارة الزبائن|S12|
|أ  2|)األطراف (زبائن وموردون|PURCHASER|إدارة الموردين|S13|
|1|المبيعات ونقطة البيع|CASHIER|فتح جلسة صندوق|S14|
|1|المبيعات ونقطة البيع|CASHIER|البحث عن صنف وإضافته للسلة|S15|
|1|المبيعات ونقطة البيع|CASHIER|)إتمام البيع (دفع نقدي/متعدد|S16|
|2|المبيعات ونقطة البيع|CASHIERوMANAGER|بيع آجل أو بدفعة جزئية|S17|
|1|المبيعات ونقطة البيع|CASHIER<br>أوMANAGER<br>) (أيهما|إغالق جلسة الصندوق والجرد النقدي|S18ا|
|1|المبيعات ونقطة البيع|CASHIERوMANAGER|مرتجع مبيعات|S19|
|2|المبيعات ونقطة البيع|CASHIERوMANAGER|قة والمسودات<sup>f</sup>إدارة الفواتير المعل|S20|
|1|المشتريات|PURCHASER|)إنشاء فاتورة شراء (مسودة|S21|
|1|المشتريات|PURCHASER<br>)ل بنفسه، قراركf (يرح|ترحيل فاتورة شراء واستالم البضاعة|S22   ا|
|2|المشتريات|PURCHASER)purchasing.return(|مرتجع مشتريات|S23|
|3|المشتريات|PURCHASERوWAREHOUSE|مالحظات المورد|S24ا|
|1|المخزون|WAREHOUSEوMANAGERوAUDITOR|عرض أرصدة المخزون وحركته|S25|
|1|المخزون|WAREHOUSE<br>) (المرسل يوافق، قرارك<br>وMANAGER|إنشاء تحويل مخزون والموافقة عليه|S26|
|2|المخزون|WAREHOUSE<br>) (المرسل يشحن والمستلم يستلم|شحن التحويل واستالمه|S27  ا|
|1|المخزون|WAREHOUSEوMANAGER|تسوية الجرد|S28|
|3|المخزون|MANAGERوPURCHASER|مستويات إعادة الطلب|S29|
|1|المالية|ACCOUNTANTوCASHIER<br>) (افتراض|سند قبض من زبون وتخصيصه|S30|



صفحة5 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

|**أولوية**|**الوحدة**|**الدور**|**السيناريو**|**الرقم**|
|---|---|---|---|---|
|1|المالية|ACCOUNTANT|سند دفع لمورد|S31|
|1|المالية|ACCOUNTANTل) وf (ينشئ ويرحCASHIER<br>)(مصروف صغير من الصندوق|تسجيل مصروف|S32|
|2|المالية|ACCOUNTANT)finance.manage(|تحويل أموال بين الحسابات|S33|
|1|المالية|ACCOUNTANTوAUDITOR|كشف حساب طرف وأرصدته|S34|
|3|المالية|ACCOUNTANT)balance.adjust(|تسوية رصيد طرف|S35|
|3|المالية|ACCOUNTANT<br>(<br>owner.transactions<br>وfinance.payments<br>)|سحوبات ومساهمات المالك|S36  ا|
|2|المالية|ACCOUNTANT)finance.manage(|إدارة البنوك والحسابات المالية|S37|
|2|المحاسبة والتقارير والرقابة|ACCOUNTANT)accounting.manage(|دليل الحسابات المحاسبي|S38|
|2|المحاسبة والتقارير والرقابة|ACCOUNTANTوAUDITOR|عرض قيود اليومية وعكسها|S39|
|2|المحاسبة والتقارير والرقابة|ACCOUNTANT<br>) (يغلق ويقفل، قرارك|إدارة الفترات المحاسبية|S40|
|2|المحاسبة والتقارير والرقابة|MANAGERوACCOUNTANTوAUDITOR|تقارير المبيعات والمخزون|S41|
|2|المحاسبة والتقارير والرقابة|ACCOUNTANTوAUDITOR|تقارير الحسابات واألرصدة|S45  أ|
|1|المحاسبة والتقارير والرقابة|AUDITORوSUPER_ADMIN|سجل التدقيق|S42|
|إ2|اإلشعارات|إ  )جميع األدوار (كل دور يرى ما يعنيه|مركز اإلشعارات داخل التطبيق أ|S44 إ   أ|



صفحة6 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**3. السيناريوهات** 

.كل سيناريو يتبع القالب ذي األقسام الثالثة عشر. عبارة «افتراض» تعني أن القاعدة ال تؤكد المعلومة 

**وحدة1: الدخول والمستخدمون والصالحيات** 

**<mark>لحياتS01 — تسجيل الدخول وتحميل الص</mark> ا** 

**1. رقم واسم السيناريو** S01 — تسجيل الدخول وتحميل الصالحيات 

**)( . الدورActor2** 

SUPER_ADMIN MANAGER CASHIER WAREHOUSE ACCOUNTANT PURCHASER ( جميع المستخدمين ) AUDITOR 

**3. الهدف** 

.الدخول إلى النظام، وتحميل األدوار والفروع المسموحة، واختيار الفرع الذي سيعمل عليه المستخدم في هذه الجلسة 

**)( . الشروط المسبقةPreconditions4** 

• .)؛ ال تسجيل ذاتي admin_provision_user (أنشأه المدير عبر is_active = true و users الحساب موجود في .) (افتراض user_branch_access صف واحد على األقل في SUPER_ADMIN للمستخدم غير • 

##### **5. الجداول المستخدمة** 

|**األعمدة المهمة**|**الجدول**|
|---|---|
|id, username, email, is_active, must_change_password, failed_login_attempts,|users|
|locked_until, last_login_at||
|user_id, role_id|user_roles|
|user_id, branch_id, can_view, can_operate|user_branch_access|



**)( . المسار األساسيMain Flow** 

**6** 

|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**الشاشة / الواجهة**|**ما يفعله المستخدم**|**الخطو**<br>**ة**|
|---|---|---|---|---|---|
|users.username,users.email<br>(افتراض: الدخول عبر البريد المرتبط بـ<br>auth.users<br>)|Supabase Auth ثم<br>SELECT|،حقل المستخدم، حقل كلمة المرور<br>»زر «دخول|شاشة تسجيل الدخول|يدخل اسم المستخدم وكلمة المرور|1|
|users.is_active,<br>users.locked_until,<br>users.failed_login_attempts|SELECT|مؤشر تحميل على الزر|شاشة تسجيل الدخول<br>)(حالة انتظار|النظام يفحص حالة الحساب|2|
|user_roles.role_id,<br>user_branch_access.branch_id,<br>can_view,can_operate|RPC<br>get_my_access<br>`)(`|مؤشر تقدم|شاشة التحميل|ل األدوار والفروعYحمZي|3 أ|
|user_branch_access.branch_id|SELECT (ضمن نتيجة<br>)الدالة|شارة+ قائمة بطاقات الفروع (**ا**لسم<br>«عرض فقط» إن<br>can_operate = false)، زر<br>»«متابعة|شاشة اختيار الفرع|)يختار الفرع (في كل مرة دخول|4|
|users.must_change_password|UPDATE|حقل كلمة جديدة، تأكيدها، زر حفظ|شاشة تغيير كلمة<br>المرور|إن كانت<br>must_change_passwor<br>d = trueر كلمة المرورf يغي|5|
|users.last_login_at|اUPDATE|قائمة جانبية مبنية على الصالحيات|لوحة التحكم|يدخل إلى لوحة التحكم|6|



**)( . المسارات البديلةAlternative Flows7** • . وتظهر رسالة عامة دون كشف سبب الفشل failed_login_attempts كلمة مرور خاطئة: تزداد 

صفحة7 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

• .عرض زمن لنتظارN وي **ا** locked_until ضبطNف في القيد: يXوصول عدد المحاوالت للحد المعر • :مستخدم له فرع واحد. يسجل على الفرع مباشر • .)عرض رسالة «تواصل مع مدير النظام» (قرارك: المدير يعيد التعيين<sup>N</sup> نسيان كلمة المرور: ال يوجد رابط استرجاع؛ ت 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|حسابك معط<sup>•</sup>ل، تواصل مع المدير|users.is_active = false|حساب غير نشط|
|]الحساب مقفل مؤقتا<sup>,</sup>حتى [الوقت|users.locked_untilفي المستقبل|حساب مقفل|
|منح أي فرع، تواصل مع المدير<sup>s</sup>لم ت|ًا   ًال صفوف فيuser_branch_access)غير<br>SUPER_ADMIN<br>(|ًال فروع مسموحة ًا|
|<sup>اسم المستخدم أو كلمة المرور غير صحيحة</sup>|قيدCHECK<br>علىfailed_login_attempts|كلمة مرور خاطئة|



**)( . الصالحياتRLS9** 

• ل كل شيء عبرMحمN فال يقرؤهما المستخدم العادي مباشرة؛ لذلك ي users.manage : القراءة تتطلب user_roles و users . get_my_access() ) SECURITY DEFINER ( 

• . فيرى المستخدم صفوفه فقط `)(` auth.uid : سياسة القراءة مبنية على user_branch_access 

**)( . ح الت الواجهةUI States10** 

|**السلوك**||**الحالة**|
|---|---|---|
||.مؤشر على زر الدخول ثم شاشة تحميل الصالحيات|تحميل       ا|
||.(ًال فروع مسموحة )رسالة وزر خروج|فارغًا|
||.رسالة تحت الحقول دون كشف أي الحقلين خاطئ|خطأ|
||.ً**ا**لنتقال للوحة التحكم مع اسم الفرع في الشريط العلوي|نجاحً|



**)( . النتيجة بعد التنفيذPostconditions11** • .جلسة صالحة وفرع نشط محدد .ثX محد last_login_at • 

**)( . معايير القبولAcceptance Criteria12** .: عندما يدخل مستخدم بيانات صحيحة وحسابه نشط فإن تظهر له شاشة اختيار الفرع بفروعه المسموحة فقطS01-AC1 • . فإن ال يصل للوحة التحكم قبل تغيير كلمة المرور must_change_password = true : عندما يكونS01-AC2 • .منع الدخول ويظهر زمن انتهاء القفلN فإن ي: عندما يكون الحساب مقفال<sup>P</sup> S01-AC3 • 

**13. مالحظات للمصمم** 

• .» في الشريط العلوي مع زر «تبديل الفرع<sup>P</sup> أبرز اسم الفرع دائما • . يمنع الكتابة can_operate = false شارة «عرض فقط» ضرورية ألن • .»ال تضع رابط «نسيت كلمة المرور 

**<mark>S02 — إنشاء مستخدم وتعيين دوره وفروعه</mark>** 

**1. رقم واسم السيناريو** S02 — إنشاء مستخدم وتعيين دوره وفروعه 

**)( . الدورActor2** SUPER_ADMIN 

**3. الهدف** 

.تجهيز موظف جديد بحساب دخول ودور وفروع 

صفحة8 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**)( . الشروط المسبقةPreconditions4** 

• users.manage ذ يملكالمنف<sup>X</sup> 

• .)نشأ ضمن العملية، افتراضN (أو ي employees ثم parties ل كطرفXالموظف مسج 

**5. الجداول المستخدمة** 

|**األعمدة المهمة**|**الجدول**|
|---|---|
|id, employee_id, username, email, is_active, must_change_password|users|
|party_id, employee_code, job_title, branch_id, hire_date, is_active|employees|
|user_id, role_id, assigned_by, assigned_at|user_roles|
|user_id, branch_id, can_view, can_operate|user_branch_access|



**)( . المسار األساسيMain Flow6** 

|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**الشاشة / الواجهة**|**ما يفعله المستخدم**|**الخطو**<br>**ة**|
|---|---|---|---|---|---|
|users.username,users.is_active,<br>employees.job_title|SELECT|،جدول (**ا**لسم، الدور، الفروع<br>الحالة)، بحث، زر «مستخدم<br>»جديد|قائمة المستخدمين|يفتح قائمة المستخدمين<br>ويضغط «مستخدم<br>»جديد|1|
|users.username,users.email,<br>employees.job_title,<br>employees.branch_id|—|اسم المستخدم، البريد،**ا**لسم<br>الكامل، المسمى الوظيفي، الفرع<br>ر كلمةfالرئيسي، مفتاح «يغي<br>»المرور عند الدخول|نموذج مستخدم جديد|ئ بيانات الحسابfيعب|2|
|roles.code,roles.name|SELECT|مربعات اختيار متعددة لألدوار<br>(منroles<br>)الةf الفع|نموذج مستخدم جديد<br>)(قسم األدوار|يختار األدوار|3 أ|
|user_branch_access.can_view,<br>can_operate|SELECT|قائمة فروع مع مفتاحي<br>»ذ<sup>f</sup>«يعرض» و«ينف|نموذج مستخدم جديد<br>)(قسم الفروع|يحدد الفروع وصالحية<br>كل فرع|4  ا|
|users,employees,user_roles,<br>user_branch_access|RPC<br>admin_provision_user<br>`)...(`|»زر «حفظ وإنشاء|نموذج مستخدم جديد|يحفظ|5|
|—|—|كلمة مؤقتة قابلة للنسخ|شاشة تأكيد اإلنشاء|يعطي كلمة المرور<br>المؤقتة للموظف|6|



**)( . المسارات البديلةAlternative Flows7** 

. is_active تعديل مستخدم قائم: تغيير األدوار أو الفروع أو • • .): زر داخل شاشة المستخدم<sup>P</sup> لسترجاع الوحيد المتاح حالياإعادة تعيين كلمة المرور ( **ا** 

.) is_active = false ( تعطيل مستخدم بدل حذفه • 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|,اسم المستخدم مستخدم مسبقا|UNIQUE<br>علىusers.username|اسم مستخدم مكرر|
|إنشاء أدوار النظام لمدير النظام فقط|ERP16 PERMISSION_DENIED|إنشاء دور نظام بدون صالحية|
|اختر دورا<sup>,</sup>وفرعا<sup>,</sup>واحدا<sup>,</sup>على األقل|ا   ا  تحقق فيadmin_provision_user(ERP16/ERP22)|بال دور أو بال فرع|
|<sup>بيانات الموظف ناقصة</sup>|NOT NULL<br>علىemployees.party_id|موظف بال طرف|



**)( . الصالحياتRLS9** 

. users.manage : كل العمليات تتطلب user_roles و users • • .) وليس مباشرة (افتراض SECURITY DEFINER ذ عبر الدالةنف<sup>MN</sup> : ت user_branch_access و employees 

**)( . ح الت الواجهةUI States10** 

|**السلوك**||**الحالة**|
|---|---|---|
||) هيكلskeleton<br>.( للجدول|تحميل|



صفحة9 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**السلوك الحالة** فارغ.«ًال مستخدمين» مع زر اإلنشاء خطأ.رسالة تحت الحقل المخالف نجاح.شاشة تأكيد بكلمة مؤقتة **)( . النتيجة بعد التنفيذPostconditions11** • .حساب نشط بدور وفروع .) (افتراض audit_logs في CREATE سجل • **)( . معايير القبولAcceptance Criteria12** . فإن ينشأ المستخدم بأدواره وفروعه دفعة واحدة<sup>P</sup> صحيحا<sup>P</sup> : عندما يحفظ المدير نموذجاS02-AC1 • .نشأ شيء وتظهر رسالة على الحقلN فإن ال ي username : عندما يتكررS02-AC2 • . الشاشة فإن ال تظهر له في القائمة users.manage : عندما يفتح مستخدم بالS02-AC3 • **13. مالحظات للمصمم** 

• .اجمع األدوار والفروع في شاشة واحدة بخطوات ظاهرة • . قبل الحفظ<sup>P</sup> اعرض ملخصا • .كلمة المرور المؤقتة تظهر مرة واحدة فقط 

#### **<mark>لحياتها</mark> ا** **<mark>لدوار وصS03 — إدارة ا</mark> أ** 

**1. رقم واسم السيناريو** S03 — إدارة األدوار وصالحياتها **)( . الدورActor2** SUPER_ADMIN 

**3. الهدف** 

.تحديد ما يستطيع كل دور فعله بربطه بأكواد الصالحيات 

**)( . الشروط المسبقةPreconditions4** . users.manage ذ يملكالمنف<sup>X</sup> • .)أ باألكواد (حالياX معبseed  فارغ، يحتاج<sup>P</sup> permissions جدول • 

**5. الجداول المستخدمة** 

||**أدة المهمة**|**األعم**||**الجدول**||
|---|---|---|---|---|---|
||code,|name, description, is_syste|m_role, is_active||roles|
|||code, name, mod|ule, description|permi|ssions|
|||role_id|, permission_id|role_permi|ssions|
||||**أMain**<br>**)**|**(  ار األساسي Flow**|**6**<br>**. المس أ**|
|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**الشاشة / الواجهة**|**ما يفعله المستخدم**|**الخطو**<br>**ة**|
|roles.code,roles.name,<br>roles.is_system_role|SELECT|أ،»بطاقات األدوار مع شارة «دور نظام<br>»زر «دور جديد|قائمة األدوار أ|يفتح قائمة األدوار|1  أ|
|roles.name,<br>roles.description,<br>roles.is_active|SELECT|»الf**ا**لسم، الوصف، مفتاح «فع|تفاصيل الدور|ƒيختار دورا|2|



صفحة10 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**الشاشة / الواجهة**|**ما يفعله المستخدم**|**الخطو**<br>**ة**|
|---|---|---|---|---|---|
|permissions.code,<br>permissions.module,<br>role_permissions.role_id,|SELECT /<br>INSERT /<br>DELETE|عة حسبfقائمة مجم<br>permissions.moduleبمربعات<br>اختيار|مصفوفة الصالحيات|ل الصالحياتfيعد|3 ا|
|permission_id||||||
|role_permissions|INSERT /<br>DELETE|اد التغييراتfزر «حفظ التغييرات» مع عد|مصفوفة الصالحيات|يحفظ|4|



**)( . المسارات البديلةAlternative Flows** 

**7** 

.إنشاء دور مخصص جديد • • .)حذف<sup>N</sup> تعطيل دور بدل حذفه (أدوار النظام ال ت 

.)نسخ صالحيات دور إلى دور جديد (افتراض: عملية واجهة فقط 

• 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|(حذف )يمكن تعطيلها<sup>s</sup>أدوار النظام ًال ت|ERP01 DOC_LOCKED|حذف دور نظام|
|ًال تملك صالحية تعديل األدوار|ERP16 PERMISSION_DENIED|تعديل بال صالحية|
|,رمز الدور مستخدم مسبقا|UNIQUE<br>علىroles.code|كود دور مكرر|



**)( . الصالحياتRLS9** 

. users.manage : القراءة مفتوحة، والكتابة تتطلب roles • • role_permissions_guard )trigger( حر•س بـ<sup>N</sup> ت role_permissions 

**)( . ح الت الواجهةUI States10** 

|**السلوك**||**الحالة**|
|---|---|---|
||.هيكل للمصفوفة|تحميل|
||.»«ًال أدوار|فارغًا|
||.شريط أحمر أعلى المصفوفة|خطأ|
||.إشعار «تم الحفظ» وتحديث العد•اد|نجاح|



**)( . النتيجة بعد التنفيذPostconditions11** 

• .ثXارتباط الدور بالصالحيات محد 

.)ق التغييرات في الدخول التالي لحاملي الدور (افتراضMطب<sup>N</sup> ت 

• 

**)( . معايير القبولAcceptance Criteria12** 

role_permissions : عندما يحدد المدير صالحية لدور ويحفظ فإن يظهر سطر جديد فيS03-AC1 • . ERP01 رفض بالرسالة الصادرة منN: عندما يحاول حذف دور نظام فإن يS03-AC2 • 

**13. مالحظات للمصمم** 

• .اعرض األدوار السبعة األساسية كأدوار نظام 

• .المصفوفة: الوحدات صفوف والصالحيات أعمدة مع بحث 

**وحدة2: الهيكل واإلعدادات** 

**<mark>S04 — إدارة الفروع والمستودعات</mark>** 

**1. رقم واسم السيناريو** S04 — إدارة الفروع والمستودعات 

صفحة11 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**)( . الدورActor2** ) org.manage (ألن SUPER_ADMIN 

**3. الهدف** 

.تعريف فرع ومستودعاته وأنواعها 

**)( . الشروط المسبقةPreconditions4** 

. org.manage ذ يملكالمنف<sup>X</sup> • 

**5. الجداول المستخدمة** 

||**أدة المهمة**|**األعم**||**الجدول**||
|---|---|---|---|---|---|
|||code, name, address,|phone, is_active|bra|nches|
|branch_id, code, nam   i|e, warehouse_type  i|, is_sellable, is_online_fulfil|ilment, address,<br>is_active|wareh|ouses|
||||**أMain**<br>**)**|**(  ار األساسي Flow**|**6**<br>**. المس أ**|
|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**الشاشة / الواجهة**|**ما يفعله المستخدم**|**الخطو**<br>**ة**|
|branches.code,<br>branches.name,<br>branches.is_active|SELECT|»جدول الفروع وزر «فرع جديد|قائمة الفروع|يفتح قائمة الفروع|1|
|branches.code,<br>branches.name,<br>branches.address,<br>branches.phone|INSERT|الرمز،**ا**لسم، العنوان، الهاتف|نموذج فرع|ƒينشئ فرعا|2|
|warehouses.branch_id,<br>warehouse_type,is_sellable,<br>is_online_fulfillment|INSERT|،**ا**لسم، الرمز، قائمة النوع (عام، صالة<br>مركزي، مرتجعات، تالف)، «قابل<br>»للبيع»، «تجهيز طلبات أونالين|نموذج مستودع|للفرع<sup>ƒ</sup>يضيف مستودعا|3|
|branches.is_active,<br>warehouses.is_active|UPDATE|»الfمفتاح «فع|/ قائمة الفروع<br>المستودعات|ƒ أو مستودعاƒل فرعاfيعط|4|



**)( . المسارات البديلةAlternative Flows7** 

• warehouse.central.access<sup>P</sup> فارغ): يتطلب الحقا branch_id ( مستودع مركزي بال فرع . is_sellable = false ضبطانNمستودعا «مرتجعات» و«تالف» ي • 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**||**القيد / القاعدة**|**الحالة**|
|---|---|---|---|
||,الرمز مستخدم مسبقا|UNIQUE<br>علىcode|رمز مكرر|
||<sup>اختر نوعا, من القائمة</sup>|CHECK<br>علىwarehouse_type|نوع مستودع غير صالح|
||<sup>ً</sup><sup>**ا**لسم مطلوب</sup>|NOT NULL<br>علىname|اسم فارغ|



**)( . الصالحياتRLS9** 

. org.manage : الكتابة تتطلب warehouses و branches • • . للمستودعات can_access_warehouse للفروع و can_access_branch :القراءة 

**)( . ح الت الواجهةUI States10** 

|**السلوك**||**الحالة**|
|---|---|---|
||.هيكل للقوائم|تحميل|
||.»«ًال فروع بعد|فارغًا|
||.رسالة على الحقل|خطأ|



صفحة12 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**السلوك الحالة** نجاح.ظهور الفرع في القائمة **)( . النتيجة بعد التنفيذPostconditions11** • .)لنXفرع ومستودع جديدان (فع **ا )( . معايير القبولAcceptance Criteria12** .) (افتراض<sup>P</sup> افتراضيا is_sellable = false تMثبN فإن ي DAMAGED نشأ مستودع بنوعN: عندما يS04-AC1 • .رفض العملية<sup>N</sup> الكتابة فإن ت org.manage : عندما يحاول مستخدم بالS04-AC2 • **13. مالحظات للمصمم** 

• .اعرض المستودعات متداخلة تحت الفرع • .لون مختلف لكل نوع مستودع 

#### **<mark>S05 — إعداد نقاط البيع والصناديق</mark>** 

**1. رقم واسم السيناريو** S05 — إعداد نقاط البيع والصناديق **)( . الدورActor2** SUPER_ADMIN ( و MANAGER ) pos.manage **3. الهدف** .ربط جهاز البيع بصندوق ومستودع وحساب بنكي افتراضي، وتعيين الكاشير عليه **)( . الشروط المسبقةPreconditions4** • .فرع ومستودع قابل للبيع موجودان • .) على الفرع can_operate (  ويعمل pos.manage ذ يملكالمنف<sup>X</sup> 

**5. الجداول المستخدمة** 

|**األعمدة المهمة**|**الجدول**|
|---|---|
|branch_id, name, code, cashbox_id, default_bank_account_id, default_warehouse_id,|pos_terminals|
|is_active||
|branch_id, name, code, is_active|cashboxes|
|cashbox_id, currency_id, is_active|cashbox_accounts|
|user_id, pos_terminal_id, is_default|user_pos_terminals|



**)( . المسار األساسيMain Flow** 

**6** 

|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**الشاشة / الواجهة**|**ما يفعله المستخدم**|**الخطوة**|
|---|---|---|---|---|---|
|pos_terminals.name,code,<br>is_active|SELECT|»جدول النقاط وزر «نقطة جديدة|قائمة نقاط البيع|يفتح نقاط البيع|1|
|cashboxes.branch_id,name,<br>code|INSERT|**ا**لسم، الرمز|نموذج صندوق|ƒينشئ صندوقا|2|
|cashbox_accounts.cashbox_id,<br>currency_id|ا   INSERT|قائمة عمالت مع مفتاح تفعيل|ا )نموذج صندوق (عمالت|يضيف عمالت للصندوق  ا|3 ا   ا|
|pos_terminals.cashbox_id,<br>default_warehouse_id,<br>default_bank_account_id|INSERT|**ا**لسم، الرمز، الصندوق، المستودع<br>**ا**لفتراضي، الحساب البنكي**ا**لفتراضي|نموذج نقطة بيع|ينشئ نقطة بيع ويربطها|4|



صفحة13 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**الشاشة / الواجهة**|**ما يفعله المستخدم**|**الخطوة**|
|---|---|---|---|---|---|
|user_pos_terminals.user_id,<br>pos_terminal_id,is_default|INSERT|»قائمة كاشيرات، مفتاح «**ا**لفتراضي|تعيين المستخدمين|ن الكاشيرfيعي|5|
||||**Alternative F**<br>**)**|**(  سارات البديلة lows**|**7**<br>**. الم**|
|||is_defaul<br>.|طة: نقطة واحدة فقطt|كاشير على أكثر من نق|•|



• .تعطيل نقطة بيع ال تحتوي جلسة مفتوحة 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|المستودع غير قابل للبيع|ERP11 WAREHOUSE_NOT_SELLABLEعند أول<br>بيع|مستودع غير قابل للبيع|
|,الرمز مستخدم مسبقا|UNIQUE<br>علىcode|رمز مكرر|
|الكاشير معي•ن على هذه النقطة|) قيد فريد متوقع علىuser_id,pos_terminal_id<br>(<br>()افتراض|تكرار تعيين كاشير|



**)( . الصالحياتRLS9** • ) والكتابة pos.session , pos.manage , sales.create , sales.view , finance.view ( : القراءة pos_terminals . can_access_branch ، مع pos.manage . pos.manage أو finance.manage : الكتابة cashbox_accounts و cashboxes • . `)(` auth.uid : القراءة بـ user_pos_terminals • 

**)( . ح الت الواجهةUI States** 

**10** 

**السلوك الحالة** تحميل.هيكل فارغ.»«ًال نقاط بيع خطأ.على الحقل نجاح.النقطة تظهر نشطة في القائمة **)( . النتيجة بعد التنفيذPostconditions11** • .نقطة بيع جاهزة لفتح جلسة **)( . معايير القبولAcceptance Criteria12** .ستخدم عمالته عند فتح الجلسة<sup>N</sup> ربط نقطة بصندوق فإن ت<sup>N</sup> : عندما تS05-AC1 • .ن كاشير على نقطة فإن تظهر له عند فتح الجلسةMعيN: عندما يS05-AC2 • **13. مالحظات للمصمم** • . خطوات: صندوق ← نقطة ← كاشيرات معالج من3 . is_sellable إن لم يكن للمستودع<sup>P</sup> اعرض تحذيرا • 

**<mark>لعداداتلت وأسعار الصرف وا</mark> إ** **<mark>S06 — العم</mark> ا** 

**1. رقم واسم السيناريو** S06 — العمالت وأسعار الصرف واإلعدادات 

**)( . الدورActor2** SUPER_ADMIN و ACCOUNTANT 

صفحة14 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**3. الهدف** 

.تحديد العملة األساسية وأسعار الصرف المعتمدة وإعدادات النظام 

**)( . الشروط المسبقةPreconditions4** 

• . لإلعدادات settings.manage ألسعار الصرف و fx.rate.manage ذ يملكالمنف<sup>X</sup> 

**5. الجداول المستخدمة** 

|**األعمدة المهمة**|**الجدول**|
|---|---|
|code, name, symbol, decimal_places, is_base, is_active, rounding_increment,<br>rounding_method|currencies|
|from_currency_id, to_currency_id, rate, rate_date, is_approved, source, note|exchange_rates|
|scope_type, branch_id, user_id, setting_key, value_text|settings|



**)( . المسار األساسيMain Flow** 

**6** 

|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**الشاشة / الواجهة**|**ما يفعله المستخدم**|**الخطو**<br>**ة**|
|---|---|---|---|---|---|
|currencies.code,symbol,is_base,<br>is_active|ا ا  SELECT|ا»جدول العمالت، شارة «أساسية|قائمة العمالت ا|يفتح العمالت|1 ا|
|exchange_rates.from_currency_id,<br>to_currency_id,rate,rate_date,<br>source|INSERT|،من عملة، إلى عملة، السعر، التاريخ<br>المصدر، مالحظة|نموذج سعر صرف|يضيف سعر صرف|2|
|exchange_rates.is_approved|UPDATE|مفتاحis_approved|قائمة أسعار الصرف|يعتمد السعر أو يوقفه|3|
|settings.scope_type,setting_key,<br>value_text|UPSERT|قائمة (عام/فرع/مستخدم)، مفتاح، قيمة|شاشة اإلعدادات|ƒل إعداداfيعد|4|



**)( . المسارات البديلةAlternative Flows7** 

• .) note ( لز•م مالحظة<sup>N</sup> وت fx.rate.manual السعر اليدوي يتطلب 

.وقف فقطNحذف سعر صرف: يNال ي 

• 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|حذف — أضف سعرا<sup>,</sup>جديدا<sup>,</sup>أو أوقف السعر<sup>s</sup>أسعار الصرف ًال ت|ERP06 FX_RATE_IMMUTABLE|حذف سعر صرف|
|<sup>السعر يجب أن يكون أكبر من صفر</sup>|CHECK<br>علىrate|سعر غير موجب|
|<sup>اكتب سبب السعر اليدوي</sup>|CHECK<br>علىnote|مالحظة مطلوبة لسعر يدوي|



**)( . الصالحياتRLS9** 

• fx.rate.manual أو fx.rate.manage : القراءة مفتوحة، والكتابة exchange_rates • . مع النطاق settings.manage ، والقراءة settings.manage : الكتابة settings . audit_rate_change )action RATE_CHANGE ( ن عبرMدوNر السعر يXتغي • 

**)( . ح الت الواجهةUI States10** 

|**السلوك**||**الحالة**|
|---|---|---|
||.هيكل|تحميل|
||.«ًال أسعار صرف» مع تنبيه أن البيع بعملة أجنبية سيتعذر|فارغًا|
||.على الحقل|خطأ|
||.السعر الجديد يظهر في أعلى القائمة|نجاح|



صفحة15 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**)( . النتيجة بعد التنفيذPostconditions11** 

• .ستخدم في المستندات الالحقةNسعر معتمد ي . audit_logs في RATE_CHANGE سجل • 

**)( . معايير القبولAcceptance Criteria12** .ضاف سعر معتمد فإن تستخدمه المستندات بتاريخ بعدهN: عندما يS06-AC1 • . منهعرض خيار اإليقاف بدالN: عندما يحاول مستخدم حذف سعر فإن ي<sup>P</sup> S06-AC2 • 

**13. مالحظات للمصمم** 

• .اعرض آخر سعر لكل زوج عمالت في أعلى الصفحة • .) كشارة ملونة source ( مصدر السعر 

#### **<mark>لت عرض العملة</mark> ا** **<mark>S43 — تفضي</mark>** 

**1. رقم واسم السيناريو** S43 — تفضيالت عرض العملة **)( . الدورActor2** 

)جميع المستخدمين (لتفضيلهم الشخصي 

**3. الهدف** 

.اختيار العملة األساسية للعرض والعملة الثانوية وطريقة إظهارها، مع أفضلية عملة الفاتورة 

**)( . الشروط المسبقةPreconditions4** • .الةXفة وفعXالعمالت معر 

.الةXفة وفعXالعمالت معر 

||**5. الجداول المستخدمة**|
|---|---|
|**األعمدة المهمة**|**الجدول**|
|scope_type, branch_id, user_id, primary_currency_id, secondary_currency_id,|display_preferences|
|display_mode, print_mode||
|code, symbol, is_base, is_active|currencies|



**)( . المسار األساسيMain Flow6** 

|**الجدول واألعمدة**|**العملية على**<br>**القاعدة**|**عناصر الواجهة**|**الشاشة / الواجهة**|**ما يفعله المستخدم**|**الخطو**<br>**ة**|
|---|---|---|---|---|---|
|display_preferences.primary_currency_id,<br>secondary_currency_id,display_mode|إ   SELECT|إ »قسم «عرض المبالغ|اإلعدادات الشخصية|يفتح تفضيالت العرض|1 ا|
|currencies.code,symbol|اSELECT|قائمتان للعمالت|اإلعدادات الشخصية|يختار العملة األساسية<br>والثانوية|2  أ|
|display_preferences.display_mode,<br>print_mode|—|خيارات: عملة واحدة / مع تلميح<br>/**ا**لثنتان؛ وطباعة مفردة أو<br>مزدوجة|اإلعدادات الشخصية|يختار طريقة العرض<br>والطباعة|3|
|display_preferences)scope_type = USER(|UPSERT|زر حفظ|اإلعدادات الشخصية|يحفظ|4|



**)( . المسارات البديلةAlternative Flows7** 

.) settings.manage ) (افتراض: لمن يملك GLOBAL ( ) أو عام BRANCH (  على مستوى الفرعالمدير يضبط تفضيال<sup>P</sup> • • بحسب التفضيل مع زكر او إشارة على عملتها األساسية او تعطي باألساس  عرض مبالغ الفاتورة<sup>N</sup> أفضلية عملة الفاتورة (قرارك): ت بالعملة األساسية وقادر على اطالع على ما يقابلها وهذه فاتورة الشراء اما البيع األفضلية لالعدادات. 

صفحة16 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|<sup>اختر عملة من القائمة</sup>|FK<br>علىprimary_currency_id|عملة غير معر•فة|
|العملة الثانوية يجب أن تختلف عن األساسية|(تحقق واجهة )افتراض|عملتان متطابقتان|



**)( . الصالحياتRLS9** 

• . ونطاق الفرع، فيدير كل مستخدم تفضيله `)(` auth.uid : القراءة والكتابة مرتبطتان بـ display_preferences 

**)( . ح الت الواجهةUI States** 

**10** 

**السلوك الحالة** تحميل.قيم افتراضية فارغ.ستخدم تفضيل الفرع ثم العامsي خطأ.رسالة عامة نجاح.تحديث فوري للمبالغ المعروضة **)( . النتيجة بعد التنفيذPostconditions11** • .صف تفضيل للمستخدم **)( . معايير القبولAcceptance Criteria12** . فإن تظهر المبالغ بالعملتين<sup>P</sup> مزدوجا<sup>P</sup> : عندما يختار المستخدم عملتين وعرضاS43-AC1 • .: عندما تكون عملة الفاتورة مختلفة عن التفضيل فإن تظهر مبالغ الفاتورة بعملتها أوال<sup>P</sup> S43-AC2 • 

**13. مالحظات للمصمم** 

• .اعرض معاينة فورية لمبلغ نموذجي • .ق نفس المعاينة على الطباعةMطب<sup>N</sup> ت 

### **وحدة3: الكتالوج والتسعير** 

**<mark>) — إنشاء منتج (موديلS07</mark> 1. رقم واسم السيناريو** ) — إنشاء منتج (موديلS07 **)( . الدورActor2** ) catalog.manage (حسب قرارك؛ WAREHOUSE و PURCHASER و MANAGER 

**3. الهدف** 

.تعريف موديل جديد وتصنيفه قبل توليد المتغيرات **)( . الشروط المسبقةPreconditions4** 

• catalog.manage ذ يملكالمنف<sup>X</sup> • .الةXفة وفعX معر product_types 

**5. الجداول المستخدمة** 

|**األعمدة المهمة**|**الجدول**|
|---|---|
|name, slug, product_type_id, brand_id, origin_country_id, authenticity_status,<br>model_code, description, status|products|
|name, code|product_types|



صفحة17 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

|**األعمدة المهمة**||**الجدول**|
|---|---|---|
||name, slug|brands|
||parent_id, name, slug|categories|



**)( . المسار األساسيMain Flow** 

**6** 

|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**الشاشة / الواجهة**|**ما يفعله المستخدم**|**الخطوة**|
|---|---|---|---|---|---|
|products.name,model_code,<br>status|SELECT|،بحث، مرشحات (النوع، الماركة<br>»الحالة)، زر «منتج جديد|قائمة المنتجات|»يضغط «منتج جديد|1|
|product_types.name,<br>brands.name,<br>products.authenticity_status|SELECT<br>) (قوائم|**ا**لسم، رمز الموديل، الوصف، نوع<br>المنتج، الماركة، بلد المنشأ، حالة<br>األصالة|أ نموذج منتج (خطوة1<br>)|ئ البيانات األساسيةfيعب|2  أ|
|categories.name,<br>product_categories<br>) (ربط|SELECT /<br>INSERT|شجرة تصنيفات متعددة**ا**لختيار|نموذج منتج (خطوة2<br>)|يربط التصنيفات|3|
|products.status = draft,<br>products.slug|INSERT|زر «حفظ كمسودة» وزر «متابعة<br>»للمتغيرات|نموذج منتج|يحفظ كمسودة|4|



**)( . المسارات البديلةAlternative Flows7** .) archived ( ) ليظهر في المتجر اإللكتروني المستقبلي، وأرشفته published (<sup>P</sup> نشر المنتج الحقا • • .ماركة أو تصنيف غير موجود: إضافة سريعة من داخل النموذج 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|ً**ا**لسم مطلوب|NOT NULL|اسم أوslug فارغ|
|<sup>المعر</sup>•<sup>ف مستخدم لمنتج آخر</sup>|UNIQUE<br>علىproducts.slug|slug مكرر|
|<sup>اختر نوع المنتج</sup>|NOT NULL<br>علىproduct_type_id|نوع منتج غير محدد|
|<sup>الحالة غير مسموحة</sup>|CHECK<br>علىstatus|حالة غير صالحة|



**)( . الصالحياتRLS9** • .، والقراءة مفتوحة catalog.manage : الكتابة products .) masterdata.manage :: سياسة الجداول المرجعية الخاصة (افتراض brands categories الجداول المرجعية • 

**)( . ح الت الواجهةUI States10** 

**السلوك الحالة** تحميل.هيكل للنموذج فارغ.«ًال منتجات» مع زر اإلنشاء خطأ.على الحقل نجاح.ًلنتقال إلضافة األلوان والمقاسات **ا )( . النتيجة بعد التنفيذPostconditions11** • . وبال متغيرات بعد draft منتج بحالة **)( . معايير القبولAcceptance Criteria12** . draft : عندما يحفظ المستخدم بيانات صحيحة فإن ينشأ منتج بحالةS07-AC1 • . فإن تظهر رسالة على الحقل وال ينشأ المنتج slug : عندما يتكررS07-AC2 • 

**13. مالحظات للمصمم** • . من لسم وقابل للتعديل **ا**<sup>P</sup> تلقائيا slug أنشئ . status شارة ملونة لـ • 

صفحة18 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**<mark>) — إضافة اللوان والمقاسات والباركود (المتغيرات</mark> أ** 

#### **<mark>S08</mark>** 

**1. رقم واسم السيناريو** ) — إضافة األلوان والمقاسات والباركود (المتغيراتS08 

**)( . الدورActor2** 

WAREHOUSE و PURCHASER و MANAGER 

**3. الهدف** . من تركيبات اللون والمقاس وإصدار باركود لكل متغير product_variants توليد **)( . الشروط المسبقةPreconditions4** • .المنتج موجود • .) مرتبطة بنوع المنتج size_groups ( مجموعة مقاسات 

.) مرتبطة بنوع المنتج size_groups ( مجموعة مقاسات 

**5. الجداول المستخدمة** 

|**األعمدة المهمة**|**الجدول**|
|---|---|
|product_id, sku, variant_key, variant_name, size_id, product_color_id, unit_id, is_default,|product_variants|
|is_active||
|product_id, name, sort_order|product_colors|
|size_group_id, name, code, numeric_value|sizes|
|variant_id, barcode, barcode_type, is_primary, is_active|barcodes|



**)( . المسار األساسيMain Flow6** 

|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**الشاشة / الواجهة**|**ما يفعله المستخدم**|**الخطوة**|
|---|---|---|---|---|---|
|product_variants.sku,<br>variant_name,is_active|SELECT|»جدول المتغيرات، زر «توليد متغيرات|تفاصيل المنتج (تبويب<br>)المتغيرات|يفتح المنتج ويختار تبويب<br>المتغيرات|1|
|product_colors.name,<br>sort_order|INSERT|أ+  نسبة+ نات اللون (اسمfاسم اللون، مكو<br>ب<sup>f</sup>جزء) عند اللون المرك|نافذة األلوان|يضيف ألوان الموديل|2|
|sizes.name,code|SELECT|شبكة مقاسات من المجموعة المرتبطة|نافذة المقاسات|يختار المقاسات|3|
|product_variants.sku,<br>variant_key,size_id,<br>product_color_id|INSERT|جدول (لون × مقاس) بمفاتيحSKU<br>»المقترحة، زر «توليد|معاينة التوليد|د المتغيرات<sup>f</sup>يول|4|
|barcodes.barcode,<br>barcode_type,is_primary|INSERT|حقل باركود، النوع<br>(<br>EAN13/UPC/CODE128<br>،)<br>»«أساسي|نافذة الباركود|يضيف باركود|5|



**)( . المسارات البديلةAlternative Flows7** 

.: توليد المتغيرات الناقصة فقط<sup>P</sup> إضافة مقاس أو لون الحقا 

• 

• .) بدل حذفه is_active = false ( إيقاف متغير 

• .)طباعة ملصقات الباركود ( واجهة فقط 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|الـSKU مستخدم لمتغير آخر|UNIQUE<br>علىproduct_variants.sku|SKU مكرر|
|<sup>هذه التركيبة )لون/مقاس( موجودة</sup>|variant_key<br>)يحسبهcompute_variant_key<br>(|مفتاح التركيبة مكرر|
|<sup>الباركود مستخدم لمتغير آخر</sup>|UNIQUE<br>علىbarcodes.barcode|باركود مكرر|



صفحة19 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**رسالة للمستخدم القيد / القاعدة الحالة**<sup>نوع الباركود غير مدعوم</sup> barcode_type على CHECK نوع باركود خاطئ **)( . الصالحياتRLS9** 

. catalog.manage : الكتابة product_variants • • .): تتبع سياسة المنتج/المرجعية (افتراض barcodes product_colors sizes 

**)( . ح الت الواجهةUI States10** 

**السلوك الحالة** تحميل.هيكل للجدول فارغ.«ًال متغيرات» مع زر التوليد خطأ.تلوين الصف المخالف نجاح.ظهور المتغيرات الجديدة مع أول باركود **)( . النتيجة بعد التنفيذPostconditions11** • . وباركود، بال تكلفة وال سعر بعد الة بـXمتغيرات فعSKU **)( . معايير القبولAcceptance Criteria12** . تركيبة قبل التوليد مقاسات فإن ت12 عرض<sup>N</sup> : عندما يختار المستخدم3 ألوان و4S08-AC1 • . فريد variant_key نشأ لهNد متغير فإن ي<sup>M</sup> و•لN: عندما يS08-AC2 • **13. مالحظات للمصمم** • .شبكة اللون × المقاس هي الشاشة المركزية • .أظهر عمود الباركود األساسي مباشرة في الجدول 

**<mark>S09 — تسعير المنتجات</mark> 1. رقم واسم السيناريو** S09 — تسعير المنتجات **)( . الدورActor2** MANAGER ) pricing.manage ( **3. الهدف** .تحديد سعر بيع الموديل أو المتغير في قائمة أسعار بعملة وتاريخ صالحية **)( . الشروط المسبقةPreconditions4** • .فةXالة وعمالت معرXقائمة أسعار فع . pricing.manage ذ يملكالمنف<sup>X</sup> • 

**5. الجداول المستخدمة** 

|**األعمدة المهمة**|**الجدول**|
|---|---|
|name, code, currency_id, price_type, is_default, is_active|price_lists|
|variant_id, price_list_id, currency_id, amount, valid_from, valid_to|variant_prices|
|name, model_code|products|



صفحة20 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**)( . المسار األساسيMain Flow6** 

|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**الشاشة / الواجهة**|**ما يفعله المستخدم**|**الخطوة**|
|---|---|---|---|---|---|
|products.name,<br>price_lists.name,price_type|أSELECT|اختيار المنتج وقائمة األسعار|شاشة التسعير|يفتح تسعير منتج|1|
|variant_prices.amount,<br>currency_id,valid_from,<br>valid_to|SELECT|( جدول متغيراتSKU، السعر<br>)الحالي، العملة، من/إلى|شاشة التسعير|يرى األسعار الحالية|2 أ|
|variant_prices.amount,<br>valid_from|RPC<br>set_model_price<br>`)...(`|حقل المبلغ، العملة، تاريخ البدء|»نافذة «سعر الموديل|يحدد سعر الموديل لكل<br>المتغيرات|3|
|variant_prices.variant_id,<br>amount,valid_from|INSERT<br>) (سعر جديد بتاريخ|تحرير داخل الخلية|شاشة التسعير|ل سعر متغير بعينهfيعد|4|



**)( . المسارات البديلةAlternative Flows7** 

• .) بعملتها retail / wholesale / special ( إنشاء قائمة أسعار جديدة • .: هامش أو ربح) خارج هذه الوثيقة price_rules ( قواعد التسعير التلقائية 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|<sup>السعر يجب أن يكون أكبر من صفر</sup>|CHECK<br>علىvariant_prices.amount|مبلغ غير موجب|
|<sup>تعذر تحديد السعر</sup>|ERP22 INVALID_STATE<br>منset_model_price|حالة غير صالحة|
|ًال تملك صالحية التسعير|ا ا سياسةpricing.manage|بال صالحية|



**)( . الصالحياتRLS9** 

. pricing.manage : القراءة مفتوحة، والكتابة variant_prices و price_lists • 

**)( . ح الت الواجهةUI States** 

**10** 

**السلوك الحالة** تحميل.هيكل فارغ.«ًال سعر» بشارة حمراء على المتغير خطأ.على الخلية نجاح.السعر الجديد يظهر مع تاريخ بدء **)( . النتيجة بعد التنفيذPostconditions11** . resolve_price ستخدم بـ<sup>N</sup> ت valid_from أسعار صالحة من • 

**)( . معايير القبولAcceptance Criteria12** 

.د سعر الموديل فإن ينعكس على كل متغيراتهMحدN: عندما يS09-AC1 • .ضاف سعر بتاريخ الحق فإن يظل الحالي ساري حتى ذلك التاريخN: عندما يS09-AC2 • 

**13. مالحظات للمصمم** 

• .) (هامش الربح costs.view اعرض ملخص التكلفة بجانب السعر لمن يملك • .أبرز المتغيرات بال سعر أوال<sup>P</sup> 

**<mark>S10 — تحديد تكلفة المنتج وتعديلها</mark>** 

**1. رقم واسم السيناريو** S10 — تحديد تكلفة المنتج وتعديلها 

صفحة21 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**)( . الدورActor2** 

MANAGER ) costs.manage ( و ACCOUNTANT 

**3. الهدف** 

.لX عند الحاجة مع سبب مسج<sup>P</sup> ضبط التكلفة يدويا 

**)( . الشروط المسبقةPreconditions4** 

. costs.manage ذ يملكالمنف<sup>X</sup> 

.األصل أن التكلفة تتحدث من ترحيل المشتريات؛ هذا لستثناء اليدوي **ا** 

• 

• 

##### **5. الجداول المستخدمة** 

|**األعمدة المهمة**|**الجدول**|
|---|---|
|variant_id, currency_id, average_cost, last_purchase_cost|variant_costs|
|target_type, target_id, old_cost_base, new_cost_base, input_cost, input_currency_id,|cost_adjustments|
|reason||
|sku, variant_name, product_id|product_variants|



**)( . المسار األساسيMain Flow** 

**6** 

|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**الشاشة / الواجهة**|**ما يفعله المستخدم**|**الخطو**<br>**ة**|
|---|---|---|---|---|---|
|product_variants.sku,<br>variant_costs.average_cost,<br>last_purchase_cost|SELECT|( بحث، جدولSKU<br>،، متوسط التكلفة<br>)آخر شراء|شاشة التكلفة|يبحث عن منتج أو متغير|1|
|cost_adjustments.target_type,<br>input_cost,input_currency_id,<br>reason|—|النطاق (متغير/موديل)، التكلفة<br>الجديدة، العملة، السبب|نافذة تعديل التكلفة|»يختار «تعديل التكلفة|2|
|variant_costs.average_cost,<br>cost_adjustments.new_cost_base|RPC<br>set_variant_costأو<br>set_model_cost|»زر «تأكيد|نافذة تعديل التكلفة|يحفظ|3|
|cost_adjustments.old_cost_base,<br>new_cost_base,reason|SELECT|،جدول (قديم، جديد، السبب<br>)المستخدم|سجل التكلفة|يراجع سجل التعديالت|4  ا|



**)( . المسارات البديلةAlternative Flows7** 

• .) set_model_cost ( ق على كل المتغيراتXتعديل على مستوى الموديل يطب . resolve_rate ل التكلفة المدخلة للعملة األساسية بـMحو<sup>N</sup> ت • 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**||**القيد / القاعدة**|**الحالة**|
|---|---|---|---|
||<sup>السبب مطلوب</sup>|CHECK<br>علىcost_adjustments.reason|السبب فارغ|
||<sup>التكلفة ًال تكون سالبة</sup>|CHECK<br>علىaverage_cost|تكلفة سالبة|
||تعذر تعديل التكلفة|ERP22 INVALID_STATE|حالة غير صالحة|



**)( . الصالحياتRLS9** 

. costs.manage والكتابة costs.view : القراءة variant_costs • . costs.view خفي التكلفة عمن ال يملك<sup>N</sup> تViews v_*_costs • 

**)( . ح الت الواجهةUI States10** 

|**السلوك**||**الحالة**|
|---|---|---|
||.هيكل|تحميل|
||.( بعدµشترs«ًال تكلفة» )لم ي|فارغ ًا|



صفحة22 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**السلوك الحالة** خطأ.على الحقل نجاح.تحديث الخلية وإضافة سطر في السجل **)( . النتيجة بعد التنفيذPostconditions11** • .تكلفة جديدة وسجل تعديل **)( . معايير القبولAcceptance Criteria12** . new_cost_base و old_cost_base لMسجNل المستخدم التكلفة بسبب فإن يX: عندما يعدS10-AC1 • . فإن يختفي عمود التكلفة costs.view : عندما ال يملك المستخدمS10-AC2 • **13. مالحظات للمصمم** • .السبب حقل إلزامي بقائمة أسباب شائعة • .) يرى التكلفة (قراءة فقط AUDITOR :قرارك 

**<mark>S11 — إدارة الخصومات</mark> 1. رقم واسم السيناريو** S11 — إدارة الخصومات **)( . الدورActor2** MANAGER ) pricing.manage ( **3. الهدف** .تعريف خصم (نسبة/مبلغ) ونطاقه وفترته، وضبط سقف خصم الكاشير **)( . الشروط المسبقةPreconditions4** . pricing.manage ذ يملكالمنف<sup>X</sup> • 

##### **5. الجداول المستخدمة** 

|**األعمدة المهمة**|**الجدول**|
|---|---|
|name, code, discount_type, value, currency_id, min_quantity, start_at, end_at,<br>is_stackable, is_active|discounts|
|discount_id, target_type, target_id|discount_targets|
|scope_type, branch_id, setting_key, value_text|settings|



**)( . المسار األساسيMain Flow6** 

|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**الشاشة / الواجهة**|**ما يفعله المستخدم**|**الخطو**<br>**ة**|
|---|---|---|---|---|---|
|discounts.name,discount_type,<br>value,is_active|SELECT|،جدول (**ا**لسم، النوع، القيمة، الفترة<br>)الحالة|قائمة الخصومات|يفتح الخصومات|1|
|discounts.discount_type,value,<br>min_quantity,start_at,end_at,<br>is_stackable|INSERT|،**ا**لسم، الرمز، النوع (نسبة/مبلغ)، القيمة<br>،العملة، الحد األدنى للكمية، من/إلى<br>»«قابل للجمع|نموذج خصم|ƒينشئ خصما|2|
|discount_targets.target_type,<br>target_id|INSERT|اختيار: منتج/متغير/تصنيف/نوع/ماركة|)نموذج خصم (النطاق|يحدد النطاق|3|
|settings.setting_key,value_text<br>)<sup>ƒ</sup>(افتراض: مفتاح غير موجود حاليا|UPSERT|حقل نسبة السقف لكل فرع|اإلعدادات|يضبط سقف خصم الكاشير|4|



صفحة23 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**)( . المسارات البديلةAlternative Flows7** • .تعطيل خصم دون حذف 

.)ق على الكل (افتراضMخصم بنطاق فارغ يطب 

• 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|<sup>قيمة الخصم غير صالحة</sup>|CHECK<br>علىvalue|قيمة غير موجبة|
|,اختر نسبة أو مبلغا|CHECK<br>علىdiscount_type|نوع خاطئ|
|النسبة ًال تتجاوز100|تحقق واجهة  ًا|نسبة أكبر من100<br>( )افتراض|



**)( . الصالحياتRLS9** . pricing.manage : القراءة مفتوحة، والكتابة discounts • • .) هذه الصالحية أو إعداد خاص MANAGER (افتراض: يلزم منح settings.manage : الكتابة settings **)( . ح الت الواجهةUI States10** 

|**السلوك**||**الحالة**|
|---|---|---|
||.هيكل|تحميل|
||.»«ًال خصومات|فارغًا|
||.على الحقل|خطأ|
||.<sup>,</sup>ظهور الخصم نشطا|نجاح|
||**(    تنفيذPostconditions**<br>**)**|**11**<br>**. النتيجة بعد ال**|



• .رى في الكاشيرNخصم نشط ي **)( . معايير القبولAcceptance Criteria12** .ف خصم لنطاق فإن يظهر للكاشير ضمن الخصومات المتاحةMعرN: عندما يS11-AC1 • .)منع (افتراضN: عندما يتجاوز خصم الكاشير السقف فإن يS11-AC2 • 

**13. مالحظات للمصمم** 

• settings قرارك: سقف خصم الكاشير من المدير — ال يوجد عمود له، فاقتراحي مفتاح في 

**): األطراف (زبائن وموردون وحدة4** 

**<mark>S12 — إدارة الزبائن</mark>** 

**1. رقم واسم السيناريو** S12 — إدارة الزبائن **)( . الدورActor2** ) parties.manage (إضافة سريعة، افتراض: يحتاج CASHIER و MANAGER 

**3. الهدف** 

.إضافة زبون وتحديد حد ائتمانه وقائمة أسعاره وعناوينه **)( . الشروط المسبقةPreconditions4** • . للقراءة parties.view للكتابة و parties.manage ذ يملكالمنف<sup>X</sup> 

صفحة24 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

##### **5. الجداول المستخدمة** 

|**األعمدة المهمة**|**الجدول**|
|---|---|
|party_type, name, phone, whatsapp, email, address, is_active|parties|
|party_id, customer_code, credit_limit, credit_limit_currency_id, default_price_list_id,|customers|
|is_active||
|customer_id, label, city, address, phone, is_default|customer_addresses|
|name, code, price_type|price_lists|



**)( . المسار األساسيMain Flow** 

**6** 

|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**الشاشة / الواجهة**|**ما يفعله المستخدم**|**الخطو**<br>**ة**|
|---|---|---|---|---|---|
|parties.name,phone,<br>customers.customer_code|SELECT|،بحث ب**ا**لسم/الهاتف، جدول (**ا**لسم<br>)الهاتف، الرصيد، الحالة|قائمة الزبائن|يفتح قائمة الزبائن|1|
|parties.party_type,name,<br>phone,whatsapp,email|—|،النوع (شخص/شركة)،**ا**لسم، الهاتف<br>واتساب، البريد|نموذج زبون|»يضغط «زبون جديد|2|
|customers.credit_limit,<br>credit_limit_currency_id,<br>default_price_list_id|SELECT<br>) (قوائم|حد**ا**لئتمان، عملته، قائمة األسعار<br>**ا**لفتراضية|نموذج زبون (قسم<br>)**ا**لئتمان|يحدد**ا**لئتمان والتسعير|3|
|customer_addresses.label,<br>city,address,is_default|INSERT|،التسمية، المدينة، العنوان، الهاتف<br>»«افتراضي|)نموذج زبون (العناوين|يضيف عناوين|4|
|parties,customers|INSERT (طرف ثم<br>)زبون|»زر «حفظ|نموذج زبون|يحفظ|5|



**)( . المسارات البديلةAlternative Flows7** • . دون تكرار الطرف<sup>P</sup> أيضا<sup>P</sup> ) يصبح زبوناطرف موجود (مورد مثال<sup>P</sup> 

• .) is_active = false ( تعطيل زبون 

• .إضافة سريعة من شاشة البيع: لسم والهاتف فقط **ا** 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|<sup>ً</sup><sup>**ا**لسم مطلوب</sup>|NOT NULL<br>علىparties.name|اسم فارغ|
|<sup>اختر شخصا, أو شركة</sup>|CHECK<br>علىparty_type|نوع طرف غير صالح|
|<sup>,الحد ًال يكون سالبا</sup>|CHECK<br>علىcredit_limit<br>( )افتراض|حد ائتمان سالب|
|<sup>العنوان مطلوب</sup>|NOT NULL<br>علىcustomer_addresses.address|عنوان فارغ|



**)( . الصالحياتRLS9** 

. parties.manage والكتابة parties.view : القراءة parties • ) والكتابة parties.view , sales.view , sales.create , accounting.view ( : القراءة customers • . parties.manage 

• parties.manage : الكتابة customer_addresses 

**)( . ح الت الواجهةUI States10** 

|**السلوك**||**الحالة**|
|---|---|---|
||.هيكل|تحميل|
||.»«ًال زبائن|فارغًا|
||.على الحقل|خطأ|
||.العودة للقائمة أو للفاتورة مع الزبون المختار|نجاح|



صفحة25 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**)( . النتيجة بعد التنفيذPostconditions11** 

• .طرف وزبون (وعناوين) جاهزون للبيع 

**)( . معايير القبولAcceptance Criteria12** 

customers وسجل مرتبط في parties حفظ زبون فإن ينشأ سجل فيN: عندما يS12-AC1 • .) في الفاتورة (افتراض<sup>P</sup> ختار تلقائياN فإن ي<sup>P</sup> سريعا<sup>P</sup> : عندما يضيف الكاشير زبوناS12-AC2 • 

**13. مالحظات للمصمم** 

.الهاتف هو مفتاح البحث األول 

.أظهر الرصيد الحالي وحد لسم **ا** لئتمان بجانب **ا** 

• 

• 

#### **<mark>S13 — إدارة الموردين</mark>** 

**1. رقم واسم السيناريو** S13 — إدارة الموردين **)( . الدورActor2** PURCHASER 

**3. الهدف** 

.إضافة مورد وشروط دفعه وعملته لفتراضية **ا )( . الشروط المسبقةPreconditions4** 

• purchasing.create أو parties.manage ذ يملكالمنف<sup>X</sup> 

##### **5. الجداول المستخدمة** 

||**األعمدة المهمة**|||**الجدول**||
|---|---|---|---|---|---|
|par|ty_type, name, pho|ne, whatsapp, email, add|ress, is_active|p|arties|
|party_id, company_name,|supplier_code, pay|ment_terms_days, defau|lt_currency_id,<br>is_active|sup|pliers|
||||code, symbol|curr|encies|
|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**أMain**<br>**)**<br>**الشاشة / الواجهة**|**(  ار األساسي Flow**<br>**ما يفعله المستخدم**|**. المس أ**<br>**الخطو**<br>**ة**|
|suppliers.company_name,<br>supplier_code,parties.phone|SELECT|،بحث، جدول (الشركة، الهاتف<br>)الرصيد|قائمة الموردين|يفتح قائمة الموردين|1|
|parties.name,<br>suppliers.company_name|—|،النوع،**ا**لسم، اسم الشركة، الهاتف<br>البريد|نموذج مورد|»يضغط «مورد جديد|2|
|suppliers.payment_terms_days,<br>default_currency_id|SELECT<br>) (قوائم|أيام السداد، العملة**ا**لفتراضية|نموذج مورد|يحدد شروط الدفع والعملة|3|
|parties,suppliers|INSERT|»زر «حفظ|نموذج مورد|يحفظ|4|



**6** 

**)( . المسارات البديلةAlternative Flows7** 

• .تحويل طرف قائم إلى مورد 

• .تعطيل مورد 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
||NOT NULLً**ا**لسم مطلوب|اسم فارغ|



صفحة26 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**)( . الصالحياتRLS9** 

• ) والكتابة parties.view , purchasing.view , accounting.view ( : القراءة suppliers .) parties.manage , purchasing.create ( 

**)( . ح الت الواجهةUI States10** 

**السلوك الحالة** تحميل.هيكل فارغ.»«ًال موردين خطأ.على الحقل نجاح.العودة للقائمة **)( . النتيجة بعد التنفيذPostconditions11** • .ال بشروط الدفعXمورد فع **)( . معايير القبولAcceptance Criteria12** .قترح عملته وتاريخ لستحقاق من شروطه **ا**<sup>N</sup> د مورد في فاتورة شراء فإن تMحدN: عندما يS13-AC1 • **13. مالحظات للمصمم** • .أظهر الرصيد المستحق للمورد في رأس الصفحة 

### **وحدة5: المبيعات ونقطة البيع** 

**<mark>S14 — فتح جلسة صندوق</mark>** 

**1. رقم واسم السيناريو** S14 — فتح جلسة صندوق **)( . الدورActor2** CASHIER **3. الهدف** .بدء وردية بيع على نقطة بيع برصيد افتتاحي لكل عملة **)( . الشروط المسبقةPreconditions4** • . وصالحية تشغيل على الفرع pos.session ) ويملك user_pos_terminals ( ن على نقطة بيعXالكاشير معي .) pos_session_assignment_guard : للكاشير على النقطة نفسها (افتراض OPEN ال جلسة • 

##### **5. الجداول المستخدمة** 

|**األعمدة المهمة**|**الجدول**|
|---|---|
|pos_terminal_id, cashier_user_id, opened_at, closed_at, status, notes|pos_sessions|
|pos_session_id, currency_id, opening_amount|pos_session_balances|
|name, code, cashbox_id, default_warehouse_id|pos_terminals|
|user_id, pos_terminal_id, is_default|user_pos_terminals|



صفحة27 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**)( . المسار األساسيMain Flow6** 

|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**الشاشة / الواجهة**|**ما يفعله المستخدم**|**الخطو**<br>**ة**|
|---|---|---|---|---|---|
|user_pos_terminals.pos_terminal_id,<br>is_default|SELECT|»زر «بدء وردية جديدة|لوحة الكاشير|»يختار «بدء وردية|1|
|pos_terminals.name,code|SELECT|نة له، النقطةfقائمة النقاط المعي<br>**ا**لفتراضية محددة|شاشة فتح جلسة|يختار نقطة البيع (إن<br>)تعددت|2|
|pos_session_balances.currency_id,<br>opening_amount|—|الة فيfحقل مبلغ لكل عملة فع<br>الصندوق|شاشة فتح جلسة|يدخل الرصيد**ا**لفتتاحي<br>لكل عملة|3|
|pos_sessions.status = OPEN,opened_at,<br>notes;pos_session_balances|ا   INSERT|»حقل مالحظات، زر «فتح الجلسة|شاشة فتح جلسة ا|يؤكد الفتح|4|
|—|—|—|شاشة البيع|يدخل شاشة البيع|5|



**)( . المسارات البديلةAlternative Flows7** 

.»عرض خيار «متابعة الجلسة الحاليةN: ي<sup>P</sup> الكاشير بجلسة مفتوحة مسبقا 

.»ن على نقطة بيعMعي<sup>N</sup> نة: رسالة «لم تXال نقطة معي 

• 

• 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|لديك جلسة مفتوحة على هذه النقطة|pos_session_assignment_guard(ERP22)|,جلسة مفتوحة مسبقا|
|,الرصيد ً**ا**لفتتاحي ًال يكون سالبا|CHECK<br>علىopening_amount|رصيد سالب|
|<sup>حالة الجلسة غير صالحة</sup>|CHECK<br>علىstatus|حالة غير صالحة|
|ًال تملك صالحية فتح الجلسات|ERP16 PERMISSION_DENIED|بال صالحية|



**)( . الصالحياتRLS9** . can_access_branch ) مع pos.session , pos.manage ( : القراءة والكتابة pos_sessions • . pos.manage أو pos.session : الكتابة pos_session_balances • • .: القراءة لصفوف المستخدم نفسه user_pos_terminals 

**)( . ح الت الواجهةUI States** 

**10** 

**السلوك الحالة** تحميل.هيكل لبطاقة النقطة فارغ.ًال نقاط معي•نة خطأ.تحت الحقل المخالف نجاح.»]انتقال لشاشة البيع وشريط «جلسة مفتوحة منذ [الوقت **)( . النتيجة بعد التنفيذPostconditions11** . بأرصدة افتتاحية OPEN جلسة • .) assert_session_open ( ال يتم أي بيع قبل جلسة مفتوحة • 

**)( . معايير القبولAcceptance Criteria12** . بصف رصيد لكل عملة OPEN نشأ جلسة<sup>N</sup> : عندما يؤكد الكاشير فإن تS14-AC1 • .: عندما يملك جلسة مفتوحة فإن ال يستطيع فتح ثانية على النقطة نفسهاS14-AC2 • 

**13. مالحظات للمصمم** 

• .) بأرقام ضخمة (شاشة لمس<sup>P</sup> كبيرالفتتاحي حقال<sup>P</sup> **ا** اجعل الرصيد • .عملة الصندوق األساسية أوال<sup>P</sup> 

صفحة28 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

#### **<mark>S15 — البحث عن صنف وإضافته للسلة</mark>** 

**1. رقم واسم السيناريو** S15 — البحث عن صنف وإضافته للسلة 

**)( . الدورActor2** 

CASHIER 

**3. الهدف** 

.إيجاد المتغير بالباركود أو لسم ورؤية سعره ورصيده في المستودع المسموح بالبيع منه **ا** 

**)( . الشروط المسبقةPreconditions4** 

.جلسة صندوق مفتوحة 

.للمتغير سعر في قائمة األسعار المستخدمة 

• 

• 

**5. الجداول المستخدمة** 

||**األعمدة المهمة**|||**الجدول**||
|---|---|---|---|---|---|
|sku, variant_na|me, product_id, size_id, p|roduct_color_id, is_|active|product_va|riants|
||variant_id, barc|ode, is_primary, is_|active|bar|codes|
|variant_id, price|_list_id, currency_id, am|ount, valid_from, v|alid_to|variant_|prices|
|variant_id, wa|rehouse_id, quantity_on|_hand, quantity_res|erved<br>**أMain Flo**<br>**)**|inventory_bal<br>**(  ار األساسي w**|ances<br><br>**. المس أ**|
|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**/ الشاشة**<br>**الواجهة**|**ما يفعله المستخدم**|**الخطو**<br>**ة**|
|barcodes.barcode,variant_id|SELECT|حقل بحث دائم التركيز، زر<br>)ماسح الكاميرا (موبايل|شاشة البيع|يمسح الباركود أو<br>يكتب للبحث|1|
|variant_prices.amount,currency_id|RPC<br>resolve_price(variant,<br>price_list, currency)|،بطاقة (اسم، لون، مقاس<br>)السعر، العملة|شاشة البيع|يظهر المتغير مع<br>سعره|2|
|inventory_balances.quantity_on_hand,<br>quantity_reserved|SELECT|شارة الكمية المتاحة، تنبيه<br>عند الصفر|شاشة البيع|يرى الرصيد المتاح|3|
|product_variants.sku|—|، الكمية-/+ أزرار|)شاشة البيع (السلة|يضيف للسلة|4|
|sales.doc_status = DRAFT|INSERT / SELECT<br>(<br>sales<br>بحالةDRAFT<br>)|زر «تعليق»، قائمة<br>»قة<sup>f</sup>«الفواتير المعل|شاشة البيع|ق الفاتورة أو<sup>f</sup>يعل<br>قة<sup>f</sup>يستأنف معل|5|



**6** 

**)( . المسارات البديلةAlternative Flows7** • . عند غياب الباركودلسم أو الـSKU بحث ب **ا** 

• .باركود غير معروف: رسالة وإمكانية بحث يدوي • .)منع إضافته (مع رسالة للمديرNمتغير بال سعر: ي 

• .قة من القائمة فتعود إلى السلة<sup>X</sup> لستئناف: اختيار فاتورة معل **ا** 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|عثر على الصنفsلم ي|ًال صف فيbarcodes|باركود غير معروف ًا|
|الرصيد غير كاف„ للصنف|ERP04 INSUFFICIENT_STOCKعند الترحيل|رصيد صفر|
|ًال يوجد سعر لهذا الصنف|ا  ًال صف فيvariant_prices|بال سعر ًا|
|هذا الصنف موقوف|product_variants.is_active = false|متغير غير نشط|



صفحة29 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**)( . الصالحياتRLS9** 

• .: القراءة مفتوحة product_variants barcodes variant_prices • ) مع inventory.view , accounting.view , reports.view ( : القراءة inventory_balances ؛ (افتراض: يلزم منح الكاشير إحدى هذه الصالحيات أو عرض الرصيد عبر can_access_warehouse .) v_stock_available 

**)( . ح الت الواجهةUI States** 

**10** 

**السلوك الحالة** تحميل.دو•ار صغير بجانب حقل البحث فارغ.»<sup>,</sup> «السلة فارغة — امسح صنفا خطأ.وميض أحمر مع صوت عند باركود مجهول نجاح.الصنف يضاف مع وميض أخضر **)( . النتيجة بعد التنفيذPostconditions11** .قة<sup>X</sup> معل DRAFT سلة جاهزة لإلتمام (في الذاكرة) أو فاتورة • 

**)( . معايير القبولAcceptance Criteria12** .ضاف الصنف للسلة بسعره الحاليNمسح باركود صالح فإن يN: عندما يS15-AC1 • .قة ويمكن استئنافها<sup>X</sup> ق الفاتورة فإن تظهر في قائمة المعل<sup>M</sup> علN: عندما يS15-AC2 • 

**13. مالحظات للمصمم** 

• .الباركود هو المسار األسرع: ال تضع النقرات في طريقه • .أزرار كبيرة للمس 

**<mark>) — إتمام البيع (دفع نقدي/متعددS16</mark>** 

**1. رقم واسم السيناريو** ) — إتمام البيع (دفع نقدي/متعددS16 **)( . الدورActor2** CASHIER 

**3. الهدف** 

.ترحيل الفاتورة واستالم الدفع بوسائل وعمالت متعددة مع إرجاع الباقي **)( . الشروط المسبقةPreconditions4** . وسلة فيها بنود OPEN جلسة • .)، افتراض finance.payments (  وصالحية قبض sales.post و sales.create الكاشير يملك • 

.) is_sellable ( مستودع البيع قابل للبيع • 

**5. الجداول المستخدمة** 

|**األعمدة المهمة**|**الجدول**|
|---|---|
|branch_id, pos_terminal_id, pos_session_id, customer_id, channel, invoice_number,<br>sale_date, currency_id, exchange_rate, subtotal, discount, tax, rounding_amount,<br>total_amount, doc_status, payment_status|sales|
|sale_id, variant_id, warehouse_id, quantity, list_price, unit_price, discount, tax_rate_id,<br>total_price|sale_items|
|party_id, branch_id, pos_session_id, payment_type, payment_context, status,<br>payment_date|payments|



صفحة30 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

||**األعمدة المهمة**|||**الجدول**||
|---|---|---|---|---|---|
|payment_id, finan|icial_account_id, currency_id<br>parent_line_id, pay|i , amount, direction, l<br>ment_method, excha|i    ine_type,<br>nge_rate|payment|_lines|
||||**أMain Fl**<br>**)**|**(  ار األساسي ow**|**6**<br>**. المس أ**|
|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**الشاشة / الواجهة**|**ما يفعله المستخدم**|**الخطو**<br>**ة**|
|sales.discount,<br>sale_items.discount,<br>sales.customer_id|—|اإلجمالي، حقل خصم، زر<br>اختيار زبون|)شاشة البيع (السلة|يراجع السلة ويضيف<br>) (ضمن السقف<sup>ƒ</sup>خصما|1|
|sales)DRAFT(,sale_items|INSERT|اإلجمالي المطلوب بعملة<br>الفاتورة، أزرار وسائل الدفع<br>،(نقد، بطاقة، تحويل، شيك<br>)محفظة|شاشة الدفع|»يضغط «دفع|2|
|payment_lines.payment_method,<br>currency_id,amount,<br>exchange_rate|INSERT|،سطر لكل (وسيلة، عملة، مبلغ<br>سعر صرف)، المتبقي يتحدث<br>ƒلحظيا|شاشة الدفع|يضيف أسطر دفع|3|
|payment_lines.line_type =<br>CHANGE_GIVEN,direction = OUT,<br>parent_line_id|INSERT|حقل «الباقي» بعملة قابلة<br>لالختيار|شاشة الدفع|يرى الباقي ويحدد عملته|4|
|sales.doc_status = POSTED,<br>payments.status = POSTED|RPCpost_sale(sale_id)ثم<br>post_payment(payment_id)|»زر «إتمام البيع|شاشة الدفع|يؤكد الدفع|5|
|sales.invoice_number,<br>invoice_code,total_amount|SELECT|إ،زر طباعة، مشاركة واتساب<br>»«بيع جديد|شاشة اإليصال|يطبع أو يرسل اإليصال|6   إ|



**)( . المسارات البديلةAlternative Flows7** 

. ← دفع جزئيS17 • • . فارغ) للبيع النقدي المباشر customer_id ( فاتورة بال زبون • price_exchange_rate طلبNعملة الفاتورة مختلفة عن عملة السعر: ي • .) أو تS20( حذف<sup>N</sup> DRAFT إلغاء قبل الترحيل: الفاتورة تبقى 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|ًال توجد جلسة مفتوحة|assert_session_open(ERP22)ًا|جلسة غير مفتوحة|
|]الرصيد غير كاف„ للصنف [ ً**ا**لسم|ERP04 INSUFFICIENT_STOCK|„رصيد غير كاف|
|المستودع غير قابل للبيع|ERP11 WAREHOUSE_NOT_SELLABLE|مستودع غير قابل للبيع|
|الفاتورة بال بنود|ERP22|فاتورة بال بنود|
|يلزم سعر الصرف لهذه العملة|ERP19 PRICE_RATE_REQUIRED|سعر صرف السعر مفقود|
|ًال تملك صالحية ترحيل المبيعات|ERP16 PERMISSION_DENIED|بال صالحية ترحيل|
|الفترة المحاسبية مغلقة|ERP08/ERP13|فترة مغلقة|



**)( . الصالحياتRLS9** 

) مع sales.create , sales.post ( ,...) والكتابة sales.view , sales.create , sales.post ( : القراءة sales • . can_access_branch(branch_id, true) • .) مع صالحية تشغيل على الفرع finance.payments , payment.cancel ( : الكتابة payment_lines و payments . sales.post يتحقق من post_sale ) SECURITY DEFINER ( الترحيل عبر • 

صفحة31 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**)( . ح الت الواجهةUI States10** 

|**السلوك**||**الحالة**|
|---|---|---|
||.زر «إتمام» معط<sup>•</sup>ل بدو•ار أثناء الترحيل|تحميل|
||.ًال يمكن فتح الدفع بسلة فارغة|فارغًا|
||.رسالة بالسبب مع بقاء السلة محفوظة|خطأ|
||.شاشة إيصال خضراء ورقم الفاتورة|نجاح|



**)( . النتيجة بعد التنفيذPostconditions11** • .) PARTIAL (أو PAID وحالة سداد POSTED فاتورة • POSTED ، ودفعة SALE_OUT حركة مخزون 

.)، وقيد محاسبي، وحركة صندوق (توليد تلقائي 

**)( . معايير القبولAcceptance Criteria12** payment_status = PAID ل الفاتورة وتصبحM يغطي اإلجمالي فإن ترح<sup>P</sup> : عندما يؤكد الكاشير دفعاS16-AC1 • . بالعملة المختارة CHANGE_GIVEN ل الباقي كسطرMسجN: عندما يزيد المدفوع عن اإلجمالي فإن يS16-AC2 • .ل الفاتورة وتبقى السلةM: عندما ال يتوفر رصيد فإن ال ترحS16-AC3 • 

**13. مالحظات للمصمم** 

• .)ن (أحمر ثم أخضر عند الصفرXشاشة الدفع: المتبقي بخط ضخم ملو • .وسائل الدفع كأزرار بأيقونات؛ العملة كشريحة تبديل • .ل بنفسه، فال مرحلة موافقةXقرارك: الكاشير ينشئ ويرح 

#### **<mark>S17 — بيع آجل أو بدفعة جزئية</mark>** 

**1. رقم واسم السيناريو** S17 — بيع آجل أو بدفعة جزئية 

**)( . الدورActor2** 

MANAGER و CASHIER 

**3. الهدف** 

. وإنشاء دين على زبون<sup>P</sup> د كلياMسد<sup>N</sup> تسجيل فاتورة ال ت 

**)( . الشروط المسبقةPreconditions4** 

• .) في الفاتورة customer_id ( زبون محدد 

.جلسة مفتوحة 

• 

**5. الجداول المستخدمة** 

|**األعمدة المهمة**|**الجدول**|
|---|---|
|customer_id, total_amount, due_date, doc_status, payment_status|sales|
|party_id, credit_limit, credit_limit_currency_id|customers|
|payment_id, sale_id, debt_currency_id, source_currency_id, settled_amount,|payment_allocations|
|source_amount, allocation_type||
|party_id, currency_id, entry_date, entry_type, debit, credit, source_type, source_id|party_ledger_entries|



صفحة32 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**)( . المسار األساسيMain Flow6** 

|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**الشاشة / الواجهة**|**ما يفعله المستخدم**|**الخطو**<br>**ة**|
|---|---|---|---|---|---|
|customers.credit_limit,<br>party_ledger_entries<br>) (الرصيد الحالي|SELECT|بحث الزبون، عرض الرصيد وحد<br>**ا**لئتمان|شاشة البيع|ƒيختار زبونا|1|
|customers.credit_limit<br>+  مقابل الرصيد<br>اإلجمالي|ا SELECT|)شريط تحذير أصفر (ال يمنع|شاشة البيع   ا|يرى تحذير**ا**لئتمان إن<br>تجاوز الحد|2|
|sales.due_date,<br>payment_lines.amount|INSERT|،المبلغ المدفوعdue_date|شاشة الدفع|يدخل دفعة جزئية أو ال<br>شيء، ويحدد تاريخ<br>**ا**لستحقاق|3    ا|
|sales.payment_status = UNPAIDأو<br>PARTIAL|RPCpost_sale|»زر «ترحيل كآجل/جزئي|شاشة الدفع|يؤكد|4|
|party_ledger_entries.entry_type =<br>SALE,debit|SELECT|سطر بيع مدين|كشف حساب الزبون|يظهر الدين في كشف<br>حساب الزبون|5|



**)( . المسارات البديلةAlternative Flows7** 

. ← تسديد الحق بسند قبضS30 • • فاتورة بال زبون ال يجوز أن تبقى بال سداد كامل. 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|حد•د زبونا<sup>,</sup>للبيع اآلجل|(تحقق واجهة )افتراض|زبون غير محدد لبيع آجل|
|تنبيه: تجاوز حد ً**ا**لئتمان|(تحذير فقط )قرارك|تجاوز ً**ا**لئتمان|
|الفاتورة بال بنود|ERP22|فاتورة بال بنود|



**)( . الصالحياتRLS9** 

- .) parties.view , sales.view , sales.create , accounting.view ( : القراءة customers • 

- — ) parties.view , accounting.view , finance.view , reports.view ( : القراءة party_ledger_entries • .) v_party_balances الكاشير بال هذه الصالحيات ال يرى الرصيد (افتراض: يلزم عرضه عبر .) finance.payments , payment.cancel ( : الكتابة payment_allocations • 

**)( . ح الت الواجهةUI States** 

**10** 

**السلوك الحالة** تحميل.دو•ار قرب الرصيد فارغ.زبون جديد برصيد صفر خطأ.على الحقل نجاح.إيصال يوضح المتبقي وتاريخ ًلستحقاٍق **ا )( . النتيجة بعد التنفيذPostconditions11** . party_ledger_entries دين على الزبون في • • .دX يعكس الجزئي أو غير المسد payment_status **)( . معايير القبولAcceptance Criteria12** ويظهر الدين بكشف payment_status = PARTIAL ل بيع بدفعة أقل من اإلجمالي فإن يصبحMرحN: عندما يS17-AC1 • .الحساب .منع البيعN: عندما يتجاوز الدين حد لئتمان فإن يظهر تحذير وال ي **ا** S17-AC2 • 

**13. مالحظات للمصمم** 

• . الفاتورة = الرصيد الجديد+ اعرض: الرصيد السابق • .التحذير أصفر وليس أحمر 

صفحة33 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

#### **<mark>لق جلسة الصندوق والجرد النقديS18 — إغ</mark> ا** 

**1. رقم واسم السيناريو** S18 — إغالق جلسة الصندوق والجرد النقدي **)( . الدورActor2** ) (أيهما MANAGER أو CASHIER 

**3. الهدف** 

.مطابقة النقد الفعلي مع المتوقع لكل عملة ثم إغالق الجلسة **)( . الشروط المسبقةPreconditions4** 

. OPEN جلسة • 

• reconcile.cash ذ يملكالمنف<sup>X</sup> 

.)منح للكاشير، افتراضN (الزم إلنشاء الجرد؛ ي 

**5. الجداول المستخدمة** 

||**األعمدة المهمة**|||**الجدول**||
|---|---|---|---|---|---|
||status, clos|ed_at, closed_by,|notes|pos_ses|sions|
|financial_account_id, pos_session_id,|i  count_date, expected_am<br>difference_amount, re|i   ount, counted_am<br>f ason, status, post|i    ount,<br>f   ed_at|cash_reconcili|ations|
|financial_account_id, transaction_typ|i e, direction, amount, curr<br>sourc|i    ency_id, pos_sessio<br>e_cash_reconciliati|fi<br>i     n_id,<br>on_id|inancial_transa|ictions|
||pos_session_id, curren|cy_id, opening_am|p<br>ount<br>**أMain Flo**<br>**)**|os_session_bal<br>**(  ار األساسي w**|ances<br><br>**. المس أ**|
|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**/ الشاشة**<br>**الواجهة**|**ما يفعله المستخدم**|**الخطو**<br>**ة**|
|pos_sessions.status|ا SELECT|»زر «إغالق الوردية|شاشة البيع ا|يضغط «إغالق<br>»الوردية|1 ا|
|pos_session_balances.opening_amount,<br>financial_transactions.amount|SELECT<br>)v_pos_session_summary(|،**ا**لفتتاحي، المبيعات<br>المقبوضات، المتوقع لكل<br>عملة|ملخص الوردية|يرى ملخص الجلسة|2|
|cash_reconciliations.counted_amount,<br>expected_amount,difference_amount|INSERT|، لكل عملةfعدZحقل مبلغ م<br>ƒيظهر الفرق لحظيا|شاشة الجرد<br>النقدي|الفعلي لكلfيدخل العد<br>عملة|3|
|cash_reconciliations.reason|—|حقلreason|شاشة الجرد<br>النقدي|يدخل سبب الفرق إن<br>جدZو|4|
|cash_reconciliations.status,posted_atد<sup>f</sup>؛ تول<br>حركةCASH_DIFFERENCE<br>) (قرارك<sup>ƒ</sup>تلقائيا|UPDATEstatus = POSTED|»زر «ترحيل الجرد|شاشة الجرد<br>النقدي|يؤكد الجرد|5|
|pos_sessions.status = CLOSED,closed_at,<br>closed_by|ا UPDATE|»زر «إغالق نهائي|ملخص الوردية ا|يغلق الجلسة|6|



**)( . المسار األساسيMain Flow6** 

**)( . المسارات البديلةAlternative Flows** 

**7** 

• .فرق صفر: ال حركة فرق • .)المدير يغلق جلسة كاشير نسي إغالقها (قرارك: أيهما يغلق • .تعدد العمالت: جرد لكل عملة، ال إغالق قبل ترحيلها كلها 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|رح‹ل لكل عملةsغلق الوردية قبل وجود جرد م<sup>s</sup>ًال ت|ERP12 POS_SESSION_NOT_RECONCILED|إغالٍق قبل الجرد|



صفحة34 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|<sup>المبلغ المعد• غير صالح</sup>|CHECK<br>علىcounted_amount|عد• سالبsمبلغ م|
|,الجلسة مغلقة مسبقا|ERP02 DOC_BAD_TRANSITION|إغالٍق جلسة مغلقة|
|ًال تملك صالحية الجرد النقدي|ERP16|بال صالحية|



**)( . الصالحياتRLS9** 

• ) والكتابة accounting.view , finance.view , reconcile.cash ( : القراءة cash_reconciliations 

reconcile.cash 

• .) مع الفرع pos.session , pos.manage ( : الكتابة pos_sessions • )؛ accounting.view , finance.view , reconcile.cash , reports.view ( : قراءة فقط financial_transactions .نشأ بالتريغر<sup>N</sup> ت 

**)( . ح الت الواجهةUI States** 

**10** 

**السلوك الحالة** تحميل.دو•ار على الملخص فارغ.(جلسة بال مبيعات ) ًلفتتاحي فقط **ا** خطأ.شريط يذكر العملة التي ينقصها جرد نجاح.ملخص نهائي قابل للطباعة **)( . النتيجة بعد التنفيذPostconditions11** . لكل عملة POSTED وجرد CLOSED جلسة • .جد فرقN إن و CASH_DIFFERENCE حركة • 

**)( . معايير القبولAcceptance Criteria12** .طلب سببN وي<sup>P</sup> عد¯ا يخالف المتوقع فإن يظهر الفرق فوراN م<sup>P</sup> : عندما يدخل الكاشير مبلغاS18-AC1 • .<sup>P</sup> تلقائيا CASH_DIFFERENCE نشأ حركة<sup>N</sup> ل الجرد بفرق فإن تMرحN: عندما يS18-AC2 • .غلق الجلسة<sup>N</sup> : عندما تبقى عملة بال جرد فإن ال تS18-AC3 • 

**13. مالحظات للمصمم** 

• .) (اختياري<sup>P</sup> ادات (فئات) تجمع المبلغ تلقائياXاعرض األوراق النقدية كعد • .الفرق: أخضر عند الصفر وأحمر غير ذلك 

#### **<mark>S19 — مرتجع مبيعات</mark>** 

**1. رقم واسم السيناريو** S19 — مرتجع مبيعات 

**)( . الدورActor2** MANAGER و CASHIER 

**3. الهدف** 

. للزبون<sup>P</sup> أو رصيدا<sup>P</sup> لة واستردادها نقداXإرجاع أصناف من فاتورة مرح 

**)( . الشروط المسبقةPreconditions4** . POSTED فاتورة بيع • . sales.return ذ يملكالمنف<sup>X</sup> • 

صفحة35 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

##### **5. الجداول المستخدمة** 

|**األعمدة المهمة**|**الجدول**|
|---|---|
|return_number, sale_id, customer_id, branch_id, warehouse_id, currency_id,<br>return_date, status, refund_method, refund_payment_id, subtotal, notes|sales_returns|
|sales_return_id, sale_item_id, variant_id, quantity, unit_refund_price, total_refund,<br>condition_type, return_reason, restock|sales_return_items|
|invoice_number, doc_status, total_amount, customer_id|sales|
|payment_type, status, payment_date|payments|



**)( . المسار األساسيMain Flow** 

**6** 

|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**الشاشة / الواجهة**|**ما يفعله المستخدم**|**الخطو**<br>**ة**|
|---|---|---|---|---|---|
|sales.invoice_number,sale_date,<br>customer_id|SELECT|بحث برقم الفاتورة/الباركود/الزبون|شاشة المرتجعات|يبحث عن الفاتورة|1|
|sale_items.quantity,<br>sales_return_items.quantity|SELECT|جدول بنود الفاتورة مع<br>وحقل كمية<sup>ƒ</sup>المباع/المرتجع سابقا<br>اإلرجاع|شاشة المرتجع<br>)(البنود|يختار البنود والكميات|2|
|sales_return_items.condition_type,<br>return_reason,restock|INSERT|قائمة الحالة (قابل<br>للبيع/تالف/معيب)، السبب، مفتاح<br>»«إعادة للمخزون|شاشة المرتجع<br>)(البنود|يحدد الحالة والسبب|3|
|sales_returns.refund_method|INSERT|أو رصيد للزبون<sup>ƒ</sup>خياران: نقدا|شاشة المرتجع<br>)(**ا**لسترداد|يختار طريقة**ا**لسترداد<br>)(الكاشير يقرر|4|
|sales_returns.status = POSTED,<br>refund_payment_id|RPC<br>post_sales_return<br>،<br>ومع النقد دفعةREFUND<br>لةYرحZم|»زر «ترحيل المرتجع|شاشة المرتجع|يؤكد|5|
|sales_returns.return_number,subtotal|SELECT|طباعة/مشاركة|إيصال المرتجع|يطبع إيصال المرتجع|6|



**)( . المسارات البديلةAlternative Flows7** 

• .)لة: المرتجع هو الطريق الوحيد (قراركXال توجد طريقة إلغاء لفاتورة مرح 

. تذهب لمستودع تالف/مرتجعات بدل المخزون القابل للبيع DAMAGED / DEFECTIVE أصناف • 

• .) (افتراض<sup>P</sup> محددا<sup>P</sup> ) يتطلب زبونا CUSTOMER_CREDIT ( رصيد الزبون 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|رح‹لةsفاتورة البيع األصلية غير م|ERP18 DOC_LINK_MISMATCH|فاتورة أصل غير مرح•لة|
|الكمية المرتجعة تتجاوز المباع|فحص فيpost_sales_return(ERP22)|كمية أكبر من المباع|
|ً**ا**لسترداد النقدي يتطلب دفعةREFUNDرح‹لةs م|ERP18|استرداد نقدي بال دفعة|
|المرتجع بال بنود|ERP22|مرتجع بال بنود|



**)( . الصالحياتRLS9** 

• . مع الفرع sales.return ,...) والكتابة sales.view , sales.return ( : القراءة sales_returns • . لدفعة لسترداد **ا** finance.payments : الكتابة payments 

**)( . ح الت الواجهةUI States10** 

|**السلوك**||**الحالة**|
|---|---|---|
||.هيكل البنود|تحميل|
||.ًال نتائج للبحث|فارغًا|
||.تلوين البند المخالف|خطأ|



صفحة36 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**السلوك الحالة** نجاح.إيصال مرتجع وشارة الطريقة **)( . النتيجة بعد التنفيذPostconditions11** • .)، وقيد/دفعة استرداد restock للمخزون (إن SALES_RETURN ، حركة POSTED مرتجع **)( . معايير القبولAcceptance Criteria12** . فإن يزداد رصيد المستودع restock رج• ع صنف قابل للبيع معN: عندما يS19-AC1 • .ل المرتجع قبل ترحيل دفعة لستردادMختار **ا** لسترداد النقدي فإن ال يرحN: عندما ي **ا** S19-AC2 • 

**13. مالحظات للمصمم** • .اعرض بنود الفاتورة كبطاقات قابلة للتحديد بنقرة • .أبرز خيار طريقة لسترداد كمفتاح من خيارين كبيرين **ا** 

#### **<mark>قة والمسودات</mark>**<sup>**[**</sup> **<mark>S20 — إدارة الفواتير المعل</mark>** 

**1. رقم واسم السيناريو** S20قة والمسودات<sup>X</sup> — إدارة الفواتير المعل **)( . الدورActor2** MANAGER و CASHIER 

**3. الهدف** 

.لغى<sup>N</sup> لة ال تM أن المرح<sup>P</sup> قة)، علما<sup>X</sup> ل (المعلMرح<sup>N</sup> استئناف أو حذف فاتورة بيع لم ت **)( . الشروط المسبقةPreconditions4** . من جلسة الكاشير نفسه DRAFT فاتورة • 

**5. الجداول المستخدمة** 

|**األعمدة المهمة**|**الجدول**|
|---|---|
|invoice_number, sale_date, customer_id, total_amount, doc_status, pos_session_id|sales|
|sale_id, variant_id, quantity, unit_price, total_price|sale_items|



**)( . المسار األساسيMain Flow6** 

|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**الشاشة / الواجهة**|**ما يفعله المستخدم**|**الخطو**<br>|
|---|---|---|---|---|---|
||||||**ة**|
|sales.invoice_number,<br>sale_date,total_amount,<br>doc_status|إSELECT|)جدول (الرقم، الوقت، الزبون، اإلجمالي|قة<sup>f</sup>قائمة الفواتير المعل    إ|»قة<sup>f</sup>يفتح «الفواتير المعل|1|
|sale_items.variant_id,<br>quantity,total_price|SELECT|بنود الفاتورة|قة<sup>f</sup>تفاصيل فاتورة معل|يعاين فاتورة|2|
|—|—|»زر «استئناف|شاشة البيع|يستأنفها|3|
|sales.doc_status|DELETE (أو<br>CANCELLED<br>)|زر «حذف المسودة» مع تأكيد|قة<sup>f</sup>تفاصيل فاتورة معل|أو يحذفها|4|



**)( . المسارات البديلةAlternative Flows7** 

CANCELLED ). (قرارك؛ مالحظة: القاعدة نفسها تسمح بـ 

• ( حال المستخدم إلى المرتجعNلة: ال يظهر زر إلغاء؛ يXفاتورة مرحS19 ).لمن يملك الصالحية فيجب إخفاؤه في الواجهة أو حجب الصالحية 

صفحة37 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

**رسالة للمستخدم القيد / القاعدة الحالة** ًال يجوز تعديل بنود مستند مرح•ل ERP03 DOC_ITEMS_LOCKED تعديل بنود مرح•لة انتقال غير مسموح ERP02 انتقال حالة غير مسموح **)( . الصالحياتRLS9** • . مع صالحية تشغيل على الفرع sales.create : الكتابة sale_items و sales • .لX يمنع تعديل المرح protect_posted_doc **)( . ح الت الواجهةUI States10 السلوك الحالة** تحميل.هيكل فارغ.»«ًال فواتير معلقة<sup>•</sup> خطأ.رسالة نجاح.اختفاء الفاتورة من القائمة **)( . النتيجة بعد التنفيذPostconditions11** • .مسودة محذوفة أو مستأنفة؛ ال أثر على المخزون أو الحسابات **)( . معايير القبولAcceptance Criteria12** .حذف مسودة فإن ال يتغير مخزون وال ينشأ قيد<sup>N</sup> : عندما تS20-AC1 • . فإن ال يظهر زر اإللغاء POSTED : عندما تكون الفاتورةS20-AC2 • **13. مالحظات للمصمم** • .اعرض مدة التعليق وفاتورة قديمة بلون تحذيري **وحدة6: المشترُيات** **<mark>) — إنشاء فاتورة شراء (مسودةS21</mark> 1. رقم واسم السيناريو** ) — إنشاء فاتورة شراء (مسودةS21 **)( . الدورActor2** PURCHASER **3. الهدف** .إدخال أصناف مورد وكلفها ومستودع لستالم قبل الترحيل **ا )( . الشروط المسبقةPreconditions4** • .الةXال وأصناف (متغيرات) فعXمورد فع • . وصالحية تشغيل على الفرع purchasing.create ذ يملكالمنف<sup>X</sup> **5. الجداول المستخدمة** 

|**األعمدة المهمة**|**الجدول**|
|---|---|
|supplier_id, branch_id, currency_id, exchange_rate, invoice_number, invoice_date,|purchase_invoices|
|due_date, subtotal, discount, tax, total_amount, doc_status, payment_status, notes||



صفحة38 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

||**األعمدة المهمة**|||**الجدول**||
|---|---|---|---|---|---|
|purchase_invoice_id, va<br>party_id, compa<br>**أ**|riant_id, wareho<br>tax_r<br>ny_name, paym<br>|use_id, quantity, unit_co<br>ate_id, tax_amount, total<br>ent_terms_days, default_<br>sku, variant_name<br>|st, discount,<br>_cost, notes<br>currency_id<br>, product_id<br>**أMain**<br>**)**<br>|purchase_invoice_<br>sup<br>product_va<br>**(  ار األساسي Flow**<br>|items<br>pliers<br>riants<br><br>**. المس أ**<br>|
|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**الشاشة / الواجهة**|**ما يفعله المستخدم**|**الخطو**<br>**ة**|
|purchase_invoices.invoice_number,<br>invoice_date,doc_status,<br>payment_status|SELECT|،جدول (الرقم، المورد، التاريخ<br>الحالة)، مرشحات|قائمة فواتير الشراء|يضغط «فاتورة شراء<br>»جديدة|1|
|suppliers.company_name,<br>payment_terms_days,<br>default_currency_id|SELECT|بحث مورد، التاريخ، رقم فاتورة<br>المورد، العملة، سعر الصرف، تاريخ<br>**ا**لستحقاق|نموذج فاتورة شراء<br>)(الرأس|يختار المورد|2|
|product_variants.sku;<br>purchase_invoice_items.quantity,<br>unit_cost,warehouse_id,discount,<br>tax_rate_id|SELECT /<br>INSERT|،بحث/باركود، الكمية، تكلفة الوحدة<br>المستودع، الخصم، الضريبة|نموذج فاتورة شراء<br>)(البنود|يضيف األصناف|3 أ|
|purchase_invoices.subtotal,discount,<br>tax,total_amount|—|،اإلجمالي الفرعي، الخصم، الضريبة<br>اإلجمالي|نموذج فاتورة شراء<br>)(الملخص|يراجع اإلجماليات|4 إ|
|purchase_invoices.doc_status =<br>DRAFT|INSERT|»زر «حفظ كمسودة|نموذج فاتورة شراء|يحفظ كمسودة|5|



**6** 

**)( . المسارات البديلةAlternative Flows7** 

• .تعديل المسودة بحرية قبل الترحيل 

• .حذف مسودة • .)نسخ فاتورة سابقة لمورد نفسه (افتراض: واجهة فقط 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|الكمية والتكلفة يجب أن تكونا موجبتين|CHECK<br>( على البنود )افتراض|كمية أو تكلفة غير صالحة|
|أكمل بيانات الفاتورة|NOT NULL|مورد أو مستودع فارغ|
|ًال يجوز تعديل بنود مستند مرح•ل|ERP03 DOC_ITEMS_LOCKED|تعديل فاتورة مرح•لة|
|<sup>سعر الصرف غير صالح</sup>|CHECK<br>علىexchange_rate|سعر صرف غير صالح|



**)( . الصالحياتRLS9** 

) مع purchasing.create , purchasing.post ( ,...) والكتابة 

• purchasing.view ( : القراءة purchase_invoices . can_access_branch(branch_id, true) 

**)( . ح الت الواجهةUI States10** 

|**السلوك**||**الحالة**|
|---|---|---|
||.هيكل|تحميل|
||.»<sup>,</sup>«ًال بنود — أضف صنفا|فارغ|
||.على الحقل/البند|خطأ|
||.»الفاتورة بحالة «مسودة|نجاح|



**)( . النتيجة بعد التنفيذPostconditions11** . بال أثر على المخزون أو الحسابات DRAFT فاتورة • 

صفحة39 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**)( . معايير القبولAcceptance Criteria12** . وال يتغير المخزون DRAFT حفظ نموذج صحيح فإن تنشأ فاتورة بحالةN: عندما يS21-AC1 • .مأل عملته وتاريخ استحقاقه من شروطه<sup>N</sup> فإن ت<sup>P</sup> : عندما يختار المستخدم مورداS21-AC2 • 

**13. مالحظات للمصمم** 

• .)البنود جدول قابل للتحرير بسرعة (لوحة المفاتيح • .أظهر مجموع التكلفة بعملة الفاتورة واألساسية 

**<mark>لم البضاعة</mark> ا** **<mark>S22 — ترحيل فاتورة شراء واست</mark> 1. رقم واسم السيناريو** S22 — ترحيل فاتورة شراء واستالم البضاعة **)( . الدورActor2** )ل بنفسه، قراركX (يرح PURCHASER **3. الهدف** .اعتماد الفاتورة لزيادة المخزون وتحديث التكلفة وتسجيل الدين أو الدفع **)( . الشروط المسبقةPreconditions4** . ببنود DRAFT فاتورة شراء • . purchasing.post ذ يملكالمنف<sup>X</sup> • 

##### **5. الجداول المستخدمة** 

|**األعمدة المهمة**|**الجدول**|
|---|---|
|doc_status, payment_status, total_amount, total_base, posted_at|purchase_invoices|
|variant_id, warehouse_id, movement_type, direction, quantity, unit_cost,<br>reference_type, reference_id|stock_movements|
|variant_id, warehouse_id, quantity_on_hand|inventory_balances|
|variant_id, currency_id, average_cost, last_purchase_cost|variant_costs|



**)( . المسار األساسيMain Flow6** 

|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**/ الشاشة**<br>**الواجهة**|**ما يفعله**<br>**المستخدم**|**الخطو**<br>**ة**|
|---|---|---|---|---|---|
|purchase_invoices.doc_status,<br>total_amount|SELECT|،بنود وإجماليات<br>»زر «ترحيل|تفاصيل<br>فاتورة الشراء|يفتح المسودة<br>ويراجعها|1|
|payments.payment_context =<br>ON_PURCHASE_RECEIPT<br>) (عند الدفع|—|خياران: «دفع عند<br>**ا**لستالم» أو «آجل<br>»)<sup>ƒ</sup>د الحقاYسدZ(ي<br>ختار عند كلZ(ي<br>)فاتورة|نافذة الترحيل|يختار طريقة<br>السداد|2|
|purchase_invoices.doc_status = POSTED,<br>posted_at|RPC<br>post_purchase_invoice(invoice_id)<br>+(<br>post_payment<br>) عند الدفع|زر «تأكيد<br>»الترحيل|نافذة الترحيل|يؤكد الترحيل|3|
|stock_movements.movement_type =<br>PURCHASE_IN;<br>inventory_balances.quantity_on_hand;<br>variant_costs.average_cost|SELECT|،»لةfشارة «مرح<br>رابط «حركات<br>»المخزون|تفاصيل<br>الفاتورة<br>)لةf(مرح|يرى النتيجة|4|



**)( . المسارات البديلةAlternative Flows7** 

.)( د بسند دفعMسدNل دين على المورد ويMسجNآجل: يS31 • 

صفحة40 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

.)، افتراض finance.payments (تحتاج ON_PURCHASE_RECEIPT نشأ دفعة بسياق<sup>N</sup> لستالم: ت **ا** دفع عند • .)( لة: ممنوع؛ العالج مرتجعXتعديل فاتورة مرحS23 • 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|]ًال يمكن ترحيل فاتورة حالتها [الحالة|ERP02 DOC_BAD_TRANSITION|ترحيل غيرDRAFT|
|الفاتورة بال بنود|ERP22|فاتورة بال بنود|
|الفترة المحاسبية مغلقة|ERP08/ERP13|فترة مغلقة/مقفلة|
|ًال تملك صالحية ترحيل المشتريات|ERP16|بال صالحية|
|(القيد المول<sup>‹</sup>د غير متوازن )خطأ إعداد حسابات|ERP07 JOURNAL_UNBALANCED|قيد غير متوازن|



**)( . الصالحياتRLS9** 

• .) مع الفرع purchasing.create , purchasing.post ( : الكتابة purchase_invoices • apply_stock_movement ) SECURITY : قراءة فقط؛ الكتابة عبر inventory_balances و stock_movements . DEFINER ( 

. فقط apply_purchase_cost : تتحدث من 

variant_costs • 

**)( . ح الت الواجهةUI States** 

**10** 

|**السلوك**||**الحالة**|
|---|---|---|
||.زر الترحيل معط<sup>•</sup>ل بدو•ار|تحميل|
||—|فارغ|
||.رسالة بالسبب مع بقاء المسودة|خطأ|
||.الفاتورة مرح•لة مع أثرها على المخزون|نجاح|
||**(    تنفيذPostconditions**<br>**)**|**11**<br>**. النتيجة بعد ال**|



**)( . النتيجة بعد التنفيذPostconditions** 

. POSTED فاتورة • • .ح، وقيد محاسبي وسطر في سجل الموردX لكل بند، ورصيد مزداد، وتكلفة بالمتوسط المرج PURCHASE_IN حركة 

**)( . معايير القبولAcceptance Criteria12** . بكمية كل بند في مستودعه quantity_on_hand ل فاتورة شراء فإن يزدادMرحN: عندما يS22-AC1 • .حX بالمتوسط المرج average_cost ل فإن يتحدثMرحN: عندما يS22-AC2 • .لة فإن ال يمكن تعديل بنودهاX: عندما تكون الفاتورة مرحS22-AC3 • 

**13. مالحظات للمصمم** 

.» صنفاY ل دينMسجN، وسي<sup>P</sup> ص األثر: «سيزداد المخزون بـXنافذة الترحيل تلخX • . costs.view عرض التكلفة لمن ال يملك<sup>N</sup> ال ت • 

**<mark>S23 — مرتجع مشتريات</mark>** 

**1. رقم واسم السيناريو** S23 — مرتجع مشتريات 

**)( . الدورActor2** PURCHASER ) purchasing.return ( 

**3. الهدف** 

.لة وتسوية القيمةXإرجاع بضاعة لمورد من فاتورة شراء مرح 

صفحة41 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**)( . الشروط المسبقةPreconditions4** 

. POSTED فاتورة شراء • • . في المستودع³رصيد كاف 

##### **5. الجداول المستخدمة** 

|**األعمدة المهمة**|**الجدول**|
|---|---|
|return_number, purchase_invoice_id, supplier_id, branch_id, warehouse_id, currency_id,<br>return_date, status, settlement_method, return_reason, refund_payment_id, subtotal|purchase_returns|
|purchase_return_id, purchase_invoice_item_id, variant_id, quantity, unit_cost, total_cost|purchase_return_items|
|invoice_number, supplier_id, doc_status|purchase_invoices|
|party_id, company_name|suppliers|



**)( . المسار األساسيMain Flow** 

**6** 

|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**الشاشة / الواجهة**|**ما يفعله المستخدم**|**الخطو**<br>**ة**|
|---|---|---|---|---|---|
|purchase_invoices.invoice_number,<br>supplier_id|SELECT|بحث برقم الفاتورة أو المورد|شاشة مرتجعات<br>المشتريات|يبحث عن الفاتورة|1|
|purchase_return_items.quantity,<br>unit_cost|SELECT / INSERT|بنود الفاتورة بالكمية<br>وحقل<sup>ƒ</sup>المشتراة/المرتجعة سابقا<br>كمية اإلرجاع|نموذج مرتجع شراء|يختار البنود والكميات|2|
|purchase_returns.return_reason,<br>settlement_method|INSERT|السبب، التسوية (رصيد دائن لدى<br>)المورد / استرداد نقدي|نموذج مرتجع شراء|يحدد السبب والتسوية|3|
|purchase_returns.status = POSTED|RPC<br>post_purchase_return|»زر «ترحيل المرتجع|نموذج مرتجع شراء|لfيرح|4|



**)( . المسارات البديلةAlternative Flows7** 

• .لة قبل الترحيلX مرح REFUND لسترداد النقدي يتطلب دفعة **ا** 

• .مرتجع جزئي على عدة دفعات 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|فاتورة الشراء األصلية غير مرح•لة|ERP18 DOC_LINK_MISMATCH|فاتورة أصل غير مرح•لة|
|الرصيد ًال يكفي لإلرجاع|ERP04 INSUFFICIENT_STOCK|„رصيد غير كاف|
|الكمية تتجاوز المشتراة|purchase_return_item_guard|كمية فوٍق المشتراة|
|ً**ا**لسترداد النقدي يتطلب دفعةREFUND مرح•لة|ERP18|استرداد نقدي بال دفعة|



**)( . الصالحياتRLS9** 

• مع purchasing.return ,...) والكتابة purchasing.view , purchasing.return ( : القراءة purchase_returns .الفرع 

**)( . ح الت الواجهةUI States10** 

|**السلوك**||**الحالة**|
|---|---|---|
||.هيكل|تحميل|
||.ًال فواتير مطابقة|فارغًا|
||.تلوين البند|خطأ|
||.مرتجع مرح•ل ورقمه|نجاح|



**)( . النتيجة بعد التنفيذPostconditions11** • . تنقص المخزون، وتسوية عند المورد PURCHASE_RETURN ، حركة POSTED مرتجع 

صفحة42 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**)( . معايير القبولAcceptance Criteria12** .ل مرتجع شراء فإن ينقص الرصيد بالكمية ويتغير حساب الموردMرحN: عندما يS23-AC1 • .رفض البندN: عندما تتجاوز الكمية المشتراة فإن يS23-AC2 • 

**13. مالحظات للمصمم** 

• .اعرض بنود الفاتورة األصلية كمرجع ثابت على جانب الشاشة 

**<mark>لحظات الموردS24 — م</mark> ا 1. رقم واسم السيناريو** S24 — مالحظات المورد **)( . الدورActor2** 

WAREHOUSE و PURCHASER 

**3. الهدف** 

.تسجيل مشكلة مع مورد (نقص، لون خاطئ، خطأ فاتورة) ومتابعتها حتى الحل 

**)( . الشروط المسبقةPreconditions4** 

• .)<sup>P</sup> مورد موجود (وفاتورة اختياريا • .)منح األمين األولN للكتابة (افتراض: ي parties.manage أو purchasing.create 

**5. الجداول المستخدمة** 

||**أعمدة المهمة**|**األ**||**الجدول**||
|---|---|---|---|---|---|
|sup|plier_id, purchase_|invoice_id, type, note, statu|s, resolved_at|supplier_|notes|
|||company_name,|supplier_code|sup|pliers|
|||invoice_numbe|r, invoice_date|purchase_in|voices|
|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**أMain**<br>**)**<br>**الشاشة / الواجهة**|**(  ار األساسي Flow**<br>**ما يفعله المستخدم**|**. المس أ**<br>**الخطو**<br>**ة**|
|supplier_notes.type,note,<br>status|SELECT|قائمة بحالةOPEN/RESOLVED|ملف المورد (تبويب<br>)المالحظات|يفتح مالحظات المورد|1 ا|
|supplier_notes.supplier_id,<br>purchase_invoice_id,type,<br>note|INSERT|النوع، الفاتورة (اختياري)، النص|نموذج مالحظة|يضيف مالحظة|2 ا|
|supplier_notes.status =<br>RESOLVED,resolved_at|ا  UPDATE|ا»زر «تم الحل|قائمة المالحظات|يغلق مالحظة|3 ا|



**6** 

**)( . المسارات البديلةAlternative Flows7** 

• .تصفية بحسب الحالة 

• .)إعادة فتح مالحظة (افتراض 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|<sup>اكتب نص المالحظة</sup>|NOT NULL<br>علىnote|نص فارغ|
|,اختر نوعا, صحيحا|CHECK<br>علىtype|نوع غير صالح|



صفحة43 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**)( . الصالحياتRLS9** 

• ) والكتابة purchasing.view , parties.view ( : القراءة supplier_notes .) purchasing.create , parties.manage ( 

**)( . ح الت الواجهةUI States** 

**10** 

**السلوك الحالة** تحميل.هيكل فارغ.»«ًال مالحظات خطأ.على الحقل نجاح.المالحظة تظهر بحالة مفتوحة **)( . النتيجة بعد التنفيذPostconditions11** . RESOLVED أو OPEN لة بحالةXمالحظة مسج • **)( . معايير القبولAcceptance Criteria12** . RESOLVED وتنتقل لحالة resolved_at لMسجN مالحظة فإن يحل<sup>XN</sup> : عندما تS24-AC1 • **13. مالحظات للمصمم** • .)نة للنوع (نقص/لون/فاتورةXشارة ملو 

.)نة للنوع (نقص/لون/فاتورةXشارة ملو 

**وحدة7: المخزون** 

**<mark>S25 — عرض أرصدة المخزون وحركته</mark>** 

**1. رقم واسم السيناريو** S25 — عرض أرصدة المخزون وحركته **)( . الدورActor2** AUDITOR و MANAGER و WAREHOUSE **3. الهدف** 

.لستعالم عن الكميات المتاحة والمحجوزة وتتبع حركة صنف **ا** 

**)( . الشروط المسبقةPreconditions4** • . مع صالحية على المستودع reports.view أو accounting.view أو inventory.view صالحية 

**5. الجداول المستخدمة** 

|**األعمدة المهمة**|**الجدول**|
|---|---|
|variant_id, warehouse_id, quantity_on_hand, quantity_reserved|inventory_balances|
|variant_id, warehouse_id, movement_type, direction, quantity, unit_cost,<br>reference_type, reference_id, movement_date, notes|stock_movements|
|code, name, warehouse_type, branch_id|warehouses|
|sku, variant_name, product_id|product_variants|



صفحة44 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**)( . المسار األساسيMain Flow6** 

|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**/ الشاشة**<br>**الواجهة**|**ما يفعله**<br>**المستخدم**|**الخطو**<br>**ة**|
|---|---|---|---|---|---|
|inventory_balances.quantity_on_hand,<br>quantity_reserved;warehouses.name;<br>product_variants.sku|SELECT<br>)v_stock_available(|مرشحات (المستودع، المنتج، المتغير)، جدول<br>(<br>SKU<br>)، المستودع، المتوفر، المحجوز|شاشة أرصدة<br>المخزون|يفتح أرصدة<br>المخزون|1|
|inventory_balances.quantity_on_hand<br>مقابلvariant_reorder_levels.min_quantity|أ   أSELECT<br>)v_low_stock(|قائمة باألصناف تحت الحد األدنى|شاشة أرصدة<br>المخزون<br>(تبويب<br>)»«منخفض|يرى<br>األصناف<br>المنخفضة|2|
|stock_movements.movement_type,<br>direction,quantity,reference_type,<br>reference_id,movement_date|SELECT|سجل زمني: النوع،**ا**لتجاه، الكمية، المرجع|بطاقة حركة<br>الصنف|يفتح بطاقة<br>صنف|3|
|stock_movements.reference_type,<br>reference_id|SELECT|رابط من<br>reference_type/reference_id|المستند<br>المصدر|ينتقل للمستند<br>المصدر|4|



**)( . المسارات البديلةAlternative Flows7** 

• . للتحويالت المشحونة غير المستلمة v_stock_in_transit :المخزون في الطريق • .) (افتراض: واجهة تصدير إلىExcel 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|ًال تملك صالحية على هذا المستودع|can_access_warehouse|مستودع خارج الصالحية|
|الجدول لإلضافة فقط — صح•ح بحركة معاكسة|ERP05 APPEND_ONLY|محاولة تعديل حركة|
|||**9**<br>**( . الصالحياتRLS**<br>**)**|



• : قراءة فقط stock_movements و inventory_balances can_access_warehouse ) مع inventory.view , accounting.view , reports.view ( . warehouse.central.access المستودع المركزي (بال فرع) يتطلب • 

**)( . ح الت الواجهةUI States** 

**10** 

**السلوك الحالة** تحميل.هيكل فارغ.»«ًال حركات في الفترة خطأ.رسالة مع إعادة المحاولة نجاح— **)( . النتيجة بعد التنفيذPostconditions11** • .)ر (استعالمXال تغي **)( . معايير القبولAcceptance Criteria12** .عرض أرصدته المسموحة فقط<sup>N</sup> فإن ت<sup>P</sup> : عندما يختار المستخدم مستودعاS25-AC1 • . مع روابط للمستندات<sup>P</sup> : عندما يفتح بطاقة صنف فإن تظهر الحركات مرتبة زمنياS25-AC2 • 

**13. مالحظات للمصمم** 

• .شارة حمراء على أصناف تحت الحد األدنى • v_stock_movements_costs عبر costs.view التكلفة تظهر فقط لمن يملك 

صفحة45 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**<mark>S26 — إنشاء تحويل مخزون والموافقة عليه</mark>** 

**1. رقم واسم السيناريو** 

S26 — إنشاء تحويل مخزون والموافقة عليه 

**)( . الدورActor2** 

MANAGER (المرسل يوافق، قرارك) و WAREHOUSE 

**3. الهدف** 

.طلب نقل أصناف من مستودع إلى آخر وإقراره قبل الشحن 

**)( . الشروط المسبقةPreconditions4** 

.لن مختلفانXمستودعان فع **ا** 

• 

• . على المستودع المرسل inventory.transfer.approve وللموافقة inventory.transfer ذ يملكالمنف<sup>X</sup> 

**5. الجداول المستخدمة** 

|**األعمدة المهمة**|**الجدول**|
|---|---|
|transfer_number, from_warehouse_id, to_warehouse_id, status, requested_at,|stock_transfers|
|approved_at, approved_by, notes||
|stock_transfer_id, variant_id, quantity_requested, unit_cost, notes|stock_transfer_items|
|code, name, warehouse_type|warehouses|
|sku, variant_name|product_variants|



**)( . المسار األساسيMain Flow** 

**6** 

|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**الشاشة / الواجهة**|**ما يفعله المستخدم**|**الخطو**<br>**ة**|
|---|---|---|---|---|---|
|stock_transfers.transfer_number,<br>status|SELECT|ا،)جدول (الرقم، من، إلى، الحالة<br>مرشحات|قائمة التحويالت|»يضغط «تحويل جديد|1|
|warehouses.name,<br>from_warehouse_id,<br>to_warehouse_id|SELECT|،من مستودع، إلى مستودع<br>مالحظات|نموذج تحويل|يختار المستودعين|2|
|stock_transfer_items.variant_id,<br>quantity_requested|INSERT|أ   ،بحث/باركود، الكمية المطلوبة<br>عرض المتاح بالمرسل|أ )نموذج تحويل (البنود|يضيف األصناف والكميات|3 أ|
|stock_transfers.status = DRAFT|INSERT|زر حفظ|نموذج تحويل|يحفظ مسودة|4|
|stock_transfers.status = APPROVED,<br>approved_at,approved_by|RPC<br>approve_transfer/<br>cancel_transfer|»زر «موافقة» أو «إلغاء|تفاصيل التحويل|أمين المستودع المرسل<br>يوافق|5|



**)( . المسارات البديلةAlternative Flows7** 

.) cancel_transfer ( إلغاء التحويل قبل الشحن 

• 

• .التحويل المطلوب من مستودع آخر: طلب يوافق عليه أمين المرسل 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|المستودعان يجب أن يختلفا|CHECK/transfer_guard|المصدر = الوجهة|
|]انتقال غير مسموح للتحويل: [من] ← [إلى|ERP02 DOC_BAD_TRANSITION|انتقال غير مسموح|
|ًال تملك صالحية الموافقة على التحويل|ERP16|بال صالحية موافقة|
|الكمية يجب أن تكون موجبة|CHECK|كمية غير موجبة|



صفحة46 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**)( . الصالحياتRLS9** 

• : القراءة stock_transfers ) والكتابة inventory.transfer , inventory.transfer.approve , inventory.view , reports.view ( . can_access_warehouse ) مع inventory.transfer , inventory.transfer.approve ( . can_access_warehouse : تتبع stock_transfer_items • 

**)( . ح الت الواجهةUI States** 

**10** 

**السلوك الحالة** تحميل.هيكل فارغ.»«ًال تحويالت خطأ.على البند . بشارة خضراء APPROVED نجاح الحالة **)( . النتيجة بعد التنفيذPostconditions11** • . جاهز للشحن، بال أثر مخزني بعد APPROVED تحويل **)( . معايير القبولAcceptance Criteria12** . approved_by لMسج<sup>N</sup> وت APPROVED : عندما يوافق أمين المرسل فإن تصبح الحالةS26-AC1 • .لغى فإن ال يتأثر المخزونN: عندما يS26-AC2 • 

**13. مالحظات للمصمم** 

• .مخطط خطوات علوي: مسودة ← موافق ← بالطريق ← مستلم 

**<mark>لمه</mark> ا** **<mark>S27 — شحن التحويل واست</mark> 1. رقم واسم السيناريو** S27 — شحن التحويل واستالمه 

**)( . الدورActor2** ) (المرسل يشحن والمستلم يستلم WAREHOUSE 

**3. الهدف** 

.تسجيل الكميات المشحونة والمستلمة والتالفة والناقصة 

**)( . الشروط المسبقةPreconditions4** • . لالستالم IN_TRANSIT للشحن، أو APPROVED تحويل 

##### **5. الجداول المستخدمة** 

|**األعمدة المهمة**|**الجدول**|
|---|---|
|status, shipped_at, shipped_by, received_at, received_by|stock_transfers|
|stock_transfer_id, variant_id, quantity_requested, quantity_shipped, quantity_received,<br>quantity_damaged, quantity_missing|stock_transfer_items|
|variant_id, warehouse_id, movement_type, direction, quantity|stock_movements|
|variant_id, warehouse_id, quantity_on_hand|inventory_balances|



صفحة47 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**)( . المسار األساسيMain Flow6** 

|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**/ الشاشة**<br>**الواجهة**|**ما يفعله**<br>**المستخدم**|**الخطو**<br>**ة**|
|---|---|---|---|---|---|
|stock_transfer_items.quantity_requested|SELECT|»قائمة البنود، زر «شحن|تفاصيل<br>التحويل|أمين المرسل<br>ƒيفتح تحويال<br>عليه<sup>ƒ</sup>موافقا|1|
|stock_transfer_items.quantity_shipped,<br>stock_transfers.status = IN_TRANSIT|RPCship_transfer(id, items)|حقل<br>quantity_shippedلكل<br>)بند (افتراضي = المطلوب|نافذة الشحن|يدخل الكميات<br>المشحونة|2|
|stock_transfers.status|SELECT )v_stock_in_transit(|تحويالتIN_TRANSIT<br>إلى مستودعه|قائمة<br>الواردات|أمين المستلم<br>يفتح التحويل<br>بالطريق|3|
|quantity_received,quantity_damaged,<br>quantity_missing|RPCreceive_transfer(id,<br>items)|،لكل بند: المستلم، التالف<br>= الناقص (المجموع<br>)المشحون|نافذة<br>**ا**لستالم|يدخل المستلم<br>والتالف<br>والناقص|4|
|stock_movements.movement_type =<br>TRANSFER_OUT/TRANSFER_IN|<sup>SELECT</sup><br>)v_transfer_discrepancies(|حالةRECEIVED، الفروقات|تفاصيل<br>التحويل<br>)(مستلم|يراجع األثر|5 أ|



**)( . المسارات البديلةAlternative Flows7** 

.)راجع<sup>N</sup> إلى مستودع تالف/مرتجعات تابع للفرع (قرارك؛ آلية القاعدة غير مؤكدة، ت<sup>P</sup> التالف ينتقل تلقائيا 

.ل ويظهر في تقرير الفروقاتMسجNاستالم جزئي: الناقص ي 

• 

• 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|الكمية المشحونة تتجاوز المطلوبة|ERP22 INVALID_STATE|شحن أكثر من المطلوب|
|الرصيد غير كاف„ في المستودع المرسل|ERP04|رصيد غير كاف„ عند الشحن|
|الناقص يجب أن يساوي المشحون+  التالف+ المستلم|ERP22|مجموع ً**ا**لستالم ًال يطابق|
|انتقال غير مسموح للتحويل|ERP02|انتقال غير مسموح|



**)( . الصالحياتRLS9** 

• ) مع inventory.transfer , inventory.transfer.approve ( : التحديث stock_transfers . للمستودعين can_access_warehouse 

• .كتب عبر الدوال فقط<sup>N</sup> حركات المخزون ت 

**)( . ح الت الواجهةUI States10** 

|**السلوك**|**الحالة**|
|---|---|
|.دو•ار على الزر|تحميل|
|.»«ًال تحويالت بالطريق|فارغًا ا|
|.شريط فوٍق الجدول|خطأ ٍ|
|الحالةRECEIVED<br>. وملخص الفروقات|نجاح|
|**(    التنفيذPostconditions**<br>**)**<br>.لةX  المرسل عند الشحن، وزيادة عند**ا**لستالم (بحسب منطق الدالة)، وفروقات مسج|**1**<br>**. النتيجة بعد**<br>•<br>خصم من|



**11** 

**)( . معايير القبولAcceptance Criteria12** 

. ويظهر في «واردات» المستلم IN_TRANSIT شحن تحويل فإن تصبح حالتهN: عندما يS27-AC1 • .حسب ضمن المتوفر للبيع<sup>N</sup> وال ت quantity_damaged لMسج<sup>N</sup> ستلم بتالف فإن تN: عندما يS27-AC2 • 

**13. مالحظات للمصمم** 

.ن عند لختاللXشاشة **ا** لستالم: جدول بحقول رقمية كبيرة ومجموع ثابت أسفلها يتلو **ا** 

• 

صفحة48 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

#### **<mark>S28 — تسوية الجرد</mark>** 

**1. رقم واسم السيناريو** S28 — تسوية الجرد 

**)( . الدورActor2** MANAGER و WAREHOUSE 

**3. الهدف** 

.) الفعلي، دون موافقة إضافية (قراركXتصحيح الكميات بعد العد 

**)( . الشروط المسبقةPreconditions4** 

• . على المستودع inventory.adjust ذ يملكالمنف<sup>X</sup> 

##### **5. الجداول المستخدمة** 

|**األعمدة المهمة**|**الجدول**|
|---|---|
|adjustment_number, warehouse_id, adjustment_date, status, reason, approved_by,<br>posted_at, notes|stock_adjustments|
|stock_adjustment_id, variant_id, system_quantity, counted_quantity,<br>difference_quantity, unit_cost, notes|stock_adjustment_items|
|variant_id, warehouse_id, quantity_on_hand|inventory_balances|
|variant_id, warehouse_id, movement_type, direction, quantity|stock_movements|



**)( . المسار األساسيMain Flow6** 

|**الجدول واألعمدة**|**العملية على**<br>**القاعدة**|**عناصر الواجهة**|**الشاشة / الواجهة**|**ما يفعله المستخدم**|**الخطو**<br>**ة**|
|---|---|---|---|---|---|
|stock_adjustments.adjustment_number,<br>reason,status|SELECT|،جدول (الرقم، المستودع، السبب<br>)الحالة|قائمة التسويات|»يضغط «تسوية جديدة|1|
|stock_adjustments.warehouse_id,<br>adjustment_date,reason|INSERT|المستودع، التاريخ، السبب (تصحيح<br>)/تلف/فقد/موجود/أخرىfعد|نموذج تسوية|يختار المستودع<br>والسبب|2|
|inventory_balances.quantity_on_hand;<br>stock_adjustment_items.system_quantity,<br>counted_quantity,difference_quantity|SELECT /<br>INSERT|،)بحث/باركود، المتوقع (من النظام<br>المعدود، الفرق المحسوب|نموذج تسوية<br>)(البنود|يدخل الكميات المعدودة|3|
|stock_adjustments.status,posted_at|UPDATE<br>status =<br>POSTED|»زر «ترحيل|نموذج تسوية|ل التسويةfيرح|4|
|stock_movements.movement_type =<br>ADJUSTMENT_IN/ADJUSTMENT_OUT|SELECT|الحركات الناتجة|تفاصيل التسوية|يراجع األثر|5 أ|



**)( . المسارات البديلةAlternative Flows7** 

• .جرد جزئي لتصنيف أو رف 

• .إلغاء مسودة قبل الترحيل 

• .<sup>P</sup> متاح إن رغبت الحقا approved_by ال موافقة إلزامية (قرارك)، لكن عمود 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|<sup>اختر سببا, من القائمة</sup>|CHECK<br>علىreason|سبب غير صالح|
|الرصيد بعد التسوية سالب|ERP04 INSUFFICIENT_STOCK|رصيد سلبي بعد التسوية|
|انتقال غير مسموح|ERP02|انتقال حالة غير مسموح|
|الفترة المحاسبية مغلقة|ERP08/ERP13|فترة مغلقة|



صفحة49 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**)( . الصالحياتRLS9** 

• ) والكتابة accounting.view , inventory.adjust , inventory.view ( : القراءة stock_adjustments . can_access_warehouse مع inventory.adjust . can_access_warehouse : تتبع stock_adjustment_items • 

**)( . ح الت الواجهةUI States10** 

**السلوك الحالة** تحميل.هيكل فارغ.»«ًال تسويات خطأ.على البند نجاح.الفرٍق الصافي بعد الترحيل **)( . النتيجة بعد التنفيذPostconditions11** .) تعادل الفرق، والرصيد = المعدود، وقيد محاسبي (بحسب اإلعداد ADJUSTMENT_IN/OUT حركات • 

**)( . معايير القبولAcceptance Criteria12** 

. المتوقع ويظهر ملو¯نا− حسب الفرق = المعدودNدخل المعدود فإن يN: عندما يS28-AC1 • . للمعدود<sup>P</sup> ل التسوية فإن يصبح رصيد الصنف مساوياMرح<sup>N</sup> : عندما تS28-AC2 • 

**13. مالحظات للمصمم** 

. بالباركود: كل مسح يزيد المعدود بواحدXشاشة العد 

• . بالباركود: كل مسح يزيد المعدود بواحدXشاشة العد • .األصناف بفرق مقارنة بالمتوقع في أعلى القائمة 

#### **<mark>S29 — مستويات إعادة الطلب</mark>** 

**1. رقم واسم السيناريو** S29 — مستويات إعادة الطلب 

**)( . الدورActor2** 

PURCHASER و MANAGER 

**3. الهدف** 

.تحديد الحد األدنى وكمية الطلب لكل صنف ومستودع لتغذية تنبيهات المخزون المنخفض 

**)( . الشروط المسبقةPreconditions4** 

.الةXمتغيرات ومستودعات فع 

• 

**5. الجداول المستخدمة** 

||**األعمدة المهمة**|||**الجدول**||
|---|---|---|---|---|---|
|variant_|id, warehouse_|id, min_quantity, reorde|r_quantity|variant_reorder|_levels|
|||sku, var|iant_name|product_v|ariants|
||variant_id|, warehouse_id, quantit|y_on_hand<br>**أMain**<br>**)**|inventory_ba<br>**(  ر األساسي Flow**|lances<br><br>**. المسا أ**|
|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**الشاشة / الواجهة**|**ما يفعله المستخدم**|**الخطو**<br>**ة**|
|variant_reorder_levels.min_quantity,<br>reorder_quantity;|SELECT|( مرشح المستودع، جدولSKU<br>،<br>)المتوفر، الحد األدنى، كمية الطلب|شاشة مستويات الطلب|يفتح مستويات إعادة<br>الطلب|1<br>|
|inventory_balances.quantity_on_hand||||||



**6** 

صفحة50 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

|**العملية على القاعدة**<br>**الجدول واألعمدة**|**عناصر الواجهة**|**الشاشة / الواجهة**|**ما يفعله المستخدم**|**الخطو**<br>**ة**|
|---|---|---|---|---|
|UPSERT<br>variant_reorder_levels.variant_id,<br>warehouse_id,min_quantity,<br>reorder_quantity|تحرير داخل الخلية أو تعبئة<br>جماعية|شاشة مستويات الطلب|ل الحد لصنف أوfيعد<br>مجموعة|2|
|UPSERT<br>variant_reorder_levels|»زر «حفظ|شاشة مستويات الطلب|يحفظ|3|
||**A**<br>**)**<br>.)      ض|**lternative Flo**<br>ودع إلى آخر (افترا|**(  سارات البديلة ws**<br>نسخ الحدود من مست|**7**<br>**. الم**<br>•|
||**ا  Validati**<br>**)**|**ا  ons & Errors**|**(   الت الخطأ والتحقق**|**8**<br>**. ح ا**|
|**رسالة للمستخدم**|**القيد / القاعدة**||**الحالة**||
|min_qu<sup>القيمة ًال تكون سالبة</sup>|antity/reorder_quant|CHECK<br>علىity|لبة|قيمة سا|
|الحد موجود مسبقا<sup>,</sup>لهذا الصنف والمستودع||(قيد فريد )افتراض|( )متغير، مستودع|تكرار|
|inventory.vللقراءة<br>.)<sup>P</sup>احقا|: ة الجدول (افتراضiew<br>catalog<br>د ال<sup>M</sup>ؤك<sup>N</sup>للكتابة؛ ت|variant_r<br>: سياس<br>.manage/inv|**(  الحياتRLS**<br>**)**<br>eorder_levels<br>وentory.adjust|**9**<br>**. الصا**<br>•|



**)( . ح الت الواجهةUI States10** 

**السلوك الحالة** تحميل.هيكل فارغ.»حد‹د حدود<sup>s</sup> «لم ت خطأ.على الخلية . عند النقص v_low_stock نجاح تظهر في **)( . النتيجة بعد التنفيذPostconditions11** • .ي التنبيهاتثة تغذXحدود محد<sup>X</sup> **)( . معايير القبولAcceptance Criteria12** . فإن يظهر الصنف في قائمة المنخفض min_quantity : عندما ينخفض المتوفر عنS29-AC1 • **13. مالحظات للمصمم** • .تحرير مباشر في الجدول مع تلوين ما هو تحت الحد **وحدة8: المالية** **<mark>S30 — سند قبض من زبون وتخصيصه</mark> 1. رقم واسم السيناريو** S30 — سند قبض من زبون وتخصيصه **)( . الدورActor2** ) (افتراض CASHIER و ACCOUNTANT **3. الهدف** .استالم مبلغ من زبون وتخصيصه على فواتير مدينة أو كسلفة **)( . الشروط المسبقةPreconditions4** • .زبون عليه رصيد أو يريد دفع سلفة 

صفحة51 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

• .ال بعملة الدفعXحساب مالي فع • finance.payments ذ يملكالمنف<sup>X</sup> 

##### **5. الجداول المستخدمة** 

|**األعمدة المهمة**|**الجدول**|
|---|---|
|party_id, branch_id, pos_session_id, payment_type, payment_context, reason_id, status,<br>payment_date, reference_number, reversal_of_payment_id|payments|
|payment_id, financial_account_id, currency_id, amount, direction, line_type,<br>payment_method, exchange_rate, reference_number|payment_lines|
|payment_id, payment_line_id, party_id, sale_id, debt_currency_id, source_currency_id,<br>settled_amount, source_amount, exchange_rate, allocation_type|payment_allocations|
|name, type, currency_id, branch_id, is_active|financial_accounts|



**)( . المسار األساسيMain Flow** 

**6** 

|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**الشاشة / الواجهة**|**ما يفعله المستخدم**|**الخطو**<br>**ة**|
|---|---|---|---|---|---|
|payments.payment_date,<br>payment_type,status|SELECT|»جدول السندات، زر «سند قبض|قائمة السندات|»يضغط «سند قبض جديد|1|
|payments.party_id<br>; فواتيرsales<br>المفتوحة|SELECT<br>)v_open_documents<br>(|بحث زبون، عرض رصيده والفواتير<br>المفتوحة|نموذج سند قبض|يختار الزبون|2|
|payment_lines.payment_method,<br>financial_account_id,currency_id,<br>amount,exchange_rate|INSERT|،وسيلة الدفع، الحساب المالي، العملة<br>المبلغ، سعر الصرف|نموذج سند قبض<br>)(األسطر|يدخل أسطر القبض|3|
|payment_allocations.sale_id,<br>settled_amount,source_amount,<br>allocation_type (DEBT/ADVANCE)|INSERT|قائمة الفواتير بمبلغ التخصيص لكل<br>فاتورة، والباقي سلفة|نموذج سند قبض<br>)(التخصيص|يخصص المبلغ|4|
|payments.status = POSTED|RPC<br>post_payment(id)|»زر «ترحيل|نموذج سند قبض|لfيرح|5|



**)( . المسارات البديلةAlternative Flows7** 

.) ADVANCE_PAYMENT ( سلفة بال فواتير • 

• settled_amount / source_amount طلب سعر الصرف وحقالNقبض بعملة تختلف عن عملة الدين: ي . payment.cancel يتطلب reversal_of_payment_id عكس السند: سند جديد بـ • 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|اتجاه السطر ًال يناسب نوع الدفعة|ERP22 INVALID_STATE|اتجاه السطر ًال يناسب النوع|
|سج‹ل بعملة الدفع نفسها<sup>s</sup>السلفة ت|ERP10 CURRENCY_MISMATCH|عملة السلفة مختلفة|
|الحساب المالي غير فع•ال|ERP20 ACCOUNT_TYPE_INVALID|حساب غير فع•ال|
|السبب المختار ًال يصلح لهذه العملية|ERP17 REASON_MISMATCH|سبب ًال يصلح|
|الفترة المحاسبية مغلقة|ERP08/ERP13|فترة مغلقة|
|ًال تملك صالحية ترحيل الدفعات|ERP16|بال صالحية|



**)( . الصالحياتRLS9** 

• branch_id ) مع صالحية تشغيل على finance.payments , payment.cancel ( : الكتابة payments • .: نفس الصالحيتين مع الفرع payment_allocations و payment_lines • .,...) مع الفرع finance.view , finance.payments , pos.session ( : القراءة financial_accounts 

صفحة52 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**)( . ح الت الواجهةUI States10** 

|**السلوك**|**الحالة**|
|---|---|
|.هيكل|تحميل|
|.»سج‹ل كسلفةs«ًال فواتير مفتوحة — ي|فارغ ًا|
|.على السطر|خطأ|
|.السند مرح• ل وانخفاض ظاهر في رصيد الزبون|نجاح|
|**(    التنفيذPostconditions**<br>**)**|**11**<br>**. النتيجة بعد**|
|POS<br>، حركات فيfinancial_transactions<br>، وتحديثpayment_status<br>.صة وسجل الزبونM للفواتير المخص|•<br>سندTED|



**)( . معايير القبولAcceptance Criteria12** . payment_status = PAID ص قبض كامل على فاتورة فإن تصبحMخصN: عندما يS30-AC1 • .ل الباقي سلفةMسجN: عندما يزيد القبض عن الديون فإن يS30-AC2 • .نشأ سند عكسي مرتبط باألصلNعكس سند فإن يN: عندما يS30-AC3 • 

**13. مالحظات للمصمم** 

• . من األقدم لألحدث مع إمكانية التعديل<sup>P</sup> ع المبلغ تلقائياXوز • .اعرض الرصيد قبل وبعد 

**<mark>S31 — سند دفع لمورد</mark> 1. رقم واسم السيناريو** S31 — سند دفع لمورد **)( . الدورActor2** ACCOUNTANT 

**3. الهدف** 

.تسديد مبلغ لمورد وتخصيصه على فواتير الشراء المستحقة أو كسلفة **)( . الشروط المسبقةPreconditions4** • .مورد عليه رصيد • .) (افتراض³ال بالعملة وبرصيد كافXحساب مالي فع . • finance.payments ذ يملكالمنف<sup>X</sup> 

##### **5. الجداول المستخدمة** 

|**األعمدة المهمة**|**الجدول**|
|---|---|
|party_id, branch_id, payment_type, payment_context, reason_id, status, payment_date,<br>reference_number|payments|
|payment_id, financial_account_id, currency_id, amount, direction, payment_method,<br>exchange_rate|payment_lines|
|payment_id, purchase_invoice_id, party_id, debt_currency_id, source_currency_id,<br>settled_amount, source_amount, allocation_type|payment_allocations|
|name, type, currency_id, branch_id|financial_accounts|



صفحة53 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**)( . المسار األساسيMain Flow6** 

|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**/ الشاشة**<br>**الواجهة**|**ما يفعله المستخدم**|**الخطو**<br>**ة**|
|---|---|---|---|---|---|
|payments.payment_type =<br>SUPPLIER_PAYMENT|SELECT|»زر «سند دفع|قائمة السندات|يضغط «سند دفع<br>»جديد|1|
|purchase_invoices.due_date,payment_status|SELECT<br>)v_open_documents<br>(|بحث مورد، الفواتير<br>المستحقة وتواريخ استحقاقها|نموذج سند دفع|يختار المورد|2|
|payment_lines.direction = OUT,<br>financial_account_id,amount|INSERT|وسيلة، حساب مالي<br>،(صندوق/بنك)، عملة، مبلغ<br>سعر صرف|نموذج سند دفع<br>)(األسطر|يدخل أسطر الدفع|3|
|payment_allocations.purchase_invoice_id,<br>settled_amount|INSERT|مبلغ التخصيص لكل فاتورة<br>شراء|نموذج سند دفع<br>)(التخصيص|يخصص على<br>الفواتير|4|
|payments.status = POSTED|RPC<br>post_payment(id)|»زر «ترحيل|نموذج سند دفع|لfيرح|5|



**)( . المسارات البديلةAlternative Flows7** • .) ADVANCE_PAYMENT ( مة للموردXدفعة مقد • .حسب سعر الصرفNعملة الدفع تختلف عن عملة الفاتورة: ي . payment.cancel عكس الدفعة بسند • 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|اتجاه السطر ًال يناسب نوع الدفعة|ERP22|اتجاه السطر|
|المبلغ المخص‹ ص يتجاوز المستحق|payment_allocation_guard|تخصيص يتجاوز المستحق|
|الحساب المالي غير فع•ال|ERP20|حساب غير فع•ال|
|الفترة المحاسبية مغلقة|ERP08/ERP13|فترة مغلقة|



**)( . الصالحياتRLS9** 

) مع finance.payments , payment.cancel ( : الكتابة 

• payments / payment_lines / payment_allocations 

.صالحية الفرع 

**)( . ح الت الواجهةUI States10** 

|**السلوك**|**الحالة**|
|---|---|
|.هيكل|تحميل|
|.»«ًال فواتير مستحقة|فارغًا|
|.على السطر|خطأ|
|تحديثpayment_status<br>. للفواتير|نجاح|
|**(    تنفيذPostconditions**<br>**)**|**11**<br>**. النتيجة بعد ال**|
|PO<br>.<sup>P</sup>أو كليا<sup>P</sup>دة جزئياX، صرف من الحساب المالي، فواتير مسد|•<br>سندSTED|



**)( . معايير القبولAcceptance Criteria12** . payment_status ص دفع على فاتورة فإن ينخفض المستحق وتتحدثMخصN: عندما يS31-AC1 • . PARTIAL : عندما ال يغطي الدفع الفاتورة فإن تصبحS31-AC2 • 

**13. مالحظات للمصمم** 

.ب الفواتير بحسب لستحقاق وأبرز المتأخرة **ا**<sup>X</sup> رت 

• 

صفحة54 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**<mark>S32 — تسجيل مصروف</mark>** 

**1. رقم واسم السيناريو** S32 — تسجيل مصروف 

**)( . الدورActor2** 

) (مصروف صغير من الصندوق CASHIER ل) وX (ينشئ ويرح ACCOUNTANT 

**3. الهدف** 

.تسجيل مصروف تشغيلي من حساب مالي مع تصنيفه 

**)( . الشروط المسبقةPreconditions4** 

• .لنXفئة مصروف وحساب مالي فع **ا** • . ويعمل على الفرع finance.expenses ذ يملكالمنف<sup>X</sup> 

**5. الجداول المستخدمة** 

|**األعمدة المهمة**|**الجدول**|
|---|---|
|branch_id, expense_category_id, payee_party_id, reference_number, amount,<br>currency_id, exchange_rate, amount_base, financial_account_id, status, expense_date,<br>notes|expenses|
|name, code, gl_account_id, is_active|expense_categories|
|name, type, currency_id, branch_id|financial_accounts|
|financial_account_id, transaction_type, direction, amount, currency_id,<br>source_expense_id, transaction_date|financial_transactions|



**)( . المسار األساسيMain Flow6** 

|**الجدول واألعمدة**|**العملية على**<br>**القاعدة**|**عناصر الواجهة**|**الشاشة / الواجهة**|**ما يفعله المستخدم**|**الخطوة**|
|---|---|---|---|---|---|
|expenses.expense_date,amount,status|SELECT|،جدول (التاريخ، الفئة، المبلغ<br>)الحالة|قائمة المصروفات|يضغط «مصروف<br>»جديد|1|
|expense_categories.name;expenses.amount,<br>currency_id,financial_account_id,<br>reference_number|SELECT<br>) (قوائم|،)الفئة، المستفيد (اختياري<br>،المبلغ، العملة، الحساب المالي<br>رقم المرجع، المالحظات|نموذج مصروف|ئ البياناتfيعب|2|
|expenses.status|INSERT ثم<br>UPDATE<br>status =<br>POSTED|»زر «حفظ» وزر «ترحيل|نموذج مصروف|لfيحفظ ويرح|3|
|financial_transactions.source_expense_id,<br>direction = OUT|SELECT|رابط الحركة المالية|تفاصيل المصروف|يرى أثره|4|



**)( . المسارات البديلةAlternative Flows7** 

• .)مصروف الكاشير: الحساب المالي = صندوق جلسته ويظهر في جرد اإلغالق (قرارك، شرط سقف المبلغ مفتوح 

• .) لمن يملك الصالحية CANCELLED ( لXإلغاء مصروف مرح 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|<sup>,المبلغ يجب أن يكون موجبا</sup>|CHECK<br>علىamount<br>( )افتراض|مبلغ غير موجب|
|الحساب المالي غير فع•ال|ERP20|حساب غير فع•ال|
|الفترة المحاسبية مغلقة|ERP08/ERP13|فترة مغلقة|
|ًال تملك صالحية ترحيل المصروفات|ERP16|بال صالحية|



صفحة55 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**)( . الصالحياتRLS9** 

) والكتابة finance.view , finance.expenses , accounting.view , reports.view ( : القراءة expenses • . can_access_branch(branch_id, true) مع finance.expenses .) accounting.manage , finance.manage ( : الكتابة expense_categories • 

**)( . ح الت الواجهةUI States** 

**10** 

**السلوك الحالة** تحميل.هيكل فارغ.»«ًال مصروفات خطأ.على الحقل نجاح.»ظهور المصروف بحالة «مرح•ل **)( . النتيجة بعد التنفيذPostconditions11** . صادرة، وقيد مرتبط بحساب الفئة EXPENSE ، حركة POSTED مصروف • 

**)( . معايير القبولAcceptance Criteria12** .ل مصروف فإن ينقص رصيد الحساب المالي بالمبلغMرحN: عندما يS32-AC1 • . من صندوقه فإن ينعكس في المتوقع بجرد اإلغالق<sup>P</sup> ل الكاشير مصروفاX: عندما يسجS32-AC2 • 

**13. مالحظات للمصمم** 

• .)نقطة مفتوحة: سقف مبلغ مصروف الكاشير (ال عمود له • .) (غير موجود في القاعدة<sup>P</sup> أضف زر «إرفاق صورة اإليصال» الحقا 

**<mark>S33 — تحويل أموال بين الحسابات</mark> 1. رقم واسم السيناريو** S33 — تحويل أموال بين الحسابات **)( . الدورActor2** ACCOUNTANT ) finance.manage ( 

**3. الهدف** 

.نقل مبلغ بين صندوق وبنك أو بين عملتين مع سعر صرف فعلي 

**)( . الشروط المسبقةPreconditions4** 

.لن مختلفانXحسابان ماليان فع **ا** 

• 

**5. الجداول المستخدمة** 

|**األعمدة المهمة**||**الجدول**|
|---|---|---|
|from_account_id, to_account_id, from_amo<br>transfer_date, status, reason_type, re|unt, to_amount, exchange_rate,<br>ason_id, related_party_id, notes|money_transfers|
||name, type, currency_id|financial_accounts|
|financial_account_id, transaction_type,|i  direction, amount, currency_id,<br>source_money_transfer_id|financial_transactions|
||code, name, applies_to|payment_reasons|



صفحة56 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**)( . المسار األساسيMain Flow6** 

|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**الشاشة / الواجهة**|**ما يفعله المستخدم**|**الخطو**<br>**ة**|
|---|---|---|---|---|---|
|money_transfers.transfer_date,<br>from_amount,to_amount,status|ا     SELECT|ا )جدول (من، إلى، المبلغ، الحالة|قائمة التحويالت المالية|»يضغط «تحويل جديد|1|
|financial_accounts.name,type,<br>currency_id|SELECT|حساب المصدر وحساب الوجهة مع<br>أرصدتهما|نموذج تحويل مالي|يختار الحسابين|2|
|money_transfers.from_amount,<br>to_amount,exchange_rate|—|مبلغ الخروج، مبلغ الدخول، سعر<br>الصرف (مطلوب عند اختالف<br>)العملتين|نموذج تحويل مالي|يدخل المبالغ|3|
|payment_reasons.name;<br>money_transfers.reason_id,<br>related_party_id|SELECT|قائمة األسباب، الطرف المرتبط<br>(اختياري)، مالحظات|نموذج تحويل مالي|يحدد السبب|4|
|money_transfers.status|UPDATEstatus<br>= POSTED|»زر «ترحيل|نموذج تحويل مالي|لfيرح|5|



**)( . المسارات البديلةAlternative Flows7** • 

.خفى سعر الصرف ويتساوى المبلغانNتحويل بنفس العملة: ي 

• .إلغاء مسودة 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|الحسابان بعملتين مختلفتين: سعر الصرف الفعلي مطلوب|ERP15 TRANSFER_RATE_INVALID|عملتان مختلفتان بال سعر|
|الحسابان يجب أن يختلفا|money_transfer_guard|حساب المصدر = الوجهة|
|السبب المختار ًال يصلح لهذه العملية|ERP17|سبب ًال يناسب|
|الفترة المحاسبية مغلقة|ERP08/ERP13|فترة مغلقة|



**)( . الصالحياتRLS9** 

• ) والكتابة accounting.view , finance.manage , finance.view ( : القراءة money_transfers . finance.manage 

**)( . ح الت الواجهةUI States10** 

|**السلوك**|||**الحالة**|
|---|---|---|---|
||.هيكل||تحميل|
||.»«ًال تحويالت|ًا ا|فارغًا ا|
||.على الحقل||خطأ|
||.(حركتان )خروج ودخول||نجاح|
||**(    تنفيذPostconditions**<br>**)**|**ال**|**11**<br>**. النتيجة بعد**|
|financial<br>.، وقيد محاسبي|TRANSF<br>فيi_transactions||•<br>حركتاER|



**)( . معايير القبولAcceptance Criteria12** . to_amount ويزيد الوجهة بـ from_amount ل تحويل فإن ينقص حساب المصدر بـMرحN: عندما يS33-AC1 • .منع الترحيلN: عندما تختلف العملتان بال سعر فإن يS33-AC2 • 

**13. مالحظات للمصمم** 

• .اعرض المبلغ المكافئ بالعملة الثانية فور إدخال السعر 

صفحة57 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

#### **<mark>S34 — كشف حساب طرف وأرصدته</mark>** 

**1. رقم واسم السيناريو** S34 — كشف حساب طرف وأرصدته 

**)( . الدورActor2** AUDITOR و ACCOUNTANT 

**3. الهدف** 

.عرض حركة مديونية زبون أو مورد ورصيده بكل عملة 

**)( . الشروط المسبقةPreconditions4** • reports.view أو finance.view أو accounting.view أو parties.view صالحية 

**5. الجداول المستخدمة** 

|**األعمدة المهمة**|**الجدول**|
|---|---|
|party_id, currency_id, entry_date, entry_type, debit, credit, source_type, source_id|party_ledger_entries|
|party_type, name, phone|parties|
|code, symbol, decimal_places|currencies|



**)( . المسار األساسيMain Flow6** 

|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**/ الشاشة**<br>**الواجهة**|**ما يفعله المستخدم**|**الخطو**<br>**ة**|
|---|---|---|---|---|---|
|party_ledger_entries.party_id,<br>currency_id,debit,credit|SELECT<br>)v_party_balances(|تبويبات زبائن/موردين، جدول<br>)(الطرف، العملة، الرصيد|شاشة األرصدة|يفتح األرصدة|1 أ|
|party_ledger_entries.entry_date,<br>entry_type,debit,credit|SELECT|الفترة، العملة، األرصدة<br>**ا**لفتتاحي/الختامي|كشف حساب|ƒيختار طرفا|2|
|party_ledger_entries.source_type,<br>source_id|SELECT|رابط من<br>source_type/source_id<br>للمستند|كشف حساب|ƒيتتبع سطرا|3|
|sales/purchase_invoicesالمفتوحة|SELECT<br>)v_open_documents<br>(|دةfفواتير غير مسد|كشف حساب<br>)(مفتوحة|يرى المستندات<br>المفتوحة|4|
|—|—|أزرارPDF/Excel|كشف حساب|ر/يطبعfيصد|5|



**)( . المسارات البديلةAlternative Flows7** 

• .رصيد بعدة عمالت: تبويب لكل عملة 

.)... OPENING SALE PAYMENT ADJUSTMENT ( تصفية نوع القيد • 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|ًال تملك صالحية عرض األرصدة|ا ا سياسةparty_ledger_entries|بال صالحية|
|ًال حركات في الفترة|نتيجة فارغة|فترة بال حركات|



**)( . الصالحياتRLS9** 

• )؛ ت كتب<sup>N</sup> parties.view , accounting.view , finance.view , reports.view ( : قراءة فقط party_ledger_entries .بالدوال 

**)( . ح الت الواجهةUI States10** 

|**السلوك**|**الحالة**|
|---|---|
||تحميل.هيكل للجدول|



صفحة58 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

||**السلوك**||**الحالة**<br>فارغ.»«ًال حركات|
|---|---|---|---|
||||خطأ.رسالة مع إعادة محاولة|
||||نجاح—|
|.       ورصيد ختامي بالعملة|يد افتتاحي وحركات|**Po**<br>**)**<br>**Acce**<br>**)**<br>وفترة فإن يظهر رص<sup>P</sup>طرفا<br>.فتح مستنده المصدرN  ي<br>.    ن بلونين هادئين|**11**<br>**( . النتيجة بعد التنفيذstconditions**<br>•<br>.)ر (استعالمXال تغي<br>**12**<br>**( . معايير القبولptance Criteria**<br>•<br>S34-AC1<br>: عندما يختار المستخدم<br>•<br>S34-AC2<br>فإن<sup>P</sup>: عندما يضغط سطرا<br>**13. مالحظات للمصمم**<br>•<br>الرصيد الجاري عمود ثابت؛ مدين/دائ|
||||**S35 — تسوية رصيد طرف**|
|||.ق<sup>X</sup>تتاحي) بسبب موث<br>**)**|**1. رقم واسم السيناريو**<br>S35 — تسوية رصيد طرف<br>**2**<br>**( . الدورActor**<br>**)**<br>ACCOUNTANT)balance.adjust(<br>**3. الهدف**<br>تعديل رصيد زبون أو مورد (إعفاء/تصحيح/اف<br>**4**<br>**( . الشروط المسبقةPreconditions**<br><br>•<br>ذ يملك<sup>X</sup>المنفbalance.adjust<br>.<br>**5. الجداول المستخدمة**|
|**أ مة**|**األعمدة المه**||**الجدول**|
|adjustment_number, party_id, currenc|y_id, side, amoun<br>status, r|t, reason_id, adjustm<br>eversal_of_id, posted_|balance_adjustments<br>ent_date,<br>at, notes|
||party_id, curren|cy_id, entry_type, de|party_ledger_entries<br>bit, credit|
|||code, name, a|payment_reasons<br>pplies_to|
|||name, p|parties<br>arty_type|
||||**6**<br>**( . المسار األساسيMain Flow**<br>**)**|
|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**الخطو**<br>**ة**<br>**ما يفعله المستخدم**<br>**الشاشة / الواجهة**|
|balance_adjustments.adjustment_number,<br>side,amount,status|SELECT|،جدول (الرقم، الطرف، الجانب<br>)المبلغ، الحالة|1<br>»يضغط «تسوية جديدة<br>قائمة تسويات<br>األرصدة|
|party_ledger_entries<br>) (الرصيد|SELECT|بحث طرف، العملة، رصيده<br>الحالي|2يختار الطرف والعملة<br>نموذج تسوية رصيد|
|balance_adjustments.side,amount,<br>reason_id,notes|SELECT /<br>INSERT|مدين/دائن، المبلغ، السبب<br>(أسباب نوع تسوية)، مالحظات|3يحدد الجانب والمبلغ<br>والسبب<br>نموذج تسوية رصيد|
|balance_adjustments.status,posted_at|UPDATEstatus =<br>POSTED|»زر «ترحيل|4لfيرح<br>نموذج تسوية رصيد|
|balance_adjustments.reversal_of_id|INSERT<br>)reversal_of_id(|»زر «عكس|5<br>)يعكس تسوية (اختياري<br>تفاصيل تسوية|



صفحة59 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**)( . المسارات البديلةAlternative Flows7** 

.نشئ تسوية جديدة مرتبطة وال يحذف األصلNالعكس ي 

• 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|,المبلغ يجب أن يكون موجبا|CHECK<br>علىamount|مبلغ غير موجب|
|السبب المختار ًال يصلح لهذه العملية|ERP17|سبب غير مناسب|
|الفترة المحاسبية مغلقة|ERP08/ERP13|فترة مغلقة|
|ًال تملك صالحية تسوية األرصدة|ERP16|بال صالحية|
|||**9**<br>**( . الصالحياتRLS**<br>**)**|



) accounting.view , parties.view , balance.adjust , finance.view ( : القراءة balance_adjustments • . balance.adjust والكتابة 

**)( . ح الت الواجهةUI States** 

**10** 

**السلوك الحالة** تحميل.هيكل فارغ.»«ًال تسويات خطأ.على الحقل نجاح.تحديث رصيد الطرف **)( . النتيجة بعد التنفيذPostconditions11** • . في سجل الطرف وقيد ADJUSTMENT وسطر POSTED تسوية 

**)( . معايير القبولAcceptance Criteria12** .ل تسوية مدينة فإن يزداد مدين الطرف بالمبلغMرح<sup>N</sup> : عندما تS35-AC1 • .نشأ تسوية مضادة مرتبطة<sup>N</sup> عكس فإن ت<sup>N</sup> : عندما تS35-AC2 • 

**13. مالحظات للمصمم** 

• .اعرض الرصيد قبل/بعد في ملخص ثابت 

**<mark>لكS36 — سحوبات ومساهمات الم</mark> ا** 

**1. رقم واسم السيناريو** S36 — سحوبات ومساهمات المالك **)( . الدورActor2** ) finance.payments و owner.transactions ( ACCOUNTANT 

**3. الهدف** 

.تسجيل سحب مالك أو إيداعه برأس المال **)( . الشروط المسبقةPreconditions4** • .) نسبة+  (طرف owners ف فيXمالك معر . OWNER_CONTRIBUTION أو OWNER_WITHDRAWAL حساب مالي وسبب نوع • 

صفحة60 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

##### **5. الجداول المستخدمة** 

|**األعمدة المهمة**|**الجدول**|
|---|---|
|party_id, ownership_percentage, is_active|owners|
|party_id, branch_id, payment_type, reason_id, status, payment_date|payments|
|payment_id, financial_account_id, currency_id, amount, direction, payment_method|payment_lines|
|code, name, payment_type, gl_account_id|payment_reasons|



**)( . المسار األساسيMain Flow** 

**6** 

|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**الشاشة / الواجهة**|**ما يفعله المستخدم**|**الخطو**<br>**ة**|
|---|---|---|---|---|---|
|owners.ownership_percentage,<br>parties.name|SELECT|ا)جدول (**ا**لسم، النسبة، الحالة|قائمة المالك|يفتح المالك|1 ا|
|payments.payment_type,<br>party_id,reason_id|INSERT|النوع، المالك، السبب|نموذج حركة مالك|يضغط «سحب» أو<br>»«مساهمة|2|
|payment_lines.amount,<br>direction,financial_account_id|INSERT|المبلغ، العملة، الحساب المالي، وسيلة<br>الدفع|نموذج حركة مالك|يدخل المبلغ والحساب|3|
|payments.status = POSTED|RPC<br>post_payment|»زر «ترحيل|نموذج حركة مالك|لfيرح|4|



**)( . المسارات البديلةAlternative Flows7** 

.إضافة مالك جديد 

• 

• .تعديل النسبة 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|<sup>النسبة غير صالحة</sup>|CHECK<br>علىownership_percentage|نسبة خارج0<br>–<br>100|
|السبب المختار ًال يصلح لهذه العملية|ERP17|سبب ًال يناسب|
|اتجاه السطر ًال يناسب نوع الدفعة|ERP22|اتجاه خاطئ|



**)( . الصالحياتRLS9** 

owner.transactions ) والكتابة owner.transactions , accounting.view ( : القراءة owners • . • payments : finance.payments 

**)( . ح الت الواجهةUI States10** 

|**السلوك**||**الحالة**|
|---|---|---|
||.هيكل|تحميل|
||.»«ًال مالك|فارغًا ا|
||.على الحقل|خطأ|
||.الحركة مرح•لة|نجاح|



**)( . النتيجة بعد التنفيذPostconditions11** 

.لة وقيد مرتبط بحساب السببXحركة مالك مرح 

• 

**)( . معايير القبولAcceptance Criteria12** 

.د على حساب المالكMقيNل سحب مالك فإن ينقص الحساب المالي ويMرحN: عندما يS36-AC1 • 

**13. مالحظات للمصمم** 

. بصيغة واضحة قبل الترحيل<sup>P</sup> شاشة حساسة: اطلب تأكيدا 

• 

صفحة61 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**<mark>S37 — إدارة البنوك والحسابات المالية</mark>** 

**1. رقم واسم السيناريو** S37 — إدارة البنوك والحسابات المالية **)( . الدورActor2** ACCOUNTANT ) finance.manage ( 

**3. الهدف** 

.تعريف بنك وحسابه وحسابات مالية (صندوق/بنك) بعمالتها 

**)( . الشروط المسبقةPreconditions4** 

.فةXالعمالت معر 

.)( فةXصناديق معرS05 

• 

• 

**5. الجداول المستخدمة** 

|**األعمدة المهمة**|**الجدول**|
|---|---|
|name, code, is_active|banks|
|bank_id, branch_id, currency_id, account_name, account_number, is_active|bank_accounts|
|name, type, currency_id, branch_id, cashbox_account_id, bank_account_id,<br>gl_account_id, is_active|financial_accounts|
|cashbox_id, currency_id, is_active|cashbox_accounts|



**)( . المسار األساسيMain Flow6** 

|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**/ الشاشة**<br>**الواجهة**|**ما يفعله المستخدم**|**الخطو**<br>**ة**|
|---|---|---|---|---|---|
|financial_accounts.name,<br>type,currency_id|SELECT<br>)v_financial_account_balances(|،جدول (**ا**لسم، النوع، العملة<br>)الفرع، الرصيد|قائمة الحسابات<br>المالية|يفتح الحسابات المالية|1|
|banks.name,code|INSERT|**ا**لسم، الرمز|نموذج بنك|ƒيضيف بنكا|2|
|bank_accounts.bank_id,<br>currency_id,account_name,<br>account_number|INSERT|البنك، الفرع، العملة، اسم<br>الحساب، رقمه|نموذج حساب بنكي|ƒ بنكياƒيضيف حسابا|3|
|financial_accounts.type,<br>cashbox_account_id,<br>bank_account_id,<br>gl_account_id|INSERT|( النوعCASH/BANK<br>،)<br>الربط بحساب صندوق أو حساب<br>بنكي، حساب دفتر األستاذ|نموذج حساب مالي|ƒ مالياƒينشئ حسابا|4|



**)( . المسارات البديلةAlternative Flows7** 

• .تعطيل حساب بدل حذفه 

• .كل حساب مالي مرتبط بمصدر واحد فقط: صندوق أو بنك 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|نوع الحساب ًال يطابق الصندوٍق/البنك المرتبط|ERP20 ACCOUNT_TYPE_INVALID|نوع حساب ًال يطابق الربط|
|عملة الحساب المالي يجب أن تطابق عملة مصدره|account_currency_guard|عملة مختلفة|
|رقم الحساب مستخدم|UNIQUE<br>( )افتراض|رقم حساب مكرر|



**)( . الصالحياتRLS9** 

.) finance.manage , masterdata.manage ( : الكتابة banks • • . مع الفرع finance.manage : الكتابة financial_accounts و bank_accounts 

صفحة62 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**)( . ح الت الواجهةUI States10** 

**السلوك الحالة** تحميل.هيكل فارغ.»«ًال حسابات خطأ.على الحقل نجاح.الحساب يظهر برصيد صفر **)( . النتيجة بعد التنفيذPostconditions11** • .حسابات مالية جاهزة للسندات والمصروفات **)( . معايير القبولAcceptance Criteria12** .نشأ حساب مالي فإن يظهر في قوائم السندات والمصروفات للفرع المعنيN: عندما يS37-AC1 • **13. مالحظات للمصمم** • .)اعرض الرصيد الحالي لكل حساب بطاقة (عملة وفرع 

**وحدة9: المحاسبة والتقارُير والرقابة** 

**<mark>S38 — دليل الحسابات المحاسبي</mark> 1. رقم واسم السيناريو** S38 — دليل الحسابات المحاسبي **)( . الدورActor2** ACCOUNTANT ) accounting.manage ( **3. الهدف** 

.بناء شجرة الحسابات وربط أحداث النظام بحساباتها **)( . الشروط المسبقةPreconditions4** . accounting.manage ذ يملكالمنف<sup>X</sup> • 

**5. الجداول المستخدمة** 

|**األعمدة المهمة**|**الجدول**|
|---|---|
|parent_id, code, name, account_type, normal_balance, is_postable, is_system, is_active|gl_accounts|
|mapping_key, branch_id, gl_account_id|gl_account_mappings|



||||**أMain F**<br>**)**|**(  ار األساسي low**|**6**<br>**. المس أ**|
|---|---|---|---|---|---|
|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**الشاشة / الواجهة**|**ما يفعله المستخدم**|**الخطو**<br>**ة**|
|gl_accounts.code,name,<br>account_type,parent_id|SELECT<br>)v_account_balances(|،شجرة قابلة للطي (الرمز،**ا**لسم<br>)النوع، الرصيد|دليل الحسابات|يفتح شجرة الحسابات|1|
|gl_accounts.parent_id,code,<br>account_type,normal_balance,<br>is_postable|INSERT|،األب، الرمز،**ا**لسم، النوع<br>»الطبيعة، «قابل للترحيل|نموذج حسابأ|ƒيضيف حسابا|2|
|gl_account_mappings.mapping_key,<br>branch_id,gl_account_id|UPSERT|)جدول (المفتاح، الفرع، الحساب|شاشة الربط المحاسبي|يربط األحداث بالحسابات|3 أ|



**)( . المسارات البديلةAlternative Flows7** 

• .تعطيل حساب بال حركة 

صفحة63 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

• .حذف<sup>N</sup> ) ال ت is_system ( حسابات النظام 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|,الحساب األب يجب أن يكون تجميعيا|ERP14 GL_PARENT_POSTABLE|أب قابل للترحيل|
|<sup>الرمز مستخدم</sup>|UNIQUE<br>علىcode|رمز مكرر|
|القيد يحوي حسابا<sup>,</sup>غير قابل للترحيل أو غير فع•ال|ERP09|حساب غير قابل للترحيل في قيد|



**)( . الصالحياتRLS9** 

• : القراءة gl_account_mappings و gl_accounts ) والكتابة accounting.view , accounting.manage , finance.view , finance.manage ( . accounting.manage **)( . ح الت الواجهةUI States10** 

**السلوك الحالة** تحميل.هيكل الشجرة فارغ.(«ًال حسابات» مع زر ًلستيراد )افتراض **ا** خطأ.على الحقل نجاح.الحساب يظهر تحت أبيه **)( . النتيجة بعد التنفيذPostconditions11** • .شجرة وربط جاهزان لتوليد القيود **)( . معايير القبولAcceptance Criteria12** .<sup>P</sup> نشأ حساب فرعي فإن يكون أبوه تجميعياN: عندما يS38-AC1 • .) ERP07 / ERP21 ( : عندما يغيب ربط حدث فإن يفشل توليد قيدهS38-AC2 • 

**13. مالحظات للمصمم** 

.)شجرة بالسحب واإلفالت لتغيير األب (اختياري 

• 

#### **<mark>S39 — عرض قيود اليومية وعكسها</mark>** 

**1. رقم واسم السيناريو** S39 — عرض قيود اليومية وعكسها 

**)( . الدورActor2** AUDITOR و ACCOUNTANT 

**3. الهدف** 

.) وعكس قيد عند الحاجة، دون قيد يدوي (قرارك<sup>P</sup> دة تلقائيا<sup>M</sup> مراجعة القيود المول 

**)( . الشروط المسبقةPreconditions4** • . للعكس accounting.post للعرض و accounting.view صالحية 

**5. الجداول المستخدمة** 

|**األعمدة المهمة**<br>entry_number, entry_date, fiscal_period_id, branch_id, description, source_type,|**الجدول**<br>journal_entries|
|---|---|
|source_id, status, reversal_of_id, posted_by, posted_at||



صفحة64 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

|**األعمدة المهمة**|**الجدول**|
|---|---|
|journal_entry_id, gl_account_id, party_id, currency_id, debit, credit, exchange_rate,<br>debit_base, credit_base, description|journal_entry_lines|
|code, name, account_type|gl_accounts|
|name, start_date, end_date, status|fiscal_periods|



**)( . المسار األساسيMain Flow** 

**6** 

|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**/ الشاشة**<br>**الواجهة**|**ما يفعله**<br>**المستخدم**|**الخطو**<br>**ة**|
|---|---|---|---|---|---|
|journal_entries.entry_number,<br>entry_date,status,source_type|SELECT|،مرشحات (الفترة، الفرع، المصدر<br>الحالة)، جدول|قائمة القيود|يفتح القيود|1|
|journal_entry_lines.gl_account_id,<br>debit,credit,debit_base,credit_base|SELECT|،رأس القيد وأسطره (الحساب، الطرف<br>مدين، دائن)، رابط المصدر|تفاصيل القيد|ƒيفتح قيدا|2|
|journal_entries.source_type,source_id|SELECT|رابط من<br>source_type/source_id|المستند المصدر|يتتبع المصدر|3|
|journal_entries.reversal_of_id,status =<br>REVERSED|RPC عكس (افتراض: دالة عامة<br>fتلف<br>erp.reverse_journal<br>)|»السبب، زر «عكس القيد|نافذة العكس|يعكس القيد|4|



**)( . المسارات البديلةAlternative Flows7** • .)ال شاشة قيد يدوي (قرارك 

• .عكس قيد في فترة مقفلة مرفوض 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|ًال تملك صالحية عكس القيود|ERP16|عكس بال صالحية|
|الفترة المحاسبية مغلقة|ERP08/ERP13|فترة مغلقة/مقفلة|
|القيد غير متوازن|ERP07|قيد غير متوازن|
|القيد يحتاج سطرين على األقل|ERP21 JOURNAL_TOO_FEW_LINES|قيد بسطر واحد|



**)( . الصالحياتRLS9** 

• ) مع accounting.view , accounting.manage , accounting.post ( : القراءة journal_entries . can_access_branch 

.) accounting.manage , accounting.post ( : الكتابة journal_entry_lines • 

**)( . ح الت الواجهةUI States10** 

|**السلوك**||**الحالة**|
|---|---|---|
||.هيكل|تحميل|
||.»«ًال قيود في الفترة|فارغًا|
||.رسالة|خطأ|
||.ظهور قيد عكسي مرتبط|نجاح|



**)( . النتيجة بعد التنفيذPostconditions11** 

• REVERSED ل واألصلXقيد عكسي مرح 

**)( . معايير القبولAcceptance Criteria12** .ربط باألصلNنشأ قيد معاكس بالقيم نفسها ويNعكس قيد فإن يN: عندما يS39-AC1 • . فإن يرى رابط مستند المصدر<sup>P</sup> : عندما يفتح مستخدم قيداS39-AC2 • 

صفحة65 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**13. مالحظات للمصمم** 

• . على القاعدة<sup>P</sup> ضاف الحقا<sup>N</sup> ) لعكس القيد؛ ت( ثغرة: ال توجد دالة عامةpublic 

**<mark>S40 — إدارة الفترات المحاسبية</mark> 1. رقم واسم السيناريو** S40 — إدارة الفترات المحاسبية **)( . الدورActor2** ) (يغلق ويقفل، قرارك ACCOUNTANT **3. الهدف** .<sup>P</sup> فتح فترة محاسبية وإغالقها ثم قفلها نهائيا **)( . الشروط المسبقةPreconditions4** . accounting.manage ذ يملكالمنف<sup>X</sup> • 

**5. الجداول المستخدمة** 

||**أعمدة المهمة**|**األ**||**الجدول**||
|---|---|---|---|---|---|
||name, start_da|te, end_date, status, close|d_by, closed_at|fiscal_p|ieriods|
|||entry_number, fiscal_p|ieriod_id, status|journal_e|ntries|
||||**أMain**<br>**)**|**(  ار األساسي Flow**|**6**<br>**. المس أ**|
|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**الشاشة / الواجهة**|**ما يفعله المستخدم**|**الخطو**<br>**ة**|
|fiscal_periods.name,<br>start_date,end_date,status|SELECT|)جدول (**ا**لسم، من، إلى، الحالة|قائمة الفترات المحاسبية|يفتح الفترات|1|
|fiscal_periods.name,<br>start_date,end_date|INSERT|**ا**لسم، التاريخان|نموذج فترة|ينشئ فترة|2|
|journal_entries.status,<br>fiscal_period_id|SELECT|عدد القيود حسب الحالة|تفاصيل الفترة|يراجع قيود الفترة غير<br>المرحلة|3|
|fiscal_periods.status =<br>CLOSED,closed_by,<br>closed_at|ا UPDATE|زر «إغالق» بتأكيد|تفاصيل الفترة|يغلق الفترة|4|
|fiscal_periods.status =<br>LOCKED|UPDATE|زر «قفل نهائي» بتأكيد مضاعف|تفاصيل الفترة|ƒيقفلها نهائيا|5|



**)( . المسارات البديلةAlternative Flows7** 

• . فقط) لمن يملك الصالحية CLOSED ( إعادة فتح فترة مغلقة 

• .فتح<sup>N</sup> المقفلة ال ت 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|تاريخ القيد خارج الفترة المحاسبية المحددة|ERP08 PERIOD_CLOSED|تاريخ قيد خارج الفترة|
|,الفترة المحاسبية مقفلة نهائيا|ERP13 PERIOD_LOCKED|فترة مقفلة|
|الفترة تتداخل مع أخرى|fiscal_period_guard|تداخل فترات|



صفحة66 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**)( . الصالحياتRLS9** 

) accounting.view , accounting.manage , finance.view , finance.manage ( : القراءة fiscal_periods • . accounting.manage والكتابة 

**)( . ح الت الواجهةUI States10** 

|**السلوك**||**الحالة**|
|---|---|---|
||.هيكل|تحميل|
||.»«ًال فترات|فارغًا|
||.شريط|خطأ|
||.الحالة الجديدة بشارة|نجاح|



**)( . النتيجة بعد التنفيذPostconditions11** 

.رفض<sup>N</sup> فترة بالحالة الجديدة؛ المستندات الالحقة بتاريخ الفترة ت 

• 

**)( . معايير القبولAcceptance Criteria12** .رفضNغلق فترة فإن ترحيل أي مستند بتاريخ ضمنها ي<sup>N</sup> : عندما تS40-AC1 • .قفل فإن ال يمكن إعادة فتحها<sup>N</sup> : عندما تS40-AC2 • 

**13. مالحظات للمصمم** 

• .قفل نهائي: نافذة تأكيد باللون األحمر واسم الفترة 

**<mark>S41 — تقارير المبيعات والمخزون</mark>** 

**1. رقم واسم السيناريو** S41 — تقارير المبيعات والمخزون **)( . الدورActor2** 

AUDITOR و ACCOUNTANT و MANAGER 

**3. الهدف** 

.عرض ملخصات المبيعات اليومية والمخزون المتاح والمنخفض وملخص الورديات 

**)( . الشروط المسبقةPreconditions4** • .)  (أو ما تقتضيه الـView reports.view صالحية 

**5. الجداول المستخدمة** 

|**أمدة المهمة**|**األع**|**الجدول**|
|---|---|---|
|sale_day, branch_id, channel, currenc<br>`...`|y_id, currency_code, invoices_count, total|v_sales_daily(View)|
|warehouse_id, warehouse_code, warehous|e_name, branch_id, is_sellable, variant_id,<br>sku, variant_name, product_name|v_stock_available(View)|
|warehouse_id, warehouse_name, variant_|id, sku, product_name, quantity_on_hand|v_low_stock(View)|
|pos_session_id, terminal_c|ode, branch_id, cashier_username, status|v_pos_session_summary<br>(View)|
||**أMain**<br>**)**|**6**<br>**( . المسار األساسي Flow**|
|**العملية على القاعدة**<br>**الجدول واألعمدة**|**الشاشة / الواجهة**<br>**عناصر الواجهة**|**الخطو**<br>**ة**<br>**ما يفعله المستخدم**|
|—<br>—|قائمة التقارير<br>بطاقات التقارير|1يفتح التقارير|



صفحة67 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**الشاشة / الواجهة**|**ما يفعله المستخدم**|**الخطو**<br>**ة**|
|---|---|---|---|---|---|
|v_sales_daily.sale_day,<br>invoices_count, اإلجمالي|SELECT|نطاق التاريخ، الفرع، القناة، العملة؛ رسم<br>جدول+|تقرير المبيعات اليومية|يختار مبيعات يومية|2|
|v_stock_available,<br>v_low_stock|SELECT|»المستودع، المنتج؛ تبويب «منخفض|تقرير المخزون|يختار المخزون<br>المتاح/المنخفض|3|
|v_pos_session_summary|SELECT|فرع/كاشير/تاريخ|تقرير الورديات|يختار ملخص الورديات|4|
|—|—|PDF/Excel|أي تقرير|رfيصد|5|
||||**Alternative**<br>**)**|**(  ارات البديلة Flows**|**7**<br>**. المس**|



**)( . المسارات البديلةAlternative Flows** 

• .تصفية بالفرع المسموح فقط • costs.view ال يرى التكلفة إال من يملك 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|ًال تملك صالحية هذا التقرير|سياسات الجداول األصلية|بال صالحية|
|قل<sup>•</sup>ص نطاٍق التاريخ|ٍ  (تحقق واجهة )افتراض|,نطاٍق كبير جدا|



**)( . الصالحياتRLS9** 

.، فتظهر للمستخدم أفرعه فقط can_access_branch / can_access_warehouse تقرأ من جداول ذات الـViews • 

**)( . ح الت الواجهةUI States10** 

|**السلوك**||**الحالة**|
|---|---|---|
||.هيكل للرسم والجدول|تحميل|
||.»«ًال بيانات في النطاٍق|فارغًا   ٍ|
||.رسالة مع إعادة المحاولة|خطأ|
||—|نجاح|
||**(    تنفيذPostconditions**<br>**)**|**11**<br>**. النتيجة بعد ال**|



.)ر (استعالمXال تغي 

• 

**)( . معايير القبولAcceptance Criteria12** .عرض إجماليات الفاتورة بحسب القناة والعملة<sup>N</sup> وفترة فإن ت<sup>P</sup> : عندما يحدد المستخدم فرعاS41-AC1 • . فإن ال يظهر التقرير reports.view : عندما ال يملكS41-AC2 • 

**13. مالحظات للمصمم** 

• .ستكمل عند التصميم النهائي<sup>N</sup> الظاهرة جزئية؛ ت مالحظة: أعمدة الـViews 

**<mark>لرصدةS45 — تقارير الحسابات وا</mark> أ** 

**1. رقم واسم السيناريو** S45 — تقارير الحسابات واألرصدة **)( . الدورActor2** 

AUDITOR و ACCOUNTANT 

**3. الهدف** 

.عرض أرصدة الحسابات واألطراف والحسابات المالية والمستندات المفتوحة 

صفحة68 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**)( . الشروط المسبقةPreconditions4** 

• reports.view أو finance.view أو accounting.view صالحية 

**5. الجداول المستخدمة** 

|**األعمدة المهمة**|**الجدول**|
|---|---|
|gl_account_id, code, name, account_type, normal_balance, parent_id,<br>is_postable, debit/credit totals|v_account_balances(View)|
|party_id, party_name, party_type, is_customer<br>`... ,`|v_party_balances(View)|
|financial_account_id, name, type, branch_id, currency_id, currency_code<br>`... ,`|v_financial_account_balances<br>(View)|
|doc_type, doc_id, doc_number, branch_id, party_id, party_name,<br>currency_id<br>`... ,`|v_open_documents(View)|



**)( . المسار األساسيMain Flow** 

**6** 

|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**الشاشة / الواجهة**|**ما يفعله المستخدم**|**الخطو**<br>**ة**|
|---|---|---|---|---|---|
|—|—|بطاقات|قائمة التقارير|يفتح تقارير الحسابات|1|
|v_account_balances.code,name,<br>account_type|SELECT|شجرة باألرصدة (مدين/دائن) ونطاق<br>تاريخ|تقرير أرصدة الحسابات|ميزان المراجعة|2|
|v_party_balances.party_name,<br>is_customer|SELECT|تبويبات زبائن/موردين، العملة|تقرير أرصدة األطراف|أرصدة األطراف|3 أ|
|v_financial_account_balances.name,<br>currency_code|SELECT|بطاقات لكل حساب|تقرير أرصدة الحسابات<br>المالية|أرصدة الصناديق والبنوك|4|
|v_open_documents.doc_type,<br>doc_number,party_name|SELECT|فواتير مفتوحة بتاريخ**ا**لستحقاق|تقرير المستندات<br>المفتوحة|المستندات المفتوحة<br>والمتأخرة|5|



**)( . المسارات البديلةAlternative Flows7** 

• .فلترة بالفرع 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**||**الحالة**|
|---|---|---|---|
|ًال تملك صالحية هذا التقرير||سياسات الجداول|بال صالحية|



**)( . الصالحياتRLS9** 

. مع الفرع reports.view و finance.view و accounting.view : تخضع لصالحيات جداولها كلView • 

**)( . ح الت الواجهةUI States10** 

|**السلوك**|**الحالة**|
|---|---|
||تحميل.هيكل|
||فارغ.»«ًال بيانات|
||خطأ.رسالة|
||نجاح—|



**)( . النتيجة بعد التنفيذPostconditions11** 

.)ر (استعالمXال تغي 

• 

**)( . معايير القبولAcceptance Criteria12** .عرض ميزان المراجعة فإن مجموع المدين يساوي مجموع الدائن بالعملة األساسيةN: عندما يS45-AC1 • 

صفحة69 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**13. مالحظات للمصمم** 

• .جدول ميزان المراجعة بشجرة قابلة للطي مع مجاميع ثابتة 

**<mark>S42 — سجل التدقيق</mark> 1. رقم واسم السيناريو** S42 — سجل التدقيق **)( . الدورActor2** SUPER_ADMIN و AUDITOR **3. الهدف** .تتبع من فعل ماذا ومتى، مع القيم قبل وبعد **)( . الشروط المسبقةPreconditions4** . audit.view ذ يملكالمنف<sup>X</sup> • 

**5. الجداول المستخدمة** 

||**أدة المهمة**|**األعم**||**الجدول**||
|---|---|---|---|---|---|
|user_id, action, entity|_type, entity_id, o|ld_values, new_values, ip_ad|dress, reason,<br>created_at|audi|t_logs|
|||us|ername, email||users|
|**أ**|||**أMain**<br>**)**<br>|**(  ار األساسي Flow**|**6**<br>**. المس أ**|
|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**الشاشة / الواجهة**|**ما يفعله المستخدم**|**الخطو**<br>**ة**|
|audit_logs.action,<br>entity_type,entity_id,<br>created_at|SELECT|مرشحات (المستخدم، اإلجراء، نوع<br>الكيان، التاريخ)، جدول|سجل التدقيق|يفتح سجل التدقيق|1|
|audit_logs.action|SELECT|( قائمة اإلجراءاتCREATE,<br>UPDATE, DELETE, POST,<br>CANCEL, APPROVE,<br>LOGIN, RATE_CHANGE,<br>MANUAL_OVERRIDE<br>)|سجل التدقيق  إ|ح بإجراء<sup>f</sup>يرش|2|
|audit_logs.old_values,<br>new_values,ip_address,<br>reason|SELECT|مقارنةold_values/<br>new_values<br>، الـIP، السبب|تفاصيل سجل|ƒيفتح سجال|3|
|audit_logs.entity_type,<br>entity_id|SELECT|رابط منentity_type/entity_id|الكيان المعني|ينتقل للكيان|4|



**)( . المسارات البديلةAlternative Flows7** 

• .تصدير نتائج التصفية 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**|**الحالة**|
|---|---|---|
|ًال تملك صالحية سجل التدقيق|audit.view|بال صالحية|
|السجل للقراءة فقط|(ًال سياسات كتابة )قراءة فقط|محاولة تعديلًا|



**)( . الصالحياتRLS9** • .)كتب بالتريغرN للمستخدم (ي ؛ الINSERT/UPDATE/DELETE audit.view فقط بـ audit_logs : SELECT 

صفحة70 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**)( . ح الت الواجهةUI States10** 

**السلوك الحالة** تحميل.هيكل فارغ.»«ًال سجالت خطأ.رسالة نجاح— **)( . النتيجة بعد التنفيذPostconditions11** • .)ر (استعالمXال تغي **)( . معايير القبولAcceptance Criteria12** . إلى جنب<sup>P</sup> : عندما يفتح المدقق سجل تعديل فإن يرى القيم قبل وبعد جنباS42-AC1 • .: عندما يحاول تعديل سجل فإن ال يتوفر أي زر تعديلS42-AC2 • **13. مالحظات للمصمم** • . ملو¯نا بين القيم<sup>P</sup> اعرض فرقا . بال أي صالحية كتابة في أي شاشة AUDITOR :نقطة • 

### **وحدة10: اإلشعارات** 

**<mark>لشعارات داخل التطبيقS44 — مركز ا</mark> إ 1. رقم واسم السيناريو** S44 — مركز اإلشعارات داخل التطبيق **)( . الدورActor2** )جميع األدوار (كل دور يرى ما يعنيه **3. الهدف** .)تنبيه المستخدم داخل التطبيق: مخزون منخفض، تحويل ينتظر موافقة، فاتورة مستحقة (قرارك **)( . الشروط المسبقةPreconditions4** • .)حسب من البيانات الحالية (افتراضNال يوجد جدول إشعارات في القاعدة؛ كل إشعار ي 

**5. الجداول المستخدمة** 

|**األعمدة المهمة**|**الجدول**|
|---|---|
|variant_id, warehouse_id, min_quantity|variant_reorder_levels|
|variant_id, warehouse_id, quantity_on_hand|inventory_balances|
|status, to_warehouse_id, from_warehouse_id|stock_transfers|
|supplier_id, due_date, payment_status, doc_status|purchase_invoices|



**)( . المسار األساسيMain Flow6** 

|**الجدول واألعمدة**|**العملية على القاعدة**|**عناصر الواجهة**|**الشاشة / الواجهة**|**ما يفعله المستخدم**|**الخطو**<br>**ة**|
|---|---|---|---|---|---|
|inventory_balances.quantity_on_hand,<br>variant_reorder_levels.min_quantity|SELECT<br>)v_low_stock(|ادfأيقونة جرس بعد|الشريط العلوي|يفتح التطبيق أو يضغط<br>جرس اإلشعارات|1|



صفحة71 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

|**واألعمدة**|**الجدول أ**|**العملية على القاعدة**|**عناصر الواجهة**|**الشاشة / الواجهة**|**ما يفعله المستخدم**|**الخطو**<br>**ة**|
|---|---|---|---|---|---|---|
|stoc<br>purchase|k_transfers.status =<br>DRAFT/APPROVED;<br>_invoices.due_date,|SELECT|إ،مجموعات: مخزون منخفض<br>تحويالت بانتظار الموافقة، فواتير<br>مستحقة|لوحة اإلشعارات|عةfيرى القائمة المجم|2|
||payment_status||||||
||—|—|رابط للشاشة المعنية<br>(<br>S25/S26/S22/S31<br>)|لوحة اإلشعارات|ƒيضغط إشعارا|3|



**)( . المسارات البديلةAlternative Flows7** 

• .)كل دور يرى مجموعاته فقط بحسب الصالحيات (الكاشير يرى مخزون الصالة فقط • .) في الجهاز<sup>P</sup> ن في القاعدة (افتراض: محلياMخز<sup>N</sup> حالة «مقروء» ال ت 

**)( . ح الت الخطأ والتحققValidations & Errors8** 

|**رسالة للمستخدم**|**القيد / القاعدة**||**الحالة**|
|---|---|---|---|
|تعذر تحميل اإلشعارات||انقطاع ً**ا**لتصال|فشل التحميل|
||||**9**<br>**( . الصالحياتRLS**<br>**)**|



• inventory_balances ) inventory.view ...(، stock_transfers :كل مجموعة تخضع لسياسة جدولها .) inventory.transfer ...(، purchase_invoices ) purchasing.view ...( 

**)( . ح الت الواجهةUI States10** 

|**السلوك**||**الحالة**|
|---|---|---|
||.دو•ار على الجرس|تحميل|
||.»«ًال إشعارات|فارغًا|
||.رسالة صغيرة مع إعادة محاولة|خطأ|
||—|نجاح|
||**(    تنفيذPostconditions**<br>**)**|**11**<br>**. النتيجة بعد ال**|



.)ر (قراءةXال تغي 

• 

**)( . معايير القبولAcceptance Criteria12** .: عندما ينخفض الرصيد عن الحد األدنى فإن يظهر إشعار «مخزون منخفض» لمن يملك صالحية العرضS44-AC1 • .نشأ تحويل بانتظار الموافقة فإن يظهر ألمين المستودع المرسلN: عندما يS44-AC2 • 

**13. مالحظات للمصمم** 

• .<sup>P</sup> (للقراءة/اإلرسال)؟ الحالي يحسبها حيا<sup>P</sup> الحقا<sup>P</sup> القرار خارج الوثيقة: هل تريد جدول إشعارات حقيقيا 

صفحة72 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

**4. الملحقات** 

**الملحق أ: مصفوفة األدوار والسينارُيوهات** 

.ذ ثانويلع أو منف<sup>X</sup> ذ رئيسي، ○ مط<sup>X</sup> ● منف<sup>X</sup> 

|**AUDITOR**|**PURCHAS**|**ACCOUNT**|**WAREHOU**|**CASHIER**|**MANAGER**|**SUPER**<br>|**السيناريو**|
|---|---|---|---|---|---|---|---|
|●|●|●|●|●|●|ا●|S01 تسجيل الدخول وتحميل الصالحيات|
|||||||●|S02 إنشاء مستخدم وتعيين دوره وفروعه|
|○||||||أ ا●|S03 إدارة األدوار وصالحياتها|
||||||○|●|S04 إدارة الفروع والمستودعات|
||||||●|●|S05 إعداد نقاط البيع والصناديق|
|○||●||||ا   إ●|S06 العمالت وأسعار الصرف واإلعدادات|
|●|●|●|●|●|●|ا  ●|S43 تفضيالت عرض العملة|
|○|●||●||●||S07<br>) إنشاء منتج (موديل|
||●||●||●||S08 إضافة األلوان والمقاسات والباركود<br>)(المتغيرات|
|○||○|||●||S09 تسعير المنتجات|
|○||●|||●||S10 تحديد تكلفة المنتج وتعديلها|
|||||○|●||S11 إدارة الخصومات|
|○||○||●|●||S12 إدارة الزبائن|
|○|●|○|||||S13 إدارة الموردين|
|||||●|●||S14 فتح جلسة صندوق|
|||||●|●||S15 البحث عن صنف وإضافته للسلة|
|○||||●|●||S16<br>) إتمام البيع (دفع نقدي/متعدد|
|||○||●|●||S17 بيع آجل أو بدفعة جزئية|
|○||○||●|ا    ●|ا|S18 إغالق جلسة الصندوق والجرد النقدي|
|○||○||●|●||S19 مرتجع مبيعات|
|||||●|●||S20قة والمسودات<sup>f</sup>إدارة الفواتير المعل|
|○|●|○|||○||S21<br>) إنشاء فاتورة شراء (مسودة|
|○|●|○|ا ○|ا|ا|ا|S22 ترحيل فاتورة شراء واستالم البضاعة|
|○|●|○|||||S23 مرتجع مشتريات|
|○|●||ا ●|ا|ا|ا|S24 مالحظات المورد|
|●|○|○|●||●||S25 عرض أرصدة المخزون وحركته|
|○|||●||○||S26 إنشاء تحويل مخزون والموافقة عليه|
|○|||●||ا○|ا|S27 شحن التحويل واستالمه|
|○||○|●||●||S28 تسوية الجرد|
||●||○||●||S29 مستويات إعادة الطلب|
|○||●||●|○||S30 سند قبض من زبون وتخصيصه|
|○|○|●|||||S31 سند دفع لمورد|
|○||●||●|○||S32 تسجيل مصروف|



صفحة73 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

|**AUDITOR**|**PURCHAS**|**ACCOUNT**|**WAREHOU**|**CASHIER**|**MANAGER**|**SUPER**|**السيناريو**|
|---|---|---|---|---|---|---|---|
|○||●|||||S33 تحويل أموال بين الحسابات|
|●|○|●|||○||S34 كشف حساب طرف وأرصدته|
|○||●|||||S35 تسوية رصيد طرف|
|○||●||||ا○|S36 سحوبات ومساهمات المالك|
|○||●|||||S37 إدارة البنوك والحسابات المالية|
|○||●|||||S38 دليل الحسابات المحاسبي|
|●||●||||○|S39 عرض قيود اليومية وعكسها|
|○||●|||||S40 إدارة الفترات المحاسبية|
|●||●|○||●||S41 تقارير المبيعات والمخزون|
|●||●|||أ○|أ|S45 تقارير الحسابات واألرصدة|
|●||||||●|S42 سجل التدقيق|
|○|●|●|●|○|●|إ  ○|S44 مركز اإلشعارات داخل التطبيق|



SUPER_ADMIN MANAGER CASHIER WAREHOUSE ACCOUNTANT PURCHASER AUDITOR :األعمدة بالترتيب 

### **الملحق ب: ربط السينارُيوهات بالجداول** 

|**الجداول**|**السيناريو**|
|---|---|
|users user_roles user_branch_access|S01 تسجيل الدخول وتحميل الصالحيات|
|users employees user_roles user_branch_access|S02 إنشاء مستخدم وتعيين دوره وفروعه|
|roles permissions role_permissions|S03 إدارة األدوار وصالحياتها|
|branches warehouses|S04 إدارة الفروع والمستودعات|
|pos_terminals cashboxes cashbox_accounts user_pos_terminals|S05 إعداد نقاط البيع والصناديق|
|currencies exchange_rates settings|S06 العمالت وأسعار الصرف واإلعدادات|
|display_preferences currencies|S43 تفضيالت عرض العملة|
|products product_types brands categories|S07<br>) إنشاء منتج (موديل|
|product_variants product_colors sizes barcodes|S08<br>) إضافة األلوان والمقاسات والباركود (المتغيرات|
|price_lists variant_prices products|S09 تسعير المنتجات|
|variant_costs cost_adjustments product_variants|S10 تحديد تكلفة المنتج وتعديلها|
|discounts discount_targets settings|S11 إدارة الخصومات|
|parties customers customer_addresses price_lists|S12 إدارة الزبائن|
|parties suppliers currencies|S13 إدارة الموردين|
|pos_sessions pos_session_balances pos_terminals user_pos_terminals|S14 فتح جلسة صندوق|
|product_variants barcodes variant_prices inventory_balances|S15 البحث عن صنف وإضافته للسلة|
|sales sale_items payments payment_lines|S16<br>) إتمام البيع (دفع نقدي/متعدد|
|sales customers payment_allocations party_ledger_entries|S17 بيع آجل أو بدفعة جزئية|
|pos_sessions cash_reconciliations financial_transactions pos_session_balances|S18 إغالق جلسة الصندوق والجرد النقدي|
|sales_returns sales_return_items sales payments|S19 مرتجع مبيعات|
|sales sale_items|S20قة والمسودات<sup>f</sup>إدارة الفواتير المعل|
|purchase_invoices purchase_invoice_items suppliers product_variants|S21<br>) إنشاء فاتورة شراء (مسودة|



صفحة74 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

|**الجداول**|**السيناريو**|
|---|---|
|purchase_invoices stock_movements inventory_balances variant_costs|S22 ترحيل فاتورة شراء واستالم البضاعة|
|purchase_returns purchase_return_items purchase_invoices suppliers|S23 مرتجع مشتريات|
|supplier_notes suppliers purchase_invoices|S24 مالحظات المورد|
|inventory_balances stock_movements warehouses product_variants|S25 عرض أرصدة المخزون وحركته|
|stock_transfers stock_transfer_items warehouses product_variants|S26 إنشاء تحويل مخزون والموافقة عليه|
|stock_transfers stock_transfer_items stock_movements inventory_balances|S27 شحن التحويل واستالمه|
|stock_adjustments stock_adjustment_items inventory_balances<br>stock_movements|S28 تسوية الجرد|
|variant_reorder_levels product_variants inventory_balances|S29 مستويات إعادة الطلب|
|payments payment_lines payment_allocations financial_accounts|S30 سند قبض من زبون وتخصيصه|
|payments payment_lines payment_allocations financial_accounts|S31 سند دفع لمورد|
|expenses expense_categories financial_accounts financial_transactions|S32 تسجيل مصروف|
|money_transfers financial_accounts financial_transactions payment_reasons|S33 تحويل أموال بين الحسابات|
|party_ledger_entries parties currencies|S34 كشف حساب طرف وأرصدته|
|balance_adjustments party_ledger_entries payment_reasons parties|S35 تسوية رصيد طرف|
|owners payments payment_lines payment_reasons|S36 سحوبات ومساهمات المالك|
|banks bank_accounts financial_accounts cashbox_accounts|S37 إدارة البنوك والحسابات المالية|
|gl_accounts gl_account_mappings|S38 دليل الحسابات المحاسبي|
|journal_entries journal_entry_lines gl_accounts fiscal_periods|S39 عرض قيود اليومية وعكسها|
|fiscal_periods journal_entries|S40 إدارة الفترات المحاسبية|
|v_sales_daily v_stock_available v_low_stock v_pos_session_summary|S41 تقارير المبيعات والمخزون|
|v_account_balances v_party_balances v_financial_account_balances<br>v_open_documents|S45 تقارير الحسابات واألرصدة|
|audit_logs users|S42 سجل التدقيق|
|variant_reorder_levels inventory_balances stock_transfers purchase_invoices|S44 مركز اإلشعارات داخل التطبيق|



### **)الملحق ج: قائمة الشاشات (بدون تكرار** 

|**السيناريوهات**||**الشاشة**||**#**|
|---|---|---|---|---|
||S01||شاشة تسجيل الدخول|1|
||S01||شاشة التحميل|2|
||S01||شاشة اختيار الفرع|3|
||S01||شاشة تغيير كلمة المرور|4|
||S01||لوحة التحكم|5|
||S02||قائمة المستخدمين|6|
||S02||نموذج مستخدم جديد|7|
||إS02|إ|شاشة تأكيد اإلنشاء|8  إ|
||أS03|أ|قائمة األدوار|9 أ|
||S03||تفاصيل الدور|10|
||اS03|ا|مصفوفة الصالحيات|11 ا|
||S04||قائمة الفروع|12|



صفحة75 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

|**السيناريوهات**|**الشاشة**|**#**|
|---|---|---|
|S04|نموذج فرع|13|
|S04|نموذج مستودع|14|
|S04|قائمة الفروع / المستودعات|15|
|S05|قائمة نقاط البيع|16|
|S05|نموذج صندوق|17|
|S05|نموذج نقطة بيع|18|
|S05|تعيين المستخدمين|19|
|اS06|قائمة العمالت|20 ا|
|S06|نموذج سعر صرف|21|
|S06|قائمة أسعار الصرف|22|
|إS06|شاشة اإلعدادات|23 إ|
|إ S43|اإلعدادات الشخصية|24إ|
|S07|قائمة المنتجات|25|
|S07|نموذج منتج|26|
|S08|تفاصيل المنتج|27|
|أS08|نافذة األلوان|28 أ|
|S08|نافذة المقاسات|29|
|S08|معاينة التوليد|30|
|S08|نافذة الباركود|31|
|S09|شاشة التسعير|32|
|S09|»نافذة «سعر الموديل|33|
|S10|شاشة التكلفة|34|
|S10|نافذة تعديل التكلفة|35|
|S10|سجل التكلفة|36|
|S11|قائمة الخصومات|37|
|S11|نموذج خصم|38|
|إS11|اإلعدادات|39إ|
|S12|قائمة الزبائن|40|
|S12|نموذج زبون|41|
|S13|قائمة الموردين|42|
|S13|نموذج مورد|43|
|S14|لوحة الكاشير|44|
|S14|شاشة فتح جلسة|45|
|S14 S15 S16 S17 S18 S20|شاشة البيع|46|
|S16 S17|شاشة الدفع|47|
|إS16|شاشة اإليصال|48 إ|
|S17|كشف حساب الزبون|49|
|S18|ملخص الوردية|50|
|S18|شاشة الجرد النقدي|51|
|S19|شاشة المرتجعات|52|
|S19|شاشة المرتجع|53|
|S19|إيصال المرتجع|54|
|S20|قة<sup>f</sup>قائمة الفواتير المعل|55|



صفحة76 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

|**السيناريوهات**|**الشاشة**|**#**|
|---|---|---|
|S20|قة<sup>f</sup>تفاصيل فاتورة معل|56|
|S21|قائمة فواتير الشراء|57|
|S21|نموذج فاتورة شراء|58|
|S22|تفاصيل فاتورة الشراء|59|
|S22|نافذة الترحيل|60|
|S22|تفاصيل الفاتورة|61|
|S23|شاشة مرتجعات المشتريات|62|
|S23|نموذج مرتجع شراء|63|
|S24|ملف المورد|64|
|اS24|نموذج مالحظة|65 ا|
|اS24|قائمة المالحظات|66 ا|
|S25|شاشة أرصدة المخزون|67|
|S25|بطاقة حركة الصنف|68|
|S25 S39|المستند المصدر|69|
|اS26|قائمة التحويالت|70 ا|
|S26|نموذج تحويل|71|
|S26 S27|تفاصيل التحويل|72|
|S27|نافذة الشحن|73|
|S27|قائمة الواردات|74|
|اS27|نافذة**ا**لستالم|75|
|S28|قائمة التسويات|76|
|S28|نموذج تسوية|77|
|S28|تفاصيل التسوية|78|
|S29|شاشة مستويات الطلب|79|
|S30 S31|قائمة السندات|80|
|S30|نموذج سند قبض|81|
|S31|نموذج سند دفع|82|
|S32|قائمة المصروفات|83|
|S32|نموذج مصروف|84|
|S32|تفاصيل المصروف|85|
|ا S33|قائمة التحويالت المالية|86 ا|
|S33|نموذج تحويل مالي|87|
|أS34|شاشة األرصدة|88 أ|
|S34|كشف حساب|89|
|أS35|قائمة تسويات األرصدة|90  أ|
|S35|نموذج تسوية رصيد|91|
|S35|تفاصيل تسوية|92|
|اS36|قائمة المالك|93 ا|
|S36|نموذج حركة مالك|94|
|S37|قائمة الحسابات المالية|95|
|S37|نموذج بنك|96|
|S37|نموذج حساب بنكي|97|
|S37|نموذج حساب مالي|98|



صفحة77 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

|**السيناريوهات**||**الشاشة**|**#**|
|---|---|---|---|
||S38|دليل الحسابات|99|
||S38|نموذج حساب|100|
||S38|شاشة الربط المحاسبي|101|
||S39|قائمة القيود|102|
||S39|تفاصيل القيد|103|
||S39|نافذة العكس|104|
||S40|قائمة الفترات المحاسبية|105|
||S40|نموذج فترة|106|
||S40|تفاصيل الفترة|107|
||S41 S45|قائمة التقارير|108|
||S41|تقرير المبيعات اليومية|109|
||S41|تقرير المخزون|110|
||S41|تقرير الورديات|111|
||S45|تقرير أرصدة الحسابات|112|
||أS45|تقرير أرصدة األطراف|113  أ|
||S45|تقرير أرصدة الحسابات المالية|114|
||S45|تقرير المستندات المفتوحة|115|
||S42|سجل التدقيق|116|
||S42|تفاصيل سجل|117|
||S42|الكيان المعني|118|
||S44|الشريط العلوي|119|
||إS44|لوحة اإلشعارات|120 إ|
|||: ات الفريدة120<br>.|عدد الشاش|



**الملحق د: جداول غير مستخدمة كجداول رئيسية** .)لم•ح إليه داخل السيناريوهات (مثل الضرائبN ال يظهر كجدول رئيسي في أي سيناريو، وبعضها ي جدوال119  من أصل<sup>P</sup> 45 

|**السبب المحتمل**|**الجدول**|
|---|---|
|.)جدول تقني ال يتعامل معه المستخدم مباشرة (مزامنة، ترقيم المستندات، رسائل األخطاء|sync_nodes|
|.)جدول تقني ال يتعامل معه المستخدم مباشرة (مزامنة، ترقيم المستندات، رسائل األخطاء|document_sequences|
|.)دار ضمن شاشة بيانات مرجعية الحقة (يلزم قرارyجدول مرجعي لخصائص المنتج؛ ي|units|
|.)دار ضمن شاشة بيانات مرجعية الحقة (يلزم قرارyجدول مرجعي لخصائص المنتج؛ ي|genders|
|.)دار ضمن شاشة بيانات مرجعية الحقة (يلزم قرارyجدول مرجعي لخصائص المنتج؛ ي|countries|
|.)دار ضمن شاشة بيانات مرجعية الحقة (يلزم قرارyجدول مرجعي لخصائص المنتج؛ ي|age_groups|
|.)دار ضمن شاشة بيانات مرجعية الحقة (يلزم قرارyجدول مرجعي لخصائص المنتج؛ ي|sports|
|.)دار ضمن شاشة بيانات مرجعية الحقة (يلزم قرارyجدول مرجعي لخصائص المنتج؛ ي|seasons|
|.)دار ضمن شاشة بيانات مرجعية الحقة (يلزم قرارyجدول مرجعي لخصائص المنتج؛ ي|collections|
|.)دار ضمن شاشة بيانات مرجعية الحقة (يلزم قرارyجدول مرجعي لخصائص المنتج؛ ي|materials|
|.)دار ضمن شاشة بيانات مرجعية الحقة (يلزم قرارyجدول مرجعي لخصائص المنتج؛ ي|fabric_types|
|.)دار ضمن شاشة بيانات مرجعية الحقة (يلزم قرارyجدول مرجعي لخصائص المنتج؛ ي|care_instructions|
|.)دار ضمن شاشة بيانات مرجعية الحقة (يلزم قرارyجدول مرجعي لخصائص المنتج؛ ي|tags|



صفحة78 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

|**السبب المحتمل**<br>.)دار ضمن شاشة بيانات مرجعية الحقة (يلزم قرارyجدول مرجعي لخصائص المنتج؛ ي|**الجدول**<br>colors|
|---|---|
|.دار ضمن شاشة بيانات مرجعية الحقةyإعداد أنظمة المقاسات؛ ي|size_systems|
|.دار ضمن شاشة بيانات مرجعية الحقةyإعداد أنظمة المقاسات؛ ي|size_groups|
|.دار ضمن شاشة بيانات مرجعية الحقةyإعداد أنظمة المقاسات؛ ي|size_ranges|
|.دار ضمن شاشة بيانات مرجعية الحقةyإعداد أنظمة المقاسات؛ ي|product_type_size_groups|
|.خصائص وخيارات ديناميكية للمنتج؛ األرجح أنها لعرض المتجر اإللكتروني|attributes|
|.خصائص وخيارات ديناميكية للمنتج؛ األرجح أنها لعرض المتجر اإللكتروني|product_type_attributes|
|.خصائص وخيارات ديناميكية للمنتج؛ األرجح أنها لعرض المتجر اإللكتروني|option_sets|
|.خصائص وخيارات ديناميكية للمنتج؛ األرجح أنها لعرض المتجر اإللكتروني|options|
|.خصائص وخيارات ديناميكية للمنتج؛ األرجح أنها لعرض المتجر اإللكتروني|product_type_option_sets|
|.خصائص وخيارات ديناميكية للمنتج؛ األرجح أنها لعرض المتجر اإللكتروني|product_type_care_instructions|
|.دار ضمن شاشة بيانات مرجعية الحقةyإعداد أنظمة المقاسات؛ ي|product_size_groups|
|.دار ضمن شاشة بيانات مرجعية الحقةyإعداد أنظمة المقاسات؛ ي|product_sizes|
|( مأل ضمن شاشة المنتجyجدول ربط المنتج بالتصنيفات والخصائص؛ يS07<br>.)|product_categories|
|( مأل ضمن شاشة المنتجyجدول ربط المنتج بالتصنيفات والخصائص؛ يS07<br>.)|product_sports|
|( مأل ضمن شاشة المنتجyجدول ربط المنتج بالتصنيفات والخصائص؛ يS07<br>.)|product_age_groups|
|( مأل ضمن شاشة المنتجyجدول ربط المنتج بالتصنيفات والخصائص؛ يS07<br>.)|product_genders|
|( مأل ضمن شاشة المنتجyجدول ربط المنتج بالتصنيفات والخصائص؛ يS07<br>.)|product_seasons|
|( مأل ضمن شاشة المنتجyجدول ربط المنتج بالتصنيفات والخصائص؛ يS07<br>.)|product_collections|
|( مأل ضمن شاشة المنتجyجدول ربط المنتج بالتصنيفات والخصائص؛ يS07<br>.)|product_tags|
|( مأل ضمن شاشة المنتجyجدول ربط المنتج بالتصنيفات والخصائص؛ يS07<br>.)|product_materials|
|( مأل ضمن شاشة المنتجyجدول ربط المنتج بالتصنيفات والخصائص؛ يS07<br>.)|product_fabrics|
|( مأل ضمن شاشة المنتجyجدول ربط المنتج بالتصنيفات والخصائص؛ يS07<br>.)|product_care_instructions|
|.خصائص وخيارات ديناميكية للمنتج؛ األرجح أنها لعرض المتجر اإللكتروني|product_attribute_values|
|.خصائص وخيارات ديناميكية للمنتج؛ األرجح أنها لعرض المتجر اإللكتروني|product_option_values|
|.خصائص وخيارات ديناميكية للمنتج؛ األرجح أنها لعرض المتجر اإللكتروني|variant_option_values|
|.صور المنتجات، مرتبطة غالبا<sup>{</sup>بالمتجر اإللكتروني الالحق|product_images|
|.صور المنتجات، مرتبطة غالبا<sup>{</sup>بالمتجر اإللكتروني الالحق|color_images|
|.قواعد تسعير تلقائية (هامش/ربح) خارج نطاق هذه المرحلة|price_rules|
|.)ستخدم داخل بنود البيع والشراء، وال شاشة إدارة لها حاليا<sup>{</sup>(يلزم قرار عن الضريبة<sup>y</sup>ت|tax_rates|
|.)جدول تقني ال يتعامل معه المستخدم مباشرة (مزامنة، ترقيم المستندات، رسائل األخطاء|error_codes|
|.)دار ضمن شاشة بيانات مرجعية الحقة (يلزم قرارyجدول مرجعي لخصائص المنتج؛ ي|product_color_components|



**) ERP ( الملحق هـ: أكواد األخطاء الموحدة** 

|**المعنى**|**السم**|**الكود**|
|---|---|---|
|)عد~ل (مثل أدوار النظامyحذف أو يyعنصر محمي ال ي|DOC_LOCKED|ERP01|
|<sup>انتقال حالة غير مسموح</sup>|DOC_BAD_TRANSITION|ERP02|
|<sup>عد~لyل ال ت</sup>f<sup>بنود مستند مرح</sup>|DOC_ITEMS_LOCKED|ERP03|



صفحة79 

لستخدام — نظام المحاسبة وإدارة المخزون **ا** وثيقة سيناريوهات 

|**المعنى**|**السم**|**الكود**|
|---|---|---|
|€رصيد مخزون غير كاف|INSUFFICIENT_STOCK|ERP04|
|<sup>صح</sup>~<sup>ح بحركة معاكسة</sup>y<sup>جدول لإلضافة فقط، ي</sup>|APPEND_ONLY|ERP05|
|<sup>حذفyأسعار الصرف ال ت</sup>|FX_RATE_IMMUTABLE|ERP06|
|<sup>القيد المول~د غير متوازن</sup>|JOURNAL_UNBALANCED|ERP07|
|<sup>التاريخ خارج الفترة المفتوحة</sup>|PERIOD_CLOSED|ERP08|
|<sup>ال</sup>f<sup>حساب غير قابل للترحيل أو غير فع</sup>|GL_ACCOUNT_NOT_POSTABLE|ERP09|
|<sup>عدم تطابق العملة</sup>|CURRENCY_MISMATCH|ERP10|
|<sup>مستودع غير قابل للبيع</sup>|WAREHOUSE_NOT_SELLABLE|ERP11|
|<sup>إغالق الجلسة قبل الجرد</sup>|POS_SESSION_NOT_RECONCILED|ERP12|
|{فترة مقفلة نهائيا|PERIOD_LOCKED|ERP13|
|<sup>حساب أب قابل للترحيل</sup>|GL_PARENT_POSTABLE|ERP14|
|<sup>سعر الصرف الفعلي مطلوب</sup>|TRANSFER_RATE_INVALID|ERP15|
|<sup>ال صالحية</sup>|PERMISSION_DENIED|ERP16|
|<sup>سبب ال يناسب العملية</sup>|REASON_MISMATCH|ERP17|
|<sup>ربط المستندات غير سليم</sup>|DOC_LINK_MISMATCH|ERP18|
|<sup>سعر صرف عملة السعر مطلوب</sup>|PRICE_RATE_REQUIRED|ERP19|
|<sup>حساب مالي غير صالح</sup>|ACCOUNT_TYPE_INVALID|ERP20|
|<sup>قيد بأقل من سطرين</sup>|JOURNAL_TOO_FEW_LINES|ERP21|
|)حالة أو بيانات غير صالحة (عام|INVALID_STATE|ERP22|



صفحة80 

