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
                  child: ColorEditorDialog(color: color),
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
}
