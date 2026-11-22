import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';

/// One localized statistic and its optional list-filter value.
class StatItem<F> {
  const StatItem({
    required this.labelKey,
    required this.value,
    required this.icon,
    required this.tone,
    this.filter,
  });

  final AppKey labelKey;
  final String? value;
  final AppIconData icon;
  final AppBadgeTone tone;

  /// Null makes this statistic informational rather than selectable.
  final F? filter;
}
