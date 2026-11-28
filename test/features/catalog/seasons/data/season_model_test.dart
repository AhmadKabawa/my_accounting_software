import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/seasons/data/models/season_model.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/entity/season.dart';

void main() {
  group('SeasonModel', () {
    test('maps date-only fields and enum to the domain entity', () {
      final model = SeasonModel.fromJson({
        'id': 12,
        'name': 'Summer 2026',
        'code': 'SUM-26',
        'season_type': 'summer',
        'start_date': '2026-06-01',
        'end_date': '2026-09-30',
        'is_active': true,
      });
      final entity = model.toEntity();
      expect(entity.seasonType, SeasonType.summer);
      expect(entity.startDate, DateTime(2026, 6, 1));
      expect(entity.endDate, DateTime(2026, 9, 30));
    });

    test('keeps optional fields nullable', () {
      final model = SeasonModel.fromJson({
        'id': '13',
        'name': 'All season',
        'code': 'ALL',
        'season_type': null,
        'start_date': null,
        'end_date': null,
        'is_active': null,
      });
      expect(model.seasonType, isNull);
      expect(model.startDate, isNull);
      expect(model.endDate, isNull);
      expect(model.isActive, isTrue);
    });
  });
}
