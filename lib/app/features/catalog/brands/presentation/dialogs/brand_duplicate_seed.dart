import 'package:flutter/widgets.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_draft.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/utility/brand_slug_from.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';

/// Copies editable fields while generating a unique name and slug. The logo
/// URL is shared because this feature has no Storage deletion path.
BrandDraft brandDuplicateSeed(BuildContext context, Brand source) {
  final name =
      '${source.name} ${BrandsKeys.duplicateSuffix.tr(context: context)}';
  return BrandDraft(
    name: name,
    slug: brandSlugFrom(name),
    logo: source.logo,
    description: source.description,
    isActive: source.isActive,
  );
}
