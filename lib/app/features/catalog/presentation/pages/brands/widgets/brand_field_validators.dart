import 'package:flutter/widgets.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/features/catalog/presentation/localization/brands_keys.dart';

/// Validators for the brand form (limits mirror the `brands` table).
abstract final class BrandFieldValidators {
  static const maxName = 150;
  static const maxSlug = 150;
  static const maxLogo = 500;
  static final _slugPattern = RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$');

  static String? name(BuildContext context, String? value) {
    final s = value?.trim() ?? '';
    if (s.isEmpty) return BrandsKeys.required.tr(context: context);
    if (s.length > maxName) return BrandsKeys.nameTooLong.tr(context: context);
    return null;
  }

  static String? slug(BuildContext context, String? value) {
    final s = value?.trim() ?? '';
    if (s.isEmpty) return BrandsKeys.slugRequired.tr(context: context);
    if (s.length > maxSlug) return BrandsKeys.slugTooLong.tr(context: context);
    if (!_slugPattern.hasMatch(s)) return BrandsKeys.slugFormat.tr(context: context);
    return null;
  }

  static String? logo(BuildContext context, String? value) {
    final s = value?.trim() ?? '';
    if (s.isEmpty) return null;
    if (s.length > maxLogo) return BrandsKeys.logoTooLong.tr(context: context);
    final uri = Uri.tryParse(s);
    final valid = uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    return valid ? null : BrandsKeys.invalidLogoUrl.tr(context: context);
  }
}
