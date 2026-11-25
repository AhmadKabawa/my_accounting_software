import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/categories/data/models/category_model.dart';

Map<String, dynamic> _json({
  dynamic productCategories = const [{'count': 4}],
}) => {
  'id': 12,
  'parent_id': 3,
  'name': 'Running shoes',
  'slug': 'running-shoes',
  'description': 'Sport shoes',
  'image': 'https://cdn.example.test/shoes.png',
  'sort_order': 8,
  'is_active': false,
  if (productCategories != null) 'product_categories': productCategories,
};

void main() {
  test('parses category fields and embedded PostgREST count', () {
    final model = CategoryModel.fromJson(_json());

    expect(model.id, 12);
    expect(model.parentId, 3);
    expect(model.name, 'Running shoes');
    expect(model.slug, 'running-shoes');
    expect(model.description, 'Sport shoes');
    expect(model.image, 'https://cdn.example.test/shoes.png');
    expect(model.sortOrder, 8);
    expect(model.isActive, isFalse);
    expect(model.productCount, 4);
    expect(model.toEntity().productCount, 4);
  });

  test('accepts map-shaped embedded count responses', () {
    final model = CategoryModel.fromJson(
      _json(productCategories: {'count': 7}),
    );

    expect(model.productCount, 7);
  });

  test('missing embedded count remains unknown, not zero', () {
    final model = CategoryModel.fromJson(_json(productCategories: null));

    expect(model.productCount, isNull);
    expect(model.toEntity().productCount, isNull);
  });

  test('malformed embedded count remains unknown', () {
    final model = CategoryModel.fromJson(
      _json(productCategories: const [{'unexpected': 5}]),
    );

    expect(model.productCount, isNull);
  });

  test('rejects an invalid category id', () {
    expect(
      () => CategoryModel.fromJson({..._json(), 'id': 'not-an-id'}),
      throwsFormatException,
    );
  });
}
