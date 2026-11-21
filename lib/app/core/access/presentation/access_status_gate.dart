import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/keys/access_keys.dart';
import 'package:accounting_software/app/core/localization/keys/common_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

/// Keeps the authenticated shell hidden until the server access snapshot is
/// ready. A failed request exposes a localized retry action, never stale access.
///
/// Once the shell has been shown, it remains mounted but inaccessible while
/// access is refreshed. This preserves dirty forms if a branch refresh fails.
class AccessStatusGate extends StatefulWidget {
  const AccessStatusGate({
    super.key,
    required this.child,
    required this.signOutLabel,
    this.onSignOut,
  });

  final Widget child;
  final AppKey signOutLabel;
  final Future<bool> Function()? onSignOut;

  @override
  State<AccessStatusGate> createState() => _AccessStatusGateState();
}

class _AccessStatusGateState extends State<AccessStatusGate> {
  bool _hasRenderedChild = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccessCubit, AccessState>(
      builder: (context, state) {
        if (state.status == AccessStatus.initial) _hasRenderedChild = false;
        final hasNoBranches = state.hasNoAvailableBranches;
        final isReady = state.isReady && !hasNoBranches;
        if (isReady) _hasRenderedChild = true;

        final Widget? statusView;
        if (hasNoBranches) {
          statusView = _buildNoBranches(context);
        } else if (isReady) {
          statusView = null;
        } else {
          statusView = _buildLoadingOrFailure(context, state);
        }

        if (!_hasRenderedChild) return statusView!;

        return Stack(
          fit: StackFit.expand,
          children: [
            Offstage(
              offstage: statusView != null,
              child: TickerMode(
                enabled: statusView == null,
                child: IgnorePointer(
                  ignoring: statusView != null,
                  child: ExcludeSemantics(
                    excluding: statusView != null,
                    child: widget.child,
                  ),
                ),
              ),
            ),
            ?statusView,
          ],
        );
      },
    );
  }

  Widget _buildNoBranches(BuildContext context) => Scaffold(
    body: Center(
      child: Padding(
        padding: context.ui.padding.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              AccessKeys.noAvailableBranches,
              textAlign: TextAlign.center,
            ),
            context.ui.spacing.gap(AppSpacing.md, axis: Axis.vertical),
            if (widget.onSignOut != null)
              AppButton(widget.signOutLabel, onPressed: widget.onSignOut),
          ],
        ),
      ),
    ),
  );

  Widget _buildLoadingOrFailure(BuildContext context, AccessState state) {
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
  }
}
