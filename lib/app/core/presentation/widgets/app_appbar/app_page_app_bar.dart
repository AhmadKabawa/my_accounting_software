import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

/// The plain app bar for ordinary pages (back arrow + optional translated
/// title), themed by `app_bar_theme.dart`. `AppAppBar` is the brand home bar.
class AppPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppPageAppBar({super.key, this.titleKey, this.actions});

  final AppKey? titleKey;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final key = titleKey;
    return AppBar(
      title: key == null ? null : AppText(key, type: AppTextType.titleLarge),
      actions: actions,
    );
  }
}
