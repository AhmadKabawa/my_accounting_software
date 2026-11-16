# SUPABASE_API_INTEGRATION.md

# دليل تكامل واجهة API لتطبيق Flutter (Dio)

> **الغرض:** هذا الملف هو عقد التكامل بين تطبيق Flutter وقاعدة Supabase.
> يُرفق مع `DATA_MODEL.md` ولا يستبدله.
>
> **مصدر المعلومات:** فحص مباشر لمشروع Supabase
> `test vaude store with claude` (`mgtkjmkaydqrugvhplci`) وقراءة ملف
> `DATA_MODEL.md` المرفق. تاريخ الفحص: 2026-11-15.
>
> **قاعدة مهمة:** لا تعتبر أي شيء موسوم بـ **\[قرار مطلوب\]** أو
> **\[تحقق مطلوب\]** عقداً نهائياً قبل إغلاقه.

------------------------------------------------------------------------

## 0. مفتاح قراءة هذا المستند

  -----------------------------------------------------------------------
  الوسم                               المعنى
  ----------------------------------- -----------------------------------
  **\[مؤكد من القاعدة\]**             تمت قراءته من PostgreSQL أو من
                                      إعدادات/كود مشروع Supabase المتصل

  **\[مؤكد من DATA_MODEL\]**          موثق في ملف `DATA_MODEL.md` المرفق،
                                      ومبني على قراءة القاعدة

  **\[مؤكد من كود Edge Function\]**   تمت مراجعة كود الدالة المنشورة
                                      نفسها

  **\[قاعدة Supabase قياسية\]**       نمط HTTP قياسي في
                                      Supabase/PostgREST/Storage/Auth

  **\[قرار مطلوب\]**                  على مالك المشروع/فريق backend تحديد
                                      السلوك قبل أن يعتمده Flutter

  **\[تحقق مطلوب\]**                  توجد معلومة لا يمكن حسمها من SQL
                                      وحده، أو يلزم اختبارها على Data API
                                      الفعلي
  -----------------------------------------------------------------------

------------------------------------------------------------------------

## 1. إعداد الاتصال العام

### 1.1 المشروع

  ---------------------------------------------------------------------------------------------
  الخاصية                             القيمة
  ----------------------------------- ---------------------------------------------------------
  Project name                        `test vaude store with claude`

  Project ref                         `mgtkjmkaydqrugvhplci`

  Project URL                         `https://mgtkjmkaydqrugvhplci.supabase.co`

  Region                              `ap-south-1`

  PostgreSQL                          17.11

  REST base URL                       `https://mgtkjmkaydqrugvhplci.supabase.co/rest/v1`

  Auth base URL                       `https://mgtkjmkaydqrugvhplci.supabase.co/auth/v1`

  Storage base URL                    `https://mgtkjmkaydqrugvhplci.supabase.co/storage/v1`

  Edge Functions base URL             `https://mgtkjmkaydqrugvhplci.supabase.co/functions/v1`
  ---------------------------------------------------------------------------------------------

**\[مؤكد من اتصال Supabase\]** المشروع كان بحالة `ACTIVE_HEALTHY` وقت
الفحص.

### 1.2 API Key

-   استخدم **Publishable key** في تطبيق Flutter.
-   قيمة المفتاح تُحقن في إعدادات البناء/البيئة ولا تُكتب داخل هذا المستند
    أو مستودع Git.
-   لا تستخدم `service_role` أو `sb_secret_...` في تطبيق الهاتف مطلقاً؛
    هذه مفاتيح خادمية تتجاوز RLS.
-   ظهر في المشروع أيضاً مفتاح `anon` قديم مفعّل للتوافق، لكن الاختيار
    الموصى به للتطبيق الجديد هو Publishable key.

``` text
SUPABASE_URL=https://mgtkjmkaydqrugvhplci.supabase.co
SUPABASE_PUBLISHABLE_KEY=<ضع المفتاح العام هنا في إعدادات البناء>
```

### 1.3 Headers الأساسية

كل طلب Data API/Storage/Functions يجب أن يحمل مفتاح المشروع في `apikey`.
عند تنفيذ عملية باسم مستخدم مسجل الدخول، يرسل التطبيق JWT الحالي في
`Authorization`.

``` http
apikey: <SUPABASE_PUBLISHABLE_KEY>
Authorization: Bearer <USER_ACCESS_TOKEN>
Accept: application/json
Content-Type: application/json
```

-   في طلبات ما قبل تسجيل الدخول، لا يوجد `USER_ACCESS_TOKEN` بعد؛
    استخدم المفتاح العام فقط وفق مسار Auth.
-   بعد تسجيل الدخول، لا تستبدل JWT المستخدم بالمفتاح العام في
    `Authorization`.
-   لا ترسل `service_role` إلى Flutter.
-   لا تسجل access token أو refresh token أو كلمات المرور في logs.

**\[قرار مطلوب\]** اعتماد آلية تخزين آمنة للجلسة على الجهاز، وسياسة
الخروج، والتعامل مع الأجهزة المشتركة.

------------------------------------------------------------------------

## 2. REST API -- الجداول والـ Views

### 2.1 كيف تتكون المسارات؟

**\[قاعدة Supabase قياسية\]** Supabase يولّد Data REST API من الجداول
والـ Views والدوال الموجودة في schema مكشوفة. المسار الأساسي:

``` text
GET    {SUPABASE_URL}/rest/v1/{table_or_view}
POST   {SUPABASE_URL}/rest/v1/{table}
PATCH  {SUPABASE_URL}/rest/v1/{table}?id=eq.{id}
DELETE {SUPABASE_URL}/rest/v1/{table}?id=eq.{id}
```

أمثلة على المشروع:

``` http
GET  /rest/v1/products?select=*
GET  /rest/v1/sales?select=*&id=eq.100
GET  /rest/v1/v_stock_available?select=*
POST /rest/v1/sales
PATCH /rest/v1/sales?id=eq.100
```

هذه أمثلة لمسارات مشتقة من أسماء كائنات القاعدة، وليست ضماناً بأن كل
عملية CRUD مسموحة. الامتيازات وRLS وقيود الجداول هي التي تحدد ما سينجح.

