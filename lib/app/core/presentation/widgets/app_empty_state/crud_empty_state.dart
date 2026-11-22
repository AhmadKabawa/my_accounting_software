import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_empty_state/app_empty_state.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/list_add_action.dart';

/// Empty/no-results presentation shared by CRUD list sections.
class CrudEmptyState extends StatelessWidget {
  const CrudEmptyState({
    super.key,
    required this.icon,
    required this.emptyTitleKey,
    required this.emptyDescriptionKey,
    required this.noResultsTitleKey,
    required this.noResultsDescriptionKey,
    required this.hasActiveFilters,
    this.addAction,
  });

  final AppIconData icon;
  final AppKey emptyTitleKey;
  final AppKey emptyDescriptionKey;
  final AppKey noResultsTitleKey;
  final AppKey noResultsDescriptionKey;
  final bool hasActiveFilters;
  final ListAddAction? addAction;

  @override
  Widget build(BuildContext context) => AppEmptyState(
    icon: icon,
    titleKey: hasActiveFilters ? noResultsTitleKey : emptyTitleKey,
    descriptionKey: hasActiveFilters
        ? noResultsDescriptionKey
        : emptyDescriptionKey,
    action: !hasActiveFilters && addAction != null
        ? ListAddButton(action: addAction!)
        : null,
  );
}
