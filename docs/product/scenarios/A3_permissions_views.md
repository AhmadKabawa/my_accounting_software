## الملحق ز: قاموس الصلاحيات

46 صلاحية، و151 رابطاً في role_permissions. الأدوار الحاملة من الجدول الفعلي.

| **الوحدة** | **الكود** | **المعنى** | **الأدوار الحاملة** |
| --- | --- | --- | --- |
| accounting | accounting.manage | إدارة دليل الحسابات وربط الحسابات | SUPER_ADMIN ACCOUNTANT |
| accounting | accounting.post | قيود يدوية وإغلاق فترات | SUPER_ADMIN ACCOUNTANT |
| accounting | accounting.view | عرض المحاسبة | SUPER_ADMIN MANAGER ACCOUNTANT AUDITOR |
| accounting | balance.adjust | تسويات أرصدة الأطراف | SUPER_ADMIN ACCOUNTANT |
| catalog | catalog.manage | إدارة المنتجات | SUPER_ADMIN MANAGER WAREHOUSE PURCHASER |
| catalog | costs.manage | تعديل التكاليف | SUPER_ADMIN MANAGER ACCOUNTANT |
| catalog | costs.view | عرض التكاليف | SUPER_ADMIN MANAGER ACCOUNTANT PURCHASER AUDITOR |
| core | audit.view | عرض سجل التدقيق | SUPER_ADMIN MANAGER ACCOUNTANT AUDITOR |
| core | settings.manage | إدارة الإعدادات | SUPER_ADMIN |
| core | users.manage | إدارة المستخدمين والصلاحيات | SUPER_ADMIN |
| finance | finance.expenses | المصاريف | SUPER_ADMIN MANAGER CASHIER ACCOUNTANT |
| finance | finance.manage | إدارة العملات والصناديق | SUPER_ADMIN ACCOUNTANT |
| finance | finance.payments | سندات القبض والدفع | SUPER_ADMIN MANAGER CASHIER ACCOUNTANT PURCHASER |
| finance | finance.view | عرض الحسابات المالية والأرصدة | SUPER_ADMIN MANAGER ACCOUNTANT AUDITOR |
| finance | fx.rate.manage | إدارة أسعار الصرف | SUPER_ADMIN ACCOUNTANT |
| finance | fx.rate.manual | استخدام سعر صرف يدوي في مستند | SUPER_ADMIN MANAGER ACCOUNTANT |
| finance | owner.transactions | سحوبات ومساهمات المالك | SUPER_ADMIN ACCOUNTANT |
| finance | payment.cancel | إلغاء/عكس دفعة | SUPER_ADMIN MANAGER ACCOUNTANT |
| finance | reconcile.cash | جرد الصندوق وتسوية فروقاته | SUPER_ADMIN MANAGER CASHIER ACCOUNTANT |
| hr | hr.manage | إدارة الموظفين | SUPER_ADMIN MANAGER |
| hr | hr.view | عرض الموظفين | SUPER_ADMIN MANAGER ACCOUNTANT AUDITOR |
| inventory | inventory.adjust | جرد وتسويات | SUPER_ADMIN MANAGER WAREHOUSE |
| inventory | inventory.transfer | تحويل مخزون | SUPER_ADMIN MANAGER WAREHOUSE |
| inventory | inventory.transfer.approve | اعتماد التحويلات | SUPER_ADMIN MANAGER WAREHOUSE |
| inventory | inventory.view | عرض المخزون | SUPER_ADMIN MANAGER CASHIER WAREHOUSE ACCOUNTANT PURCHASER AUDITOR |
| inventory | inventory.view_other_branches | الاطلاع على مخزون الفروع الأخرى | SUPER_ADMIN MANAGER CASHIER WAREHOUSE PURCHASER |
| inventory | warehouse.central.access | الوصول للمستودع المركزي | SUPER_ADMIN MANAGER WAREHOUSE PURCHASER AUDITOR |
| masterdata | masterdata.manage | إدارة البيانات الأساسية | SUPER_ADMIN MANAGER WAREHOUSE PURCHASER |
| org | org.manage | إدارة الفروع والمستودعات | SUPER_ADMIN |
| parties | parties.manage | إدارة الأطراف | SUPER_ADMIN MANAGER ACCOUNTANT PURCHASER |
| parties | parties.quick_add | إضافة سريعة لزبون | CASHIER |
| parties | parties.view | عرض الأطراف | SUPER_ADMIN MANAGER CASHIER ACCOUNTANT PURCHASER AUDITOR |
| pos | pos.manage | إدارة أجهزة نقاط البيع وكل الورديات | SUPER_ADMIN MANAGER |
| pos | pos.session | فتح/إغلاق وردية | SUPER_ADMIN MANAGER CASHIER |
| pricing | pricing.manage | إدارة الأسعار والخصومات | SUPER_ADMIN MANAGER |
| purchasing | purchasing.create | إنشاء فواتير شراء | SUPER_ADMIN MANAGER PURCHASER |
| purchasing | purchasing.post | ترحيل فواتير شراء | SUPER_ADMIN MANAGER PURCHASER |
| purchasing | purchasing.return | مرتجع مشتريات وإلغاء فواتير الشراء | SUPER_ADMIN MANAGER PURCHASER |
| purchasing | purchasing.view | عرض المشتريات | SUPER_ADMIN MANAGER WAREHOUSE ACCOUNTANT PURCHASER AUDITOR |
| reports | reports.view | عرض التقارير | SUPER_ADMIN MANAGER ACCOUNTANT PURCHASER AUDITOR |
| sales | discount.exceptional | خصم استثنائي | SUPER_ADMIN MANAGER |
| sales | sales.create | إنشاء مبيعات | SUPER_ADMIN MANAGER CASHIER |
| sales | sales.discount | منح خصم | SUPER_ADMIN MANAGER CASHIER |
| sales | sales.post | ترحيل مبيعات | SUPER_ADMIN MANAGER CASHIER |
| sales | sales.return | مرتجع مبيعات | SUPER_ADMIN MANAGER CASHIER |
| sales | sales.view | عرض المبيعات | SUPER_ADMIN MANAGER CASHIER ACCOUNTANT AUDITOR |