### 2.2 جداول public -- 121 جدولاً

**\[مؤكد من القاعدة وDATA_MODEL\]** أسماء الجداول التالية موجودة في
schema `public`:

``` text
age_groups
attributes
audit_logs
balance_adjustments
bank_accounts
banks
barcodes
branches
brands
care_instructions
cash_reconciliations
cashbox_accounts
cashboxes
categories
collections
color_images
colors
cost_adjustments
countries
currencies
customer_addresses
customers
discount_targets
discounts
display_preferences
document_sequences
employees
error_codes
exchange_rates
expense_categories
expenses
fabric_types
financial_accounts
financial_transactions
fiscal_periods
genders
gl_account_mappings
gl_accounts
inventory_balances
journal_entries
journal_entry_lines
materials
money_transfers
option_sets
options
owners
parties
party_ledger_entries
payment_allocations
payment_lines
payment_reasons
payments
permissions
pos_session_balances
pos_sessions
pos_terminal_price_lists
pos_terminals
price_lists
price_rules
product_age_groups
product_attribute_values
product_care_instructions
product_categories
product_collections
product_color_components
product_colors
product_fabrics
product_genders
product_images
product_materials
product_option_values
product_seasons
product_size_groups
product_sizes
product_sports
product_tags
product_type_attributes
product_type_care_instructions
product_type_option_sets
product_type_size_groups
product_types
product_variants
products
purchase_invoice_items
purchase_invoices
purchase_return_items
purchase_returns
role_permissions
roles
sale_items
sales
sales_return_items
sales_returns
seasons
settings
size_groups
size_ranges
size_systems
sizes
sports
stock_adjustment_items
stock_adjustments
stock_movements
stock_transfer_items
stock_transfers
supplier_notes
suppliers
sync_nodes
tags
tax_rates
units
user_branch_access
user_pos_terminals
user_price_lists
user_roles
users
variant_costs
variant_option_values
variant_prices
variant_reorder_levels
warehouses
```

**لا تعِد تعريف الأعمدة هنا:** أسماء الأعمدة وأنواعها وPK/FK والقيود
وسياسات RLS لكل جدول موثقة تفصيلياً في `DATA_MODEL.md`، القسم §8. يجب أن
يرجع مطور Flutter إليه عند إنشاء Models/DTOs.

### 2.3 Views -- 19 View

**\[مؤكد من القاعدة وDATA_MODEL\]** كل Views التالية موجودة في `public`،
وتُستخدم للقراءة/الاستعلامات المجمعة بحسب صلاحياتها:

  View                              الغرض المختصر
  --------------------------------- --------------------------------------
  `v_account_balances`              أرصدة حسابات الدليل
  `v_financial_account_balances`    أرصدة الحسابات المالية وحركاتها
  `v_low_stock`                     الأصناف/المتغيرات تحت حد إعادة الطلب
  `v_open_documents`                الفواتير المرحلة غير المسددة بالكامل
  `v_party_balances`                أرصدة الأطراف حسب العملة
  `v_pos_session_summary`           ملخص جلسات نقاط البيع
  `v_product_attributes`            خصائص وخيارات المنتج
  `v_product_type_attribute_defs`   تعريفات خصائص نوع المنتج
  `v_purchase_items_costs`          تكاليف بنود الشراء
  `v_sale_items_costs`              تكاليف بنود البيع
  `v_sales_daily`                   ملخص المبيعات اليومي
  `v_stock_available`               المخزون المتاح والمحجوز والقادم
  `v_stock_in_transit`              البضاعة قيد النقل
  `v_stock_movements_costs`         تكلفة حركات المخزون
  `v_transfer_costs`                تكلفة التحويلات
  `v_transfer_discrepancies`        فروقات الاستلام في التحويلات
  `v_user_access`                   ملخص أدوار وفروع ومحطات المستخدم
  `v_variant_attributes`            خصائص متغيرات المنتج
  `v_variant_list_prices`           أسعار المتغيرات ضمن قوائم الأسعار

أمثلة:

``` http
GET /rest/v1/v_stock_available?select=*&warehouse_id=eq.1
GET /rest/v1/v_party_balances?select=*&party_id=eq.10
GET /rest/v1/v_open_documents?select=*&branch_id=eq.1
```

**تنبيه أمني مهم من DATA_MODEL:** أربع Views موسومة `barrier` دون
`security_invoker=true`: - `v_purchase_items_costs` -
`v_sale_items_costs` - `v_stock_movements_costs` - `v_transfer_costs`

هذه Views تعمل بصلاحيات المالك وتُقيّد داخلياً بصلاحية عرض التكلفة. لا تنشئ
لها استخداماً في الواجهة قبل اختبارها بحسابات وصلاحيات مختلفة ومراجعة
تحذيرات Supabase Security Advisor.

### 2.4 حدود الوصول الفعلية

**\[مؤكد من القاعدة\]** - RLS مفعّل على جميع جداول `public`. - هناك 460
سياسة RLS في `public`. - الجداول السبعة التي لا تملك سياسات كتابة هي:
`audit_logs`, `cost_adjustments`, `error_codes`,
`financial_transactions`, `inventory_balances`, `party_ledger_entries`,
`stock_movements`. هذه ليست جداول CRUD عادية؛ الكتابة تتم من خلال منطق
النظام/الدوال/Triggers. - `document_sequences` محمي بسياسة
`deny_direct_access`؛ لا يقرأه التطبيق ولا يكتب إليه مباشرة. - بيانات
المستندات مرتبطة بصلاحيات المستخدم والفروع/المستودعات، لذلك نجاح الطلب
يعتمد على JWT والصلاحيات ونطاق الفرع. - لا تفترض أن `SELECT` privilege
يعني أن كل الصفوف مرئية؛ RLS قد يرجع قائمة فارغة. - لا تفترض أن نجاح GET
يعني أن INSERT/UPDATE/DELETE مسموح.

