import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_color_swatch/app_color_swatch.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_form_dialog/app_form_dialog.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/failures/color_failures.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/usecase/create_color_use_case.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/usecase/update_color_use_case.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/color_form/color_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/dialogs/color_editor_dialog.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/localization/colors_keys.dart';
import '../../../../../helpers/localized_app.dart';
import '../../support/fake_colors_repository.dart';

Future<void> _pumpEditor(
  WidgetTester tester,
  FakeColorsRepository repository, {
  CatalogColor? color,
  CatalogColorDraft? seed,
  bool duplicate = false,
  ValueChanged<bool?>? onResult,
}) async {
  setScreenSize(tester, const Size(1280, 900));
  await tester.pumpWidget(
    buildTestApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async {
              final result = await showAppFormDialog<bool>(
                context,
                (_) => BlocProvider(
                  create: (_) => ColorFormCubit(
                    createColor: CreateColorUseCase(repository),
                    updateColor: UpdateColorUseCase(repository),
                    flashMessages: FlashMessages(),
                  ),
                  child: ColorEditorDialog(
                    color: duplicate ? null : color,
                    seed: seed,
                    duplicate: duplicate,
                  ),
                ),
              );
              onResult?.call(result);
            },
            child: const Text('Open editor'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open editor'));
  await tester.pumpAndSettle();
}

TextEditingController _controller(WidgetTester tester, int index) => tester
    .widget<TextFormField>(find.byType(TextFormField).at(index))
    .controller!;

Future<void> _tapSave(WidgetTester tester) async {
  await tester.drag(find.byType(ListView).first, const Offset(0, -700));
  await tester.pumpAndSettle();
  final save = find.text(ColorsKeys.save.en);
  await tester.ensureVisible(save);
  await tester.pumpAndSettle();
  await tester.tap(save);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  testWidgets('required fields block saving', (tester) async {
    final repository = FakeColorsRepository();
    await _pumpEditor(tester, repository);

    await _tapSave(tester);

    expect(find.text(ColorsKeys.required.en), findsNWidgets(2));
    expect(repository.created, isEmpty);
  });

  testWidgets('an invalid hex blocks saving with a clear message', (
    tester,
  ) async {
    final repository = FakeColorsRepository();
    await _pumpEditor(tester, repository);
    await tester.enterText(find.byType(TextFormField).at(0), 'Navy');
    await tester.enterText(find.byType(TextFormField).at(1), 'NAVY');
    await tester.enterText(find.byType(TextFormField).at(3), '12');
    await _tapSave(tester);

    expect(find.text(ColorsKeys.hexFormat.en), findsOneWidget);
    expect(repository.created, isEmpty);
  });

  testWidgets('a valid form saves a draft and closes with true', (
    tester,
  ) async {
    final repository = FakeColorsRepository();
    bool? result;
    await _pumpEditor(tester, repository, onResult: (v) => result = v);

    await tester.enterText(find.byType(TextFormField).at(0), 'Navy');
    await tester.enterText(find.byType(TextFormField).at(1), 'NAVY');
    await tester.enterText(find.byType(TextFormField).at(3), '1e3a8a');
    await tester.enterText(find.byType(TextFormField).at(2), '5');
    await _tapSave(tester);

    final draft = repository.created.single;
    expect(draft.name, 'Navy');
    expect(draft.code, 'NAVY');
    expect(draft.hexCode, '#1E3A8A');
    expect(draft.sortOrder, 5);
    expect(result, isTrue);
  });

  testWidgets('tapping a preset fills the HEX field', (tester) async {
    await _pumpEditor(tester, FakeColorsRepository());

    final preset = find.byWidgetPredicate(
      (w) => w is AppColorSwatch && w.hex == '#DC2626' && w.onTap != null,
    );
    await tester.ensureVisible(preset);
    await tester.pumpAndSettle();
    await tester.tap(preset);
    await tester.pump();

    expect(_controller(tester, 3).text, '#DC2626');
    expect(find.byType(AppColorSwatch), findsWidgets);
  });

  testWidgets('a duplicate code shows the specific error and stays open', (
    tester,
  ) async {
    final repository = FakeColorsRepository()
      ..saveResult = const Left(ColorDuplicateFailure());
    bool? result;
    await _pumpEditor(tester, repository, onResult: (v) => result = v);

    await tester.enterText(find.byType(TextFormField).at(0), 'Navy');
    await tester.enterText(find.byType(TextFormField).at(1), 'NAVY');
    await _tapSave(tester);

    expect(find.text(ColorsKeys.duplicateError.en), findsOneWidget);
    expect(find.byType(ColorEditorDialog), findsOneWidget);
    expect(result, isNull);
  });

  testWidgets('HEX suggests a name until the user edits the name', (
    tester,
  ) async {
    await _pumpEditor(tester, FakeColorsRepository());

    await tester.enterText(find.byType(TextFormField).at(3), '#000000');
    await tester.pump();
    expect(_controller(tester, 0).text, 'Black');

    await tester.enterText(find.byType(TextFormField).at(0), 'Midnight');
    await tester.enterText(find.byType(TextFormField).at(3), '#FFFFFF');
    await tester.pump();
    expect(_controller(tester, 0).text, 'Midnight');
  });

  testWidgets('manual RGBA input is stored uppercase with alpha', (
    tester,
  ) async {
    final repository = FakeColorsRepository();
    await _pumpEditor(tester, repository);

    await tester.enterText(find.byType(TextFormField).at(0), 'Soft blue');
    await tester.enterText(find.byType(TextFormField).at(1), 'SOFT-BLUE');
    await tester.enterText(find.byType(TextFormField).at(3), '#aabbcc80');
    await tester.enterText(find.byType(TextFormField).at(2), '0');
    await _tapSave(tester);

    expect(repository.created.single.hexCode, '#AABBCC80');
  });

  testWidgets('editing prefills values and updates by id', (tester) async {
    final repository = FakeColorsRepository();
    await _pumpEditor(tester, repository, color: sampleColor);

    expect(_controller(tester, 0).text, 'Navy');
    expect(_controller(tester, 1).text, 'NAVY');
    expect(_controller(tester, 2).text, '2');
    expect(_controller(tester, 3).text, '#1E3A8A');

    await tester.enterText(find.byType(TextFormField).at(0), 'Dark navy');
    await _tapSave(tester);

    expect(repository.updated.single.$1, 7);
    expect(repository.updated.single.$2.name, 'Dark navy');
  });
  testWidgets('duplicate seed creates unique name and code and preserves appearance', (tester) async {
    await _pumpEditor(tester, FakeColorsRepository());
    final seed = colorDuplicateSeed(tester.element(find.byType(Scaffold).first), sampleColor);
    expect(seed.name, 'Navy (Copy)');
    expect(seed.code, 'NAVY-COPY');
    expect(seed.hexCode, sampleColor.hexCode);
    expect(seed.sortOrder, sampleColor.sortOrder);
  });

  testWidgets('duplicate editor starts clean, selects the unique fields and saves via create', (tester) async {
    const seed = CatalogColorDraft(
      name: 'Navy (Copy)',
      code: 'NAVY-COPY',
      hexCode: '#1E3A8A',
      sortOrder: 2,
    );
    final repository = FakeColorsRepository();
    await _pumpEditor(tester, repository, seed: seed, duplicate: true);
    expect(_controller(tester, 0).selection.baseOffset, 0);
    expect(_controller(tester, 0).selection.extentOffset, 'Navy (Copy)'.length);
    expect(_controller(tester, 1).selection.baseOffset, 0);
    expect(_controller(tester, 1).text, 'NAVY-COPY');
    await tester.tap(find.text(ColorsKeys.cancel.en));
    await tester.pumpAndSettle();
    expect(find.text(ColorsKeys.editorSubtitle.en), findsNothing);
    expect(find.text('Unsaved changes'), findsNothing);
    expect(repository.created, isEmpty);
  });

  testWidgets('saving a duplicate creates a new color with copied values', (tester) async {
    const seed = CatalogColorDraft(
      name: 'Navy (Copy)',
      code: 'NAVY-COPY',
      hexCode: '#1E3A8A',
      sortOrder: 2,
    );
    final repository = FakeColorsRepository();
    await _pumpEditor(tester, repository, seed: seed, duplicate: true);
    await tester.enterText(find.byType(TextFormField).at(0), 'New navy');
    await _tapSave(tester);
    expect(repository.created.single.name, 'New navy');
    expect(repository.created.single.code, 'NAVY-COPY');
    expect(repository.created.single.hexCode, '#1E3A8A');
    expect(repository.updated, isEmpty);
  });


}
