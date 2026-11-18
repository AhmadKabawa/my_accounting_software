import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/permission.dart';

/// UI visibility only. Database policies remain the authorization boundary.
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
      selector: (state) =>
          state.isReady &&
          state.snapshot!.permissions.any(
            (granted) => granted.covers(permission),
          ),
      builder: (context, allowed) => allowed ? child : fallback,
    );
  }
}
