import 'package:dartz/dartz.dart';
import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

enum SizeRangeError { reversed, stepNotPositive, tooManyRows }

class SizeRangeSpec extends Equatable {
  const SizeRangeSpec({
    required this.from,
    required this.to,
    required this.step,
    this.codePrefix = '',
  });

  final Decimal from;
  final Decimal to;
  final Decimal step;
  final String codePrefix;

  @override
  List<Object?> get props => [from, to, step, codePrefix];
}

class GeneratedSizeRow extends Equatable {
  const GeneratedSizeRow({
    required this.code,
    required this.name,
    required this.numericValue,
    required this.sortOrder,
  });

  final String code;
  final String name;
  final Decimal numericValue;
  final int sortOrder;

  @override
  List<Object?> get props => [code, name, numericValue, sortOrder];
}

class SizeRangePlan extends Equatable {
  const SizeRangePlan({required this.rows, required this.skippedCodes});

  /// Rows that will be saved, in generation order.
  final List<GeneratedSizeRow> rows;

  /// Codes already present in the group: skipped, reported to the user.
  final List<String> skippedCodes;

  @override
  List<Object?> get props => [rows, skippedCodes];
}

/// Builds the preview of a numeric size range (e.g. 36 to 46 step 1 = 11 rows).
///
/// All arithmetic uses [Decimal], never `double`, so 0.1 steps stay exact.
abstract final class SizeRangeGenerator {
  /// Hard ceiling on generated rows (before skipping existing codes).
  static const maxRows = 200;

  static Either<SizeRangeError, SizeRangePlan> plan({
    required SizeRangeSpec spec,
    required Set<String> existingCodes,
    int firstSortOrder = 0,
  }) {
    if (spec.step <= Decimal.zero) {
      return const Left(SizeRangeError.stepNotPositive);
    }
    if (spec.from > spec.to) return const Left(SizeRangeError.reversed);

    final existing = {for (final code in existingCodes) code.toUpperCase()};
    final prefix = spec.codePrefix.trim().toUpperCase();
    final rows = <GeneratedSizeRow>[];
    final skipped = <String>[];
    var generated = 0;
    var sortOrder = firstSortOrder;

    for (var value = spec.from; value <= spec.to; value += spec.step) {
      generated++;
      if (generated > maxRows) return const Left(SizeRangeError.tooManyRows);
      final text = value.toString();
      final code = '$prefix${text.replaceAll('.', '_')}';
      if (existing.contains(code)) {
        skipped.add(code);
        continue;
      }
      rows.add(
        GeneratedSizeRow(
          code: code,
          name: text,
          numericValue: value,
          sortOrder: sortOrder++,
        ),
      );
    }
    return Right(SizeRangePlan(rows: rows, skippedCodes: skipped));
  }
}
