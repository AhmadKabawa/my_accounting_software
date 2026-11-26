import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport.dart';
import 'sport_identity.dart';
import 'sport_status_badge.dart';

/// Grid-mode tile for one sport.
class SportGridTile extends StatelessWidget {
  const SportGridTile(this.sport, {super.key});

  final Sport sport;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SportIdentity(sport, size: AppIconSize.xl, maxNameLines: 2),
      context.ui.spacing.gap(AppSpacing.xs),
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppText.raw(
          sport.code,
          type: AppTextType.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      context.ui.spacing.gap(AppSpacing.sm),
      SportStatusBadge(sport),
    ],
  );
}
