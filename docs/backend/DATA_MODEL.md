# DATA_MODEL.md — نموذج بيانات النظام المحاسبي/ERP

> **مُستخرَج مباشرةً من قاعدة البيانات** (مشروع Supabase `test vaude store with claude`، المعرّف `mgtkjmkaydqrugvhplci`) بتاريخ **2026-11-27**، بعد تطبيق migrations الدفعتين `s1`–`s6` و`cat07_01`–`cat07_04c`. طُبّقت على القاعدة الحية migrations: `cat07_01_storage_masterdata_image_folders`, `cat07_02_created_at_brands_colors`, `cat07_03_stats_rpcs_and_color_usage_view`, `cat07_04a_categories_cycle_guard`, `cat07_04b_discount_target_delete_guards`, `cat07_04c_slug_format_and_default_size_group_index`. لا شيء هنا مكتوب من الذاكرة: الأعمدة والعلاقات والقيود والسياسات والدوال والـ Views مقروءة من `pg_catalog`.
> التنسيق مضغوط عمداً (سطر لكل جدول). اقرأ **§1 الاصطلاحات** أولاً.

## الفهرس
1. الاصطلاحات ورموز الاختصار
2. ملخص القاعدة (أعداد مقروءة)
3. قواعد النظام العابرة (دورة حياة المستند، العكس، الحماية، الترقيم، التدقيق)
4. القيم المعدودة (حالات وأنواع من قيود CHECK)
5. رموز الأخطاء `error_codes`
6. الأدوار والصلاحيات
7. الربط المحاسبي والإعدادات والترقيم
8. الجداول (121)
9. الـ Views (20)
10. الدوال (`public` و`erp`)
11. Storage وEdge Functions
12. سياسات RLS: النمط العام والاستثناءات
13. ملاحظات أمنية وفجوات معروفة
14. سجل تغييرات الدفعة s1–s6
15. سجل تغييرات CAT-07

---

## 1) الاصطلاحات ورموز الاختصار

**أنواع الأعمدة:** `i8`=bigint · `i4`=integer · `i2`=smallint · `t`=text · `v(n)`=varchar(n) (`v` بلا طول = varchar غير محدود) · `n(p,s)`=numeric · `b`=boolean · `ts`=timestamptz · `tsn`=timestamp بلا منطقة · `d`=date · `u`=uuid · `j`=jsonb · `f8`=double.

**رموز العمود:** `name:type[*][!][=default]`
- `*` جزء من المفتاح الأساسي (PK) · `!` NOT NULL · `=ID` عمود identity (`GENERATED ... AS IDENTITY`) · `=now` اختصار `now()` · `=uuid` اختصار `gen_random_uuid()`.
- **`+std`** في نهاية سطر `cols`: للجدول **ثلاثة أعمدة مزامنة قياسية محذوفة من القائمة اختصاراً**: `updated_at:ts!=now`, `uuid:u!=uuid` (مع فهرس فريد `ux_<table>_uuid`), `origin_node_id:i8!=1` (FK→`sync_nodes`). يملكها 115 جدولاً. الجداول التي لا تملكها كلها (`audit_logs`، `cost_adjustments`، `error_codes`، `document_sequences`، `sync_nodes`، `users`) تُسرد أعمدتها كاملة.

**أسطر الجدول:**
- `fk:` علاقات `col→جدول[.عمود_مرجعي]` (المرجعي `id` يُحذف) مع `/cascade` أو `/setnull` أو `/restrict` عند وجود قاعدة DELETE غير الافتراضية (الافتراضي NO ACTION). `users.id→auth.users` يعني schema `auth`. علاقة `origin_node_id→sync_nodes` محذوفة لجداول `+std`.
- `uq` قيود UNIQUE · `ux:` فهارس فريدة/جزئية (غير مرتبطة بقيد) مع شرط `WHERE` · `ck:` قيود CHECK (**باستثناء قوائم القيم المعدودة**، فهي في §4).
- `tg:` triggers بصيغة `الاسم[=الدالة(وسائط)]@توقيت+أحداث`: `B`=BEFORE `A`=AFTER · `i`=INSERT `u`=UPDATE `d`=DELETE · `(of col)`=UPDATE OF. الاسم بلا بادئة `trg_`. الدوال في schema `erp` ما لم يُذكر.
- `rls:` حالة RLS ثم سياسات مُطبَّعة: `read` (SELECT) و`write` (INSERT/UPDATE/DELETE متطابقة) أو `ins/upd/del` عند اختلافها.

**اختصارات تعابير RLS:**
- `perm[a,b]` = `erp.has_any_permission(array['a','b'])` (يكفي واحد). `perm[a]` = `erp.has_permission('a')`.
- `can_access_branch(x)` = قراءة/تشغيل على الفرع `x` · `can_access_branch(x, operate)` = صلاحية تشغيل (`p_operate=true`). `branch(x)` = نفس الدالة داخل `SELECT` مُغلَّف.
- `can_access_warehouse(x[, operate])` مثلها للمستودع.
- `EXISTS(t p WHERE …)` = استعلام فرعي على الجدول الأب `t` (لوراثة رؤية الأب).
- كل استدعاءات الدوال في السياسات مغلَّفة بـ `(SELECT …)` لكاش initplan (في المصدر)، وهنا مبسَّطة للقراءة.

**أنواع الدوال في §10:** `[DEFINER]` = SECURITY DEFINER · `S`/`I`/`V` = stable/immutable/volatile · `auth` = EXECUTE لـ authenticated.

---

## 2) ملخص القاعدة (أعداد مقروءة)

| العنصر | العدد | | العنصر | العدد |
|---|---|---|---|---|
| جداول public | **121** | | أعمدة (جداول public) | 1277 |
| Views | **20** (0 materialized) | | PK | 121 |
| FK | 392 | | UNIQUE | 92 |
| CHECK | 164 | | فهارس (public) | 587 |
| سياسات RLS (public) | **460** | | سياسات storage | **9** |
| Triggers (public) | **286** | | دوال public | **57** |
| دوال erp | **105** | | أعمدة identity | 100 |
| ENUM types | 0 | | جداول مقسَّمة | 0 |
| الصلاحيات `permissions` | 46 | | روابط `role_permissions` | 151 |
| الأدوار | 7 | | `error_codes` | 29 |
| فترات محاسبية | 24 (2026، 2027) | | حسابات الدليل | 51 |
| ربطات GL | 24 | | فئات مصروف | 8 |
| أسباب الدفع | 13 | | Edge Functions | 3 |

- **RLS مفعّل على جميع جداول public** (لا استثناء)، ولا `FORCE` على أي منها. تتوفر أدوات بناء في `erp` (`standard_table`, `apply_policies`, `set_policies`, `pol_*`) لإنشاء الجداول والسياسات القياسية.
- **لا ENUM**: كل القيم المعدودة عبر `CHECK … IN (…)` (§4).
- الإضافات: `pg_stat_statements`, `pg_trgm`, `pgcrypto`, `plpgsql`, `supabase_vault`, `uuid-ossp`.
- الفروع: `1:MAIN الفرع الرئيسي` · `2:BR2 فرع الاختبار الثاني`. العملات: `1:USD (أساس)` · `2:SYP`. المنطقة الزمنية (إعداد): `Asia/Damascus`.

---

## 3) قواعد النظام العابرة

### 3.1 دورة حياة المستند
- **مسودة → مُرحَّل:** `DRAFT → POSTED` لا يتم إلا عبر دوال `post_*` (SECURITY DEFINER). trigger `forbid_direct_post` يمنع تغيير الحالة إلى POSTED أو تعديل `reversal_of_*` مباشرة، و`guard_status_permission` يشترط الصلاحية المناسبة (خارج سياق النظام).
- **الإلغاء:** `CANCELLED` **للمسودات فقط** (والتحويل المخزني قبل الشحن).
- **العكس:** المستند المُرحَّل لا يُعدَّل ولا يُلغى؛ يُعكس **بمستند معاكس** يشير إلى الأصل (`reversal_of_id` أو `reversal_of_payment_id`)، وتصبح حالة **الأصل `REVERSED`** (موحَّد في s1 على: `payments`, `expenses`, `balance_adjustments`, `money_transfers`؛ و`stock_adjustments`, `cash_reconciliations`, `journal_entries` كانت كذلك). فهرس فريد جزئي `ux_<table>_reversal_of` يضمن عكساً واحداً فقط لكل أصل.
- **الاستبعاد من الحسابات:** الدوال التي تقرأ الدفعات (`doc_due_paid`, `party_advance_rows`, `post_payment_core`, …) والـ View `v_open_documents` (بعد s6) تفلتر بـ `status = 'POSTED'`، فيُستبعد الأصل المعكوس تلقائياً؛ مستند `reverse_payment` العكسي نفسه `POSTED` لكنه لا ينسخ التخصيصات (فيتحرّر ما استهلكه الأصل).
- **أنواع حالات لا تدخل REVERSED:** `sales`/`purchase_invoices` (`doc_status`: DRAFT/POSTED/CANCELLED) و`sales_returns`/`purchase_returns` و`stock_transfers`.

### 3.2 الحماية (triggers قياسية)
| Trigger | الدالة | الوظيفة |
|---|---|---|
| `protect_posted` | `protect_posted_doc(status_col [, free_cols_csv])` | يمنع UPDATE/DELETE لمستند غير DRAFT (ERP01). الأعمدة في `free_cols` يجوز تعديلها **على POSTED فقط** (مثل `payment_status`, `reviewed_*`, `receipt_image_path`). الدالة نفسها لم تُعدَّل في هذه الدفعة. |
| `protect_items` | `protect_posted_children(parent, fk_col, parent_status_col [,'Y'])` | يمنع تعديل بنود/أسطر مستند أب غير DRAFT (ERP03)؛ `'Y'` يسمح بالإدراج. |
| `forbid_direct_post` | `forbid_direct_post(status_col, reversal_col)` | (ERP02) يُلزم **إنشاء** المستند بحالة `DRAFT` وبلا `reversal_*`، ويمنع `UPDATE` مباشراً إلى `POSTED` أو تعديل عمود العكس؛ يتجاوزه `sys_active()`. غير موجود على `payments`. |
| `guard_perm` | `guard_status_permission(status_col, post_perms_csv [, cancel_perms_csv])` | (ERP16) الانتقال إلى `POSTED` يتطلب أيّاً من `post_perms`، والانتقال إلى `CANCELLED` أو `REVERSED` يتطلب أيّاً من `cancel_perms` (الافتراضي = `post_perms`). يُتجاوز عند `auth.uid()` فارغ أو `sys_active()`. |
| `append_only` | `forbid_change()` | يمنع UPDATE/DELETE (ERP05): `audit_logs`, `financial_transactions`, `party_ledger_entries`, `stock_movements`. |
| `audit` | `audit_row()` | يكتب `audit_logs` (CREATE/UPDATE/DELETE) لكل تغيير. |
| `actor` | `set_created_by()` | يضبط `created_by = auth.uid()`. |
| `assign_number` | `assign_doc_number(col, doc_type)` | يولّد الرقم عبر `erp.next_doc_number` من `document_sequences`. |
| `reason_guard` | `reason_guard(applies_to)` | يتحقق من تطابق `reason_id` مع نوع العملية (ERP17). |
| `guard_ccy` | `account_currency_guard()` | عملة السطر = عملة الحساب المالي (ERP10/ERP20). |
| `set_updated_at` | `set_updated_at()` | `updated_at = now()`. |

**علَم النظام:** `erp.sys_begin()` = `set_config('erp.system_post','on', true)` (محلي بالمعاملة)، و`erp.sys_active()` = `current_setting('erp.system_post', true) = 'on'`. تستعمله دوال SECURITY DEFINER لتجاوز الحُرّاس، ويبقى فعّالاً حتى نهاية المعاملة (مهم عند الاختبار داخل معاملة واحدة).

### 3.3 الترقيم
`erp.next_doc_number(doc_type, branch)` يخزّن العدّاد في `document_sequences (doc_type, branch_id, fiscal_year)` (UNIQUE NULLS NOT DISTINCT) ولا يصل إليه أحد مباشرة (سياسة `deny_direct_access`). الأنواع المستعملة عبر triggers: `SALE`, `RETURN`, `ADJUSTMENT`, `BALANCE_ADJUSTMENT`, `TRANSFER`, `JOURNAL`؛ ومن دوال: `PAYMENT` (لمستندات `apply_advance`، يُخزَّن في `payments.reference_number`). **لا يوجد عمود `payment_number`** في `payments`.

### 3.4 التدقيق `audit_logs`
`action` ∈ {CREATE, UPDATE, DELETE, POST, CANCEL, APPROVE, LOGIN, RATE_CHANGE, MANUAL_OVERRIDE} (قيد CHECK). `RATE_CHANGE` و`MANUAL_OVERRIDE` يستلزمان `reason` غير فارغ. الدوال الجديدة تكتب `POST` (`apply_advance`) و`UPDATE` (`attach_expense_receipt`) مع `new_values.operation` = `APPLY_ADVANCE` / `ATTACH_RECEIPT`.

### 3.5 الأخطاء
كل أخطاء الأعمال عبر `erp.raise_err(code, key, msg, detail)` برمز `SQLSTATE = ERPnn` (انظر §5).

---

## 4) القيم المعدودة (من قيود CHECK)

### 4.1 الحالات
| الجدول.العمود | القيم |
|---|---|
| `payments.status` | DRAFT, POSTED, CANCELLED, **REVERSED** |
| `expenses.status` | DRAFT, POSTED, CANCELLED, **REVERSED** |
| `balance_adjustments.status` | DRAFT, POSTED, CANCELLED, **REVERSED** |
| `money_transfers.status` | DRAFT, POSTED, CANCELLED, **REVERSED** |
| `stock_adjustments.status` | DRAFT, POSTED, CANCELLED, REVERSED |
| `cash_reconciliations.status` | DRAFT, POSTED, CANCELLED, REVERSED |
| `journal_entries.status` | DRAFT, POSTED, REVERSED |
| `sales.doc_status` / `purchase_invoices.doc_status` | DRAFT, POSTED, CANCELLED |
| `sales_returns.status` / `purchase_returns.status` | DRAFT, POSTED, CANCELLED |
| `stock_transfers.status` | DRAFT, APPROVED, IN_TRANSIT, RECEIVED, CANCELLED |
| `sales.payment_status` / `purchase_invoices.payment_status` | UNPAID, PARTIAL, PAID |
| `pos_sessions.status` | OPEN, CLOSED |
| `fiscal_periods.status` | OPEN, CLOSED, LOCKED |
| `supplier_notes.status` | OPEN, RESOLVED |
| `products.status` | draft, published, archived |

### 4.2 الأنواع والتصنيفات
| الجدول.العمود | القيم |
|---|---|
| `payments.payment_type` | SUPPLIER_PAYMENT, CUSTOMER_RECEIPT, EMPLOYEE_PAYMENT, OWNER_WITHDRAWAL, OWNER_CONTRIBUTION, REFUND |
| `payments.payment_context` | ON_PURCHASE_RECEIPT, REGULAR_PAYMENT, ADVANCE_PAYMENT, SALE_RECEIPT |
| `payment_lines.direction` / `financial_transactions.direction` / `stock_movements.direction` | IN, OUT |
| `payment_lines.line_type` | PAYMENT, CHANGE_GIVEN, CUSTOMER_REFUND, SUPPLIER_REFUND, OTHER |
| `payment_lines.payment_method` (nullable) | CASH, CARD, BANK_TRANSFER, CHEQUE, E_WALLET |
| `payment_allocations.allocation_type` | DEBT, ADVANCE, ADVANCE_APPLICATION, REFUND |
| `payment_reasons.applies_to` | PAYMENT, EXPENSE, ADJUSTMENT |
| `payment_reasons.payment_type` (nullable) | نفس قيم `payments.payment_type` |
| `balance_adjustments.side` | DEBIT, CREDIT |
| `financial_accounts.type` | CASH, BANK |
| `financial_transactions.transaction_type` | SALE, PAYMENT, EXPENSE, TRANSFER, ADJUSTMENT, OPENING, CASH_DIFFERENCE |
| `party_ledger_entries.entry_type` | OPENING, SALE, SALE_RETURN, PURCHASE, PURCHASE_RETURN, PAYMENT, ADVANCE, ADJUSTMENT |
| `gl_accounts.account_type` | ASSET, LIABILITY, EQUITY, REVENUE, EXPENSE |
| `gl_accounts.normal_balance` | DEBIT, CREDIT |
| `parties.party_type` | PERSON, COMPANY |
| `sales.channel` | POS, ONLINE, PHONE |
| `sales_returns.refund_method` | CASH_REFUND, CUSTOMER_CREDIT |
| `purchase_returns.settlement_method` | SUPPLIER_CREDIT, CASH_REFUND |
| `sales_return_items.condition_type` | SELLABLE, DAMAGED, DEFECTIVE |
| `stock_adjustments.reason` | COUNT_CORRECTION, DAMAGE, LOSS, FOUND, OTHER |
| `stock_movements.movement_type` | PURCHASE_IN, SALE_OUT, TRANSFER_IN, TRANSFER_OUT, ADJUSTMENT_IN, ADJUSTMENT_OUT, SALES_RETURN, PURCHASE_RETURN, OPENING (ويُلزَم اتجاه IN لـ PURCHASE_IN/TRANSFER_IN/ADJUSTMENT_IN/SALES_RETURN/OPENING وOUT لباقيها) |
| `supplier_notes.type` | MISSING_ITEM, WRONG_COLOR, INVOICE_ISSUE |
| `warehouses.warehouse_type` | GENERAL, SHOP_FLOOR, CENTRAL, RETURNS, DAMAGED |
| `sync_nodes.node_type` | CLOUD, LOCAL |
| `exchange_rates.source` | system, manual, bank, market (`manual` يستلزم `note`) |
| `currencies.rounding_method` | HALF_UP, UP, DOWN |
| `settings.scope_type` / `display_preferences.scope_type` | GLOBAL, BRANCH, USER |
| `display_preferences.display_mode` | PRIMARY_ONLY, PRIMARY_WITH_TOOLTIP, BOTH |
| `display_preferences.print_mode` | SINGLE, DUAL |
| `price_lists.price_type` | retail, wholesale, special |
| `price_rules.calculation_method` | markup, margin |
| `price_rules.cost_basis` | last_purchase, average |
| `discounts.discount_type` | percentage, fixed |
| `discount_targets.target_type` | product, variant, category, product_type, brand |
| `cost_adjustments.target_type` | VARIANT, PRODUCT |
| `audit_logs.action` | CREATE, UPDATE, DELETE, POST, CANCEL, APPROVE, LOGIN, RATE_CHANGE, MANUAL_OVERRIDE |