**\[تحقق مطلوب\]** SQL grants وschema privileges تم فحصها، لكن قائمة
Data API Exposed Schemas النهائية إعداد لوحة تحكم مستقل. يجب التأكد من
أن `public` مكشوف في `Integrations → Data API` وأن `erp` غير مكشوف. لا
تضف `erp` إلى Exposed Schemas لتجاوز المشكلة.

------------------------------------------------------------------------

## 3. REST Query Syntax -- الفلاتر والفرز والصفحات

**\[قاعدة Supabase قياسية\]** معاملات PostgREST الشائعة:

  المطلوب         مثال
  --------------- ------------------------------------
  تحديد الأعمدة   `select=id,name,created_at`
  مساواة          `id=eq.10`
  عدم المساواة    `status=neq.DRAFT`
  أكبر/أصغر       `amount=gte.100` / `amount=lt.500`
  قائمة           `id=in.(1,2,3)`
  null            `deleted_at=is.null`
  بحث نصي         `name=ilike.*ali*`
  ترتيب           `order=created_at.desc`
  ترتيب متعدد     `order=status.asc,created_at.desc`
  عدد محدود       `limit=50`
  ترقيم بالمدى    Header: `Range: 0-49`
  العلاقات        `select=*,customers(name)`

مثال طلب Dio:

``` dart
final response = await dio.get(
  '/rest/v1/products',
  queryParameters: {
    'select': 'id,sku,name,is_active',
    'is_active': 'eq.true',
    'order': 'name.asc',
    'limit': 50,
  },
);
```

**قواعد تطبيقية:** 1. استخدم pagination في القوائم؛ لا تحمل كل البيانات
دفعة واحدة. 2. لا تستخدم `select=*` في الشاشات الإنتاجية دون حاجة؛ حدد
الأعمدة المطلوبة. 3. عند بناء filters ديناميكية، لا تسمح بإدخال اسم عمود
أو operator غير موثوق من المستخدم. 4. استخدم علاقات FK الموثقة في
`DATA_MODEL.md` لبناء nested select. 5. لا تعتمد على ترتيب الصفوف دون
`order`. 6. حد الصفوف الافتراضي في Supabase قد يكون 1000؛ يجب أن تكون
الصفحات أصغر ومحددة.

------------------------------------------------------------------------

## 4. RPC API -- دوال قاعدة البيانات العامة

### 4.1 صيغة الاستدعاء

**\[قاعدة Supabase قياسية\]** دوال PostgreSQL العامة المتاحة عبر Data
API تُستدعى هكذا:

``` http
POST {SUPABASE_URL}/rest/v1/rpc/{function_name}
Content-Type: application/json
apikey: <PUBLISHABLE_KEY>
Authorization: Bearer <USER_ACCESS_TOKEN>
```

-   جسم JSON يستخدم أسماء معاملات الدالة نفسها، مثل `p_sale_id`.
-   لا ترسل معاملات positional array؛ أرسل JSON object.
-   دوال `RETURNS TABLE` ترجع عادةً array من objects.
-   دوال `RETURNS jsonb` ترجع JSON.
-   دوال `RETURNS boolean/text/numeric/integer` ترجع قيمة scalar.
-   `RETURNS void` لا تملك payload أعمال مفيداً؛ تعامل مع نجاح HTTP وعدم
    وجود بيانات وفق استجابة PostgREST الفعلية.

### 4.2 قائمة دوال public التي وثّقها DATA_MODEL

**\[مؤكد من DATA_MODEL §10.1\]** الأسماء والتواقيع التالية مستخرجة من
القاعدة. كل هذه الدوال في `public` ومُنحت صلاحية EXECUTE لدور
`authenticated` وفق فحص الملف/القاعدة، ولا تمنح `anon` صلاحية الاستدعاء.

#### الهوية والوصول

  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  RPC                          المعاملات                                                                                                                                                                                                          الإرجاع
  ---------------------------- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ -----------------------
  `get_my_access`              لا شيء                                                                                                                                                                                                             `jsonb`

  `my_has_permission`          `p_code text`                                                                                                                                                                                                      `boolean`

  `complete_password_change`   لا شيء                                                                                                                                                                                                             `void`

  `admin_provision_user`       `p_user_id uuid, p_username text, p_full_name text, p_role_codes text[], p_branch_ids bigint[], p_can_operate boolean, p_email text, p_phone text, p_job_title text, p_home_branch_id bigint, p_party_id bigint`   `jsonb`

  `admin_provision_user`       `p_user_id uuid, p_username text, p_full_name text, p_role_codes text[], p_branches jsonb, p_email text, p_phone text, p_job_title text, p_home_branch_id bigint, p_party_id bigint`                               `jsonb`
  (overload)                                                                                                                                                                                                                                      
  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

**تنبيه overload:** توجد نسختان من `admin_provision_user`. لا تستخدم RPC
هذه مباشرة من Flutter في مسار إنشاء المستخدم؛ استخدم Edge Function
`provision-user` الموثقة في §6.

#### ترحيل المستندات

  -----------------------------------------------------------------------------------------------------------------------------------------------
  RPC                            المعاملات                                                                                الإرجاع
  ------------------------------ ---------------------------------------------------------------------------------------- -----------------------
  `post_sale`                    `p_sale_id bigint`                                                                       `jsonb`

  `post_sales_return`            `p_return_id bigint`                                                                     `jsonb`

  `post_purchase_invoice`        `p_invoice_id bigint`                                                                    `jsonb`

  `post_purchase_return`         `p_return_id bigint`                                                                     `jsonb`

  `post_payment`                 `p_payment_id bigint`                                                                    `jsonb`

  `post_expense`                 `p_expense_id bigint`                                                                    `jsonb`

  `post_money_transfer`          `p_transfer_id bigint`                                                                   `jsonb`

  `post_balance_adjustment`      `p_adjustment_id bigint`                                                                 `jsonb`

  `post_cash_reconciliation`     `p_recon_id bigint`                                                                      `jsonb`

  `post_stock_adjustment`        `p_adjustment_id bigint`                                                                 `jsonb`

  `post_opening_cash`            `p_financial_account bigint, p_amount numeric, p_date timestamptz, p_notes text`         `jsonb`

  `post_opening_party_balance`   `p_party bigint, p_kind text, p_currency bigint, p_amount numeric, p_date timestamptz`   `jsonb`

  `post_opening_stock`           `p_warehouse bigint, p_date timestamptz, p_items jsonb`                                  `jsonb`

  `opening_readiness`            لا شيء                                                                                   `jsonb`
  -----------------------------------------------------------------------------------------------------------------------------------------------

