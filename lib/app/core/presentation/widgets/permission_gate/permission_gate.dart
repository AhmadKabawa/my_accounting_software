import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/access/access_cubit.dart';
import 'package:accounting_software/app/core/access/permission.dart';

/// يعرض [child] فقط إذا كان للدور الحالي [permission]، وإلا يعرض [fallback].
///
/// للتحكم في الظهور فقط، وليس حماية: الخادم هو من يفرض الصلاحية.
class PermissionGate extends StatelessWidget {
  const PermissionGate({
    super.key,
    required this.permission,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  });

  final Permission permission;
  final Widget child;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AccessCubit, AccessState, bool>(
      selector: (state) => state.role.allows(permission),
      builder: (context, allowed) => allowed ? child : fallback,
    );
  }
}