### 4.3 الكتالوج
| الجدول.العمود | القيم / القيد |
|---|---|
| `attributes.data_type` | text, number, boolean, date, json, option |
| `barcodes.barcode_type` | EAN13, UPC, CODE128 |
| `care_instructions.care_type` | washing, drying, ironing, bleaching, dry_cleaning |
| `color_images.image_type` / `product_images.image_type` | front, back, detail, fabric, other |
| `fabric_types.fabric_category` | knit, woven, fleece |
| `materials.material_type` | natural, synthetic, blended |
| `option_sets.selection_type` | single, multiple |
| `products.authenticity_status` | original, non_original, unknown |
| `seasons.season_type` | summer, winter, spring, autumn |
| `units.unit_type` | weight, length, volume, piece — CHECK `units_unit_type_check` موجود في القاعدة |

---

## 5) رموز الأخطاء `error_codes` (code | key | message)

| code | key | message |
|---|---|---|
| ERP01 | DOC_LOCKED | مستند مُرحَّل أو ملغى لا يُعدَّل ولا يُحذف |
| ERP02 | DOC_BAD_TRANSITION | انتقال حالة غير مسموح للمستند — الإلغاء (CANCELLED) للمسودات فقط، والمستند المرحّل يُعكس بمستند معاكس فتصبح حالته REVERSED |
| ERP03 | DOC_ITEMS_LOCKED | لا يجوز تعديل بنود مستند ليس في حالة مسودة |
| ERP04 | INSUFFICIENT_STOCK | الرصيد غير كافٍ والسياسة تمنع الرصيد السالب |
| ERP05 | APPEND_ONLY | جدول للإضافة فقط، التصحيح بحركة معاكسة |
| ERP06 | FX_RATE_IMMUTABLE | أسعار الصرف لا تُعدَّل ولا تُحذف، تُضاف أسعار جديدة |
| ERP07 | JOURNAL_UNBALANCED | القيد غير متوازن (مجموع المدين لا يساوي الدائن) |
| ERP08 | PERIOD_CLOSED | الفترة المحاسبية مغلقة أو التاريخ خارج الفترة |
| ERP09 | GL_ACCOUNT_NOT_POSTABLE | حساب غير قابل للترحيل أو غير فعّال |
| ERP10 | CURRENCY_MISMATCH | عدم تطابق العملات |
| ERP11 | WAREHOUSE_NOT_SELLABLE | المستودع غير قابل للبيع |
| ERP12 | POS_SESSION_NOT_RECONCILED | لا تُغلق الوردية قبل جرد POSTED لكل عملة |
| ERP13 | PERIOD_LOCKED | الفترة المحاسبية مقفلة نهائياً |
| ERP14 | GL_PARENT_POSTABLE | الحساب الأب يجب أن يكون تجميعياً وغير قابل للترحيل |
| ERP15 | TRANSFER_RATE_INVALID | بيانات سعر الصرف أو المبالغ في تحويل الأموال غير صحيحة |
| ERP16 | PERMISSION_DENIED | لا تملك الصلاحية المطلوبة لهذه العملية |
| ERP17 | REASON_MISMATCH | سبب الدفع/التسوية لا يطابق نوع العملية |
| ERP18 | DOC_LINK_MISMATCH | عدم تطابق بين المستند ومرجعه (فاتورة/بند/دفعة) |
| ERP19 | PRICE_RATE_REQUIRED | يلزم سعر صرف السعر عند اختلاف عملة السعر عن عملة الفاتورة |
| ERP20 | ACCOUNT_TYPE_INVALID | نوع الحساب المالي غير مناسب للعملية |
| ERP21 | JOURNAL_TOO_FEW_LINES | القيد يحتاج سطرين على الأقل |
| ERP22 | INVALID_STATE | حالة أو بيانات غير صالحة للعملية |
| ERP23 | PRICE_LIST_NOT_ALLOWED | قائمة الأسعار غير مسموحة لهذا المستخدم أو نقطة البيع |
| ERP24 | PRICE_MISMATCH | السعر لا يطابق سعر القائمة المعتمد ولا يجوز تعديل سعر السطر |
| ERP25 | PRICE_NOT_FOUND | لا يوجد سعر قابل للحل للصنف في قائمة الأسعار |
| ERP26 | DISCOUNT_CAP_EXCEEDED | الخصم يتجاوز السقف المسموح |
| ERP27 | ATTRIBUTE_VALUE_INVALID | قيمة الخاصية لا تطابق نوعها أو خياراتها |
| ERP28 | REQUIRED_ATTRIBUTES_MISSING | خصائص إلزامية ناقصة، لا يمكن نشر المنتج |
| ERP29 | PRODUCT_MUST_START_DRAFT | يُنشأ المنتج مسودة أولاً ثم تُحفظ خصائصه ثم يُنشر |

---

## 6) الأدوار والصلاحيات

**46 صلاحية** في `permissions` (العمود `module` يصنّفها)، و**7 أدوار** و**151 رابطاً** في `role_permissions`. جداول: `roles`, `permissions`, `role_permissions`, `user_roles`, `user_branch_access (can_view, can_operate)`, `user_pos_terminals`, `user_price_lists`.

| الدور | العدد | الصلاحيات |
|---|---|---|
| SUPER_ADMIN | 45 | accounting.manage, accounting.post, accounting.view, audit.view, balance.adjust, catalog.manage, costs.manage, costs.view, discount.exceptional, finance.expenses, finance.manage, finance.payments, finance.view, fx.rate.manage, fx.rate.manual, hr.manage, hr.view, inventory.adjust, inventory.transfer, inventory.transfer.approve, inventory.view, inventory.view_other_branches, masterdata.manage, org.manage, owner.transactions, parties.manage, parties.view, payment.cancel, pos.manage, pos.session, pricing.manage, purchasing.create, purchasing.post, purchasing.return, purchasing.view, reconcile.cash, reports.view, sales.create, sales.discount, sales.post, sales.return, sales.view, settings.manage, users.manage, warehouse.central.access |
| MANAGER | 36 | accounting.view, audit.view, catalog.manage, costs.manage, costs.view, discount.exceptional, finance.expenses, finance.payments, finance.view, fx.rate.manual, hr.manage, hr.view, inventory.adjust, inventory.transfer, inventory.transfer.approve, inventory.view, inventory.view_other_branches, masterdata.manage, parties.manage, parties.view, payment.cancel, pos.manage, pos.session, pricing.manage, purchasing.create, purchasing.post, purchasing.return, purchasing.view, reconcile.cash, reports.view, sales.create, sales.discount, sales.post, sales.return, sales.view, warehouse.central.access |
| ACCOUNTANT | 23 | accounting.manage, accounting.post, accounting.view, audit.view, balance.adjust, costs.manage, costs.view, finance.expenses, finance.manage, finance.payments, finance.view, fx.rate.manage, fx.rate.manual, hr.view, inventory.view, owner.transactions, parties.manage, parties.view, payment.cancel, purchasing.view, reconcile.cash, reports.view, sales.view |
| PURCHASER | 14 | catalog.manage, costs.view, finance.payments, inventory.view, inventory.view_other_branches, masterdata.manage, parties.manage, parties.view, purchasing.create, purchasing.post, purchasing.return, purchasing.view, reports.view, warehouse.central.access |
| CASHIER | 13 | finance.expenses, finance.payments, inventory.view, inventory.view_other_branches, parties.quick_add, parties.view, pos.session, reconcile.cash, sales.create, sales.discount, sales.post, sales.return, sales.view |
| AUDITOR | 11 | accounting.view, audit.view, costs.view, finance.view, hr.view, inventory.view, parties.view, purchasing.view, reports.view, sales.view, warehouse.central.access |
| WAREHOUSE | 9 | catalog.manage, inventory.adjust, inventory.transfer, inventory.transfer.approve, inventory.view, inventory.view_other_branches, masterdata.manage, purchasing.view, warehouse.central.access |

> المجموع 23+11+13+36+14+45+9 = **151**. الصلاحية الوحيدة غير المرتبطة بـ SUPER_ADMIN هي `parties.quick_add` (46 − 45)؛ ترتبط بـ CASHIER فقط.

---

## 7) الربط المحاسبي والإعدادات والترقيم

**`gl_account_mappings` (24 ربطاً عاماً، `branch_id` فارغ):**
`AP_SUPPLIERS→2101` · `AR_CUSTOMERS→1201` · `CASH_OVER→4202` · `CASH_SHORT→6110` · `COGS→5101` · `CUSTOMER_ADVANCES→2102` · `EMPLOYEE_ADVANCES→1203` · `FX_GAIN→4201` · `FX_LOSS→6108` · `INVENTORY→1301` · `INVENTORY_ADJUSTMENT→5102` · `INVENTORY_IN_TRANSIT→1302` · `OPENING_BALANCE_EQUITY→3104` · `OWNER_CAPITAL→3101` · `OWNER_DRAWINGS→3102` · `RETAINED_EARNINGS→3103` · `ROUNDING_DIFF→6109` · `SALARIES_PAYABLE→2103` · `SALES_DISCOUNT→4103` · `SALES_RETURNS→4102` · `SALES_REVENUE→4101` · `SUPPLIER_ADVANCES→1202` · `TAX_INPUT→1401` · `TAX_OUTPUT→2201`.
(`erp.gl(key, branch)` تفضّل ربط الفرع إن وُجد ثم العام؛ الربط الحالي كله عام. غياب المفتاح = ERP22.)

**`settings` (GLOBAL):** `NEGATIVE_STOCK_POLICY=BLOCK` · `COST_METHOD=LAST` · `REQUIRE_COST_ON_SALE=N` · `DISCOUNT_MAX_PERCENT=10` · `TIMEZONE=Asia/Damascus`. القراءة عبر `erp.get_setting(key, branch, user)` (النطاق: USER ثم BRANCH ثم GLOBAL).

**قيد الترحيل الواحد:** `ux_journal_source_once (source_type, source_id)` على `journal_entries` للأصل غير العكسي، لأنواع: SALE, SALES_RETURN, PURCHASE, PURCHASE_RETURN, TRANSFER_SHIP, TRANSFER_RECEIVE, PAYMENT, EXPENSE, MONEY_TRANSFER, BALANCE_ADJ, STOCK_ADJ, CASH_RECON.

**أنماط قيود الترحيل للدفعات والسلف:**
- سلفة = تخصيص `allocation_type='ADVANCE'` (بلا وثيقة، `party_id` إلزامي، `payment_line_id` موجود).
- تطبيق سلفة = تخصيصات `ADVANCE_APPLICATION` بـ `parent_allocation_id` يشير للسلفة، وتشير إلى فاتورة (`sale_id` أو `purchase_invoice_id`) بالعملة نفسها، بلا أسطر نقدية؛ القيد: عميل `CUSTOMER_ADVANCES ← AR_CUSTOMERS`، مورد `AP_SUPPLIERS ← SUPPLIER_ADVANCES`.
- المتبقي من السلفة = `source_amount` − مجموع تخصيصات `ADVANCE_APPLICATION` التابعة لها ضمن دفعات `status='POSTED'` (دالة `erp.party_advance_rows`).

---

## 8) الجداول (121)

مرتبة أبجدياً. كل جدول: `cols` ثم (إن وُجد) `fk` / `uq` / `ux` / `ck` / `tg` ثم `rls`. القيم المعدودة في §4، والاصطلاحات في §1. ملاحظة `note:` = تعليق الجدول الموجود في القاعدة (`COMMENT ON TABLE`) أو توضيح مضاف.

#### age_groups
cols: id:i8*=ID, name:v(100)!, min_age:i4, max_age:i4, is_active:b!=true, sort_order:i4=0 +std
uq (name)
ck: age_groups_check: (min_age IS NULL) OR (max_age IS NULL) OR (min_age <= max_age)
tg: set_updated_at@Bu
rls: on | read: true | write: perm[masterdata.manage]

#### attributes
cols: id:i8*=ID, name:v(150)!, code:v(80)!, data_type:v(20)!, unit_id:i8, is_filterable:b!=false, is_required:b!=false, is_variant_option:b!=false, is_active:b!=true, option_set_id:i8 +std
fk: option_set_id→option_sets; unit_id→units
uq (code)
ck: ck_attributes_option_set: (data_type = 'option') = (option_set_id IS NOT NULL)
tg: set_updated_at@Bu
rls: on | read: true | write: perm[masterdata.manage]

#### audit_logs
cols: id:i8*=ID, user_id:u, action:v(30)!, entity_type:v(50)!, entity_id:t, old_values:j, new_values:j, ip_address:v(45), created_at:ts!=now, reason:t, uuid:u!=uuid, origin_node_id:i8!=1
fk: origin_node_id→sync_nodes; user_id→users
ck: audit_logs_reason_required: (action NOT IN ('RATE_CHANGE','MANUAL_OVERRIDE')) OR (NULLIF(btrim(reason), '') IS NOT NULL)
tg: append_only=forbid_change()@Bud
rls: on | read: perm[audit.view]

#### balance_adjustments
cols: id:i8*=ID, adjustment_number:v(100)!, party_id:i8!, currency_id:i8!, side:v(6)!, amount:n(20,4)!, reason_id:i8!, adjustment_date:ts!, status:v(20)!='DRAFT', reversal_of_id:i8, created_by:u, posted_at:ts, notes:t +std
fk: created_by→users; currency_id→currencies; party_id→parties; reason_id→payment_reasons; reversal_of_id→balance_adjustments
uq (adjustment_number)
ux: ux_balance_adjustments_reversal_of (reversal_of_id) WHERE (reversal_of_id IS NOT NULL)
ck: ck_balance_adj_amount: amount > 0; ck_balance_adj_reversal: (reversal_of_id IS NULL) OR (reversal_of_id <> id)
tg: actor=set_created_by()@Bi, assign_number=assign_doc_number('adjustment_number', 'BALANCE_ADJUSTMENT')@Bi, audit=audit_row()@Aiud, forbid_direct_post('status', 'reversal_of_id')@Biu, guard_perm=guard_status_permission('status', 'balance.adjust')@Biu, protect_posted=protect_posted_doc('status')@Bud, reason_guard('ADJUSTMENT')@Biu, set_updated_at@Bu
rls: on | read: perm[accounting.view,parties.view,balance.adjust,finance.view] | write: perm[balance.adjust]

#### bank_accounts
cols: id:i8*=ID, bank_id:i8!, branch_id:i8, currency_id:i8!, account_name:v(150)!, account_number:v(100), is_active:b!=true +std
fk: bank_id→banks; branch_id→branches; currency_id→currencies
uq (bank_id, account_number)
tg: audit=audit_row()@Aiud, set_updated_at@Bu
rls: on | read: perm[finance.view,finance.manage,finance.payments,accounting.view,pos.session,pos.manage,reconcile.cash,sales.post] AND (branch_id IS NULL OR can_access_branch(branch_id)) | write: perm[finance.manage] AND (branch_id IS NULL OR can_access_branch(branch_id, operate))

#### banks
cols: id:i8*=ID, name:v(150)!, code:v(50), is_active:b!=true +std
uq (code)
tg: audit=audit_row()@Aiud, set_updated_at@Bu
rls: on | read: true | write: perm[finance.manage,masterdata.manage]

#### barcodes
cols: id:i8*=ID, variant_id:i8!, barcode:v(100)!, barcode_type:v(20)!='EAN13', is_primary:b!=false, is_active:b!=true +std
fk: variant_id→product_variants/cascade
uq (barcode)
ux: ux_barcodes_one_primary (variant_id) WHERE is_primary
tg: audit=audit_row()@Aiud, set_updated_at@Bu
rls: on | read: true | write: perm[catalog.manage]

#### branches
cols: id:i8*=ID, code:v(50)!, name:v(150)!, address:t, phone:v(50), is_active:b!=true +std
uq (code)
tg: audit=audit_row()@Aiud, set_updated_at@Bu
rls: on | read: branch(branches.id) | write: perm[org.manage]

#### brands
cols: id:i8*=ID, name:v(150)!, slug:v(150)!, logo:v(500), description:t, is_active:b!=true, created_at:ts!=now +std
uq (name); uq (slug)
ck: brands_slug_format_check: slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'
tg: guard_discount_target_ref=trg_block_delete_discount_target_ref('brand')@Bd, set_updated_at@Bu
rls: on | read: true | write: perm[masterdata.manage]

#### care_instructions
cols: id:i8*=ID, name:v(150)!, code:v(50)!, care_type:v(30)!, description:t, icon:v(255), sort_order:i4=0, is_active:b!=true +std
uq (code)
tg: set_updated_at@Bu
rls: on | read: true | write: perm[masterdata.manage]

#### cash_reconciliations
cols: id:i8*=ID, financial_account_id:i8!, pos_session_id:i8, count_date:ts!, expected_amount:n(20,4)!, counted_amount:n(20,4)!, difference_amount:n(20,4)!, reason:t, status:v(20)!='DRAFT', created_by:u, posted_at:ts, reversal_of_id:i8 +std
fk: created_by→users; financial_account_id→financial_accounts; pos_session_id→pos_sessions; reversal_of_id→cash_reconciliations
ux: ux_cash_recon_session_account (pos_session_id, financial_account_id) WHERE (pos_session_id IS NOT NULL AND status <> 'CANCELLED'); ux_cash_reconciliations_reversal_of (reversal_of_id) WHERE (reversal_of_id IS NOT NULL)
ck: ck_cash_recon_counted: counted_amount >= 0; ck_cash_recon_diff: difference_amount = (counted_amount - expected_amount)
tg: actor=set_created_by()@Bi, audit=audit_row()@Aiud, forbid_direct_post('status', 'reversal_of_id')@Biu, guard=cash_reconciliation_guard()@Biu, guard_perm=guard_status_permission('status', 'reconcile.cash,pos.session', 'reconcile.cash')@Biu, protect_posted=protect_posted_doc('status')@Bud, set_updated_at@Bu
rls: on | read: perm[finance.view,reconcile.cash,accounting.view] AND EXISTS(financial_accounts a WHERE a.id = financial_account_id) | write: perm[reconcile.cash] AND EXISTS(financial_accounts a WHERE a.id = financial_account_id)