## الملحق ح: Views وأعمدتها الفعلية

19 View في public، أعمدتها وترتيبها كما في القاعدة.

| **الـ View** | **الأعمدة** |
| --- | --- |
| v_account_balances | gl_account_id, code, name, account_type, normal_balance, parent_id, is_postable, debit_base, credit_base, balance_base |
| v_financial_account_balances | financial_account_id, name, type, branch_id, currency_id, currency_code, balance, total_in, total_out, last_transaction_date, is_active |
| v_low_stock | warehouse_id, warehouse_code, warehouse_name, branch_id, is_sellable, variant_id, sku, variant_name, product_id, product_name, quantity_on_hand, quantity_reserved, quantity_available, quantity_incoming, min_quantity, reorder_quantity, below_min |
| v_open_documents | doc_type, doc_id, doc_number, branch_id, party_id, party_name, currency_id, doc_date, due_date, total_amount, paid_amount, remaining_amount, payment_status, days_overdue |
| v_party_balances | party_id, party_name, party_type, is_customer, is_supplier, currency_id, currency_code, total_debit, total_credit, balance, last_entry_date |
| v_pos_session_summary | pos_session_id, pos_terminal_id, terminal_code, branch_id, cashier_user_id, cashier_username, status, opened_at, closed_at, invoices_count |
| v_product_attributes | product_id, kind, item_id, code, name, data_type, is_filterable, option_id, display_value |
| v_product_type_attribute_defs | product_type_id, kind, item_id, code, name, data_type, option_set_id, unit_id, is_filterable, is_required, sort_order, is_active |
| v_purchase_items_costs | id, purchase_invoice_id, variant_id, unit_cost, total_cost |
| v_sale_items_costs | id, sale_id, variant_id, unit_cost, unit_cost_currency_id |
| v_sales_daily | sale_day, branch_id, channel, currency_id, currency_code, invoices_count, total_amount, total_base, total_discount |
| v_stock_available | warehouse_id, warehouse_code, warehouse_name, branch_id, is_sellable, variant_id, sku, variant_name, product_id, product_name, quantity_on_hand, quantity_reserved, quantity_available, quantity_incoming, min_quantity, reorder_quantity, below_min |
| v_stock_in_transit | transfer_id, transfer_number, from_warehouse_id, to_warehouse_id, transfer_item_id, variant_id, sku, variant_name, quantity_shipped, quantity_received, quantity_damaged, quantity_missing, quantity_in_transit, unit_cost, shipped_at, days_in_transit |
| v_stock_movements_costs | id, variant_id, warehouse_id, movement_type, quantity, unit_cost, currency_id, movement_date |
| v_transfer_costs | transfer_item_id, transfer_id, variant_id, unit_cost, loss_value |
| v_transfer_discrepancies | transfer_id, transfer_number, from_warehouse_id, to_warehouse_id, received_at, transfer_item_id, variant_id, sku, variant_name, quantity_shipped, quantity_received, quantity_damaged, quantity_missing, unaccounted_quantity, discrepancy_type, unit_cost, loss_value |
| v_user_access | user_id, username, email, is_active, full_name, job_title, role_codes, branch_codes, terminal_codes |
| v_variant_attributes | variant_id, product_id, sku, variant_name, is_active, size_id, size_name, size_code, product_color_id, color_name, color_components |
| v_variant_list_prices | variant_id, product_id, sku, variant_name, price_list_id, price_list_code, price_type, currency_id, currency_code, amount, valid_from, valid_to, is_current |

التكلفة وقيمة الخسارة تُقرآن من v_transfer_costs (costs.view). v_variant_list_prices بصف واحد لكل (متغير، قائمة) هو السعر الساري، وسعر مستقبلي (is_current = false) يظهر فقط عند غياب سعر ساري، وبلا أعمدة تكلفة.

