# عقد `public.get_my_access()`

المصدر الوحيد لأدوار المستخدم وصلاحياته وفروعه ومستودعاته ونقاط بيعه (قرار-68). لا تُستعمل `SystemRoles` الثابتة في القالب القديم كمصدر بديل.

## ما فُحص فعلاً

تم فحص تعريف الدالة المنشور في قاعدة المشروع `test vaude store with claude` بتاريخ 2026-11-17 عبر `pg_get_functiondef`: التوقيع `public.get_my_access()` بلا معاملات، نوع الإرجاع `jsonb`، وتستند الدالة إلى `auth.uid()` ومستخدم فعّال في `public.users`. كما فُحصت أنواع أعمدة الهوية والنطاقات في قاعدة البيانات. عينة الرد السابقة موثقة أدناه؛ لم يُنفّذ بعد استدعاء REST فعلي بتوكن مستخدم.

لم تُفحص بعد حالات مستخدم غير مدير (MANAGER أو AUDITOR أو CASHIER)، أو حساب معطّل، أو مستخدم بلا فروع، أو مستخدم غير موجود في `users`. يُعاد فحصها عند بناء AUTH-01 بمستخدمي الاختبار (قرار-81).

## شكل الرد (من العينة)

الأسماء أدناه كما وردت، والقيم الشخصية مُخفاة.

```json
{
  "user_id": "<uuid>",
  "username": "admin",
  "email": "<البريد المسجَّل في Auth أو null>",
  "is_super_admin": true,
  "roles": [{ "code": "SUPER_ADMIN", "name": "مدير النظام" }],
  "permissions": ["accounting.manage", "…"],
  "branches": [
    { "branch_id": 1, "code": "MAIN", "name": "الفرع الرئيسي", "can_view": true, "can_operate": true }
  ],
  "warehouses": [
    { "warehouse_id": 1, "code": "WH-SHOP", "name": "صالة العرض", "type": "SHOP_FLOOR", "branch_id": 1, "is_sellable": true },
    { "warehouse_id": 3, "code": "WH-CENTRAL", "name": "المستودع المركزي", "type": "CENTRAL", "branch_id": null, "is_sellable": false }
  ],
  "pos_terminals": [
    { "pos_terminal_id": 1, "code": "POS-01", "name": "نقطة البيع 1", "branch_id": 1, "is_default": true }
  ]
}
```

| الحقل | النوع | ملاحظات |
|---|---|---|
| `user_id` | uuid | هو `auth.users.id` |
| `username` | نص | |
| `email` | نص أو null | عمود `public.users.email` يسمح بـ null |
| `is_super_admin` | منطقي | يتجاوز فحوص الفروع في القاعدة؛ لا يغني الواجهة عن قراءة `permissions` |
| `roles[]` | `{code, name}` | تعدد الأدوار مدعوم (قرار-40) |
| `permissions[]` | نصوص | أكواد مثل `catalog.manage`؛ تجاهل أي كود غير معروف للتطبيق |
| `branches[]` | `{branch_id, code, name, can_view, can_operate}` | `can_operate = false` يعني «عرض فقط»؛ المعرف bigint ويصل JSON كعدد صحيح |
| `warehouses[]` | `{warehouse_id, code, name, type, branch_id, is_sellable}` | `branch_id` يكون `null` للمستودع المركزي؛ المعرف bigint |
| `pos_terminals[]` | `{pos_terminal_id, code, name, branch_id, is_default}` | المعرفات bigint |
| معاملات الدالة | لا شيء | `POST /rest/v1/rpc/get_my_access` مع جسم JSON فارغ `{}` |
| نوع الإرجاع | jsonb | كائن JSON مطابق للعقد |

## ما تُظهره العينة عن المدير العام

- يحصل على **كل** الفروع (فرعان في بيانات الاختبار) فتظهر له شاشة اختيار الفرع (قرار-67)، رغم أن وثائق S01 تفترض أن لا صفوف `user_branch_access` لـ SUPER_ADMIN.
- يعيد **46** صلاحية بما فيها `parties.quick_add`، بينما `role_permissions` تربط 45 لهذا الدور، والوثيقة 1.3 تقول إن SUPER_ADMIN لا يحمل `parties.quick_add`. الدالة هي المرجع (قرار-51)؛ لا يُبنى منطق الواجهة على الفرق بين العددين.

## قواعد للعميل (قرار-68)

1. لا افتراضات: أي حقل مطلوب ناقص أو بشكل مختلف يُعامَل فشلاً في تحميل الصلاحيات. البريد وحده يقبل `null` لأن العمود يسمح بذلك.
2. فشل التحميل يمنع وظائف ERP مع رسالة وزر إعادة محاولة، ولا تُمنح صلاحيات افتراضية.
3. إخفاء الأزرار والمسارات من `permissions` ليس حماية؛ الحماية في القاعدة (ERP16).
4. سياسة التخزين والتحديث معتمدة في [ADR-0006](../architecture/ADR/0006-access-snapshot-lifecycle.md): ذاكرة فقط، ومسح عند انتهاء الجلسة، وإعادة تحميل عند تسجيل الدخول أو تغيير الفرع.
