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
/// لا تُستخدم wildcards: الخادم يعيد أكواداً صريحة من KnownPermissionCodes.
extension type const Permission(String value) {
  /// `module.action`
  Permission.of(String module, PermissionAction action)
    : this('$module.${action.name}');

  /// صلاحيتان متطابقتان فقط؛ لا تُوسَّع الصلاحية إلى وحدة أو النظام كله.
  bool covers(Permission required) => value == required.value;
}
