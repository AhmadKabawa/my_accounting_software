import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/catalog_tag.dart';

sealed class TagFormEffect {
  const TagFormEffect();
}

class TagSavedEffect extends TagFormEffect {
  const TagSavedEffect(this.tag);

  final CatalogTag tag;
}

class TagSaveFailedEffect extends TagFormEffect {
  const TagSaveFailedEffect(this.messageKey);

  final AppKey messageKey;
}
