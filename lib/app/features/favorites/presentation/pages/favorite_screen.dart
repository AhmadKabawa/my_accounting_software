import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

/// Placeholder module: the destination exists in the shell, its content is
/// not built yet, so it says so instead of looking functional.
class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AppText(AppKeys.common.comingSoon, type: AppTextType.titleMedium),
      ),
    );
  }
}
