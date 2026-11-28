import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/collections/data/models/collection_model.dart';

void main() {
  group('CollectionModel', () {
    test('maps description, image and date-only values', () {
      final model = CollectionModel.fromJson({
        'id': 7,
        'name': 'Summer capsule',
        'code': 'SUM-CAP',
        'description': 'Seasonal range',
        'image': 'https://cdn.example.test/collections/summer.webp',
        'start_date': '2026-05-01',
        'end_date': '2026-08-31',
        'is_active': true,
      });
      final entity = model.toEntity();
      expect(entity.image, contains('/collections/'));
      expect(entity.startDate, DateTime(2026, 5, 1));
      expect(entity.endDate, DateTime(2026, 8, 31));
      expect(entity.description, 'Seasonal range');
    });

    test('accepts absent optional values', () {
      final model = CollectionModel.fromJson({
        'id': 8,
        'name': 'Evergreen',
        'code': 'EVER',
      });
      expect(model.image, isNull);
      expect(model.startDate, isNull);
      expect(model.endDate, isNull);
      expect(model.isActive, isTrue);
    });
  });
}
