import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon_data.dart';

/// The single place where the app's icons are defined.
///
/// Add an icon here, then use it as `AppIcon(AppIcons.email)`. To change an
/// icon everywhere (e.g. Material → SVG) edit only its line below.
abstract final class AppIcons {
  static const email = AppIconData.material(Icons.mail_outline);
  static const lock = AppIconData.material(Icons.lock_outline);
  static const visibility = AppIconData.material(Icons.visibility);
  static const visibilityOff = AppIconData.material(Icons.visibility_off);
  static const person = AppIconData.material(Icons.person_outline);
  static const phone = AppIconData.material(Icons.phone_outlined);
  static const pin = AppIconData.material(Icons.pin_outlined);
  static const logout = AppIconData.material(Icons.logout);

  static const sale = AppIconData.material(Icons.receipt_long_outlined);
  static const purchase = AppIconData.material(Icons.shopping_cart_outlined);
  static const payment = AppIconData.material(Icons.payments_outlined);
  static const customers = AppIconData.material(Icons.groups_outlined);
  static const reports = AppIconData.material(Icons.bar_chart_outlined);
  static const cash = AppIconData.material(
    Icons.account_balance_wallet_outlined,
  );
  static const receivable = AppIconData.material(Icons.south_west);
  static const payable = AppIconData.material(Icons.north_east);
  static const trendUp = AppIconData.material(Icons.trending_up);
  static const info = AppIconData.material(Icons.info_outline);
  static const refresh = AppIconData.material(Icons.refresh);

  /// Fallback drawn when an image fails to load.
  static const brokenImage = AppIconData.material(Icons.broken_image_outlined);

  static const home = AppIconData.material(Icons.home_outlined);
  static const homeActive = AppIconData.material(Icons.home);
  static const profile = AppIconData.material(Icons.person_outline);
  static const profileActive = AppIconData.material(Icons.person);

  // Message kinds (InlineBanner, MessageViewWidgets). `info` is above.
  static const success = AppIconData.material(Icons.check_circle_outline);
  static const error = AppIconData.material(Icons.error_outline);
  static const warning = AppIconData.material(Icons.warning_amber_outlined);
  static const close = AppIconData.material(Icons.close);
  static const notifications = AppIconData.material(
    Icons.notifications_outlined,
  );
  static const more = AppIconData.material(Icons.more_vert);
  static const back = AppIconData.material(Icons.arrow_back);
  static const sidebarCollapse = AppIconData.material(Icons.menu_open);
  static const sidebarExpand = AppIconData.material(Icons.menu);

  // Pickers (ScopeSelector).
  static const expand = AppIconData.material(Icons.expand_more);
  static const search = AppIconData.material(Icons.search);
  static const sortAscending = AppIconData.material(Icons.arrow_upward);
  static const sortDescending = AppIconData.material(Icons.arrow_downward);
  static const check = AppIconData.material(Icons.check);

  /// Placeholder until a brand SVG asset (`AppIconData.svg(...)`) is added.
  static const google = AppIconData.material(Icons.account_circle_outlined);
}
