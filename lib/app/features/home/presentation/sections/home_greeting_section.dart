import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/auth/domain/session/session_gate.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/session/session_cubit.dart';
import 'package:accounting_software/app/features/home/presentation/localization/home_keys.dart';
import 'package:accounting_software/app/features/home/presentation/support/home_format.dart';

/// "Good morning, <name>" for the signed-in user.
class HomeGreetingSection extends StatelessWidget {
  const HomeGreetingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final name = context.select<SessionCubit, String>(
      (cubit) => switch (cubit.current) {
        SessionAuthenticated(:final user) =>
          (user.fullName ?? '').trim().isEmpty ? user.email : user.fullName!.trim(),
        _ => '',
      },
    );
    final greeting = greetingFor(DateTime.now());

    if (name.isEmpty) return AppText(greeting, type: AppTextType.headlineSmall);
    return AppText.raw(
      HomeKeys.greetingWithName.tr(
        context: context,
        namedArgs: {'greeting': greeting.tr(context: context), 'name': name},
      ),
      type: AppTextType.headlineSmall,
    );
  }
}
