import 'package:equatable/equatable.dart';

enum ActivityKind { sale, purchase, payment }

/// One line of the recent-activity list.
class ActivityItem extends Equatable {
  const ActivityItem({
    required this.kind,
    required this.counterparty,
    required this.amount,
  });

  final ActivityKind kind;
  final String counterparty;
  final num amount;

  @override
  List<Object?> get props => [kind, counterparty, amount];
}

/// What the dashboard shows. Amounts are in the company currency.
class HomeSummary extends Equatable {
  const HomeSummary({
    required this.cashBalance,
    required this.receivables,
    required this.payables,
    required this.monthSales,
    required this.recent,
    this.isSample = false,
  });

  final num cashBalance;
  final num receivables;
  final num payables;
  final num monthSales;
  final List<ActivityItem> recent;

  /// True while the data is a placeholder, so the UI can say so.
  final bool isSample;

  @override
  List<Object?> get props => [
    cashBalance,
    receivables,
    payables,
    monthSales,
    recent,
    isSample,
  ];
}
