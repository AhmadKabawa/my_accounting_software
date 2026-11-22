import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_card/app_card.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_skeleton/app_skeleton.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/color_list_query.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/color_stats.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/color_stats/color_stats_cubit.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/color_stats/color_stats_state.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/localization/colors_keys.dart';

class ColorStatsSection extends StatelessWidget {
  const ColorStatsSection({super.key, required this.onStatusSelected});

  final ValueChanged<ColorStatusFilter> onStatusSelected;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ColorStatsCubit, ColorStatsState>(
        builder: (context, state) {
          if (state.status == ColorStatsStatus.failed) {
            final failure = state.failure;
            if (failure != null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InlineBanner(
                    messageKey: failure.messageKey,
                    variant: InlineBannerVariant.error,
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: AppButton(
                      CatalogUiKeys.retry,
                      variant: AppButtonVariant.text,
                      onPressed: context.read<ColorStatsCubit>().refresh,
                    ),
                  ),
                ],
              );
            }
          }
          if (state.stats case final ColorStats stats) {
            return Wrap(
              spacing: context.ui.spacing.value(AppSpacing.sm),
              runSpacing: context.ui.spacing.value(AppSpacing.sm),
              children: [
                _StatCard(
                  label: ColorsKeys.totalColors,
                  value: stats.total,
                  onTap: () => onStatusSelected(ColorStatusFilter.all),
                ),
                _StatCard(
                  label: ColorsKeys.activeColors,
                  value: stats.active,
                  onTap: () => onStatusSelected(ColorStatusFilter.active),
                ),
                _StatCard(
                  label: ColorsKeys.inactiveColors,
                  value: stats.inactive,
                  onTap: () => onStatusSelected(ColorStatusFilter.inactive),
                ),
              ],
            );
          }
          return const AppSkeleton.card();
        },
      );
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final AppKey label;
  final int value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: context.ui.size.width(AppComponentSize.cardWidth),
    child: AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(label, type: AppTextType.bodySmall),
          context.ui.spacing.gap(AppSpacing.xs),
          AppText.raw('$value', type: AppTextType.titleLarge),
        ],
      ),
    ),
  );
}
