import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/keys/access_keys.dart';
import 'package:accounting_software/app/core/localization/keys/common_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

/// Keeps the authenticated shell hidden until the server access snapshot is
/// ready. A failed request exposes a localized retry action, never stale access.
class AccessStatusGate extends StatelessWidget {
  const AccessStatusGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccessCubit, AccessState>(
      builder: (context, state) {
        if (state.hasNoAvailableBranches) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: context.ui.padding.all(AppSpacing.lg),
                child: AppText(
                  AccessKeys.noAvailableBranches,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        if (state.isReady) return child;

        final isFailure = state.status == AccessStatus.failure;
        return Scaffold(
          body: Center(
            child: Padding(
              padding: context.ui.padding.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isFailure)
                    AppText(AccessKeys.loadFailed, textAlign: TextAlign.center)
                  else ...[
                    const CircularProgressIndicator(),
                    context.ui.spacing.gap(AppSpacing.md, axis: Axis.vertical),
                    AppText(AccessKeys.loading, textAlign: TextAlign.center),
                  ],
                  if (isFailure) ...[
                    context.ui.spacing.gap(AppSpacing.md, axis: Axis.vertical),
                    AppButton(
                      CommonKeys.retry,
                      onPressed: context.read<AccessCubit>().retry,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
