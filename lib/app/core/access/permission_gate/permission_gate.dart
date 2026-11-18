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
    this.requiresOperation = false,
  });

  final Permission permission;
  final Widget child;
  final Widget fallback;
  final bool requiresOperation;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccessCubit, AccessState>(
      builder: (context, state) {
        final allowed =
            state.isReady &&
            state.snapshot!.permissions.any(
              (granted) => granted.covers(permission),
            ) &&
            (!requiresOperation ||
                context.read<AccessCubit>().canOperateInSelectedBranch);
        return allowed ? child : fallback;
      },
    );
  }
}
