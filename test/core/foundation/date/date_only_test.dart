import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/foundation/date/date_only.dart';

void main() {
  group('DateOnly', () {
    test('round trips yyyy-MM-dd without shifting the day', () {
      final value = DateTime(2026, 11, 27, 23, 45);
      expect(DateOnly.toApiString(value), '2026-11-27');
      expect(DateOnly.fromApiString('2026-11-27'), DateTime(2026, 11, 27));
    });

    test('handles month boundaries and leap day', () {
      expect(DateOnly.toApiString(DateTime(2024, 2, 1)), '2024-02-01');
      expect(DateOnly.toApiString(DateTime(2024, 2, 29)), '2024-02-29');
      expect(DateOnly.toApiString(DateTime(2024, 3, 31)), '2024-03-31');
      expect(DateOnly.fromApiString('2023-02-29'), isNull);
    });

    test('rejects malformed values', () {
      expect(DateOnly.fromApiString(null), isNull);
      expect(DateOnly.fromApiString('2026-2-03'), isNull);
      expect(DateOnly.fromApiString('not-a-date'), isNull);
    });
  });
}
