import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/permission.dart';

extension AccessContextX on BuildContext {
  /// Read inside build; returns false while access is loading or failed.
  bool can(Permission permission) =>
      select<AccessCubit, bool>((cubit) => cubit.can(permission));

  /// Permission plus the selected branch's `can_operate` scope.
  bool canOperate(Permission permission) =>
      select<AccessCubit, bool>((cubit) => cubit.canOperate(permission));
}
