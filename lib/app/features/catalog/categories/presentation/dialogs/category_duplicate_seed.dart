import 'package:flutter/widgets.dart';
import 'package:accounting_software/app/core/foundation/validation/slug.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_draft.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/localization/categories_keys.dart';

/// Duplicate under the same parent with a localized suffix and a fresh slug.
CategoryDraft categoryDuplicateSeed(BuildContext context, Category source) {
  final name =
      '${source.name} ${CategoriesKeys.duplicateSuffix.tr(context: context)}';
  final generatedSlug = Slug.from(name);
  return CategoryDraft(
    parentId: source.parentId,
    name: name,
    slug: generatedSlug.isEmpty ? '${source.slug}-copy' : generatedSlug,
    description: source.description,
    image: source.image,
    sortOrder: source.sortOrder,
    isActive: source.isActive,
  );
}