#### cashbox_accounts
cols: id:i8*=ID, cashbox_id:i8!, currency_id:i8!, is_active:b!=true +std
fk: cashbox_id→cashboxes; currency_id→currencies
uq (cashbox_id, currency_id)
tg: audit=audit_row()@Aiud, set_updated_at@Bu
rls: on | read: EXISTS(cashboxes p WHERE p.id = cashbox_id) | write: perm[finance.manage,pos.manage] AND EXISTS(cashboxes p WHERE p.id = cashbox_id AND can_access_branch(p.branch_id, operate))

#### cashboxes
cols: id:i8*=ID, branch_id:i8!, name:v(100)!, code:v(50)!, is_active:b!=true +std
fk: branch_id→branches
uq (code)
tg: audit=audit_row()@Aiud, set_updated_at@Bu
rls: on | read: perm[finance.view,finance.manage,finance.payments,accounting.view,pos.session,pos.manage,reconcile.cash,sales.post] AND can_access_branch(branch_id) | write: perm[finance.manage,pos.manage] AND can_access_branch(branch_id, operate)

#### categories
cols: id:i8*=ID, parent_id:i8, name:v(150)!, slug:v(150)!, description:t, image:v(500), sort_order:i4=0, is_active:b!=true +std
fk: parent_id→categories
uq (slug)
ck: categories_check: (parent_id IS NULL) OR (parent_id <> id); categories_slug_format_check: slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'
tg: categories_no_cycle=trg_categories_no_cycle()@Bu(of parent_id), guard_discount_target_ref=trg_block_delete_discount_target_ref('category')@Bd, set_updated_at@Bu
rls: on | read: true | write: perm[masterdata.manage]

#### collections
cols: id:i8*=ID, name:v(150)!, code:v(50)!, description:t, image:v(500), start_date:d, end_date:d, is_active:b!=true +std
uq (code)
tg: set_updated_at@Bu
rls: on | read: true | write: perm[masterdata.manage]

#### color_images
cols: id:i8*=ID, image_url:v(500)!, image_type:v(20)!='other', alt_text:v(250), is_primary:b!=false, sort_order:i4=0, product_color_id:i8! +std
fk: product_color_id→product_colors/cascade
ux: ux_ci_one_primary (product_color_id) WHERE is_primary
tg: audit=audit_row()@Aiud, set_updated_at@Bu
rls: on | read: true | write: perm[catalog.manage]

#### colors
cols: id:i8*=ID, name:v(100)!, code:v(50)!, hex_code:v(9), is_active:b!=true, sort_order:i4=0, created_at:ts!=now +std
uq (code)
ck: colors_hex_code_check: (hex_code IS NULL) OR (hex_code ~ '^#[0-9A-Fa-f]{6}([0-9A-Fa-f]{2})?$')
tg: set_updated_at@Bu
rls: on | read: true | write: perm[masterdata.manage]

#### cost_adjustments
cols: id:i8*=ID, target_type:t!, target_id:i8!, old_cost_base:n(18,4), new_cost_base:n(18,4)!, input_cost:n(18,4)!, input_currency_id:i8!, reason:t!, created_by:u=auth.uid(), created_at:ts!=now, uuid:u!=uuid, origin_node_id:i8!=1
fk: input_currency_id→currencies; origin_node_id→sync_nodes
ck: cost_adjustments_reason_check: length(TRIM(BOTH FROM reason)) > 0
rls: on | read (p_read بدور `public` لا `authenticated`): has_permission('costs.view')

#### countries
cols: id:i8*=ID, name:v(100)!, code:v(3)!, is_active:b!=true +std
uq (code)
tg: set_updated_at@Bu
rls: on | read: true | write: perm[masterdata.manage]

#### currencies
cols: id:i8*=ID, code:v(10)!, name:v(100)!, symbol:v(10), decimal_places:i4!=2, is_base:b!=false, is_active:b!=true, rounding_increment:n(20,6)!=0, rounding_method:v(10)!='HALF_UP' +std
uq (code)
ux: ux_currencies_single_base (is_base) WHERE is_base
ck: currencies_decimal_places_check: (decimal_places >= 0) AND (decimal_places <= 8); currencies_rounding_increment_check: rounding_increment >= 0
tg: audit=audit_row()@Aiud, set_updated_at@Bu
rls: on | read: true | write: perm[finance.manage]

#### customer_addresses
cols: id:i8*=ID, customer_id:i8!, label:v(50), city:v(100), address:t!, phone:v(50), is_default:b!=false +std
fk: customer_id→customers/cascade
ux: ux_customer_addresses_one_default (customer_id) WHERE is_default
tg: set_updated_at@Bu
rls: on | read: EXISTS(customers p WHERE p.id = customer_id) | write: perm[parties.manage] AND EXISTS(customers p WHERE p.id = customer_id)

#### customers
cols: id:i8*=ID, party_id:i8!, customer_code:v(50), credit_limit:n(20,4), credit_limit_currency_id:i8, default_price_list_id:i8, is_active:b!=true +std
fk: credit_limit_currency_id→currencies; default_price_list_id→price_lists; party_id→parties
uq (customer_code); uq (party_id)
ck: ck_customers_credit: (credit_limit IS NULL) OR (credit_limit >= 0 AND credit_limit_currency_id IS NOT NULL)
tg: audit=audit_row()@Aiud, set_updated_at@Bu
rls: on | read: perm[parties.view,sales.view,sales.create,accounting.view] | write: perm[parties.manage]

#### discount_targets
cols: id:i8*=ID, discount_id:i8!, target_type:v(20)!, target_id:i8! +std
fk: discount_id→discounts/cascade
uq (discount_id, target_type, target_id)
ix: ix_discount_targets_target (target_type, target_id)

**حماية الحذف polymorphic:** `trg_guard_discount_target_ref` على `categories`, `brands`, `product_types`, `products`, `product_variants` يمنع حذف أي هدف مشار إليه في `discount_targets`؛ يرفع SQLSTATE `23503` بالقيد `discount_targets_target_ref`.
tg: set_updated_at@Bu
rls: on | read: true | write: perm[pricing.manage]

#### discounts
cols: id:i8*=ID, name:v(150)!, code:v(50)!, discount_type:v(20)!, value:n(20,4)!, currency_id:i8, min_quantity:n(20,4), start_at:ts, end_at:ts, is_stackable:b!=false, is_active:b!=true +std
fk: currency_id→currencies
uq (code)
ck: ck_discounts_fixed_currency: (discount_type <> 'fixed') OR (currency_id IS NOT NULL); ck_discounts_min_qty: (min_quantity IS NULL) OR (min_quantity >= 0); ck_discounts_period: (start_at IS NULL) OR (end_at IS NULL) OR (end_at >= start_at); ck_discounts_value: (value > 0) AND (discount_type <> 'percentage' OR value <= 100)
tg: audit=audit_row()@Aiud, set_updated_at@Bu
rls: on | read: true | write: perm[pricing.manage]

#### display_preferences
cols: id:i8*=ID, scope_type:v(10)!='GLOBAL', branch_id:i8, user_id:u, primary_currency_id:i8!, secondary_currency_id:i8, display_mode:v(20)!='PRIMARY_WITH_TOOLTIP', print_mode:v(10)!='SINGLE' +std
fk: branch_id→branches; primary_currency_id→currencies; secondary_currency_id→currencies; user_id→users
ux: ux_display_pref_branch (branch_id) WHERE (scope_type = 'BRANCH'); ux_display_pref_global ((1)) WHERE (scope_type = 'GLOBAL'); ux_display_pref_user (user_id) WHERE (scope_type = 'USER')
ck: ck_display_pref_currencies: (secondary_currency_id IS NULL) OR (secondary_currency_id <> primary_currency_id); ck_display_pref_scope_cols: (scope_type='GLOBAL' AND branch_id IS NULL AND user_id IS NULL) OR (scope_type='BRANCH' AND branch_id IS NOT NULL AND user_id IS NULL) OR (scope_type='USER' AND user_id IS NOT NULL AND branch_id IS NULL)
tg: audit=audit_row()@Aiud, set_updated_at@Bu
rls: on | read: scope_type='GLOBAL' OR (scope_type='BRANCH' AND can_access_branch(branch_id)) OR (scope_type='USER' AND user_id = auth.uid()) OR perm[settings.manage] | write: perm[settings.manage] OR (scope_type='USER' AND user_id = auth.uid())

#### document_sequences
note: RLS مفعّل بدون سياسات عمداً: لا يصل إليه إلا erp.next_doc_number (SECURITY DEFINER).
cols: id:i8*=ID, doc_type:v(40)!, branch_id:i8, fiscal_year:i4!, prefix:v(20), next_number:i4!=1
fk: branch_id→branches
uq NULLS NOT DISTINCT (doc_type, branch_id, fiscal_year)
rls: on | other: deny_direct_access (ALL, anon+authenticated): false

#### employees
cols: id:i8*=ID, party_id:i8!, employee_code:v(50), job_title:v(100), branch_id:i8, hire_date:d, is_active:b!=true +std
fk: branch_id→branches; party_id→parties
uq (employee_code); uq (party_id)
tg: audit=audit_row()@Aiud, set_updated_at@Bu
rls: on | read: perm[hr.view] | write: perm[hr.manage]

#### error_codes
cols: code:v(5)*, key:v(50)!, description_ar:t!
uq (key)
rls: on | read: true

#### exchange_rates
cols: id:i8*=ID, from_currency_id:i8!, to_currency_id:i8!, rate:n(20,8)!, rate_date:ts!, is_approved:b!=true, source:v(50)='manual', note:t, created_by:u, created_at:ts!=now +std
fk: created_by→users; from_currency_id→currencies; to_currency_id→currencies
uq (from_currency_id, to_currency_id, rate_date)
ck: ck_exchange_rates_pair: from_currency_id <> to_currency_id; ck_exchange_rates_rate: rate > 0; ck_exchange_rates_reason: (source IS DISTINCT FROM 'manual') OR (NULLIF(btrim(COALESCE(note,'')), '') IS NOT NULL)
tg: actor=set_created_by()@Bi, audit_rate=audit_rate_change()@Aiu, fx_guard=exchange_rate_guard()@Bud, set_updated_at@Bu
rls: on | read: true | write: perm[fx.rate.manage,fx.rate.manual]

#### expense_categories
cols: id:i8*=ID, name:v(100)!, code:v(50), gl_account_id:i8, is_active:b!=true +std
fk: gl_account_id→gl_accounts
uq (code)
tg: audit=audit_row()@Aiud, set_updated_at@Bu
rls: on | read: true | write: perm[accounting.manage,finance.manage]

#### expenses
cols: id:i8*=ID, branch_id:i8!, expense_category_id:i8!, payee_party_id:i8, reference_number:v(100), amount:n(20,4)!, currency_id:i8!, exchange_rate:n(20,8)!=1, amount_base:n(20,4)!=0, financial_account_id:i8!, status:v(20)!='POSTED', expense_date:ts!, created_by:u, notes:t, reversal_of_id:i8, reviewed_by:u, reviewed_at:ts, review_note:t, receipt_image_path:v(500) +std
fk: branch_id→branches; created_by→users; currency_id→currencies; expense_category_id→expense_categories; financial_account_id→financial_accounts; payee_party_id→parties; reversal_of_id→expenses; reviewed_by→users
ux: ux_expenses_reversal_of (reversal_of_id) WHERE (reversal_of_id IS NOT NULL)
ck: ck_expenses_amount: (amount > 0) AND (exchange_rate > 0) AND (amount_base >= 0); ck_expenses_reversal: (reversal_of_id IS NULL) OR (reversal_of_id <> id)
tg: actor=set_created_by()@Bi, audit=audit_row()@Aiud, forbid_direct_post('status', 'reversal_of_id')@Biu, guard_ccy=account_currency_guard()@Biu, guard_perm=guard_status_permission('status', 'finance.expenses', 'finance.manage')@Biu, protect_posted=protect_posted_doc('status', 'reviewed_by,reviewed_at,review_note,receipt_image_path')@Bud, receipt_guard=expense_receipt_guard()@Bu(of receipt_image_path), review_guard=expense_review_guard()@Biu, set_updated_at@Bu
rls: on | read: perm[finance.view,finance.expenses,accounting.view,reports.view] AND can_access_branch(branch_id) | write: perm[finance.expenses] AND can_access_branch(branch_id, operate)

#### fabric_types
cols: id:i8*=ID, name:v(100)!, code:v(50)!, fabric_category:v(30), is_named_fabric:b!=false, description:t, is_active:b!=true +std
uq (code)
tg: set_updated_at@Bu
rls: on | read: true | write: perm[masterdata.manage]

#### financial_accounts
cols: id:i8*=ID, name:v(150)!, type:v(10)!, currency_id:i8!, branch_id:i8, cashbox_account_id:i8, bank_account_id:i8, gl_account_id:i8, is_active:b!=true +std
fk: bank_account_id→bank_accounts; branch_id→branches; cashbox_account_id→cashbox_accounts; currency_id→currencies; gl_account_id→gl_accounts
uq (bank_account_id); uq (cashbox_account_id)
ck: ck_financial_accounts_source: (type='CASH' AND cashbox_account_id IS NOT NULL AND bank_account_id IS NULL) OR (type='BANK' AND bank_account_id IS NOT NULL AND cashbox_account_id IS NULL)
tg: audit=audit_row()@Aiud, guard=financial_account_guard()@Biu, set_updated_at@Bu
rls: on | read: perm[finance.view,finance.manage,finance.payments,accounting.view,pos.session,pos.manage,reconcile.cash,sales.post] AND (branch_id IS NULL OR can_access_branch(branch_id)) | write: perm[finance.manage] AND (branch_id IS NULL OR can_access_branch(branch_id, operate))

#### financial_transactions
cols: id:i8*=ID, financial_account_id:i8!, transaction_type:v(25)!, direction:v(3)!, amount:n(20,4)!, currency_id:i8!, pos_session_id:i8, source_payment_line_id:i8, source_expense_id:i8, source_money_transfer_id:i8, source_cash_reconciliation_id:i8, reference_type:v(50), reference_id:i8, created_by:u, transaction_date:ts!, notes:t +std
fk: created_by→users; currency_id→currencies; financial_account_id→financial_accounts; pos_session_id→pos_sessions; source_cash_reconciliation_id→cash_reconciliations; source_expense_id→expenses; source_money_transfer_id→money_transfers; source_payment_line_id→payment_lines
uq (source_cash_reconciliation_id); uq (source_expense_id); uq (source_payment_line_id); uq (source_money_transfer_id, direction)
ck: ck_fin_tx_amount: amount > 0; ck_fin_tx_one_source: num_nonnulls(source_payment_line_id, source_expense_id, source_money_transfer_id, source_cash_reconciliation_id) <= 1
tg: actor=set_created_by()@Bi, append_only=forbid_change()@Bud, guard_ccy=account_currency_guard()@Bi, set_updated_at@Bu
rls: on | read: perm[finance.view,accounting.view,reconcile.cash,reports.view] AND EXISTS(financial_accounts a WHERE a.id = financial_account_id)

#### fiscal_periods
cols: id:i8*=ID, name:v(100)!, start_date:d!, end_date:d!, status:v(10)!='OPEN', closed_by:u, closed_at:ts +std
fk: closed_by→users
uq (start_date, end_date)
ck: ck_fiscal_periods_range: start_date <= end_date
tg: audit=audit_row()@Aiud, guard=fiscal_period_guard()@Bud, set_updated_at@Bu
rls: on | read: perm[accounting.view,accounting.manage,finance.view,finance.manage] | write: perm[accounting.manage]

#### genders
cols: id:i8*=ID, name:v(50)!, code:v(30)!, is_active:b!=true, sort_order:i4=0 +std
uq (code)
tg: set_updated_at@Bu
rls: on | read: true | write: perm[masterdata.manage]

#### gl_account_mappings
cols: id:i8*=ID, mapping_key:v(50)!, branch_id:i8, gl_account_id:i8! +std
fk: branch_id→branches; gl_account_id→gl_accounts
uq NULLS NOT DISTINCT (mapping_key, branch_id)
tg: audit=audit_row()@Aiud, set_updated_at@Bu
rls: on | read: perm[accounting.view,accounting.manage,finance.view,finance.manage] | write: perm[accounting.manage]

#### gl_accounts
cols: id:i8*=ID, parent_id:i8, code:v(30)!, name:v(200)!, account_type:v(20)!, normal_balance:v(6)!, is_postable:b!=true, is_system:b!=false, is_active:b!=true +std
fk: parent_id→gl_accounts
uq (code)
ck: ck_gl_accounts_parent: (parent_id IS NULL) OR (parent_id <> id)
tg: audit=audit_row()@Aiud, guard=gl_account_guard()@Biu, set_updated_at@Bu
rls: on | read: perm[accounting.view,accounting.manage,finance.view,finance.manage] | write: perm[accounting.manage]

#### inventory_balances
cols: id:i8*=ID, variant_id:i8!, warehouse_id:i8!, quantity_on_hand:n(20,4)!=0, quantity_reserved:n(20,4)!=0 +std
fk: variant_id→product_variants; warehouse_id→warehouses
uq (variant_id, warehouse_id)
ck: ck_inventory_reserved: quantity_reserved >= 0
tg: set_updated_at@Bu
rls: on | read: perm[inventory.view,accounting.view,reports.view] AND can_access_warehouse(warehouse_id)

#### journal_entries
cols: id:i8*=ID, entry_number:v(100)!, entry_date:d!, fiscal_period_id:i8!, branch_id:i8, description:t, source_type:v(50), source_id:i8, status:v(20)!='DRAFT', reversal_of_id:i8, created_by:u, posted_by:u, created_at:ts!=now, posted_at:ts +std
fk: branch_id→branches; created_by→users; fiscal_period_id→fiscal_periods; posted_by→users; reversal_of_id→journal_entries
uq (entry_number)
ux: ux_journal_entries_reversal_of (reversal_of_id) WHERE (reversal_of_id IS NOT NULL); ux_journal_source_once (source_type, source_id) WHERE (reversal_of_id IS NULL AND source_id IS NOT NULL AND source_type IN ('SALE','SALES_RETURN','PURCHASE','PURCHASE_RETURN','TRANSFER_SHIP','TRANSFER_RECEIVE','PAYMENT','EXPENSE','MONEY_TRANSFER','BALANCE_ADJ','STOCK_ADJ','CASH_RECON'))
ck: ck_journal_reversal: (reversal_of_id IS NULL) OR (reversal_of_id <> id)
tg: actor=set_created_by()@Bi, assign_number=assign_doc_number('entry_number', 'JOURNAL')@Bi, audit=audit_row()@Aiud, guard=journal_guard()@Biu, guard_perm=guard_status_permission('status', 'accounting.post')@Biu, journal_flip=journal_reversal_flip()@Au, protect_posted=protect_posted_doc('status')@Bud, set_updated_at@Bu
rls: on | read: perm[accounting.view,accounting.manage,accounting.post] AND (branch_id IS NULL OR can_access_branch(branch_id)) | write: perm[accounting.manage,accounting.post] AND (branch_id IS NULL OR can_access_branch(branch_id, operate))

