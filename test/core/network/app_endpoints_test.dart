import 'package:accounting_software/app/core/services/network/api_end_points.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const products = AppEndpoints.products;

  test('plain ids are unchanged', () {
    expect(products.byId('42').path, '/products/42');
    expect(products.reviews('42').path, '/products/42/reviews');
    expect(products.related('42').path, '/products/42/related');
    expect(products.byCategory('shoes').path, '/products/category/shoes');
  });

  test('reserved characters cannot change the path structure', () {
    expect(products.byId('a/b').path, '/products/a%2Fb');
    expect(products.byId('a?x=1#f').path, '/products/a%3Fx%3D1%23f');
    expect(products.byId('../admin').path, '/products/..%2Fadmin');
    expect(products.byCategory('men & women').path,
        '/products/category/men%20%26%20women');
  });

  test('non-ASCII values are percent-encoded as UTF-8', () {
    expect(products.byCategory('أحذية').path, startsWith('/products/category/%D8'));
  });
}
