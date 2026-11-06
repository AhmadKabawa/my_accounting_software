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

  /// Placeholder until a brand SVG asset (`AppIconData.svg(...)`) is added.
  static const google = AppIconData.material(Icons.account_circle_outlined);
}