#### journal_entry_lines
cols: id:i8*=ID, journal_entry_id:i8!, gl_account_id:i8!, party_id:i8, currency_id:i8!, debit:n(20,4)!=0, credit:n(20,4)!=0, exchange_rate:n(20,8)!=1, debit_base:n(20,4)!=0, credit_base:n(20,4)!=0, description:v(250) +std
fk: currency_id→currencies; gl_account_id→gl_accounts; journal_entry_id→journal_entries/cascade; party_id→parties
ck: ck_jel_amounts: debit >= 0 AND credit >= 0 AND (debit = 0 OR credit = 0) AND debit + credit > 0 AND debit_base >= 0 AND credit_base >= 0 AND (debit_base = 0 OR credit_base = 0) AND (debit > 0) = (debit_base > 0) AND (credit > 0) = (credit_base > 0); ck_jel_rate: exchange_rate > 0
tg: protect_items=protect_posted_children('journal_entries', 'journal_entry_id', 'status')@Biud, set_updated_at@Bu
rls: on | read: EXISTS(journal_entries p WHERE p.id = journal_entry_id) | write: perm[accounting.manage,accounting.post] AND EXISTS(journal_entries p WHERE p.id = journal_entry_id)

#### materials
cols: id:i8*=ID, name:v(100)!, code:v(50)!, material_type:v(20), description:t, is_active:b!=true +std
uq (code)
tg: set_updated_at@Bu
rls: on | read: true | write: perm[masterdata.manage]

#### money_transfers
cols: id:i8*=ID, from_account_id:i8!, to_account_id:i8!, from_amount:n(20,4)!, to_amount:n(20,4)!, exchange_rate:n(20,8), transfer_date:ts!, status:v(20)!='POSTED', reason_type:v(50), reason_id:i8, related_party_id:i8, created_by:u, notes:t, reversal_of_id:i8 +std
fk: created_by→users; from_account_id→financial_accounts; related_party_id→parties; reversal_of_id→money_transfers; to_account_id→financial_accounts
ux: ux_money_transfers_reversal_of (reversal_of_id) WHERE (reversal_of_id IS NOT NULL)
ck: ck_money_transfers_accounts: from_account_id <> to_account_id; ck_money_transfers_amounts: from_amount > 0 AND to_amount > 0; ck_money_transfers_fx: (exchange_rate IS NULL) OR (exchange_rate > 0); ck_money_transfers_reversal: (reversal_of_id IS NULL) OR (reversal_of_id <> id)
tg: actor=set_created_by()@Bi, audit=audit_row()@Aiud, forbid_direct_post('status', 'reversal_of_id')@Biu, guard=money_transfer_guard()@Biu, guard_perm=guard_status_permission('status', 'finance.manage')@Biu, protect_posted=protect_posted_doc('status')@Bud, set_updated_at@Bu
rls: on | read: perm[finance.view,finance.manage,accounting.view] AND (EXISTS(financial_accounts a WHERE a.id = from_account_id) OR EXISTS(financial_accounts a WHERE a.id = to_account_id)) | write: perm[finance.manage] AND EXISTS(financial_accounts a WHERE a.id = from_account_id) AND EXISTS(financial_accounts a WHERE a.id = to_account_id)

#### option_sets
cols: id:i8*=ID, name:v(100)!, code:v(50)!, selection_type:v(20)!='single', is_active:b!=true +std
uq (code)
tg: set_updated_at@Bu
rls: on | read: true | write: perm[masterdata.manage]

#### options
cols: id:i8*=ID, option_set_id:i8!, name:v(100)!, code:v(50)!, sort_order:i4=0, is_active:b!=true +std
fk: option_set_id→option_sets
uq (id, option_set_id); uq (option_set_id, code)
tg: set_updated_at@Bu
rls: on | read: true | write: perm[masterdata.manage]

#### owners
cols: id:i8*=ID, party_id:i8!, ownership_percentage:n(8,4), is_active:b!=true +std
fk: party_id→parties
uq (party_id)
ck: ck_owners_pct: (ownership_percentage IS NULL) OR (ownership_percentage >= 0 AND ownership_percentage <= 100)
tg: audit=audit_row()@Aiud, set_updated_at@Bu
rls: on | read: perm[owner.transactions,accounting.view] | write: perm[owner.transactions]

#### parties
note: الطرف الموحد: نفس الطرف قد يكون زبوناً ومورداً وموظفاً.
cols: id:i8*=ID, code:v(50), party_type:v(20)!, name:v(200)!, phone:v(50), whatsapp:v(50), email:v(150), address:t, is_active:b!=true, created_at:ts!=now +std
uq (code)
tg: audit=audit_row()@Aiud, set_updated_at@Bu
rls: on | read: perm[parties.view] | write: perm[parties.manage]

#### party_ledger_entries
cols: id:i8*=ID, party_id:i8!, currency_id:i8!, entry_date:ts!, entry_type:v(30)!, debit:n(20,4)!=0, credit:n(20,4)!=0, source_type:v(50), source_id:i8, created_at:ts!=now +std
fk: currency_id→currencies; party_id→parties
ck: ck_ledger_amounts: debit >= 0 AND credit >= 0 AND ((debit = 0) <> (credit = 0))
tg: append_only=forbid_change()@Bud, set_updated_at@Bu
rls: on | read: perm[parties.view,accounting.view,finance.view,reports.view]

#### payment_allocations
cols: id:i8*=ID, payment_id:i8!, payment_line_id:i8, parent_allocation_id:i8, party_id:i8, sale_id:i8, purchase_invoice_id:i8, sales_return_id:i8, purchase_return_id:i8, debt_currency_id:i8!, source_currency_id:i8!, settled_amount:n(20,4)!, source_amount:n(20,4)!, exchange_rate:n(20,8), allocation_type:v(25)!, notes:t +std
fk: debt_currency_id→currencies; parent_allocation_id→payment_allocations; party_id→parties; payment_id→payments/cascade; payment_line_id→payment_lines; purchase_invoice_id→purchase_invoices; purchase_return_id→purchase_returns; sale_id→sales; sales_return_id→sales_returns; source_currency_id→currencies
ck: ck_payment_alloc_amounts: settled_amount > 0 AND source_amount > 0; ck_payment_alloc_doc_by_type: (allocation_type = 'ADVANCE' AND num_nonnulls(sale_id, purchase_invoice_id, sales_return_id, purchase_return_id) = 0 AND party_id IS NOT NULL) OR (allocation_type IN ('DEBT','REFUND','ADVANCE_APPLICATION') AND num_nonnulls(sale_id, purchase_invoice_id, sales_return_id, purchase_return_id) = 1); ck_payment_alloc_fx: (exchange_rate IS NULL) OR (exchange_rate > 0); ck_payment_alloc_one_doc: num_nonnulls(sale_id, purchase_invoice_id, sales_return_id, purchase_return_id) <= 1; ck_payment_alloc_parent: (allocation_type <> 'ADVANCE_APPLICATION') OR (parent_allocation_id IS NOT NULL)
tg: audit=audit_row()@Aiud, guard=payment_allocation_guard()@Biu, protect_items=protect_posted_children('payments', 'payment_id', 'status', 'Y')@Biud, set_updated_at@Bu
rls: on | read: EXISTS(payments p WHERE p.id = payment_id) | write: perm[finance.payments,payment.cancel] AND EXISTS(payments p WHERE p.id = payment_id AND can_access_branch(p.branch_id, operate))

#### payment_lines
cols: id:i8*=ID, payment_id:i8!, financial_account_id:i8!, currency_id:i8!, amount:n(20,4)!, direction:v(3)!, line_type:v(30)!='PAYMENT', parent_line_id:i8, payment_method:v(30)='CASH', exchange_rate:n(20,8), reference_number:v(100), notes:t +std
fk: currency_id→currencies; financial_account_id→financial_accounts; parent_line_id→payment_lines; payment_id→payments/cascade
ck: ck_payment_lines_amount: amount > 0; ck_payment_lines_change: (line_type <> 'CHANGE_GIVEN') OR (parent_line_id IS NOT NULL); ck_payment_lines_fx: (exchange_rate IS NULL) OR (exchange_rate > 0); ck_payment_lines_method: (payment_method IS NULL) OR payment_method IN ('CASH','CARD','BANK_TRANSFER','CHEQUE','E_WALLET'); ck_payment_lines_parent: (parent_line_id IS NULL) OR (parent_line_id <> id)
tg: guard=payment_line_guard()@Biu, guard_ccy=account_currency_guard()@Biu, protect_items=protect_posted_children('payments', 'payment_id', 'status', 'Y')@Biud, set_updated_at@Bu
rls: on | read: EXISTS(payments p WHERE p.id = payment_id) | write: perm[finance.payments,payment.cancel] AND EXISTS(payments p WHERE p.id = payment_id AND can_access_branch(p.branch_id, operate))

#### payment_reasons
cols: id:i8*=ID, code:v(50)!, name:v(150)!, applies_to:v(20)!, payment_type:v(30), gl_account_id:i8, is_active:b!=true +std
fk: gl_account_id→gl_accounts
uq (code)
ck: ck_payment_reasons_type: (payment_type IS NULL) OR payment_type IN ('SUPPLIER_PAYMENT','CUSTOMER_RECEIPT','EMPLOYEE_PAYMENT','OWNER_WITHDRAWAL','OWNER_CONTRIBUTION','REFUND')
tg: audit=audit_row()@Aiud, set_updated_at@Bu
rls: on | read: true | write: perm[accounting.manage,finance.manage]

#### payments
note: لا يوجد trigger forbid_direct_post على payments، ولا عمود payment_number (الرقم = reference_number، ويولَّد لمستندات apply_advance بـ next_doc_number('PAYMENT')).
cols: id:i8*=ID, party_id:i8, branch_id:i8!, pos_session_id:i8, payment_type:v(30)!, payment_context:v(30)!='REGULAR_PAYMENT', reason_id:i8, status:v(20)!='POSTED', payment_date:ts!, reference_number:v(100), reversal_of_payment_id:i8, notes:t, created_by:u, created_at:ts!=now +std
fk: branch_id→branches; created_by→users; party_id→parties; pos_session_id→pos_sessions; reason_id→payment_reasons; reversal_of_payment_id→payments
ux: ux_payments_reversal_of (reversal_of_payment_id) WHERE (reversal_of_payment_id IS NOT NULL)
ck: ck_payments_reversal: (reversal_of_payment_id IS NULL) OR (reversal_of_payment_id <> id)
tg: actor=set_created_by()@Bi, audit=audit_row()@Aiud, guard_perm=guard_status_permission('status', 'finance.payments', 'payment.cancel')@Biu, protect_posted=protect_posted_doc('status')@Bud, reason_guard('PAYMENT')@Biu, set_updated_at@Bu
rls: on | read: perm[finance.view,finance.payments,payment.cancel,accounting.view,sales.view,purchasing.view,reports.view] AND can_access_branch(branch_id) | write: perm[finance.payments,payment.cancel] AND can_access_branch(branch_id, operate)

#### permissions
cols: id:i8*=ID, code:v(100)!, name:v(150)!, module:v(80)!, description:t +std
uq (code)
tg: set_updated_at@Bu
rls: on | read: true | write: is_super_admin()

#### pos_session_balances
cols: id:i8*=ID, pos_session_id:i8!, currency_id:i8!, opening_amount:n(20,4)!=0 +std
fk: currency_id→currencies; pos_session_id→pos_sessions/cascade
uq (pos_session_id, currency_id)
ck: ck_pos_session_balances_open: opening_amount >= 0
tg: set_updated_at@Bu
rls: on | read: EXISTS(pos_sessions p WHERE p.id = pos_session_id) | write: perm[pos.session,pos.manage] AND EXISTS(pos_sessions p WHERE p.id = pos_session_id)

#### pos_sessions
cols: id:i8*=ID, pos_terminal_id:i8!, cashier_user_id:u!, opened_at:ts!, closed_at:ts, status:v(20)!='OPEN', closed_by:u, notes:t +std
fk: cashier_user_id→users; closed_by→users; pos_terminal_id→pos_terminals
ux: ux_pos_sessions_one_open_per_cashier (cashier_user_id) WHERE (status = 'OPEN')
ck: ck_pos_sessions_closed: (status = 'OPEN' AND closed_at IS NULL AND closed_by IS NULL) OR (status = 'CLOSED' AND closed_at IS NOT NULL); ck_pos_sessions_dates: (closed_at IS NULL) OR (closed_at >= opened_at)
tg: audit=audit_row()@Aiud, guard=pos_session_guard()@Biu, pos_assignment=pos_session_assignment_guard()@Bi, set_updated_at@Bu
rls: on | read: perm[pos.session,pos.manage,finance.view,reconcile.cash,sales.view] AND (cashier_user_id = auth.uid() OR EXISTS(pos_terminals t WHERE t.id = pos_terminal_id AND can_access_branch(t.branch_id))) | write: perm[pos.session,pos.manage] AND (cashier_user_id = auth.uid() OR perm[pos.manage]) AND EXISTS(pos_terminals t WHERE t.id = pos_terminal_id AND can_access_branch(t.branch_id, operate))

#### pos_terminal_price_lists
cols: id:i8*=ID, pos_terminal_id:i8!, price_list_id:i8!, is_default:b!=false +std
fk: pos_terminal_id→pos_terminals/cascade; price_list_id→price_lists/cascade
uq (pos_terminal_id, price_list_id)
ux: ux_pos_terminal_price_lists_one_default (pos_terminal_id) WHERE is_default
tg: audit=audit_row()@Aiud, set_updated_at@Bu
rls: on | read: true | write: perm[pos.manage,users.manage]

#### pos_terminals
cols: id:i8*=ID, branch_id:i8!, name:v(100)!, code:v(50)!, cashbox_id:i8, default_bank_account_id:i8, default_warehouse_id:i8, is_active:b!=true +std
fk: branch_id→branches; cashbox_id→cashboxes; default_bank_account_id→bank_accounts; default_warehouse_id→warehouses
uq (code)
tg: audit=audit_row()@Aiud, set_updated_at@Bu
rls: on | read: perm[pos.session,pos.manage,sales.create,sales.view,finance.view] AND can_access_branch(branch_id) | write: perm[pos.manage] AND can_access_branch(branch_id, operate)

#### price_lists
cols: id:i8*=ID, name:v(100)!, code:v(50)!, currency_id:i8!, price_type:v(20)!, is_default:b!=false, is_active:b!=true +std
fk: currency_id→currencies
uq (code)
tg: audit=audit_row()@Aiud, set_updated_at@Bu
rls: on | read: true | write: perm[pricing.manage]

#### price_rules
cols: id:i8*=ID, name:v(150)!, code:v(50)!, calculation_method:v(20)!, percentage:n(8,4)!, product_type_id:i8, category_id:i8, brand_id:i8, product_id:i8, price_list_id:i8, target_currency_id:i8, priority:i4!=0, is_active:b!=true, cost_basis:v!='last_purchase' +std
fk: brand_id→brands; category_id→categories; price_list_id→price_lists; product_id→products; product_type_id→product_types; target_currency_id→currencies
uq (code)
ck: ck_price_rules_pct: percentage >= 0 AND (calculation_method <> 'margin' OR percentage < 100)
tg: audit=audit_row()@Aiud, set_updated_at@Bu
rls: on | read: perm[pricing.manage,costs.view] | write: perm[pricing.manage]

#### product_age_groups
cols: product_id:i8*, age_group_id:i8* +std
fk: age_group_id→age_groups; product_id→products/cascade
tg: set_updated_at@Bu
rls: on | read: true | write: perm[catalog.manage]

#### product_attribute_values
cols: product_id:i8*, attribute_id:i8*, value_text:v(500), value_number:n(20,6), value_boolean:b, value_date:d, value_json:j, option_id:i8 +std
fk: attribute_id→attributes; option_id→options; product_id→products/cascade
ck: ck_pav_one_value: num_nonnulls(value_text, value_number, value_boolean, value_date, value_json, option_id) = 1
tg: pav_guard=product_attribute_value_guard()@Biu, set_updated_at@Bu
rls: on | read: true | write: perm[catalog.manage]

#### product_care_instructions
cols: product_id:i8*, care_instruction_id:i8*, sort_order:i4=0, notes:t +std
fk: care_instruction_id→care_instructions; product_id→products/cascade
tg: set_updated_at@Bu
rls: on | read: true | write: perm[catalog.manage]

#### product_categories
cols: product_id:i8*, category_id:i8*, is_primary:b!=false +std
fk: category_id→categories; product_id→products/cascade
ux: ux_pc_one_primary (product_id) WHERE is_primary
tg: set_updated_at@Bu
rls: on | read: true | write: perm[catalog.manage]

#### product_collections
cols: product_id:i8*, collection_id:i8* +std
fk: collection_id→collections; product_id→products/cascade
tg: set_updated_at@Bu
rls: on | read: true | write: perm[catalog.manage]

#### product_color_components
note: تركيبة اللون النهائي. part_name فارغ = على كامل القطعة. percentage = نسبة اللون داخل الجزء (مجموع كل جزء = 100).
cols: id:i8*=ID, product_color_id:i8!, color_id:i8!, part_name:v, percentage:n!=100, is_primary:b!=false, sort_order:i4=0 +std
fk: color_id→colors; product_color_id→product_colors/cascade
ux: ux_pcc_component (product_color_id, COALESCE(part_name, ''), color_id); ux_pcc_one_primary (product_color_id) WHERE is_primary
ix: ix_pcc_color_id (color_id)
ck: product_color_components_part_name_check: (part_name IS NULL) OR (length(TRIM(BOTH FROM part_name)) > 0); product_color_components_percentage_check: percentage > 0 AND percentage <= 100
tg: check_color_components=trg_check_color_components()@Aiud, set_updated_at@Bu
rls: on | read: true | write: perm[catalog.manage]

