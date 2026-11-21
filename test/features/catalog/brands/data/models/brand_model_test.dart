import 'package:accounting_software/app/features/catalog/brands/data/models/brand_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BrandModel', () {
    test('maps PostgREST fields and embedded product count', () {
      final model = BrandModel.fromJson({
        'id': 42,
        'name': 'Northwind',
        'slug': 'northwind',
        'logo': 'https://example.com/logo.png',
        'description': 'Supplier brand',
        'is_active': false,
        'products': [
          {'count': 7},
        ],
      });

      expect(model.id, 42);
      expect(model.name, 'Northwind');
      expect(model.slug, 'northwind');
      expect(model.isActive, isFalse);
      expect(model.productCount, 7);
      expect(model.toEntity().productCount, 7);
      expect(model.toJson()['id'], 42);
      expect(model.toJson()['is_active'], isFalse);
    });

    test('treats an empty embedded relation as zero products', () {
      final model = BrandModel.fromJson({
        'id': '9',
        'name': 'Contoso',
        'slug': 'contoso',
        'products': <dynamic>[],
      });

      expect(model.id, 9);
      expect(model.productCount, 0);
      expect(model.isActive, isTrue);
    });

    test('rejects a missing or invalid database id', () {
      expect(
        () => BrandModel.fromJson({'name': 'A', 'slug': 'a'}),
        throwsFormatException,
      );
    });
  });
}