#### عكس المستندات

  -------------------------------------------------------------------------------------------------
  RPC                             المعاملات                                 الإرجاع
  ------------------------------- ----------------------------------------- -----------------------
  `reverse_payment`               `p_payment_id bigint, p_reason text`      `jsonb`

  `reverse_expense`               `p_expense_id bigint, p_reason text`      `jsonb`

  `reverse_balance_adjustment`    `p_adjustment_id bigint, p_reason text`   `jsonb`

  `reverse_money_transfer`        `p_transfer_id bigint, p_reason text`     `jsonb`

  `reverse_cash_reconciliation`   `p_id bigint, p_reason text`              `jsonb`

  `reverse_stock_adjustment`      `p_adjustment_id bigint, p_reason text`   `jsonb`

  `reverse_journal_entry`         `p_journal_id bigint, p_reason text`      `jsonb`
  -------------------------------------------------------------------------------------------------

#### السلف

  -----------------------------------------------------------------------------------------------------------------------------------
  RPC                           المعاملات                                                                     الإرجاع
  ----------------------------- ----------------------------------------------------------------------------- -----------------------
  `apply_advance`               `p_party_id bigint, p_currency_id bigint, p_allocations jsonb, p_date date`   `jsonb`

  `list_party_advances`         `p_party_id bigint, p_currency_id bigint`                                     TABLE

  `get_party_advance_balance`   `p_party_id bigint, p_currency_id bigint`                                     TABLE
  -----------------------------------------------------------------------------------------------------------------------------------

`apply_advance` عقده التفصيلي موثق من DATA_MODEL: - للزبون:
`p_allocations = [{"sale_id": 123, "amount": 50}]` - للمورد:
`p_allocations = [{"purchase_invoice_id": 456, "amount": 50}]` - لا تخلط
`sale_id` و`purchase_invoice_id` في نفس الطلب. - السلف تُستهلك من الأقدم
إلى الأحدث ضمن الطرف والعملة. - الإرجاع يحتوي `payment_id`,
`payment_number`, `party_id`, `currency_id`, `applied`,
`remaining_advance_balance`. - الأخطاء المحتملة المذكورة: ERP16, ERP22,
ERP18, ERP10, ERP08/ERP13.

مثال:

``` http
POST /rest/v1/rpc/apply_advance
```

``` json
{
  "p_party_id": 25,
  "p_currency_id": 1,
  "p_allocations": [
    { "sale_id": 123, "amount": 50.00 }
  ],
  "p_date": "2026-11-15"
}
```

**\[قرار/اختبار مطلوب\]** المثال يوضح شكل المعاملات المستخرج من التوثيق،
لكن يجب اختبار response الفعلي في بيئة التطوير قبل كتابة DTO نهائي.

#### المصروفات

  -----------------------------------------------------------------------------------------
  RPC                          المعاملات                            الإرجاع
  ---------------------------- ------------------------------------ -----------------------
  `attach_expense_receipt`     `p_expense_id bigint, p_path text`   `jsonb`

  `list_expenses_for_review`   `p_branch_id bigint`                 TABLE

  `mark_expense_reviewed`      `p_expense_id bigint, p_note text`   `jsonb`
  -----------------------------------------------------------------------------------------

#### التحويلات والمخزون

  ---------------------------------------------------------------------------------------------
  RPC                     المعاملات                                     الإرجاع
  ----------------------- --------------------------------------------- -----------------------
  `approve_transfer`      `p_transfer_id bigint`                        `jsonb`

  `ship_transfer`         `p_transfer_id bigint, p_items jsonb`         `jsonb`

  `receive_transfer`      `p_transfer_id bigint, p_items jsonb`         `jsonb`

  `cancel_transfer`       `p_transfer_id bigint`                        `jsonb`

  `branch_stock_lookup`   `p_variant bigint, p_current_branch bigint`   TABLE
  ---------------------------------------------------------------------------------------------

#### التسعير والتكلفة

  --------------------------------------------------------------------------------------------------------------------------------------------------------------
  RPC                           المعاملات                                                                                                الإرجاع
  ----------------------------- -------------------------------------------------------------------------------------------------------- -----------------------
  `resolve_price`               `p_variant bigint, p_price_list bigint, p_display_currency bigint, p_at timestamptz`                     TABLE

  `resolve_cost`                `p_variant bigint, p_at timestamptz`                                                                     `numeric`

  `get_allowed_price_lists`     `p_branch bigint, p_terminal bigint, p_customer bigint`                                                  TABLE

  `get_draft_price_warnings`    `p_sale_id bigint`                                                                                       TABLE

  `refresh_draft_line_prices`   `p_sale_id bigint, p_line_ids bigint[]`                                                                  `jsonb`

  `set_discount_cap`            `p_branch bigint, p_percent numeric`                                                                     `jsonb`

  `set_model_cost`              `p_product bigint, p_cost numeric, p_currency bigint, p_reason text`                                     `integer`

  `set_model_price`             `p_product bigint, p_price_list bigint, p_amount numeric, p_currency bigint, p_valid_from timestamptz`   `integer`

  `set_variant_cost`            `p_variant bigint, p_cost numeric, p_currency bigint, p_reason text`                                     `numeric`
  --------------------------------------------------------------------------------------------------------------------------------------------------------------