#### product_colors
note: اللون النهائي للموديل (قد يكون مركباً: أحمر/أسود). المتغيرات ترتبط به مباشرة وكذلك صور الألوان.
cols: id:i8*=ID, product_id:i8!, name:v!, sort_order:i4=0 +std
fk: product_id→products/cascade
uq (id, product_id); uq (product_id, name)
ck: product_colors_name_check: length(TRIM(BOTH FROM name)) > 0
tg: audit=audit_row()@Aiud, set_updated_at@Bu
rls: on | read: true | write: perm[catalog.manage]

#### product_fabrics
cols: product_id:i8*, fabric_type_id:i8*, is_primary:b!=false, notes:t +std
fk: fabric_type_id→fabric_types; product_id→products/cascade
ux: ux_pf_one_primary (product_id) WHERE is_primary
tg: set_updated_at@Bu
rls: on | read: true | write: perm[catalog.manage]

#### product_genders
cols: product_id:i8*, gender_id:i8* +std
fk: gender_id→genders; product_id→products/cascade
tg: set_updated_at@Bu
rls: on | read: true | write: perm[catalog.manage]

#### product_images
cols: id:i8*=ID, product_id:i8!, image_url:v(500)!, image_type:v(20)!='other', alt_text:v(250), is_primary:b!=false, sort_order:i4=0 +std
fk: product_id→products/cascade
ux: ux_pi_one_primary (product_id) WHERE is_primary
tg: audit=audit_row()@Aiud, set_updated_at@Bu
rls: on | read: true | write: perm[catalog.manage]

#### product_materials
cols: product_id:i8*, material_id:i8*, percentage:n(8,4)!, is_primary:b!=false +std
fk: material_id→materials; product_id→products/cascade
ux: ux_pm_one_primary (product_id) WHERE is_primary
ck: product_materials_percentage_check: percentage > 0 AND percentage <= 100
tg: materials_total=check_materials_total()@Aiud, set_updated_at@Bu
rls: on | read: true | write: perm[catalog.manage]

#### product_option_values
cols: product_id:i8*, option_set_id:i8*, option_id:i8*, sort_order:i4=0 +std
fk: option_id,option_set_id→options.id,option_set_id; option_set_id→option_sets; product_id→products/cascade
tg: pov_guard=product_option_value_guard()@Biu, set_updated_at@Bu
rls: on | read: true | write: perm[catalog.manage]

#### product_seasons
cols: product_id:i8*, season_id:i8* +std
fk: product_id→products/cascade; season_id→seasons
tg: set_updated_at@Bu
rls: on | read: true | write: perm[catalog.manage]

#### product_size_groups
cols: product_id:i8*, size_group_id:i8*, is_default:b!=false, sort_order:i4=0 +std
fk: product_id→products/cascade; size_group_id→size_groups
ux: ux_psg_one_default (product_id) WHERE is_default
tg: set_updated_at@Bu
rls: on | read: true | write: perm[catalog.manage]

#### product_sizes
cols: product_id:i8*, size_id:i8*, is_additional:b!=false, sort_order:i4=0 +std
fk: product_id→products/cascade; size_id→sizes
tg: set_updated_at@Bu
rls: on | read: true | write: perm[catalog.manage]

#### product_sports
cols: product_id:i8*, sport_id:i8* +std
fk: product_id→products/cascade; sport_id→sports
tg: set_updated_at@Bu
rls: on | read: true | write: perm[catalog.manage]

#### product_tags
cols: product_id:i8*, tag_id:i8* +std
fk: product_id→products/cascade; tag_id→tags
tg: set_updated_at@Bu
rls: on | read: true | write: perm[catalog.manage]

#### product_type_attributes
cols: product_type_id:i8*, attribute_id:i8*, is_required:b!=false, sort_order:i4=0 +std
fk: attribute_id→attributes; product_type_id→product_types
tg: set_updated_at@Bu
rls: on | read: true | write: perm[masterdata.manage]

#### product_type_care_instructions
cols: product_type_id:i8*, care_instruction_id:i8*, is_required:b!=false, sort_order:i4=0 +std
fk: care_instruction_id→care_instructions; product_type_id→product_types
tg: set_updated_at@Bu
rls: on | read: true | write: perm[masterdata.manage]

#### product_type_option_sets
cols: product_type_id:i8*, option_set_id:i8*, is_required:b!=false, sort_order:i4=0 +std
fk: option_set_id→option_sets; product_type_id→product_types
tg: set_updated_at@Bu
rls: on | read: true | write: perm[masterdata.manage]

#### product_type_size_groups
cols: id:i8*=ID, product_type_id:i8!, size_group_id:i8!, gender_id:i8, is_default:b!=false, sort_order:i4=0 +std
fk: gender_id→genders; product_type_id→product_types; size_group_id→size_groups
ux: ux_pt_size_groups (product_type_id, size_group_id, gender_id) NULLS NOT DISTINCT; ux_pt_size_groups_one_default (product_type_id, gender_id) NULLS NOT DISTINCT WHERE is_default
tg: set_updated_at@Bu
rls: on | read: true | write: perm[masterdata.manage]

#### product_types
cols: id:i8*=ID, name:v(150)!, code:v(50)!, description:t, is_active:b!=true, sort_order:i4=0 +std
uq (code)
tg: guard_discount_target_ref=trg_block_delete_discount_target_ref('product_type')@Bd, set_updated_at@Bu
rls: on | read: true | write: perm[masterdata.manage]

#### product_variants
cols: id:i8*=ID, product_id:i8!, sku:v(100)!, variant_key:v(200)!, variant_name:v(250), unit_id:i8, is_default:b!=false, is_active:b!=true, created_at:ts!=now, size_id:i8, product_color_id:i8 +std
fk: product_color_id,product_id→product_colors.id,product_id; product_id,size_id→product_sizes.product_id,size_id; product_id→products; unit_id→units
uq (product_id, variant_key); uq (sku)
ux: ux_pv_one_default (product_id) WHERE is_default
tg: audit=audit_row()@Aiud, guard_discount_target_ref=trg_block_delete_discount_target_ref('product')@Bd, pv_variant_key=trg_pv_variant_key()@Biu(of size_id, product_color_id), set_updated_at@Bu
rls: on | read: true | write: perm[catalog.manage]

#### products
note: المنتج/الموديل. status=published هو ما سيظهر في المتجر الإلكتروني مستقبلاً.
cols: id:i8*=ID, name:v(250)!, slug:v(250)!, product_type_id:i8!, brand_id:i8, origin_country_id:i8, authenticity_status:v(20)!='unknown', description:t, model_code:v(100), status:v(20)!='draft', created_at:ts!=now +std
fk: brand_id→brands; origin_country_id→countries; product_type_id→product_types
uq (slug)
ix: ix_products_brand_model (brand_id, model_code) — يغطي products.brand_id
tg: audit=audit_row()@Aiud, guard_discount_target_ref=trg_block_delete_discount_target_ref('variant')@Bd, product_publish_guard@Biu(of status, product_type_id), set_updated_at@Bu
rls: on | read: true | write: perm[catalog.manage]

#### purchase_invoice_items
cols: id:i8*=ID, purchase_invoice_id:i8!, variant_id:i8!, warehouse_id:i8!, quantity:n(20,4)!, unit_cost:n(20,4)!, discount:n(20,4)!=0, tax_rate_id:i8, tax_amount:n(20,4)!=0, total_cost:n(20,4)!, notes:t +std
fk: purchase_invoice_id→purchase_invoices/cascade; tax_rate_id→tax_rates; variant_id→product_variants; warehouse_id→warehouses
ck: ck_purchase_items: quantity > 0 AND unit_cost >= 0 AND discount >= 0 AND tax_amount >= 0 AND total_cost >= 0
tg: protect_items=protect_posted_children('purchase_invoices', 'purchase_invoice_id', 'doc_status')@Biud, set_updated_at@Bu
rls: on | read: EXISTS(purchase_invoices p WHERE p.id = purchase_invoice_id) | write: perm[purchasing.create,purchasing.post] AND EXISTS(purchase_invoices p WHERE p.id = purchase_invoice_id AND can_access_branch(p.branch_id, operate))

#### purchase_invoices
cols: id:i8*=ID, supplier_id:i8!, branch_id:i8!, currency_id:i8!, exchange_rate:n(20,8)!=1, invoice_number:v(100), invoice_date:d!, due_date:d, subtotal:n(20,4)!=0, discount:n(20,4)!=0, tax:n(20,4)!=0, total_amount:n(20,4)!, total_base:n(20,4)!=0, doc_status:v(20)!='DRAFT', payment_status:v(20)!='UNPAID', notes:t, created_by:u, created_at:ts!=now, posted_at:ts +std
fk: branch_id→branches; created_by→users; currency_id→currencies; supplier_id→suppliers
uq (supplier_id, invoice_number)
ck: ck_purchase_inv_amounts: subtotal >= 0 AND discount >= 0 AND tax >= 0 AND total_amount >= 0 AND total_base >= 0; ck_purchase_inv_due: (due_date IS NULL) OR (due_date >= invoice_date); ck_purchase_inv_rate: exchange_rate > 0; ck_purchase_inv_total: total_amount = (subtotal - discount) + tax
tg: actor=set_created_by()@Bi, audit=audit_row()@Aiud, guard_perm=guard_status_permission('doc_status', 'purchasing.post', 'purchasing.return')@Biu, protect_posted=protect_posted_doc('doc_status', 'payment_status')@Bud, set_updated_at@Bu
rls: on | read: perm[purchasing.view,purchasing.create,purchasing.post,accounting.view,reports.view,finance.view] AND can_access_branch(branch_id) | write: perm[purchasing.create,purchasing.post] AND can_access_branch(branch_id, operate)

#### purchase_return_items
cols: id:i8*=ID, purchase_return_id:i8!, purchase_invoice_item_id:i8!, variant_id:i8!, quantity:n(20,4)!, unit_cost:n(20,4)!, total_cost:n(20,4)!, notes:t +std
fk: purchase_invoice_item_id→purchase_invoice_items; purchase_return_id→purchase_returns/cascade; variant_id→product_variants
ck: ck_purchase_ret_items: quantity > 0 AND unit_cost >= 0 AND total_cost >= 0
tg: guard=purchase_return_item_guard()@Biu, protect_items=protect_posted_children('purchase_returns', 'purchase_return_id', 'status')@Biud, set_updated_at@Bu
rls: on | read: EXISTS(purchase_returns p WHERE p.id = purchase_return_id) | write: perm[purchasing.return] AND EXISTS(purchase_returns p WHERE p.id = purchase_return_id AND can_access_branch(p.branch_id, operate))

#### purchase_returns
cols: id:i8*=ID, return_number:v(100)!, purchase_invoice_id:i8!, supplier_id:i8!, branch_id:i8!, warehouse_id:i8!, currency_id:i8!, return_date:ts!, status:v(20)!='DRAFT', settlement_method:v(20)!='SUPPLIER_CREDIT', return_reason:v(250), refund_payment_id:i8, subtotal:n(20,4)!=0, total_base:n(20,4)!=0, notes:t, created_by:u, created_at:ts!=now, posted_at:ts +std
fk: branch_id→branches; created_by→users; currency_id→currencies; purchase_invoice_id→purchase_invoices; refund_payment_id→payments; supplier_id→suppliers; warehouse_id→warehouses
uq (return_number)
ck: ck_purchase_ret_amounts: subtotal >= 0 AND total_base >= 0; ck_purchase_ret_refund: (status <> 'POSTED') OR (settlement_method <> 'CASH_REFUND') OR (refund_payment_id IS NOT NULL)
tg: actor=set_created_by()@Bi, assign_number=assign_doc_number('return_number', 'RETURN')@Bi, audit=audit_row()@Aiud, guard=purchase_return_guard()@Bi, guard_perm=guard_status_permission('status', 'purchasing.return')@Biu, protect_posted=protect_posted_doc('status')@Bud, set_updated_at@Bu
rls: on | read: perm[purchasing.view,purchasing.return,accounting.view,reports.view,finance.view] AND can_access_branch(branch_id) | write: perm[purchasing.return] AND can_access_branch(branch_id, operate)

#### role_permissions
cols: id:i8*=ID, role_id:i8!, permission_id:i8! +std
fk: permission_id→permissions/cascade; role_id→roles/cascade
uq (role_id, permission_id)
tg: audit=audit_row()@Aiud, guard=role_permissions_guard()@Biud, set_updated_at@Bu
rls: on | read: true | write: perm[users.manage]

#### roles
cols: id:i8*=ID, code:v(50)!, name:v(100)!, description:t, is_system_role:b!=false, is_active:b!=true +std
uq (code)
tg: audit=audit_row()@Aiud, guard=roles_guard()@Biud, set_updated_at@Bu
rls: on | read: true | write: perm[users.manage]

#### sale_items
cols: id:i8*=ID, sale_id:i8!, variant_id:i8!, warehouse_id:i8!, quantity:n(20,4)!, list_price:n(20,4)!, list_price_currency_id:i8!, price_exchange_rate:n(20,8), unit_price:n(20,4)!, unit_cost:n(20,4), unit_cost_currency_id:i8, discount_id:i8, discount:n(20,4)!=0, tax_rate_id:i8, tax_amount:n(20,4)!=0, total_price:n(20,4)! +std
fk: discount_id→discounts; list_price_currency_id→currencies; sale_id→sales/cascade; tax_rate_id→tax_rates; unit_cost_currency_id→currencies; variant_id→product_variants; warehouse_id→warehouses
ck: ck_sale_items: quantity > 0 AND list_price >= 0 AND unit_price >= 0 AND discount >= 0 AND tax_amount >= 0 AND total_price >= 0; ck_sale_items_cost: (unit_cost IS NULL) OR (unit_cost >= 0 AND unit_cost_currency_id IS NOT NULL); ck_sale_items_fx: (price_exchange_rate IS NULL) OR (price_exchange_rate > 0)
tg: guard=sale_item_guard()@Biu, protect_items=protect_posted_children('sales', 'sale_id', 'doc_status')@Biud, set_updated_at@Bu
rls: on | read (p_read بدور `public` لا `authenticated`): EXISTS(sales p WHERE p.id = sale_id AND can_access_branch(p.branch_id) AND has_any_permission[sales.view,sales.create,sales.post,reports.view,accounting.view,finance.view]) | write: perm[sales.create,sales.post] AND EXISTS(sales p WHERE p.id = sale_id AND can_access_branch(p.branch_id, operate))

#### sales
cols: id:i8*=ID, branch_id:i8!, pos_terminal_id:i8, pos_session_id:i8, customer_id:i8, channel:v(20)!='POS', invoice_number:v(100)!, invoice_code:v(40), sale_date:ts!, due_date:d, currency_id:i8!, exchange_rate:n(20,8)!=1, subtotal:n(20,4)!=0, discount_id:i8, discount:n(20,4)!=0, tax:n(20,4)!=0, rounding_amount:n(20,4)!=0, total_amount:n(20,4)!, total_base:n(20,4)!=0, doc_status:v(20)!='DRAFT', payment_status:v(20)!='UNPAID', notes:t, created_by:u, created_at:ts!=now, posted_at:ts, price_list_id:i8 +std
fk: branch_id→branches; created_by→users; currency_id→currencies; customer_id→customers; discount_id→discounts; pos_session_id→pos_sessions; pos_terminal_id→pos_terminals; price_list_id→price_lists
uq (invoice_code); uq (branch_id, invoice_number)
ck: ck_sales_amounts: subtotal >= 0 AND discount >= 0 AND tax >= 0 AND total_amount >= 0 AND total_base >= 0; ck_sales_rate: exchange_rate > 0
tg: actor=set_created_by()@Bi, assign_code=assign_invoice_code()@Bi, assign_number=assign_doc_number('invoice_number', 'SALE')@Bi, audit=audit_row()@Aiud, guard_perm=guard_status_permission('doc_status', 'sales.post', 'sales.return')@Biu, protect_posted=protect_posted_doc('doc_status', 'payment_status')@Bud, sale_guard=sale_header_guard()@Biu, set_updated_at@Bu
rls: on | read: perm[sales.view,sales.create,sales.post,reports.view,accounting.view,finance.view] AND can_access_branch(branch_id) | write: perm[sales.create,sales.post] AND can_access_branch(branch_id, operate)

#### sales_return_items
cols: id:i8*=ID, sales_return_id:i8!, sale_item_id:i8!, variant_id:i8!, quantity:n(20,4)!, unit_refund_price:n(20,4)!, total_refund:n(20,4)!, condition_type:v(20)!='SELLABLE', return_reason:v(250), restock:b!=true, notes:t +std
fk: sale_item_id→sale_items; sales_return_id→sales_returns/cascade; variant_id→product_variants
ck: ck_sales_ret_items: quantity > 0 AND unit_refund_price >= 0 AND total_refund >= 0
tg: guard=sales_return_item_guard()@Biu, protect_items=protect_posted_children('sales_returns', 'sales_return_id', 'status')@Biud, set_updated_at@Bu
rls: on | read: EXISTS(sales_returns p WHERE p.id = sales_return_id) | write: perm[sales.return] AND EXISTS(sales_returns p WHERE p.id = sales_return_id AND can_access_branch(p.branch_id, operate))

#### sales_returns
cols: id:i8*=ID, return_number:v(100)!, sale_id:i8!, customer_id:i8, branch_id:i8!, warehouse_id:i8!, currency_id:i8!, return_date:ts!, status:v(20)!='DRAFT', refund_method:v(20)!='CUSTOMER_CREDIT', refund_payment_id:i8, subtotal:n(20,4)!=0, total_base:n(20,4)!=0, notes:t, created_by:u, created_at:ts!=now, posted_at:ts +std
fk: branch_id→branches; created_by→users; currency_id→currencies; customer_id→customers; refund_payment_id→payments; sale_id→sales; warehouse_id→warehouses
uq (return_number)
ck: ck_sales_ret_amounts: subtotal >= 0 AND total_base >= 0; ck_sales_ret_refund: (status <> 'POSTED') OR (refund_method <> 'CASH_REFUND') OR (refund_payment_id IS NOT NULL)
tg: actor=set_created_by()@Bi, assign_number=assign_doc_number('return_number', 'RETURN')@Bi, audit=audit_row()@Aiud, guard=sales_return_guard()@Bi, guard_perm=guard_status_permission('status', 'sales.return')@Biu, protect_posted=protect_posted_doc('status')@Bud, set_updated_at@Bu
rls: on | read: perm[sales.view,sales.return,reports.view,accounting.view,finance.view] AND can_access_branch(branch_id) | write: perm[sales.return] AND can_access_branch(branch_id, operate)

