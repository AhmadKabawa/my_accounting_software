import 'package:dartz/dartz.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/size_systems/shared/domain/range/size_range_generator.dart';

SizeRangeSpec _spec(
  String from,
  String to,
  String step, [
  String prefix = '',
]) => SizeRangeSpec(
  from: Decimal.parse(from),
  to: Decimal.parse(to),
  step: Decimal.parse(step),
  codePrefix: prefix,
);

SizeRangePlan _plan(
  SizeRangeSpec spec, {
  Set<String> existing = const {},
  int firstSortOrder = 0,
}) => SizeRangeGenerator.plan(
  spec: spec,
  existingCodes: existing,
  firstSortOrder: firstSortOrder,
).getOrElse(() => throw StateError('expected a plan'));

void main() {
  group('SizeRangeGenerator', () {
    test('CAT07-SZ-AC3: 36 to 46 step 1 yields 11 sizes', () {
      final plan = _plan(_spec('36', '46', '1', 'EU'));
      expect(plan.rows, hasLength(11));
      expect(plan.rows.first.code, 'EU36');
      expect(plan.rows.first.name, '36');
      expect(plan.rows.last.code, 'EU46');
      expect(plan.skippedCodes, isEmpty);
    });

    test('sort order follows generation order from the first value', () {
      final plan = _plan(_spec('36', '38', '1'), firstSortOrder: 10);
      expect(plan.rows.map((r) => r.sortOrder), [10, 11, 12]);
    });

    test('CAT07-SZ-AC4: a reversed range is rejected', () {
      final result = SizeRangeGenerator.plan(
        spec: _spec('46', '36', '1'),
        existingCodes: const {},
      );
      expect(result, const Left(SizeRangeError.reversed));
    });

    test('a non-positive step is rejected', () {
      for (final step in ['0', '-1']) {
        expect(
          SizeRangeGenerator.plan(
            spec: _spec('1', '5', step),
            existingCodes: const {},
          ),
          const Left(SizeRangeError.stepNotPositive),
        );
      }
    });

    test('from == to yields exactly one row', () {
      expect(_plan(_spec('40', '40', '1')).rows, hasLength(1));
    });

    test('0.1 steps are exact (no binary floating point drift)', () {
      final plan = _plan(_spec('0', '0.5', '0.1'));
      expect(plan.rows.map((r) => r.name), [
        '0',
        '0.1',
        '0.2',
        '0.3',
        '0.4',
        '0.5',
      ]);
      expect(plan.rows.last.numericValue, Decimal.parse('0.5'));
    });

    test('decimal points become underscores in the code', () {
      final plan = _plan(_spec('36', '37', '0.5', 'EU'));
      expect(plan.rows.map((r) => r.code), ['EU36', 'EU36_5', 'EU37']);
    });

    test('existing codes are skipped (case-insensitive) and reported', () {
      final plan = _plan(_spec('36', '38', '1', 'eu'), existing: {'EU37'});
      expect(plan.rows.map((r) => r.code), ['EU36', 'EU38']);
      expect(plan.skippedCodes, ['EU37']);
    });

    test('a range above the row ceiling is rejected', () {
      final result = SizeRangeGenerator.plan(
        spec: _spec('0', '${SizeRangeGenerator.maxRows}', '1'),
        existingCodes: const {},
      );
      expect(result, const Left(SizeRangeError.tooManyRows));
    });

    test('exactly the ceiling is accepted', () {
      final plan = _plan(_spec('1', '${SizeRangeGenerator.maxRows}', '1'));
      expect(plan.rows, hasLength(SizeRangeGenerator.maxRows));
    });
  });
}
