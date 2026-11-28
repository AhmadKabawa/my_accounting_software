import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/routing/size_systems_routes.dart';

void main() {
  group('SizeSystemsRoutes', () {
    test('the registry exposes only the stable list destination', () {
      expect(SizeSystemsRoutes.all, [SizeSystemsRoutes.sizeSystems]);
      expect(SizeSystemsRoutes.sizeSystems.path, '/catalog/size-systems');
    });

    test('dynamic route templates match their location builders', () {
      expect(SizeSystemsRoutes.groupsPath, '/catalog/size-systems/:systemId');
      expect(SizeSystemsRoutes.groups(7), '/catalog/size-systems/7');
      expect(
        SizeSystemsRoutes.sizesPath,
        '/catalog/size-systems/:systemId/groups/:groupId',
      );
      expect(SizeSystemsRoutes.sizes(7, 3), '/catalog/size-systems/7/groups/3');
    });

    test('route names are unique', () {
      final names = {
        SizeSystemsRoutes.sizeSystems.name,
        SizeSystemsRoutes.groupsName,
        SizeSystemsRoutes.sizesName,
      };
      expect(names, hasLength(3));
    });
  });
}
