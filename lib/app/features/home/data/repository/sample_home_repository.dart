import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/home/domain/entity/home_summary.dart';
import 'package:accounting_software/app/features/home/domain/repository/home_repository.dart';

/// PLACEHOLDER: returns fixed sample figures (flagged `isSample`) until the
/// sales / purchases / payments modules exist. Replace it by a repository that
/// aggregates the real modules and change the binding in `home_di.dart`.
class SampleHomeRepository implements HomeRepository {
  const SampleHomeRepository();

  @override
  Future<Either<Failure, HomeSummary>> getSummary() async {
    return const Right(
      HomeSummary(
        isSample: true,
        cashBalance: 48250,
        receivables: 12400,
        payables: 7300,
        monthSales: 91800,
        recent: [
          ActivityItem(
            kind: ActivityKind.sale,
            counterparty: 'Al-Noor Trading',
            amount: 3200,
          ),
          ActivityItem(
            kind: ActivityKind.payment,
            counterparty: 'Al-Amal Co.',
            amount: 1500,
          ),
          ActivityItem(
            kind: ActivityKind.purchase,
            counterparty: 'Gulf Supplies',
            amount: 2750,
          ),
        ],
      ),
    );
  }
}
