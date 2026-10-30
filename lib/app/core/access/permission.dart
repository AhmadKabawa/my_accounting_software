/// الإجراءات القياسية التي يمكن منحها على أي وحدة (module).
/// لإجراء خاص بوحدة واحدة استخدم `Permission('module.custom_action')`.
enum PermissionAction {
  view,
  create,
  edit,
  delete,
  post,
  reverse,
  approve,
  export,
}

/// صلاحية واحدة بالصيغة `module.action`.
///
/// extension type بنفس نمط [StorageKey] و`AppKey`: لا تكلفة وقت تشغيل،
/// ومنع خلط الصلاحيات مع النصوص العادية.
///
/// الرموز الخاصة (للمنح فقط):
/// - `*` يغطي كل شيء (المالك).
/// - `module.*` يغطي كل إجراءات الوحدة.
extension type const Permission(String value) {
  /// صلاحية كل شيء.
  static const all = Permission('*');

  /// `module.action`
  Permission.of(String module, PermissionAction action)
    : this('$module.${action.name}');

  /// كل إجراءات وحدة معينة: `module.*`
  Permission.module(String module) : this('$module.*');

  /// هل هذه الصلاحية الممنوحة تغطي الصلاحية المطلوبة [required]؟
  bool covers(Permission required) {
    if (value == '*' || value == required.value) return true;
    if (!value.endsWith('.*')) return false;
    // `sales.*` → البادئة `sales.`
    return required.value.startsWith(value.substring(0, value.length - 1));
  }
}
