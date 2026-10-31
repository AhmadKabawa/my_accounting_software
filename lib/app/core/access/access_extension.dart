import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/access/access_cubit.dart';
import 'package:accounting_software/app/core/access/permission.dart';

/// اختصار للواجهة: `context.can(Permissions.sales.create)`.
/// يعيد البناء عند تغيّر الدور، لذا يُستخدم داخل `build` فقط.
extension AccessContextX on BuildContext {
  bool can(Permission permission) => select<AccessCubit, bool>(
    (cubit) => cubit.state.role.allows(permission),
  );
}
