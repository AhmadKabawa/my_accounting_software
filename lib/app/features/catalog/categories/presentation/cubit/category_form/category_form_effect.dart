import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category.dart';

sealed class CategoryFormEffect {
  const CategoryFormEffect();
}

class CategorySavedEffect extends CategoryFormEffect {
  const CategorySavedEffect(this.category);

  final Category category;
}

class CategorySaveFailedEffect extends CategoryFormEffect {
  const CategorySaveFailedEffect(this.messageKey);

  final AppKey messageKey;
}