#### الكتالوج والصور والأطراف

  --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  RPC                           المعاملات                                                                                                                  الإرجاع
  ----------------------------- -------------------------------------------------------------------------------------------------------------------------- -----------------------
  `attach_product_image`        `p_product_id bigint, p_path text, p_image_type text, p_alt_text text, p_is_primary boolean, p_sort_order integer`         `jsonb`

  `delete_product_image`        `p_image_id bigint`                                                                                                        `jsonb`

  `attach_color_image`          `p_product_color_id bigint, p_path text, p_image_type text, p_alt_text text, p_is_primary boolean, p_sort_order integer`   `jsonb`

  `delete_color_image`          `p_image_id bigint`                                                                                                        `jsonb`

  `assign_internal_barcode`     `p_variant bigint`                                                                                                         `text`

  `generate_internal_barcode`   لا شيء                                                                                                                     `text`

  `product_missing_required`    `p_product bigint`                                                                                                         TABLE

  `quick_add_customer`          `p_name text, p_phone text, p_whatsapp text`                                                                               `jsonb`

  `generate_fiscal_year`        `p_year integer`                                                                                                           `jsonb`
  --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

> ملاحظة: التواقيع أعلاه تعرض أسماء المعاملات وأنواعها. بعض المعاملات
> لها DEFAULT في PostgreSQL؛ يمكن عادةً حذف المعامل الاختياري من JSON عند
> الاستدعاء. راجع `DATA_MODEL.md` §10.1 للتفاصيل الدقيقة للـ defaults
> ووصف صلاحيات كل دالة.

### 4.3 ما الذي لا يعنيه وجود RPC؟

لا تستدعِ دوال schema `erp` مباشرة. **\[مؤكد من القاعدة\]** - schema
`erp` ليست جزءاً من واجهة التطبيق المقصودة. - `anon` لا يملك `USAGE` على
schema `erp`. - لا تُنشئ Flutter RPC باسم `erp.some_function`. - دوال
`erp` هي منطق داخلي تستخدمه دوال `public` وTriggers.

### 4.4 أمثلة Dio لاستدعاء RPC

``` dart
Future<dynamic> callRpc(
  String functionName,
  Map<String, dynamic> params,
) async {
  final response = await dio.post(
    '/rest/v1/rpc/$functionName',
    data: params,
  );
  return response.data;
}

// مثال:
final result = await callRpc(
  'post_sale',
  {'p_sale_id': 123},
);
```

**\[قرار مطلوب\]** اعتمد allow-list بأسماء RPC المسموحة في طبقة
Repository/Service بدلاً من السماح باستدعاء اسم دالة عشوائي.

------------------------------------------------------------------------

## 5. Auth API -- تسجيل الدخول والجلسات

### 5.1 ما هو مؤكد من المشروع؟

-   جدول `public.users.id` مرتبط بـ `auth.users.id`.
-   Edge Function `provision-user` تنشئ حساب Auth ببريد داخلي بالشكل:
    `username@store.local`
-   كود الدالة يضع `email_confirm: true`، ويخزن `username` في
    `user_metadata`.
-   كود الدالة يطلب تغيير كلمة المرور بعد الإنشاء
    (`must_change_password: true`).
-   توجد RPC باسم `get_my_access`, `my_has_permission`,
    `complete_password_change`.

### 5.2 نقاط Auth القياسية

المسارات القياسية (تُستخدم وفق إعدادات Auth ونسخة API):

``` text
POST /auth/v1/token?grant_type=password
POST /auth/v1/token?grant_type=refresh_token
POST /auth/v1/logout
GET  /auth/v1/user
```

تسجيل الدخول بكلمة مرور يعيد session تتضمن access token وrefresh token.
استخدم access token في `Authorization: Bearer ...` لبقية API.

### 5.3 قرار مهم: تسجيل الدخول باسم المستخدم

**\[قرار مطلوب قبل برمجة شاشة الدخول\]** - لا توجد في المعلومات التي
فُحصت Edge Function مخصصة لتسجيل الدخول باسم username. - Supabase Auth
password flow يتعامل مع email/phone؛ بينما إنشاء المستخدم الحالي يحوّل
username إلى `username@store.local`. - يجب تحديد هل Flutter سيحوّل
username إلى البريد الداخلي بهذه القاعدة قبل طلب Auth، أم ستُنشأ Edge
Function مخصصة لتسجيل الدخول بالاسم. - لا تفترض أن حقل `users.email` هو
بريد Auth الداخلي؛ كود provision-user ينشئ البريد الداخلي ويحتفظ ببيانات
المستخدم في جدول `users`.

**\[قرار مطلوب\]** تحديد سلوك المستخدم الذي لديه
`must_change_password=true`: منع بقية الشاشات حتى تغيير كلمة المرور، ثم
استدعاء `complete_password_change`، ثم إعادة تحميل `get_my_access`.

### 5.4 Dio وJWT

-   عند تسجيل الدخول، احفظ session بطريقة آمنة.
-   حدّث Authorization header عند تغير access token.
-   عند 401، جرّب refresh وفق آلية واحدة متزامنة؛ لا تنفذ refresh متوازياً
    لكل طلب.
-   إذا فشل refresh، امسح الجلسة واطلب تسجيل الدخول من جديد.
-   لا تكرر تلقائياً POST ترحيل/عكس المستندات بعد 401 أو timeout دون
    التحقق من حالة المستند أولاً؛ فقد تكون العملية تمت في الخادم ولم يصل
    الرد.

------------------------------------------------------------------------

## 6. Edge Functions API

**\[مؤكد من اتصال Supabase وفحص كود الدوال\]** توجد 3 دوال منشورة، وكلها
`verify_jwt=true` وقت الفحص.

Base URL:

``` text
{SUPABASE_URL}/functions/v1
```

### 6.1 `provision-user`

``` http
POST /functions/v1/provision-user
Authorization: Bearer <USER_ACCESS_TOKEN>
apikey: <PUBLISHABLE_KEY>
Content-Type: application/json
```

تتطلب صلاحية `users.manage`، وتتحقق من صلاحية المتصل قبل إنشاء المستخدم.

Request body المدعوم في الكود:

``` json
{
  "username": "cashier01",
  "temp_password": "temporary-password",
  "full_name": "Cashier One",
  "role_codes": ["CASHIER"],
  "branches": [
    {
      "branch_id": 1,
      "can_view": true,
      "can_operate": true
    }
  ],
  "email": "cashier@example.com",
  "phone": "000000000",
  "job_title": "Cashier",
  "home_branch_id": 1,
  "party_id": null
}
```

التوافق القديم للفروع مدعوم أيضاً:

