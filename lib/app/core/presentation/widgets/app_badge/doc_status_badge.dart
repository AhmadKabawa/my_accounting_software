import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/keys/badge_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';

/// A translated badge for the document and payment states in DATA_MODEL.md.
class DocStatusBadge extends StatelessWidget {
  const DocStatusBadge({
    super.key,
    required this.status,
    this.size = AppBadgeSize.medium,
  });

  final String status;
  final AppBadgeSize size;

  @override
  Widget build(BuildContext context) {
    final normalized = status.trim().toUpperCase();
    final (label, tone) = switch (normalized) {
      'DRAFT' => (BadgeKeys.draft, AppBadgeTone.neutral),
      'POSTED' => (BadgeKeys.posted, AppBadgeTone.success),
      'REVERSED' => (BadgeKeys.reversed, AppBadgeTone.warning),
      'CANCELLED' => (BadgeKeys.cancelled, AppBadgeTone.error),
      'UNPAID' => (BadgeKeys.unpaid, AppBadgeTone.warning),
      'PARTIAL' => (BadgeKeys.partial, AppBadgeTone.info),
      'PAID' => (BadgeKeys.paid, AppBadgeTone.success),
      _ => (BadgeKeys.unknown, AppBadgeTone.neutral),
    };

    return AppBadge(label: label, tone: tone, size: size);
  }
}
