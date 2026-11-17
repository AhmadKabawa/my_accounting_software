import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_navigation_bar/app_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('NavBarItem.icons keeps the AppIconData it is given', () {
    const item = NavBarItem.icons(
      icon: AppIcons.home,
      activeIcon: AppIcons.homeActive,
      label: NavKeys.home,
    );
    expect(item.icon, AppIcons.home);
    expect(item.activeIcon, AppIcons.homeActive);
  });

  test('the IconData constructor wraps it as a Material AppIconData', () {
    const item = NavBarItem(icon: Icons.home, label: NavKeys.home);
    expect(item.icon, isA<MaterialIconData>());
    expect((item.icon as MaterialIconData).data, Icons.home);
    expect(item.activeIcon, isNull);
  });
}
