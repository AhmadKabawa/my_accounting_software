import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon_data.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icons.dart';

void main() {
  test('catalog areas expose distinct material icons', () {
    final icons = [
      AppIcons.brands,
      AppIcons.productTypes,
      AppIcons.units,
      AppIcons.optionSets,
      AppIcons.attributes,
      AppIcons.colors,
      AppIcons.materials,
      AppIcons.fabricTypes,
      AppIcons.tags,
      AppIcons.sports,
      AppIcons.genders,
      AppIcons.ageGroups,
    ];

    expect(icons, everyElement(isA<MaterialIconData>()));
    expect(icons.toSet(), hasLength(icons.length));
  });
}