#### seasons
cols: id:i8*=ID, name:v(100)!, code:v(50)!, season_type:v(20), start_date:d, end_date:d, is_active:b!=true +std
uq (code)
tg: set_updated_at@Bu
rls: on | read: true | write: perm[masterdata.manage]

#### settings
cols: id:i8*=ID, scope_type:v(10)!='GLOBAL', branch_id:i8, user_id:u, setting_key:v(80)!, value_text:v(500)!, updated_by:u +std
fk: branch_id→branches; updated_by→users; user_id→users
ux: ux_settings_branch (branch_id, setting_key) WHERE (scope_type = 'BRANCH'); ux_settings_global (setting_key) WHERE (scope_type = 'GLOBAL'); ux_settings_user (user_id, setting_key) WHERE (scope_type = 'USER')
ck: ck_settings_scope_cols: (scope_type='GLOBAL' AND branch_id IS NULL AND user_id IS NULL) OR (scope_type='BRANCH' AND branch_id IS NOT NULL AND user_id IS NULL) OR (scope_type='USER' AND user_id IS NOT NULL AND branch_id IS NULL)
tg: audit=audit_row()@Aiud, set_updated_at@Bu, set_updated_by@Biu
rls: on | read: scope_type='GLOBAL' OR (scope_type='BRANCH' AND can_access_branch(branch_id)) OR (scope_type='USER' AND user_id = auth.uid()) OR perm[settings.manage] | write: perm[settings.manage] OR (scope_type='USER' AND user_id = auth.uid())

#### size_groups
cols: id:i8*=ID, size_system_id:i8!, gender_id:i8, name:v(150)!, code:v(50)!, description:t, is_active:b!=true +std
fk: gender_id→genders; size_system_id→size_systems
uq (code)
tg: set_updated_at@Bu
rls: on | read: true | write: perm[masterdata.manage]

#### size_ranges
cols: id:i8*=ID, size_group_id:i8!, name:v(150)!, from_size_id:i8!, to_size_id:i8!, step:n(8,2)!=1, is_active:b!=true +std
fk: from_size_id→sizes; size_group_id→size_groups; to_size_id→sizes
ck: size_ranges_step_check: step > 0
tg: set_updated_at@Bu
rls: on | read: true | write: perm[masterdata.manage]

#### size_systems
cols: id:i8*=ID, name:v(100)!, code:v(30)!, description:t, is_active:b!=true +std
uq (code)
tg: set_updated_at@Bu
rls: on | read: true | write: perm[masterdata.manage]

#### sizes
cols: id:i8*=ID, size_group_id:i8!, name:v(50)!, code:v(50)!, numeric_value:n(8,2), sort_order:i4=0, is_active:b!=true +std
fk: size_group_id→size_groups
uq (size_group_id, code)
tg: set_updated_at@Bu
rls: on | read: true | write: perm[masterdata.manage]