``` json
{
  "branch_ids": [1],
  "can_operate": true
}
```

قواعد تحقق صريحة من الكود: - username من 3 إلى 32 حرفاً، أحرف إنجليزية
صغيرة/أرقام/`.`/`_`/`-`، ويبدأ بحرف أو رقم. - كلمة المرور المؤقتة 8 أحرف
على الأقل. - يلزم `full_name` إذا لم يُمرر `party_id`. - يلزم دور واحد
على الأقل في `role_codes`. - منح `SUPER_ADMIN` يتطلب أن يكون المتصل
Super Admin. - غير Super Admin يحتاج فرعاً واحداً على الأقل وفق RPC.

Response success (المضمون المؤكد من الكود؛ قد يحتوي أيضاً حقولاً إضافية من
RPC):

``` json
{
  "ok": true,
  "username": "cashier01",
  "internal_email": "cashier01@store.local",
  "must_change_password": true
}
```

أخطاء HTTP التي يخرجها الكود: - `401 UNAUTHENTICATED` -
`403 PERMISSION_DENIED` - `400 BAD_REQUEST` - `400 BAD_USERNAME` -
`400 WEAK_PASSWORD` - `409 USERNAME_TAKEN` - `400 AUTH_CREATE_FAILED` -
`400 PROVISION_FAILED` - `405 METHOD_NOT_ALLOWED`

### 6.2 `reset-password`

``` http
POST /functions/v1/reset-password
Authorization: Bearer <USER_ACCESS_TOKEN>
apikey: <PUBLISHABLE_KEY>
Content-Type: application/json
```

تتطلب صلاحية `users.manage`.

Request:

``` json
{
  "user_id": "00000000-0000-0000-0000-000000000000",
  "temp_password": "temporary-password"
}
```

قواعد الكود: - `user_id` يجب أن يكون UUID صالحاً. - كلمة المرور 8 أحرف
على الأقل. - لا يمكن إعادة تعيين كلمة مرور مستخدم `SUPER_ADMIN` إلا من
Super Admin. - بعد التغيير يضبط `must_change_password=true` ويعيد
`failed_login_attempts=0` و`locked_until=null`.

Success response:

``` json
{
  "ok": true,
  "user_id": "00000000-0000-0000-0000-000000000000",
  "must_change_password": true
}
```

أخطاء HTTP من الكود: - `401 UNAUTHENTICATED` - `403 PERMISSION_DENIED` -
`400 BAD_REQUEST` - `400 WEAK_PASSWORD` - `404 NOT_FOUND` -
`400 AUTH_UPDATE_FAILED` - `500 FLAG_UPDATE_FAILED` -
`405 METHOD_NOT_ALLOWED`

### 6.3 `quick-service`

``` http
POST /functions/v1/quick-service
Authorization: Bearer <USER_ACCESS_TOKEN>
apikey: <PUBLISHABLE_KEY>
Content-Type: application/json
```

الكود الحالي يستقبل:

``` json
{ "name": "World" }
```

ويرجع رسالة Hello. لا ينفذ منطق ERP ولا يتصل بجداول النظام.

**\[قرار مطلوب\]** هذه الدالة تبدو قالباً تجريبياً وليست جزءاً من وظائف
ERP؛ إما حذفها أو تعريف الغرض منها قبل استخدامها.

------------------------------------------------------------------------

## 7. Storage API -- رفع وتنزيل الملفات

### 7.1 Buckets الموجودة

**\[مؤكد من قاعدة Storage\]**

  Bucket                 Public   الحجم الأقصى أنواع الملفات
  -------------------- -------- -------------- -----------------
  `product-images`          نعم           5 MB JPEG, PNG, WebP
  `expense-receipts`         لا           5 MB JPEG, PNG, WebP

### 7.2 مسارات Storage

``` text
POST   /storage/v1/object/{bucket}/{path}
GET    /storage/v1/object/public/{bucket}/{path}
DELETE /storage/v1/object/{bucket}/{path}
```

-   صور المنتجات: bucket `product-images` عام.
-   إيصالات المصروفات: bucket `expense-receipts` خاص.
-   المسار الموثق لإيصال المصروف: `<branch_id>/<file>`.
-   دالة `attach_expense_receipt` تربط المسار بمصروف موجود وتتحقق من
    الملف/المسار وفق منطق القاعدة.

مثال رفع ملف (الـ path مثال شكلي، لا يعتبر naming policy معتمدة للصور):

``` http
POST /storage/v1/object/product-images/products/123/front.webp
apikey: <PUBLISHABLE_KEY>
Authorization: Bearer <USER_ACCESS_TOKEN>
Content-Type: image/webp
```

مثال مسار إيصال:

``` text
expense-receipts/1/expense-123-receipt.webp
```

**\[قرار مطلوب\]** اعتماد naming convention موحد لصور المنتجات والألوان،
بما في ذلك هل المسار يتضمن product_id أو color_id أو variant_id، وكيفية
تسمية الملفات والإصدارات.

### 7.3 الوصول إلى الملفات

-   `product-images` عام: يمكن بناء Public URL للعرض بعد رفع الملف.
-   `expense-receipts` خاص: استخدم authenticated download أو signed URL
    قصير العمر؛ لا تجعل bucket عاماً.
-   صلاحيات Storage لا تغني عن صلاحيات صفوف ERP.
-   سياسات Storage في القاعدة: 8 سياسات، كلها لدور `authenticated`.
-   سياسات `product-images`: القراءة على bucket، والكتابة تتطلب
    `catalog.manage`.
-   سياسات `expense-receipts`: القراءة تتطلب صلاحية مالية مناسبة ونطاق
    فرع، والكتابة تتطلب `finance.expenses` مع صلاحية تشغيل على الفرع.
-   upsert/استبدال الملف يحتاج مراعاة امتيازات INSERT + SELECT + UPDATE
    في Storage.

**\[تحقق مطلوب\]** اختبار upload/download/signed URL بحساب مستخدم محدود
الصلاحية، وليس بحساب مدير النظام فقط.

------------------------------------------------------------------------

## 8. Error Handling -- معالجة الأخطاء

