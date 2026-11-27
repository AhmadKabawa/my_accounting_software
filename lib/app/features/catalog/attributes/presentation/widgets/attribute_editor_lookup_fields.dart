import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_lookup_choices.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/catalog_attribute.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/cubit/attribute_lookups/attribute_lookups_state.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/localization/attributes_keys.dart';

class AttributeUnitPicker extends StatelessWidget {
  const AttributeUnitPicker({
    super.key,
    required this.attribute,
    required this.keepCurrentInactive,
    required this.selectedId,
    required this.state,
    required this.onChanged,
  });
  final CatalogAttribute? attribute;
  final bool keepCurrentInactive;
  final int? selectedId;
  final AttributeLookupsState state;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = [...state.units];
    if (keepCurrentInactive &&
        selectedId != null &&
        !options.any((v) => v.id == selectedId) &&
        attribute?.unitId == selectedId) {
      options.add(
        AttributeUnitChoice(
          id: attribute!.unitId!,
          name: attribute!.unitName ?? '',
          symbol: attribute!.unitSymbol ?? '',
          isActive: false,
        ),
      );
    }
    AttributeUnitChoice? selected;
    for (final option in options) {
      if (option.id == selectedId) selected = option;
    }
    return SearchableDropdown<AttributeUnitChoice>(
      options: options,
      labelKey: AttributesKeys.unit,
      optionLabel: (value) => value.name,
      optionSubtitle: (value) => value.symbol,
      value: selected,
      loading: state.loading,
      errorKey: state.unitFailure?.messageKey,
      clearable: true,
      mode: SearchableDropdownMode.panel,
      onChanged: (value) => onChanged(value?.id),
    );
  }
}

class AttributeOptionSetPicker extends StatelessWidget {
  const AttributeOptionSetPicker({
    super.key,
    required this.attribute,
    required this.keepCurrentInactive,
    required this.selectedId,
    required this.state,
    required this.locked,
    required this.onChanged,
  });
  final CatalogAttribute? attribute;
  final bool keepCurrentInactive;
  final int? selectedId;
  final AttributeLookupsState state;
  final bool locked;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = [...state.optionSets];
    if (keepCurrentInactive &&
        selectedId != null &&
        !options.any((v) => v.id == selectedId) &&
        attribute?.optionSetId == selectedId) {
      options.add(
        AttributeOptionSetChoice(
          id: attribute!.optionSetId!,
          name: attribute!.optionSetName ?? '',
          code: attribute!.optionSetCode ?? '',
          isActive: false,
        ),
      );
    }
    AttributeOptionSetChoice? selected;
    for (final option in options) {
      if (option.id == selectedId) selected = option;
    }
    return FormField<int>(
      key: const ValueKey('attribute-option-set'),
      initialValue: selectedId,
      validator: (value) =>
          value == null || !options.any((option) => option.id == value)
          ? AttributesKeys.required.tr(context: context)
          : null,
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SearchableDropdown<AttributeOptionSetChoice>(
            options: options,
            labelKey: AttributesKeys.optionSet,
            optionLabel: (value) => value.name,
            optionSubtitle: (value) => value.code,
            value: selected,
            loading: state.loading,
            errorKey: state.optionSetFailure?.messageKey,
            clearable: true,
            enabled: !locked,
            mode: SearchableDropdownMode.panel,
            onChanged: (value) {
              field.didChange(value?.id);
              onChanged(value?.id);
            },
          ),
          if (field.hasError) AppText.raw(field.errorText!),
        ],
      ),
    );
  }
}