**مطابقة التنفيذ في Flutter (CAT-07 Sizes):**
- نموذج القراءة `CatalogSizeModel` يقرأ: `id,size_group_id,name,code,numeric_value,sort_order,is_active,updated_at`، ويحوّل `numeric_value` إلى Decimal.
- إسقاط القائمة يضيف `product_sizes(count)` لعداد الاستخدام، مع إسقاط احتياطي بلا العداد إذا أعاد PostgREST HTTP 400.
- Payload الإنشاء/التعديل يرسل فقط `size_group_id,name,code,numeric_value,sort_order,is_active`. لا يرسل `id` أو `updated_at` أو `uuid` أو `origin_node_id)؛ تُترك قيم الهوية/المزامنة والطابع الزمني للقاعدة.
- الإنشاء الفردي POST لكائن، والإنشاء الجماعي POST لمصفوفة مع `Prefer: return=representation`؛ لم تُثبت ذرّية POST المصفوفي بطلب API حي في فحص 2026-11-28.
- التعديل PATCH على `id=eq.<id>`، والتفعيل/الإيقاف PATCH لـ `is_active`، والحذف DELETE فعلي على `id`. لا يوجد في هذا المسار تحويل الحذف إلى soft delete.
- **فارق توثيق:** `+std` في سجل الجدول يشمل أعمدة البنية القياسية مثل `updated_at,uuid,origin_node_id`؛ هذه الأعمدة موجودة في القاعدة الحية لكنها ليست حقولاً يحررها نموذج Sizes. لا يوجد تعارض في FK أو UNIQUE: القاعدة الحية تؤكد FK إلى `size_groups` وUNIQUE على `(size_group_id,code)`.


#### sports
cols: id:i8*=ID, name:v(100)!, code:v(50)!, description:t, is_active:b!=true, sort_order:i4=0 +std
uq (code)
tg: set_updated_at@Bu
rls: on | read: true | write: perm[masterdata.manage]

#### stock_adjustment_items
cols: id:i8*=ID, stock_adjustment_id:i8!, variant_id:i8!, system_quantity:n(20,4)!, counted_quantity:n(20,4)!, difference_quantity:n(20,4)!, unit_cost:n(20,4), notes:t +std
fk: stock_adjustment_id→stock_adjustments/cascade; variant_id→product_variants
uq (stock_adjustment_id, variant_id)
ck: ck_stock_adjustment_items_qty: counted_quantity >= 0 AND difference_quantity = (counted_quantity - system_quantity)
tg: calc=stock_adj_item_calc()@Biu, protect_items=protect_posted_children('stock_adjustments', 'stock_adjustment_id', 'status')@Biud, set_updated_at@Bu
rls: on | read: EXISTS(stock_adjustments p WHERE p.id = stock_adjustment_id) | write: perm[inventory.adjust] AND EXISTS(stock_adjustments p WHERE p.id = stock_adjustment_id AND can_access_warehouse(p.warehouse_id, operate))

#### stock_adjustments
cols: id:i8*=ID, adjustment_number:v(100)!, warehouse_id:i8!, adjustment_date:ts!, status:v(20)!='DRAFT', reason:v(30)!, created_by:u, approved_by:u, posted_at:ts, notes:t, reversal_of_id:i8 +std
fk: approved_by→users; created_by→users; reversal_of_id→stock_adjustments; warehouse_id→warehouses
uq (adjustment_number)
ux: ux_stock_adjustments_reversal_of (reversal_of_id) WHERE (reversal_of_id IS NOT NULL)
tg: actor=set_created_by()@Bi, assign_number=assign_doc_number('adjustment_number', 'ADJUSTMENT')@Bi, audit=audit_row()@Aiud, forbid_direct_post('status', 'reversal_of_id')@Biu, guard_perm=guard_status_permission('status', 'inventory.adjust')@Biu, protect_posted=protect_posted_doc('status')@Bud, set_updated_at@Bu
rls: on | read: perm[inventory.view,inventory.adjust,accounting.view] AND can_access_warehouse(warehouse_id) | write: perm[inventory.adjust] AND can_access_warehouse(warehouse_id, operate)

#### stock_movements
cols: id:i8*=ID, variant_id:i8!, warehouse_id:i8!, movement_type:v(30)!, direction:v(3)!, quantity:n(20,4)!, unit_cost:n(20,4), currency_id:i8, reference_type:v(50), reference_id:i8, reference_item_id:i8, movement_date:ts!, created_by:u, created_at:ts!=now, notes:t +std
fk: created_by→users; currency_id→currencies; variant_id→product_variants; warehouse_id→warehouses
ck: ck_stock_movements_cost: (unit_cost IS NULL) OR (unit_cost >= 0 AND currency_id IS NOT NULL); ck_stock_movements_dir_match: (movement_type IN ('PURCHASE_IN','TRANSFER_IN','ADJUSTMENT_IN','SALES_RETURN','OPENING') AND direction = 'IN') OR (movement_type IN ('SALE_OUT','TRANSFER_OUT','ADJUSTMENT_OUT','PURCHASE_RETURN') AND direction = 'OUT'); ck_stock_movements_qty: quantity > 0
tg: actor=set_created_by()@Bi, append_only=forbid_change()@Bud, apply_stock=apply_stock_movement()@Ai, set_updated_at@Bu
rls: on | read: perm[inventory.view,accounting.view,reports.view] AND can_access_warehouse(warehouse_id)

#### stock_transfer_items
cols: id:i8*=ID, stock_transfer_id:i8!, variant_id:i8!, quantity_requested:n(20,4)!, quantity_shipped:n(20,4)!=0, quantity_received:n(20,4)!=0, quantity_damaged:n(20,4)!=0, quantity_missing:n(20,4)!=0, unit_cost:n(20,4), notes:t +std
fk: stock_transfer_id→stock_transfers/cascade; variant_id→product_variants
uq (stock_transfer_id, variant_id)
ck: ck_stock_transfer_items_qty: quantity_requested > 0 AND quantity_shipped >= 0 AND quantity_received >= 0 AND quantity_damaged >= 0 AND quantity_missing >= 0 AND (quantity_received + quantity_damaged + quantity_missing) <= quantity_shipped AND quantity_shipped <= quantity_requested
tg: protect_items=protect_posted_children('stock_transfers', 'stock_transfer_id', 'status')@Biud, set_updated_at@Bu
rls: on | read: EXISTS(stock_transfers p WHERE p.id = stock_transfer_id) | write: perm[inventory.transfer,inventory.transfer.approve] AND EXISTS(stock_transfers p WHERE p.id = stock_transfer_id AND (can_access_warehouse(p.from_warehouse_id, operate) OR can_access_warehouse(p.to_warehouse_id, operate)))

#### stock_transfers
cols: id:i8*=ID, transfer_number:v(100)!, from_warehouse_id:i8!, to_warehouse_id:i8!, status:v(20)!='DRAFT', requested_at:ts, approved_at:ts, shipped_at:ts, received_at:ts, created_by:u, approved_by:u, shipped_by:u, received_by:u, notes:t +std
fk: approved_by→users; created_by→users; from_warehouse_id→warehouses; received_by→users; shipped_by→users; to_warehouse_id→warehouses
uq (transfer_number)
ck: ck_stock_transfers_wh: from_warehouse_id <> to_warehouse_id
tg: actor=set_created_by()@Bi, assign_number=assign_doc_number('transfer_number', 'TRANSFER')@Bi, audit=audit_row()@Aiud, guard=transfer_guard()@Biu, set_updated_at@Bu
rls: on | read: perm[inventory.view,inventory.transfer,inventory.transfer.approve,reports.view] AND (can_access_warehouse(from_warehouse_id) OR can_access_warehouse(to_warehouse_id)) | write: perm[inventory.transfer,inventory.transfer.approve] AND (can_access_warehouse(from_warehouse_id, operate) OR can_access_warehouse(to_warehouse_id, operate))

#### supplier_notes
cols: id:i8*=ID, supplier_id:i8!, purchase_invoice_id:i8, type:v(30)!, note:t!, status:v(20)!='OPEN', created_by:u, created_at:ts!=now, resolved_at:ts +std
fk: created_by→users; purchase_invoice_id→purchase_invoices; supplier_id→suppliers
ck: ck_supplier_notes_resolved: (status = 'RESOLVED') = (resolved_at IS NOT NULL)
tg: actor=set_created_by()@Bi, set_updated_at@Bu
rls: on | read: perm[purchasing.view,parties.view] | write: perm[purchasing.create,parties.manage]

#### suppliers
cols: id:i8*=ID, party_id:i8!, company_name:v(200), supplier_code:v(50), payment_terms_days:i4=0, default_currency_id:i8, is_active:b!=true +std
fk: default_currency_id→currencies; party_id→parties
uq (party_id); uq (supplier_code)
ck: ck_suppliers_terms: (payment_terms_days IS NULL) OR (payment_terms_days >= 0)
tg: audit=audit_row()@Aiud, set_updated_at@Bu
rls: on | read: perm[parties.view,purchasing.view,accounting.view] | write: perm[parties.manage,purchasing.create]

#### sync_nodes
note: العقد المشاركة بالمزامنة. الصف رقم 1 دائماً هو السحابة. المعرّف العالمي لكل صف هو العمود uuid، ونطاق معرّفات العقدة k هو [k*10^12 .. (k+1)*10^12-1] (السحابة [1..10^12-1]) عبر erp.set_node_id_range. القرار موثق في docs/ARCHITECTURE_DECISIONS.md
cols: id:i8*=ID, code:v(30)!, name:v(100)!, node_type:v(10)!='CLOUD', branch_id:i8, is_active:b!=true, created_at:ts!=now, updated_at:ts!=now
fk: branch_id→branches
uq (code)
tg: set_updated_at@Bu
rls: on | read: perm[org.manage] | write: perm[org.manage]

#### tags
cols: id:i8*=ID, name:v(100)!, slug:v(100)!, is_active:b!=true +std
uq (name); uq (slug)
tg: set_updated_at@Bu
rls: on | read: true | write: perm[masterdata.manage]

#### tax_rates
cols: id:i8*=ID, name:v(100)!, code:v(30)!, rate:n(8,4)!, is_inclusive:b!=false, gl_account_id:i8, is_active:b!=true +std
fk: gl_account_id→gl_accounts
uq (code)
ck: ck_tax_rates_rate: rate >= 0 AND rate <= 100
tg: audit=audit_row()@Aiud, set_updated_at@Bu
rls: on | read: true | write: perm[pricing.manage,accounting.manage]

#### units
cols: id:i8*=ID, name:v(100)!, symbol:v(20)!, unit_type:v(30)!, base_unit_id:i8, conversion_factor:n(20,8)!=1, is_active:b!=true +std
fk: base_unit_id→units
uq (symbol)
ck: ck_units_base: (base_unit_id IS NOT NULL) OR (conversion_factor = 1); units_conversion_factor_check: conversion_factor > 0
tg: set_updated_at@Bu
rls: on | read: true | write: perm[masterdata.manage]

#### user_branch_access
cols: id:i8*=ID, user_id:u!, branch_id:i8!, can_view:b!=true, can_operate:b!=false +std
fk: branch_id→branches; user_id→users/cascade
uq (user_id, branch_id)
tg: audit=audit_row()@Aiud, guard=self_access_guard()@Biud, set_updated_at@Bu
rls: on | read: user_id = auth.uid() OR perm[users.manage] | write: perm[users.manage]

#### user_pos_terminals
cols: id:i8*=ID, user_id:u!, pos_terminal_id:i8!, is_default:b!=false, assigned_at:ts=now +std
fk: pos_terminal_id→pos_terminals/cascade; user_id→users/cascade
uq (user_id, pos_terminal_id)
ux: ux_user_pos_terminals_one_default (user_id) WHERE is_default
tg: audit=audit_row()@Aiud, guard=self_access_guard()@Biud, set_updated_at@Bu
rls: on | read: user_id = auth.uid() OR perm[pos.manage,users.manage] | write: perm[pos.manage,users.manage]

#### user_price_lists
cols: id:i8*=ID, user_id:u!, price_list_id:i8!, is_default:b!=false +std
fk: price_list_id→price_lists/cascade; user_id→users/cascade
uq (user_id, price_list_id)
ux: ux_user_price_lists_one_default (user_id) WHERE is_default
tg: audit=audit_row()@Aiud, guard=self_access_guard()@Biud, set_updated_at@Bu
rls: on | read: user_id = auth.uid() OR perm[users.manage,pricing.manage] | write: perm[users.manage]

#### user_roles
cols: id:i8*=ID, user_id:u!, role_id:i8!, assigned_by:u, assigned_at:ts=now +std
fk: assigned_by→users; role_id→roles; user_id→users/cascade
uq (user_id, role_id)
tg: audit=audit_row()@Aiud, guard=user_roles_guard()@Biud, set_updated_at@Bu
rls: on | read: user_id = auth.uid() OR perm[users.manage] | write: perm[users.manage]

#### users
cols: id:u*, employee_id:i8!, username:v(100)!, is_active:b!=true, must_change_password:b!=false, last_login_at:ts, created_at:ts!=now, updated_at:ts!=now, email:v(150), failed_login_attempts:i4!=0, locked_until:ts
fk: employee_id→employees; id→auth.users/restrict
uq (email); uq (employee_id); uq (username)
ck: users_failed_login_attempts_check: failed_login_attempts >= 0
tg: audit=audit_row()@Aiud, guard=users_guard()@Bu, set_updated_at@Bu
rls: on | read: id = auth.uid() OR perm[users.manage] | write: perm[users.manage]

#### variant_costs
note: تُحدَّث من دوال ترحيل المشتريات فقط (المتوسط المرجح).
cols: variant_id:i8*, currency_id:i8!, average_cost:n(20,4)!=0, last_purchase_cost:n(20,4) +std
fk: currency_id→currencies; variant_id→product_variants/cascade
ck: variant_costs_average_cost_check: average_cost >= 0; variant_costs_last_purchase_cost_check: (last_purchase_cost IS NULL) OR (last_purchase_cost >= 0)
tg: audit=audit_row()@Aiud, set_updated_at@Bu
rls: on | read: perm[costs.view] | write: perm[costs.manage]

#### variant_option_values
cols: variant_id:i8*, option_set_id:i8*, option_id:i8! +std
fk: option_id,option_set_id→options.id,option_set_id; option_set_id→option_sets; variant_id→product_variants/cascade
tg: set_updated_at@Bu, vov_variant_key=trg_vov_variant_key()@Aiud
rls: on | read: true | write: perm[catalog.manage]

#### variant_prices
cols: id:i8*=ID, variant_id:i8!, price_list_id:i8!, currency_id:i8!, amount:n(20,4)!, valid_from:ts, valid_to:ts +std
fk: currency_id→currencies; price_list_id→price_lists; variant_id→product_variants
uq NULLS NOT DISTINCT (variant_id, price_list_id, currency_id, valid_from)
ck: ck_variant_prices_amount: amount >= 0; ck_variant_prices_validity: (valid_to IS NULL) OR (valid_from IS NULL) OR (valid_to > valid_from)
tg: audit=audit_row()@Aiud, set_updated_at@Bu
rls: on | read: true | write: perm[pricing.manage]

#### variant_reorder_levels
cols: id:i8*=ID, variant_id:i8!, warehouse_id:i8!, min_quantity:n(20,4)!=0, reorder_quantity:n(20,4) +std
fk: variant_id→product_variants/cascade; warehouse_id→warehouses
uq (variant_id, warehouse_id)
ck: variant_reorder_levels_min_quantity_check: min_quantity >= 0; variant_reorder_levels_reorder_quantity_check: (reorder_quantity IS NULL) OR (reorder_quantity >= 0)
tg: set_updated_at@Bu
rls: on | read: true | write: perm[catalog.manage]

#### warehouses
cols: id:i8*=ID, branch_id:i8, code:v(50)!, name:v(150)!, warehouse_type:v(30)!='GENERAL', is_sellable:b!=true, is_online_fulfillment:b!=false, address:t, is_active:b!=true, created_at:ts!=now +std
fk: branch_id→branches
uq (code)
tg: audit=audit_row()@Aiud, set_updated_at@Bu
rls: on | read: can_access_warehouse(id) | write: perm[org.manage]

---

## 9) الـ Views (20)

كلها في `public`. الأعمدة والأنواع مقروءة من `pg_attribute`؛ `from` = الجداول/الـ Views التي يعتمد عليها (من `pg_depend`). `invoker` = `security_invoker=true` (تحترم RLS للمستخدم). `barrier` = `security_barrier=true` **بلا** `security_invoker` أي تعمل بصلاحيات المالك (وتُقيّد نفسها داخلياً بصلاحية التكلفة) — 4 Views وهي ما ينبّه عليه مستشار الأمان. `grants`: `ALL` = authenticated يملك كل امتيازات DML الافتراضية على الـ View (الـ Views المجمَّعة لا تقبل الكتابة عملياً)، `SELECT` = قراءة فقط.

#### v_account_balances  `[invoker, grants ALL]`
cols: gl_account_id:i8, code:v(30), name:v(200), account_type:v(20), normal_balance:v(6), parent_id:i8, is_postable:b, debit_base:n, credit_base:n, balance_base:n
from: gl_accounts, journal_entries, journal_entry_lines

#### v_financial_account_balances  `[invoker, ALL]`
cols: financial_account_id:i8, name:v(150), type:v(10), branch_id:i8, currency_id:i8, currency_code:v(10), balance:n, total_in:n, total_out:n, last_transaction_date:ts, is_active:b
from: currencies, financial_accounts, financial_transactions

#### v_low_stock  `[invoker, ALL]`
cols: warehouse_id:i8, warehouse_code:v(50), warehouse_name:v(150), branch_id:i8, is_sellable:b, variant_id:i8, sku:v(100), variant_name:v(250), product_id:i8, product_name:v(250), quantity_on_hand:n(20,4), quantity_reserved:n(20,4), quantity_available:n, quantity_incoming:n, min_quantity:n(20,4), reorder_quantity:n(20,4), below_min:b
from: v_stock_available

#### v_open_documents  `[invoker, ALL]` — **عُدِّلت في s6**
note: `paid_amount` = مجموع `settled_amount` لتخصيصات `DEBT` و`ADVANCE_APPLICATION` من دفعات `status='POSTED'` فقط (مطابق لـ `erp.doc_due_paid`)؛ قبل s6 كانت تحتسب تخصيصات الدفعات المعكوسة والمسودات. لا تخصم المرتجعات (بخلاف `doc_due_paid`).
cols: doc_type:t, doc_id:i8, doc_number:v, branch_id:i8, party_id:i8, party_name:v(200), currency_id:i8, doc_date:ts, due_date:d, total_amount:n(20,4), paid_amount:n, remaining_amount:n, payment_status:v(20), days_overdue:i4
from: customers, parties, payment_allocations, purchase_invoices, sales, suppliers

#### v_party_balances  `[invoker, ALL]`
cols: party_id:i8, party_name:v(200), party_type:v(20), is_customer:b, is_supplier:b, currency_id:i8, currency_code:v(10), total_debit:n, total_credit:n, balance:n, last_entry_date:ts
from: currencies, customers, parties, party_ledger_entries, suppliers

#### v_pos_session_summary  `[invoker, ALL]`
cols: pos_session_id:i8, pos_terminal_id:i8, terminal_code:v(50), branch_id:i8, cashier_user_id:u, cashier_username:v(100), status:v(20), opened_at:ts, closed_at:ts, invoices_count:i8
from: pos_sessions, pos_terminals, sales, users

#### v_product_attributes  `[invoker, ALL]`
cols: product_id:i8, kind:t, item_id:i8, code:t, name:t, data_type:t, is_filterable:b, option_id:i8, display_value:v
from: attributes, option_sets, options, product_attribute_values, product_option_values

#### v_product_type_attribute_defs  `[invoker, ALL]`
cols: product_type_id:i8, kind:t, item_id:i8, code:t, name:t, data_type:t, option_set_id:i8, unit_id:i8, is_filterable:b, is_required:b, sort_order:i4, is_active:b
from: attributes, option_sets, product_type_attributes, product_type_option_sets

#### v_purchase_items_costs  `[barrier, SELECT]`
cols: id:i8, purchase_invoice_id:i8, variant_id:i8, unit_cost:n(20,4), total_cost:n(20,4)
from: purchase_invoice_items, purchase_invoices

#### v_sale_items_costs  `[barrier, SELECT]`
cols: id:i8, sale_id:i8, variant_id:i8, unit_cost:n(20,4), unit_cost_currency_id:i8
from: sale_items, sales

#### v_sales_daily  `[invoker, ALL]`
cols: sale_day:d, branch_id:i8, channel:v(20), currency_id:i8, currency_code:v(10), invoices_count:i8, total_amount:n, total_base:n, total_discount:n
from: currencies, sales

#### v_stock_available  `[invoker, ALL]`
cols: warehouse_id:i8, warehouse_code:v(50), warehouse_name:v(150), branch_id:i8, is_sellable:b, variant_id:i8, sku:v(100), variant_name:v(250), product_id:i8, product_name:v(250), quantity_on_hand:n(20,4), quantity_reserved:n(20,4), quantity_available:n, quantity_incoming:n, min_quantity:n(20,4), reorder_quantity:n(20,4), below_min:b
from: inventory_balances, product_variants, products, v_stock_in_transit, variant_reorder_levels, warehouses

#### v_stock_in_transit  `[invoker, SELECT]`
cols: transfer_id:i8, transfer_number:v(100), from_warehouse_id:i8, to_warehouse_id:i8, transfer_item_id:i8, variant_id:i8, sku:v(100), variant_name:v(250), quantity_shipped:n(20,4), quantity_received:n(20,4), quantity_damaged:n(20,4), quantity_missing:n(20,4), quantity_in_transit:n, unit_cost:n(20,4), shipped_at:ts, days_in_transit:i4
from: product_variants, stock_transfer_items, stock_transfers

#### v_stock_movements_costs  `[barrier, SELECT]`
cols: id:i8, variant_id:i8, warehouse_id:i8, movement_type:v(30), quantity:n(20,4), unit_cost:n(20,4), currency_id:i8, movement_date:ts
from: stock_movements

#### v_transfer_costs  `[barrier, SELECT]`
cols: transfer_item_id:i8, transfer_id:i8, variant_id:i8, unit_cost:n(20,4), loss_value:n
from: stock_transfer_items, stock_transfers

#### v_transfer_discrepancies  `[invoker, SELECT]`
cols: transfer_id:i8, transfer_number:v(100), from_warehouse_id:i8, to_warehouse_id:i8, received_at:ts, transfer_item_id:i8, variant_id:i8, sku:v(100), variant_name:v(250), quantity_shipped:n(20,4), quantity_received:n(20,4), quantity_damaged:n(20,4), quantity_missing:n(20,4), unaccounted_quantity:n, discrepancy_type:t, unit_cost:n(20,4), loss_value:n
from: product_variants, stock_transfer_items, stock_transfers

#### v_user_access  `[invoker, ALL]`
cols: user_id:u, username:v(100), email:v(150), is_active:b, full_name:v(200), job_title:v(100), role_codes:varchar[], branch_codes:varchar[], terminal_codes:varchar[]
from: branches, employees, parties, pos_terminals, roles, user_branch_access, user_pos_terminals, user_roles, users

#### v_variant_attributes  `[invoker, ALL]`
cols: variant_id:i8, product_id:i8, sku:v(100), variant_name:v(250), is_active:b, size_id:i8, size_name:v(50), size_code:v(50), product_color_id:i8, color_name:v, color_components:j
from: colors, product_color_components, product_colors, product_variants, sizes

#### v_color_usage `[invoker, SELECT]`
cols: color_id:i8, product_count:i8, component_count:i8
from: colors, product_color_components, product_colors

#### v_variant_list_prices  `[invoker, SELECT]`
cols: variant_id:i8, product_id:i8, sku:v(100), variant_name:v(250), price_list_id:i8, price_list_code:v(50), price_type:v(20), currency_id:i8, currency_code:v(10), amount:n(20,4), valid_from:ts, valid_to:ts, is_current:b
from: currencies, price_lists, product_variants, variant_prices

> **أثر توحيد REVERSED على الـ Views:** لا View يذكر `CANCELLED` حرفياً، لكن البحث الحرفي وحده **لا يكفي**: `v_open_documents` كانت تجمع التخصيصات بلا أي شرط على حالة الدفعة فتحتسب الدفعات المعكوسة والمسودات كمدفوعة (وهو قصور قائم قبل s1 أيضاً). صُحّحت في **s6**. بقية الـ Views لا تقرأ `payments` ولا `payment_allocations` (تقرأ الدفاتر append-only `party_ledger_entries` و`financial_transactions` التي تُعكس بقيود معاكسة)، فلا تتأثر.

---

## 10) الدوال

الأسماء بلا بادئة = schema `public` (واجهة RPC للتطبيق). كلها `[DEFINER]` و`auth` (EXECUTE لـ authenticated وليس anon) ما لم يُذكر خلاف ذلك. `S` = stable، وغير ذلك volatile. الجميع يعيدون `jsonb` ما لم يُذكر.

### 10.1 دوال public (57)

جميعها EXECUTE لـ `authenticated` فقط؛ الدوال الموسومة `[INVOKER]` تعمل بصلاحيات المستدعي وتحترم RLS، والبقية SECURITY DEFINER ما لم يُذكر خلاف ذلك.

**إحصاءات البيانات الأساسية (CAT-07)**
- `brand_stats() → TABLE(total bigint, active bigint, inactive bigint, with_products bigint, without_products bigint, most_used_brand_id bigint, most_used_count bigint)` [S، INVOKER، EXECUTE لـ authenticated فقط].
- `color_stats() → TABLE(total bigint, active bigint, inactive bigint, used bigint, unused bigint)` [S، INVOKER، EXECUTE لـ authenticated فقط].

**هوية ووصول**
- `get_my_access() → jsonb` [S] · `my_has_permission(p_code text) → boolean` [S] · `complete_password_change() → void`
- `admin_provision_user(p_user_id uuid, p_username text, p_full_name text, p_role_codes text[], p_branch_ids i8[], p_can_operate boolean = true, p_email text = null, p_phone text = null, p_job_title text = null, p_home_branch_id i8 = null, p_party_id i8 = null) → jsonb`
- `admin_provision_user(p_user_id uuid, p_username text, p_full_name text, p_role_codes text[], p_branches jsonb, p_email text = null, p_phone text = null, p_job_title text = null, p_home_branch_id i8 = null, p_party_id i8 = null) → jsonb` *(overload)*

**الترحيل (`DRAFT → POSTED`)**
- `post_sale(p_sale_id i8)` · `post_sales_return(p_return_id i8)` · `post_purchase_invoice(p_invoice_id i8)` · `post_purchase_return(p_return_id i8)`
- `post_payment(p_payment_id i8)` · `post_expense(p_expense_id i8)` · `post_money_transfer(p_transfer_id i8)` · `post_balance_adjustment(p_adjustment_id i8)` · `post_cash_reconciliation(p_recon_id i8)` · `post_stock_adjustment(p_adjustment_id i8)`
- `post_opening_cash(p_financial_account i8, p_amount numeric, p_date ts = now(), p_notes text = null)` · `post_opening_party_balance(p_party i8, p_kind text, p_currency i8, p_amount numeric, p_date ts = now())` · `post_opening_stock(p_warehouse i8, p_date ts, p_items jsonb)` · `opening_readiness() [S]`

**العكس (الأصل → `REVERSED`، مستند معاكس مرتبط)**
- `reverse_payment(p_payment_id i8, p_reason text = null)` (صلاحية `payment.cancel`) · `reverse_expense(p_expense_id i8, p_reason text = null)` · `reverse_balance_adjustment(p_adjustment_id i8, p_reason text = null)` · `reverse_money_transfer(p_transfer_id i8, p_reason text = null)`
- `reverse_cash_reconciliation(p_id i8, p_reason text = null)` · `reverse_stock_adjustment(p_adjustment_id i8, p_reason text = null)` · `reverse_journal_entry(p_journal_id i8, p_reason text = null)`

**السلف (جديد، s2)**
- `apply_advance(p_party_id i8, p_currency_id i8, p_allocations jsonb, p_date date = null) → jsonb` — صلاحية `finance.payments` + تشغيل على فرع الفواتير. `p_allocations`: `[{"sale_id":N,"amount":X}]` (زبون) أو `[{"purchase_invoice_id":N,"amount":X}]` (مورد)، لا يُخلطان. السلف الأقدم أولاً (`payment_date` ثم `id`) ضمن طرف+عملة. يبني دفعة (`payment_type` CUSTOMER_RECEIPT/SUPPLIER_PAYMENT، `payment_context='REGULAR_PAYMENT'`، بلا جلسة) بتخصيصات `ADVANCE_APPLICATION` ويمرّرها عبر `post_payment`. المُرجَع: `{payment_id, payment_number, party_id, currency_id, applied:[{doc_type, doc_id, doc_number, amount, new_payment_status, advances_used:[{advance_allocation_id, advance_payment_id, amount}]}], remaining_advance_balance}`. الأخطاء: ERP16, ERP22, ERP18, ERP10, ERP08/ERP13. ذرّي بالكامل. `p_date` الفارغ = `erp.local_date()`.
- `list_party_advances(p_party_id i8, p_currency_id i8 = null) → TABLE(advance_allocation_id i8, payment_id i8, payment_number text, payment_date ts, currency_id i8, currency_code text, original_amount numeric, applied_amount numeric, remaining_amount numeric, branch_id i8, payment_type text)` [S] — صلاحية أيٌّ من `finance.payments|finance.view|accounting.view|parties.view`، وتُصفّى بفروع القراءة؛ `remaining_amount > 0` فقط، الأقدم أولاً.
- `get_party_advance_balance(p_party_id i8, p_currency_id i8 = null) → TABLE(currency_id i8, currency_code text, remaining_amount numeric)` [S] — مجموع المتبقي لكل عملة (صف بصفر عند تحديد العملة).

**المصروفات**
- `attach_expense_receipt(p_expense_id i8, p_path text) → jsonb {expense_id, receipt_image_path, replaced, changed}` (جديد، s3) — لمصروف `POSTED` غير عكسي وغير مراجَع؛ المنشئ أو `finance.expenses` + تشغيل على الفرع؛ المسار `branch_id/…` داخل bucket `expense-receipts` والملف موجود؛ ERP16/ERP22.
- `list_expenses_for_review(p_branch_id i8 = null) → TABLE(expense_id i8, reference_number text, branch_id i8, cashier_user_id uuid, cashier_name text, pos_session_id i8, category_id i8, category_name text, amount numeric, currency_id i8, currency_code text, expense_date ts, review_status text, notes text)` [S]
- `mark_expense_reviewed(p_expense_id i8, p_note text = null)`

**التحويلات المخزنية والمخزون**
- `approve_transfer(p_transfer_id i8)` · `ship_transfer(p_transfer_id i8, p_items jsonb = null)` · `receive_transfer(p_transfer_id i8, p_items jsonb = null)` · `cancel_transfer(p_transfer_id i8)`
- `branch_stock_lookup(p_variant i8, p_current_branch i8 = null) → TABLE(branch_id i8, branch_code text, branch_name text, warehouse_id i8, warehouse_code text, warehouse_name text, quantity_on_hand numeric, quantity_available numeric)` [S]

**التسعير والتكلفة**
- `resolve_price(p_variant i8, p_price_list i8, p_display_currency i8 = null, p_at ts = now()) → TABLE(amount numeric, currency_id i8, source text)` [S] · `resolve_cost(p_variant i8, p_at ts = now()) → numeric` [S]
- `get_allowed_price_lists(p_branch i8, p_terminal i8 = null, p_customer i8 = null) → TABLE(price_list_id i8, code text, name text, currency_id i8, price_type text, is_default boolean, is_suggested boolean)` [S]
- `get_draft_price_warnings(p_sale_id i8) → TABLE(line_id i8, variant_id i8, quantity numeric, locked_price numeric, current_price numeric, price_currency_id i8, status text)` [S] · `refresh_draft_line_prices(p_sale_id i8, p_line_ids i8[] = null)`
- `set_discount_cap(p_branch i8, p_percent numeric)` · `set_model_cost(p_product i8, p_cost numeric, p_currency i8, p_reason text) → integer` · `set_model_price(p_product i8, p_price_list i8, p_amount numeric, p_currency i8, p_valid_from ts = now()) → integer` · `set_variant_cost(p_variant i8, p_cost numeric, p_currency i8, p_reason text) → numeric`

**الكتالوج والصور والأطراف**
- `attach_product_image(p_product_id i8, p_path text, p_image_type text = 'front', p_alt_text text = null, p_is_primary boolean = false, p_sort_order integer = null)` · `delete_product_image(p_image_id i8)`
- `attach_color_image(p_product_color_id i8, p_path text, p_image_type text = 'front', p_alt_text text = null, p_is_primary boolean = false, p_sort_order integer = null)` · `delete_color_image(p_image_id i8)`
- `assign_internal_barcode(p_variant i8) → text` · `generate_internal_barcode() → text`
- `product_missing_required(p_product i8) → TABLE(kind text, item_id i8, code text, name text)` [S، **INVOKER**] · `quick_add_customer(p_name text, p_phone text, p_whatsapp text = null)`

**المحاسبة**
- `generate_fiscal_year(p_year integer)`

### 10.2 دوال erp — مساعدات (غير triggers)
`[DEFINER]` ما لم يُذكر. **schema `erp` غير مكشوف للـ API** (انظر §13).

| التوقيع | النوع |
|---|---|
| `has_permission(p_code text) → boolean` · `has_any_permission(p_codes text[]) → boolean` · `is_super_admin() → boolean` | S |
| `require_perm(p_codes text[]) → void` · `require_branch(p_branch i8) → void` · `require_warehouse(p_wh i8) → void` | S — ترفع ERP16؛ تسمح لـ«سياق الخدمة» |
| `can_access_branch(p_branch i8, p_operate boolean = false) → boolean` · `can_access_warehouse(p_warehouse i8, p_operate boolean = false) → boolean` | S |
| `is_service_context() → boolean` (INVOKER) | S — `auth.uid()` فارغ ودور ليس anon/authenticated |
| `raise_err(p_code text, p_key text, p_msg text, p_detail text = null) → void` (INVOKER) | V |
| `sys_begin() → void` · `sys_active() → boolean` (INVOKER) | V / S |
| `assert_period_open(p_date date) → void` · `period_for(p_date date) → i8` · `ensure_fiscal_year(p_year integer) → integer` | ERP08/ERP13 |
| `assert_session_open(p_session i8) → void` · `assert_session_owner(p_session i8, p_branch i8 = null) → void` | S |
| `local_date(p_ts ts = now()) → date` · `base_currency_id() → i8` · `get_setting(p_key text, p_branch i8 = null, p_user uuid = null) → text` | S |
| `get_rate(p_from i8, p_to i8, p_at ts = now()) → numeric` · `resolve_rate(p_currency i8, p_given numeric = null, p_at ts = now()) → numeric` | S |
| `round_currency(p_amount numeric, p_currency i8) → numeric` · `rounding_tolerance(p_currency i8) → numeric` | S |
| `gl(p_key text, p_branch i8 = null) → i8` — حلّ `gl_account_mappings` | S |
| `post_journal(p_date date, p_branch i8, p_desc text, p_src_type text, p_src_id i8, p_lines jsonb, p_reversal_of i8 = null) → i8` · `reverse_journal(p_id i8, p_date date = null, p_desc text = null) → i8` · `jl_line(p_acct i8, p_party i8, p_cur i8, p_rate numeric, p_amount numeric, p_credit boolean, p_base numeric, p_desc text, p_plug boolean = false) → jsonb` (IMMUTABLE) | V |
| `ledger_add(p_party i8, p_cur i8, p_type text, p_debit numeric, p_credit numeric, p_src text, p_src_id i8, p_date ts) → void` | V |
| `post_payment_core(p_payment_id i8) → jsonb` — منطق ترحيل الدفعات (يستدعيه `post_payment`) | V |
| `doc_due_paid(p_kind text, p_id i8, OUT o_cur i8, OUT o_due numeric, OUT o_paid numeric) → record` · `refresh_payment_status(p_kind text, p_id i8) → void` | S / V |
| `party_advance_rows(p_party i8, p_currency i8 = null, p_ptype text = null) → TABLE(advance_allocation_id i8, payment_id i8, payment_ref text, payment_date ts, branch_id i8, currency_id i8, original_amount numeric, applied_amount numeric, remaining_amount numeric, payment_type text)` — مساعد داخلي (s2)، بلا صلاحيات | S |
| `stock_move(p_variant i8, p_wh i8, p_type text, p_qty numeric, p_cost numeric, p_cur i8, p_ref text, p_ref_id i8, p_item_id i8, p_date ts, p_notes text = null) → void` · `apply_purchase_cost(p_variant i8, p_qty numeric, p_cost_base numeric) → void` · `variant_cost_base(p_variant i8) → numeric` · `resolve_cost_basis(p_variant i8, p_at ts, p_basis text) → numeric` | V / S |
| `next_doc_number(p_doc_type text, p_branch i8 = null) → text` | V |
| `allowed_price_list_ids(p_branch i8, p_terminal i8 = null) → SETOF i8` · `default_price_list_id(p_branch i8, p_terminal i8 = null) → i8` · `discount_cap_percent(p_branch i8) → numeric` | S |
| `compute_variant_key(p_size_id i8, p_color_ids i8[], p_option_ids i8[]) → text` · `ean13_check_digit(p_first12 text) → integer` (IMMUTABLE) · `validate_image_path(p_path text) → void` | — |
| `set_node_id_range(p_node_id i8) → jsonb` (INVOKER) | V |
| **أدوات بناء المخطط (INVOKER):** `standard_table(p_table regclass)` · `add_sync_columns(p_table regclass)` · `attach_audit(p_table regclass)` · `make_append_only(p_table regclass)` · `apply_policies(p_table regclass, p_write_perm text, p_read_perm text = null)` · `set_policies(p_table regclass, p_read text, p_write text = null)` · `pol_perm(p_table regclass, p_read text[], p_write text[])` · `pol_branch(p_table regclass, p_col text, p_read text[], p_write text[], p_nullable boolean = false)` · `pol_child(p_table regclass, p_parent text, p_fk text, p_write text[], p_parent_branch text = null)` | V |

### 10.3 دوال erp — Triggers (`→ trigger`)
`account_currency_guard` · `apply_stock_movement` (AFTER INSERT على `stock_movements`) · `assign_doc_number` · `assign_invoice_code` · `audit_rate_change` · `audit_row` · `cash_reconciliation_guard` · `check_materials_total` · `exchange_rate_guard` · `expense_receipt_guard` (جديد s3) · `expense_review_guard` · `financial_account_guard` · `fiscal_period_guard` · `forbid_change` · `forbid_direct_post` · `gl_account_guard` · `guard_status_permission` · `journal_guard` · `journal_reversal_flip` · `money_transfer_guard` · `payment_allocation_guard` · `payment_line_guard` · `pos_session_assignment_guard` · `pos_session_guard` · `product_attribute_value_guard` · `product_option_value_guard` · `product_publish_guard` · `protect_posted_children` · `protect_posted_doc` · `purchase_return_guard` · `purchase_return_item_guard` · `reason_guard` · `role_permissions_guard` · `roles_guard` · `sale_header_guard` · `sale_item_guard` · `sales_return_guard` · `sales_return_item_guard` · `self_access_guard` · `set_created_by` · `set_updated_at` · `set_updated_by` · `stock_adj_item_calc` · `transfer_guard` · `trg_check_color_components` · `trg_pv_variant_key` · `trg_vov_variant_key` · `user_roles_guard` · `users_guard`

---

## 11) Storage وEdge Functions

**Buckets (`storage.buckets`):**
| id | public | الحد | MIME |
|---|---|---|---|
| `product-images` | **نعم** | 5 MB | image/jpeg, image/png, image/webp |
| `expense-receipts` | لا | 5 MB | image/jpeg, image/png, image/webp |

**سياسات storage (9، كلها `authenticated`):**
| السياسة | العملية | الشرط |
|---|---|---|
| `product_images_read` | SELECT | `bucket_id='product-images'` |
| `product_images_insert` / `_update` / `_delete` | INSERT / UPDATE / DELETE | `bucket_id='product-images'` AND `has_permission('catalog.manage')` |
| `masterdata_images_insert` | INSERT فقط | `bucket_id='product-images'` AND المجلد الأول أحد `brands`, `categories`, `collections` AND `has_permission('masterdata.manage')` |
| `expense_receipts_read` | SELECT | `bucket_id='expense-receipts'` AND `has_any_permission[finance.view,finance.expenses,accounting.view]` AND المجلد الأول رقم AND `can_access_branch(folder1)` |
| `expense_receipts_insert` / `_update` / `_delete` | INSERT / UPDATE / DELETE | `bucket_id='expense-receipts'` AND `has_permission('finance.expenses')` AND المجلد الأول `^[0-9]+$` AND `can_access_branch(folder1, operate)` |

عقد المسار لإيصالات المصروف: `<branch_id>/<file>` (يتحقق منه `attach_expense_receipt`).

**Edge Functions:**
| الاسم | النسخة | ملاحظة |
|---|---|---|
| `provision-user` | 2 | إنشاء مستخدم (الوصف من الاسم؛ لم يُفحص الكود) |
| `reset-password` | 1 | إعادة تعيين كلمة المرور (الوصف من الاسم؛ لم يُفحص الكود) |
| `quick-service` | 1 | قالب "Hello" الافتراضي، لا يلمس أي جدول؛ **مرشّح للحذف** |

---

## 12) سياسات RLS: النمط العام والاستثناءات

- **460 سياسة** في `public`: `p_read` (SELECT) ×120 [118 لدور `authenticated` + 2 لدور `public`] · `p_insert` ×113 · `p_update` ×113 · `p_delete` ×113 · `deny_direct_access` ×1.
- **الاستثناءات:**
  - `document_sequences`: سياسة وحيدة `deny_direct_access` (ALL، `anon`+`authenticated`، `USING false / CHECK false`)؛ الوصول فقط عبر `erp.next_doc_number`.
  - `cost_adjustments.p_read` و`sale_items.p_read` مُنشأتان بدور `public` (لا `authenticated`) — الشرط نفسه يعتمد على `auth.uid()` فلا يمنح anon شيئاً، لكنه خروج عن النمط.
  - **جداول للقراءة فقط (7)** بلا سياسات كتابة (الكتابة عبر دوال/triggers فقط): `audit_logs`, `cost_adjustments`, `error_codes`, `financial_transactions`, `inventory_balances`, `party_ledger_entries`, `stock_movements`.
- **أنماط القراءة:**
  1. بيانات رئيسية مفتوحة: `read: true`، الكتابة بصلاحية (`masterdata.manage` / `catalog.manage` / `pricing.manage`).
  2. مستندات الفرع: `perm[…] AND can_access_branch(branch_id)` للقراءة، و`perm[…] AND can_access_branch(branch_id, operate)` للكتابة.
  3. جداول الأبناء: `EXISTS(parent p WHERE p.id = fk [AND can_access_branch(p.branch_id…)])` فترث رؤية الأب.
  4. المخزون: `can_access_warehouse(warehouse_id[, operate])`.
  5. الحسابات المالية: القراءة مشروطة بوجود الحساب المالي المرئي (`EXISTS financial_accounts`).
  6. المستخدم يرى سجله: `user_id = auth.uid() OR perm[users.manage]`.
- السياسة لكل جدول مذكورة في سطر `rls:` ضمن §8.

---

- **Storage (`storage.objects`):** 9 سياسات، منها `masterdata_images_insert` (INSERT فقط على `product-images/brands/`, `categories/`, `collections/` مع `masterdata.manage`) إضافة إلى سياسات `catalog.manage` العامة لبقية عمليات الكتابة.

## 13) ملاحظات أمنية وفجوات معروفة

> **سجل البنود الموحّد:** [`docs/OPEN_DECISIONS.md`](../OPEN_DECISIONS.md). يبقى هذا القسم للتفصيل التاريخي؛ لا تُضف فيه بنداً جديداً.


**مقروءة من القاعدة:**
- **schema `erp`**: `anon` بلا `USAGE`؛ `authenticated` و`service_role` لديهما `USAGE`. كثير من دوال erp قابلة للتنفيذ من PUBLIC (ظاهر كـ `ANON` في فحص الامتياز) لكن غياب `USAGE` على الـ schema يمنع استدعاءها عبر API. لا إعداد `pgrst.db_schemas` ظاهر من SQL، فتأكّد من إعدادات "Exposed schemas" في لوحة Supabase أنها لا تتضمن `erp`.
- **دوال public**: كلها EXECUTE لـ `authenticated` فقط (لا `anon`)؛ الجديدة (`apply_advance`, `list_party_advances`, `get_party_advance_balance`, `attach_expense_receipt`) سُحب عنها `public` و`anon`.
- **4 Views بلا `security_invoker`** (`v_purchase_items_costs`, `v_sale_items_costs`, `v_stock_movements_costs`, `v_transfer_costs`): تعمل بصلاحيات المالك وتُنبَّه في مستشار الأمان؛ مقصودة لحجب التكلفة.
- مهلة الجلسات: `anon` 3s، `authenticated` 8s (statement_timeout).
- تحذير Auth في مستشار الأمان (حماية كلمات المرور المسرّبة) خارج مخطط البيانات.

**حالة البيانات (فحص 2026-11-16):** جدولا `attributes` و`product_type_attributes` فارغان، فلا خصائص إلزامية معرّفة بعد. `get_my_access()` تعيد للمدير العام 46 صلاحية بما فيها `parties.quick_add` (انظر `GET_MY_ACCESS.md`).

**فجوات/قرارات مفتوحة:**
1. **لا عمود `payment_number`** في `payments` (الرقم في `reference_number`؛ السلف القديمة بلا رقم وتُعرض `PAY-<id>`).
2. **رؤية السلف مقابل استهلاكها:** `list_party_advances` تُصفّي بفروع القراءة، بينما `apply_advance` يستهلك سلف الطرف من **أي فرع** (حسابات GL عامة فلا أثر محاسبي)، فقد يختلف «المتاح» في رسالة ERP22 عمّا تعرضه الواجهة.
3. **استبدال إيصال المصروف** لا يحذف الملف القديم من الـ bucket.
4. نص **ERP01** ما زال يقول «مُرحَّل أو ملغى» (لا يذكر REVERSED).
5. `quick-service` Edge Function قالب غير مستعمل.
6. **`v_open_documents` لا تخصم المرتجعات** (`remaining_amount = total_amount − paid_amount`) بينما `erp.doc_due_paid` يخصم المرتجعات المرحّلة (`due = total − مرتجعات`)؛ قد يختلف رقماهما لفاتورة لها مرتجع مرحّل. لم يُغيَّر لأنه خارج نطاق REVERSED.
7. القيم الافتراضية: `payments.status` و`expenses.status` و`money_transfers.status` الافتراضي `'POSTED'` (والبقية `'DRAFT'`)؛ على `payments` لا يوجد `forbid_direct_post`، فالإنشاء كمسودة يتطلب تمرير `status='DRAFT'` صراحةً.

---

## 14) سجل تغييرات الدفعة s1–s6

| Migration | المضمون |
|---|---|
| `s1_unify_reversed_status` | إضافة `REVERSED` إلى 4 قيود CHECK (`payments`, `expenses`, `balance_adjustments`, `money_transfers`)؛ تحويل الصفوف CANCELLED المعكوسة إلى REVERSED (**0 صف** حالياً، بتعطيل `trg_protect_posted` مؤقتاً داخل المعاملة وحده إن وُجدت صفوف)؛ جعل دوال العكس الأربع تضع `REVERSED`؛ تحديث نص `ERP02`. |
| `s2_apply_advance_and_list_party_advances` | `apply_advance`, `list_party_advances`, `get_party_advance_balance`, `erp.party_advance_rows`. |
| `s3_attach_expense_receipt` | `attach_expense_receipt`، `erp.expense_receipt_guard` + `trg_receipt_guard` (UPDATE OF `receipt_image_path`)، وإضافة `receipt_image_path` للأعمدة الحرّة في `trg_protect_posted` على `expenses` (الدالة `protect_posted_doc` نفسها لم تُمسّ). |
| `s4_fix_audit_action_values_in_new_functions` | `audit_logs.action` له CHECK: استُعملت `POST`/`UPDATE` مع `new_values.operation`. |
| `s5_fix_attach_receipt_null_creator_check` | `coalesce(created_by = auth.uid(), false)` لمنع تجاوز فحص الصلاحية عند `created_by` فارغ. |
| `s6_fix_v_open_documents_exclude_non_posted_payments` | `v_open_documents`: المدفوع من دفعات `POSTED` فقط وبأنواع `DEBT`/`ADVANCE_APPLICATION`. اكتُشف بعد s1–s5 (راجع §9). أعمدة الـ View وأنواعها و`security_invoker` والصلاحيات دون تغيير. |


## 15) سجل تغييرات CAT-07 (2026-11-27)

طُبّقت migrations التالية على القاعدة الحية للمشروع `mgtkjmkaydqrugvhplci`، بالترتيب:

| Migration | المضمون |
|---|---|
| `cat07_01_storage_masterdata_image_folders` | إضافة سياسة `storage.objects.masterdata_images_insert`: INSERT فقط إلى `product-images/brands/`, `categories/`, `collections/` للمستخدم `authenticated` ذي `masterdata.manage`. |
| `cat07_02_created_at_brands_colors` | إضافة `created_at timestamptz NOT NULL DEFAULT now()` إلى `brands` و`colors`. القيم المعبأة للصفوف القديمة مشتقة تقريبياً من `updated_at` وليست تاريخ إنشاء موثوقاً. |
| `cat07_03_stats_rpcs_and_color_usage_view` | إضافة `brand_stats()`, `color_stats()` (كلاهما SECURITY INVOKER، EXECUTE لـ authenticated فقط) وView `v_color_usage` مع `security_invoker=true`. |
| `cat07_04a_categories_cycle_guard` | إضافة `trg_categories_no_cycle`، BEFORE UPDATE OF `parent_id`، مع advisory transaction lock؛ يرفض الدورة بـ SQLSTATE `23514` والقيد `categories_parent_no_cycle`. |
| `cat07_04b_discount_target_delete_guards` | إضافة فهرس `ix_discount_targets_target` وحراس حذف `trg_guard_discount_target_ref` على `categories`, `brands`, `product_types`, `products`, `product_variants`؛ يرفض الحذف بـ `23503` والقيد `discount_targets_target_ref`. |
| `cat07_04c_slug_format_and_default_size_group_index` | إضافة CHECK لصيغة slug على `categories` و`brands` بالنمط `^[a-z0-9]+(-[a-z0-9]+)*$`، وفهرس `ux_pt_size_groups_one_default` لافتراضي واحد لكل (نوع، جنس). |

**ملاحظة created_at:** لا تُفسَّر قيمة `created_at` للصفوف الموجودة قبل migration على أنها تاريخ إنشاء دقيق؛ إنها تقدير من `updated_at` وقت التعبئة. الصفوف الجديدة تستخدم `now()` افتراضياً.

**إعادة المطابقة مع القاعدة في 2026-11-27:** Views 20، دوال public 57، دوال erp 105، فهارس public 587، Triggers public 286، CHECK public 164، سياسات Storage 9، سياسات RLS في public 460، و`error_codes` 29. الأعداد تحققت بقراءة catalog؛ اختبارات السلوك والصلاحيات المذكورة في سجل التسليم لم تُنفّذ بعد.
