import 'package:accounting_software/app/core/network/api_end_points.dart';
import 'package:flutter_test/flutter_test.dart';

/// Core owns only the tools (`AppEndpoint`, `encodePathSegment`); the endpoints
/// themselves live in each feature. This class stands in for a feature's
/// endpoints, built the way a real one is.
abstract final class _Items {
  static const String base = '/items';

  static const list = AppEndpoint(base);

  static AppEndpoint byId(String id) =>
      AppEndpoint('$base/${encodePathSegment(id)}');

  static AppEndpoint reviews(String id) =>
      AppEndpoint('$base/${encodePathSegment(id)}/reviews');

  static AppEndpoint byCategory(String category) =>
      AppEndpoint('$base/category/${encodePathSegment(category)}');
}

void main() {
  test('AppEndpoint is used as its path', () {
    expect(_Items.list.path, '/items');
    expect(_Items.list.toStringPath(), '/items');
  });

  test('plain ids are unchanged', () {
    expect(_Items.byId('42').path, '/items/42');
    expect(_Items.reviews('42').path, '/items/42/reviews');
    expect(_Items.byCategory('shoes').path, '/items/category/shoes');
  });

  test('reserved characters cannot change the path structure', () {
    expect(_Items.byId('a/b').path, '/items/a%2Fb');
    expect(_Items.byId('a?x=1#f').path, '/items/a%3Fx%3D1%23f');
    expect(_Items.byId('../admin').path, '/items/..%2Fadmin');
    expect(
      _Items.byCategory('men & women').path,
      '/items/category/men%20%26%20women',
    );
  });

  test('non-ASCII values are percent-encoded as UTF-8', () {
    expect(
      _Items.byCategory('أحذية').path,
      startsWith('/items/category/%D8'),
    );
  });

  test('"." and ".." are rejected instead of being passed through', () {
    for (final bad in ['.', '..']) {
      expect(() => encodePathSegment(bad), throwsArgumentError, reason: bad);
      expect(() => _Items.byId(bad), throwsArgumentError, reason: bad);
      expect(() => _Items.reviews(bad), throwsArgumentError, reason: bad);
      expect(() => _Items.byCategory(bad), throwsArgumentError, reason: bad);
    }
  });

  test('dots inside a longer value are fine', () {
    expect(_Items.byId('a.b').path, '/items/a.b');
    expect(_Items.byId('...').path, '/items/...');
  });
}
