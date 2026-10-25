import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/foundation/localization/translations/app_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_navigation_bar/custom_navigation_bar.dart';

class MainPagesScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainPagesScreen({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,

      /// إذا ضغط على نفس التبويب
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: navigationShell,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: CustomNavigationBar(
          // style: NavBarStyle.elegant,
          items: navItems,
          activeIndex: navigationShell.currentIndex,
          onIndexChanged: _onTap,
          elevation: 2,
          showLabelsAlways: false,
        ),
      ),
    );
  }
}

List<NavBarItem> navItems = [
  NavBarItem(
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
    label: AppKeys.home,
  ),
  NavBarItem(
    icon: Icons.chat_outlined,
    activeIcon: Icons.chat,
    label: AppKeys.chat,
  ),
  NavBarItem(
    icon: Icons.favorite_outline,
    activeIcon: Icons.favorite,
    label: AppKeys.favorite,
  ),
  NavBarItem(
    icon: Icons.person_outline,
    activeIcon: Icons.person,
    label: AppKeys.person,
  ),
];
