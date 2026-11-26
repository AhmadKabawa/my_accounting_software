import 'package:flutter/widgets.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport_draft.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/localization/sports_keys.dart';

/// Copies the sport's description and order while making its identity unique.
SportDraft sportDuplicateSeed(BuildContext context, Sport source) => SportDraft(
  name: '${source.name} ${SportsKeys.duplicateSuffix.tr(context: context)}',
  code: source.code + SportsKeys.duplicateCodeSuffix.tr(context: context),
  description: source.description,
  sortOrder: source.sortOrder,
  isActive: source.isActive,
);
