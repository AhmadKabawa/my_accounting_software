import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_appbar/app_page_app_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icons.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/home/domain/entity/home_summary.dart';
import 'package:accounting_software/app/features/home/presentation/cubit/home_cubit.dart';
import 'package:accounting_software/app/features/home/presentation/cubit/home_state.dart';
import 'package:accounting_software/app/features/home/presentation/localization/home_keys.dart';
import 'package:accounting_software/app/features/home/presentation/sections/home_greeting_section.dart';
import 'package:accounting_software/app/features/home/presentation/sections/home_overview_section.dart';
import 'package:accounting_software/app/features/home/presentation/sections/home_quick_actions_section.dart';
import 'package:accounting_software/app/features/home/presentation/sections/home_recent_activity_section.dart';
import 'package:accounting_software/app/features/home/presentation/sections/home_sample_notice_section.dart';

/// Needs a `HomeCubit` and a `SessionCubit` above it (provided by the router).
/// The screen only arranges the sections for the current state.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppPageAppBar(titleKey: NavKeys.home),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) => switch (state) {
          HomeLoading() => const Center(child: CircularProgressIndicator()),
          HomeFailed(:final messageKey) => _Failure(messageKey: messageKey),
          HomeLoaded(:final summary) => _Content(summary: summary),
        },
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    Widget gap() => context.ui.spacing.gap(AppSpacing.lg, axis: Axis.vertical);
    Widget title(AppKey key) => Padding(
      padding: context.ui.padding.symmetric(vertical: AppSpacing.sm),
      child: AppText(key, type: AppTextType.titleMedium),
    );

    return RefreshIndicator(
      onRefresh: context.read<HomeCubit>().load,
      child: ListView(
        padding: context.ui.padding.all(AppSpacing.lg),
        children: [
          const HomeGreetingSection(),
          gap(),
          if (summary.isSample) ...[const HomeSampleNoticeSection(), gap()],
          title(HomeKeys.overview),
          HomeOverviewSection(summary: summary),
          gap(),
          title(HomeKeys.quickActions),
          const HomeQuickActionsSection(),
          gap(),
          title(HomeKeys.recentActivity),
          HomeRecentActivitySection(items: summary.recent),
        ],
      ),
    );
  }
}

class _Failure extends StatelessWidget {
  const _Failure({required this.messageKey});

  final AppKey messageKey;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: context.ui.padding.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(messageKey, textAlign: TextAlign.center),
            context.ui.spacing.gap(AppSpacing.md, axis: Axis.vertical),
            AppButton(
              HomeKeys.retry,
              icon: AppIcons.refresh,
              onPressed: context.read<HomeCubit>().load,
            ),
          ],
        ),
      ),
    );
  }
}
