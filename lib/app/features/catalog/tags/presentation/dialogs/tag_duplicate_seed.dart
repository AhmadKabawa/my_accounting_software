import 'package:flutter/widgets.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/catalog_tag.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/catalog_tag_draft.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/localization/tags_keys.dart';

/// Makes the name and slug unique; `tags` has no other editable field.
CatalogTagDraft tagDuplicateSeed(BuildContext context, CatalogTag source) =>
    CatalogTagDraft(
      name: '${source.name} ${TagsKeys.duplicateSuffix.tr(context: context)}',
      slug: source.slug + TagsKeys.duplicateSlugSuffix.tr(context: context),
      isActive: source.isActive,
    );