### 8.1 أخطاء HTTP وPostgREST

يجب أن يتعامل Dio مع: - `400`: بيانات غير صالحة، constraint، أو خطأ
تحقق. - `401`: جلسة/Token غير صالح أو مفقود. - `403`: صلاحية/Grant/RLS
أو منع من Edge Function. - `404`: مورد غير موجود أو مسار غير صحيح. -
`409`: تعارض، مثل username مستخدم أو unique constraint. - `429`: تجاوز
rate limit إن فُعّل. - `5xx`: خطأ خادم أو قاعدة/شبكة وسيطة.

شكل خطأ PostgREST الشائع:

``` json
{
  "code": "P0001",
  "details": null,
  "hint": null,
  "message": "Error message"
}
```

هذا شكل توضيحي شائع وليس ضماناً أن كل دوال ERP تعيد نفس `code`.

### 8.2 رموز ERP

**\[مؤكد من DATA_MODEL §5\]** يوجد جدول `error_codes` يحوي 29 رمزاً. يجب
على Flutter الاحتفاظ بـ: - `code` كمعرّف ثابت للمنطق. - `key` كمفتاح
ترجمة/رسالة. - `description_ar` كرسالة عربية افتراضية.

لا تعتمد على تحليل نص `message` لاتخاذ قرار برمجي؛ اعتمد على `code` أو
`key` عندما يكونان متاحين.

أمثلة رموز موثقة: - `ERP01`: مستند مرحّل/ملغى محمي من التعديل والحذف. -
`ERP02`: انتقال حالة غير مسموح. - `ERP03`: تعديل بنود مستند أب مقفل. -
`ERP16`: صلاحية غير كافية. - `ERP22`: حالة/مدخل غير صالح وفق سياق
العملية.

### 8.3 ما يحتاج توحيداً

**\[قرار مطلوب\]** 1. اعتماد DTO موحد لأخطاء التطبيق: `httpStatus`,
`code`, `key`, `message`, `details`. 2. توحيد تحويل أخطاء PostgREST إلى
رسائل عربية. 3. تحديد الأخطاء التي تسمح بإعادة المحاولة والأخطاء التي لا
تسمح. 4. عدم إعادة تنفيذ عمليات الترحيل والعكس تلقائياً بعد timeout؛
استعلم عن المستند أولاً.

------------------------------------------------------------------------

## 9. Dio -- الهيكل المقترح في Flutter

هذا تنظيم مقترح وليس كوداً موجوداً في قاعدة البيانات:

``` text
lib/
  core/
    network/
      dio_client.dart
      auth_interceptor.dart
      api_exception.dart
      api_result.dart
  data/
    datasources/
      remote/
        rest_data_source.dart
        rpc_data_source.dart
        storage_data_source.dart
        edge_functions_data_source.dart
    models/
    repositories/
  features/
    ...
```

### 9.1 إعداد Dio الأساسي

``` dart
final dio = Dio(
  BaseOptions(
    baseUrl: 'https://mgtkjmkaydqrugvhplci.supabase.co',
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
    headers: {
      'apikey': supabasePublishableKey,
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ),
);
```

### 9.2 إضافة JWT

``` dart
dio.interceptors.add(
  InterceptorsWrapper(
    onRequest: (options, handler) {
      final token = sessionStore.accessToken;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
  ),
);
```

`sessionStore` هنا مسؤولية تطبيق Flutter ويجب تحديده مع فريق التطبيق. لا
تضع token ثابتاً في الكود.

### 9.3 قراءة جدول

``` dart
final response = await dio.get(
  '/rest/v1/branches',
  queryParameters: {
    'select': 'id,code,name,is_active',
    'order': 'name.asc',
  },
);
```

### 9.4 إنشاء سجل

``` dart
final response = await dio.post(
  '/rest/v1/<table_name>',
  data: {
    // الحقول المسموح بها لهذا الجدول
  },
  options: Options(
    headers: {
      'Prefer': 'return=representation',
    },
  ),
);
```

### 9.5 تحديث سجل

``` dart
final response = await dio.patch(
  '/rest/v1/<table_name>',
  queryParameters: {'id': 'eq.123'},
  data: {
    // الحقول المطلوب تحديثها
  },
  options: Options(
    headers: {
      'Prefer': 'return=representation',
    },
  ),
);
```

لا تنفذ PATCH دون filter محدد، ولا تحاول تعديل مستند POSTED مباشرة.

### 9.6 حذف سجل

``` dart
final response = await dio.delete(
  '/rest/v1/<table_name>',
  queryParameters: {'id': 'eq.123'},
);
```

الحذف ليس مسموحاً لكل الجداول أو الحالات. المستندات المرحلة تُعكس بدلاً من
حذفها.

### 9.7 RPC

``` dart
final response = await dio.post(
  '/rest/v1/rpc/post_sale',
  data: {'p_sale_id': 123},
);
```

### 9.8 Edge Function

``` dart
final response = await dio.post(
  '/functions/v1/provision-user',
  data: {
    'username': 'cashier01',
    'temp_password': 'temporary-password',
    'full_name': 'Cashier One',
    'role_codes': ['CASHIER'],
    'branches': [
      {
        'branch_id': 1,
        'can_view': true,
        'can_operate': true,
      }
    ],
  },
);
```

------------------------------------------------------------------------

## 10. ما يجب أن يلتزم به مطور Flutter

1.  استخدام `DATA_MODEL.md` كمرجع نهائي للأعمدة والعلاقات والقيود
    والحالات وسياسات RLS.
2.  استخدام هذا الملف كمرجع لمسارات API وأنواع الاتصال وتواقيع RPC
    وStorage وEdge Functions.
3.  عدم الكتابة مباشرة في جداول الدفاتر append-only أو الجداول التي تدار
    عبر RPC/Triggers.
