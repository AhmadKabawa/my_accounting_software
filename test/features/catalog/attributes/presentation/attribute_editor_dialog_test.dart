import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_form_dialog/app_form_dialog.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_lookup_choices.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/catalog_attribute.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/create_attribute_use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/update_attribute_use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/get_attribute_unit_choices_use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/get_attribute_option_set_choices_use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/cubit/attribute_form/attribute_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/cubit/attribute_lookups/attribute_lookups_cubit.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/dialogs/attribute_editor_dialog.dart';
import '../../../../helpers/localized_app.dart';
import '../support/fake_attributes_repository.dart';

Future<void> _openEditor(
  WidgetTester tester,
  FakeAttributesRepository repository, {
  CatalogAttribute? attribute,
  bool duplicate = false,
}) async {
  await tester.pumpWidget(
    buildTestApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => showAppFormDialog<bool>(
              context,
              (_) => MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (_) => AttributeFormCubit(
                      createAttribute: CreateAttributeUseCase(repository),
                      updateAttribute: UpdateAttributeUseCase(repository),
                      flashMessages: FlashMessages(),
                    ),
                  ),
                  BlocProvider(
                    create: (_) => AttributeLookupsCubit(
                      getUnits: GetAttributeUnitChoicesUseCase(repository),
                      getOptionSets: GetAttributeOptionSetChoicesUseCase(
                        repository,
                      ),
                    )..load(),
                  ),
                ],
                child: AttributeEditorDialog(
                  attribute: attribute,
                  duplicate: duplicate,
                ),
              ),
            ),
            child: const Text('Open editor'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open editor'));
  await tester.pumpAndSettle();
}

CatalogAttribute _attribute({
  AttributeDataType type = AttributeDataType.option,
  int? unitId,
  int? optionSetId = 3,
  int? links = 0,
  int? values = 0,
}) => CatalogAttribute(
  id: 8,
  name: 'Material',
  code: 'MATERIAL',
  dataType: type,
  unitId: unitId,
  unitName: unitId == null ? null : 'Kilogram',
  unitSymbol: unitId == null ? null : 'kg',
  optionSetId: optionSetId,
  optionSetName: optionSetId == null ? null : 'Sizes',
  optionSetCode: optionSetId == null ? null : 'SIZES',
  isFilterable: true,
  isActive: true,
  linkedProductTypesCount: links,
  valueCount: values,
);

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  testWidgets('trim-equivalent name changes do not mark the editor dirty', (
    tester,
  ) async {
    final repository = FakeAttributesRepository();
    await _openEditor(tester, repository, attribute: _attribute());
    await tester.enterText(find.byType(TextFormField).first, 'Material ');
    await tester.pump();
    expect(
      tester.widget<AppFormDialog>(find.byType(AppFormDialog)).dirty,
      isFalse,
    );
  });

  testWidgets('changing type clears the option-set relationship before PATCH', (
    tester,
  ) async {
    final repository = FakeAttributesRepository();
    await _openEditor(tester, repository, attribute: _attribute());
    await tester.tap(find.byType(SearchableDropdown<AttributeDataType>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Text').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(repository.updatedDrafts, hasLength(1));
    expect(repository.updatedDrafts.single.$2.dataType, AttributeDataType.text);
    expect(repository.updatedDrafts.single.$2.optionSetId, isNull);
    expect(repository.updatedDrafts.single.$2.unitId, isNull);
  });

  testWidgets('option type cannot be saved without an option set', (
    tester,
  ) async {
    final repository = FakeAttributesRepository();
    await _openEditor(tester, repository);
    await tester.enterText(find.byType(TextFormField).first, 'Material');
    await tester.enterText(find.byType(TextFormField).at(1), 'MATERIAL');
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SearchableDropdown<AttributeDataType>));
    await tester.pumpAndSettle();
    for (var index = 0; index < 6; index++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    }
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<SearchableDropdown<AttributeDataType>>(
            find.byType(SearchableDropdown<AttributeDataType>),
          )
          .value,
      AttributeDataType.option,
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(repository.createdDrafts, isEmpty);
  });

  testWidgets('used attribute locks data type and option set pickers', (
    tester,
  ) async {
    final repository = FakeAttributesRepository();
    await _openEditor(tester, repository, attribute: _attribute(links: 1));
    final typePicker = tester.widget<SearchableDropdown<AttributeDataType>>(
      find.byType(SearchableDropdown<AttributeDataType>),
    );
    final setPicker = tester
        .widget<SearchableDropdown<AttributeOptionSetChoice>>(
          find.byType(SearchableDropdown<AttributeOptionSetChoice>),
        );
    expect(typePicker.enabled, isFalse);
    expect(setPicker.enabled, isFalse);
  });

  testWidgets(
    'duplicate copies type and filterable state, activates and creates a -copy code',
    (tester) async {
      final repository = FakeAttributesRepository();
      await _openEditor(
        tester,
        repository,
        attribute: _attribute(),
        duplicate: true,
      );
      final code = tester
          .widget<TextFormField>(find.byType(TextFormField).at(1))
          .controller!
          .text;
      expect(code, endsWith('-copy'));
      expect(code.length, lessThanOrEqualTo(80));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(repository.createdDrafts, hasLength(1));
      expect(
        repository.createdDrafts.single.dataType,
        AttributeDataType.option,
      );
      expect(repository.createdDrafts.single.optionSetId, 3);
      expect(repository.createdDrafts.single.isFilterable, isTrue);
      expect(repository.createdDrafts.single.isActive, isTrue);
    },
  );
}
