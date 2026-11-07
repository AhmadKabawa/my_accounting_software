import 'package:accounting_software/app/features/home/domain/entity/home_summary.dart';
import 'package:accounting_software/app/features/home/presentation/localization/home_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';

/// Groups digits by thousands: `48250` → `48,250`.
String formatAmount(num value) {
  final text = value.round().abs().toString();
  final grouped = text.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return value < 0 ? '-$grouped' : grouped;
}

/// Greeting by the hour; the boundary is a named constant, not a loose number.
const _eveningStartsAtHour = 12;

HomeKeys greetingFor(DateTime now) =>
    now.hour < _eveningStartsAtHour
    ? HomeKeys.greetingMorning
    : HomeKeys.greetingEvening;

AppKey activityLabel(ActivityKind kind) => switch (kind) {
  ActivityKind.sale => HomeKeys.activitySale,
  ActivityKind.purchase => HomeKeys.activityPurchase,
  ActivityKind.payment => HomeKeys.activityPayment,
};
