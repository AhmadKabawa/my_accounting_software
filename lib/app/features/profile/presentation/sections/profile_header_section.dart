import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/auth/domain/entity/user/user_entity.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/session/session_cubit.dart';
import 'package:accounting_software/app/features/auth/domain/session/session_gate.dart';

/// Avatar initial, name and e-mail of the signed-in user.
class ProfileHeaderSection extends StatelessWidget {
  const ProfileHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select<SessionCubit, UserEntity?>(
      (cubit) => switch (cubit.current) {
        SessionAuthenticated(:final user) => user,
        _ => null,
      },
    );
    if (user == null) return const SizedBox.shrink();

    final name = (user.fullName ?? '').trim();
    final label = name.isEmpty ? user.email : name;
    final radius = context.ui.size.width(AppComponentSize.avatarLarge) / 2;

    return Column(
      children: [
        CircleAvatar(
          radius: radius,
          child: AppText.raw(
            String.fromCharCode(label.runes.first).toUpperCase(),
            type: AppTextType.headlineMedium,
          ),
        ),
        context.ui.spacing.gap(AppSpacing.md, axis: Axis.vertical),
        AppText.raw(
          label,
          type: AppTextType.titleLarge,
          textAlign: TextAlign.center,
        ),
        if (name.isNotEmpty)
          AppText.raw(user.email, textAlign: TextAlign.center),
      ],
    );
  }
}
