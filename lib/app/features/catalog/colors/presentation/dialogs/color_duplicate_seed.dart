import 'package:flutter/widgets.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color_draft.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/localization/colors_keys.dart';

/// Copies the color's appearance and order while making its identity unique.
CatalogColorDraft colorDuplicateSeed(
  BuildContext context,
  CatalogColor source,
) => CatalogColorDraft(
  name: source.name + ' ' + ColorsKeys.duplicateSuffix.tr(context: context),
  code: source.code + ColorsKeys.duplicateCodeSuffix.tr(context: context),
  hexCode: source.hexCode,
  sortOrder: source.sortOrder,
  isActive: source.isActive,
);