4.  عدم تغيير حالة المستند إلى `POSTED` عبر PATCH؛ استخدم `post_*`.
5.  عدم حذف مستند مرحّل؛ استخدم `reverse_*` حيث توجد دالة عكس.
6.  عدم استدعاء schema `erp` مباشرة.
7.  إرسال JWT المستخدم في Authorization بعد تسجيل الدخول.
8.  عدم وضع service role/secret key في Flutter.
9.  تطبيق pagination وطلب الأعمدة المطلوبة فقط.
10. التعامل مع RLS كجزء من عقد API، لا كخطأ عارض.
11. عدم افتراض أن كل جدول يسمح بـ CRUD.
12. عدم إعادة محاولة ترحيل/عكس مستند تلقائياً بعد timeout.
13. اختبار كل Repository بحسابات ذات صلاحيات مختلفة وفروع مختلفة.
14. تحديث Models عند تغير `DATA_MODEL.md` أو migrations.

------------------------------------------------------------------------

## 11. قرارات/تحققات لازمة لإغلاق عقد API

> **سجل البنود الموحّد:** [`docs/OPEN_DECISIONS.md`](../OPEN_DECISIONS.md). يبقى هذا القسم للتفصيل التاريخي؛ لا تُضف فيه بنداً جديداً.


الحالة بعد مراجعة 2026-11-16 (القرارات في `docs/product/scenarios/A4_decisions_log.md`):

| # | الموضوع | الحالة | المرجع أو المطلوب |
|---|---|---|---|
| 1 | Exposed schemas في Data API | **[تحقق مطلوب]** | التأكد من أن `public` مكشوف و`erp` غير مكشوف، قبل أي إدخال بيانات حقيقية |
| 2 | تسجيل الدخول بـ username | **محلول جزئياً** | قرار-37 وقرار-66: `username@<نطاق dart-define>`، وبريد كامل إن أُدخل؛ بريد `admin` في Auth حقيقي، فيُثبَّت بتجربة دخول فعلية في AUTH-01 |
| 3 | تغيير كلمة المرور الأولى | **محلول** | قرار-37: `must_change_password` و`complete_password_change()` قبل اختيار الفرع |
| 4 | DTOs لردود RPC | **جزئي** | `get_my_access` موثقة في `GET_MY_ACCESS.md`؛ بقية الدوال تُوثَّق عند أول استعمال في شاشتها |
| 5 | أخطاء PostgreSQL/ERP | **محلول بالقرار** | قرار-76: الرمز `ERPnn` ← AppKey بنصين. التنفيذ يتطلب أن يحمل `ApiException` الحقلين `code` و`details` (انظر `V1_SCOPE.md`)؛ تُؤخذ عينات حقيقية عند التنفيذ |
| 6 | Pagination | **محلول** | قرار-75: 10/25/50/100 والافتراضي 25 |
| 7 | Storage paths للصور | **محلول** | قرار-73: `products/<id>/<uuid>.<ext>` و`colors/<id>/<uuid>.<ext>`؛ `validate_image_path` تشترط وجود الملف في `product-images` ولا تفرض نمطاً |
| 8 | استبدال وحذف الصور/الإيصالات | **جزئي** | حذف صورة المنتج يحذف الصف والملف (معيار قبول S55)؛ استبدال إيصال المصروف يترك الملف القديم (DATA_MODEL §13، مقبول مؤقتاً) |
| 9 | `quick-service` | **قرار الحذف متخذ** | يُنفَّذ ضمن قائمة التشغيل قبل الإطلاق |
| 10 | Realtime | **v2** | لا بث في v1؛ لا تفترض أنه مفعل |
| 11 | سياسة إعادة المحاولة | **محلول** | `ARCHITECTURE_RULES §6`: GET فقط تلقائياً؛ الترحيل والعكس لا يُعادان، ويُستعلم عن المستند أولاً (القسم 8.3) |
| 12 | API contract آلي | **v2** | استخراج OpenAPI ومقارنته عند استقرار الواجهات |

### ما لم يتم ادعاء توثيقه هنا

-   لم يتم اختراع request/response JSON لكل واحدة من 55 RPC؛ التواقيع
    معروفة من القاعدة، لكن لا يتوفر عقد JSON مفصل لكل دالة في
    DATA_MODEL.
-   لم يتم اعتبار كل الجداول قابلة للكتابة لمجرد وجودها.
-   لم يتم اعتبار إعداد Exposed Schemas مؤكداً من SQL وحده.
-   لم يتم تضمين أي service role أو secret key.
-   لم يتم افتراض تفعيل Realtime أو سياسات rate limiting.
-   لم يتم اعتبار `quick-service` وظيفة ERP فعلية.

------------------------------------------------------------------------

## 12. مراجع Supabase الرسمية

-   [Data REST API](https://supabase.com/docs/guides/api)
-   [Creating API
    Routes](https://supabase.com/docs/guides/api/creating-routes)
-   [Securing your
    API](https://supabase.com/docs/guides/api/securing-your-api)
-   [Flutter
    initialization](https://supabase.com/docs/reference/dart/initializing)
-   [Flutter API
    reference](https://supabase.com/docs/reference/dart/introduction)
-   [Auth sessions](https://supabase.com/docs/guides/auth/sessions)
-   [Storage
    uploads](https://supabase.com/docs/guides/storage/uploads/standard-uploads)
-   [Edge Functions](https://supabase.com/docs/guides/functions)

------------------------------------------------------------------------

## 13. علاقة هذا الملف بـ DATA_MODEL.md

  -----------------------------------------------------------------------
  الوثيقة                             مسؤوليتها
  ----------------------------------- -----------------------------------
  `DATA_MODEL.md`                     ماذا يوجد داخل قاعدة البيانات:
                                      الجداول، الأعمدة، العلاقات، القيود،
                                      RLS، Triggers، الدوال، Views

  `SUPABASE_API_INTEGRATION.md`       كيف يتصل Flutter بهذه القاعدة: Base
                                      URLs، REST، RPC، Auth، Storage،
                                      Edge Functions، Dio، الأخطاء،
                                      القرارات المفتوحة
  -----------------------------------------------------------------------

**طريقة الاستخدام:** أرفق الملفين معاً عند تسليم العمل لمطور Flutter أو
لمساعد برمجي. لا تدمجهما؛ لكل ملف مسؤولية مختلفة، وتحديث أحدهما لا يلغي
الآخر.
