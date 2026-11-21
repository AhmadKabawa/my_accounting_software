import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color.dart';

sealed class ColorFormEffect {
  const ColorFormEffect();
}

class ColorSavedEffect extends ColorFormEffect {
  const ColorSavedEffect(this.color);

  final CatalogColor color;
}

class ColorSaveFailedEffect extends ColorFormEffect {
  const ColorSaveFailedEffect(this.messageKey);

  final AppKey messageKey;
}
