import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport_draft.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/usecase/create_sport_use_case.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/usecase/update_sport_use_case.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/cubit/sport_form/sport_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/dialogs/sport_editor_dialog.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/localization/sports_keys.dart';
import '../../../../helpers/localized_app.dart';

class _CreateSport extends Mock implements CreateSportUseCase {}

class _UpdateSport extends Mock implements UpdateSportUseCase {}

class _FlashMessages extends Mock implements FlashMessages {}

void main() {
  setUpAll(() {
    useTranslations(const Locale('en'));
    registerFallbackValue(const SportDraft(name: '', code: ''));
  });

  testWidgets('sport editor switch reaches the form cubit draft', (
    tester,
  ) async {
    final create = _CreateSport();
    final update = _UpdateSport();
    final flash = _FlashMessages();
    SportDraft? saved;
    when(() => create(any())).thenAnswer((invocation) async {
      saved = invocation.positionalArguments.single as SportDraft;
      return Right<Failure, Sport>(
        const Sport(
          id: 8,
          name: 'Running',
          code: 'RUNNING',
          isActive: false,
          sortOrder: 0,
        ),
      );
    });
    final cubit = SportFormCubit(
      createSport: create,
      updateSport: update,
      flashMessages: flash,
    );
    addTearDown(cubit.close);
    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: TextButton(
            onPressed: () => showDialog<void>(
              context: tester.element(find.byType(Scaffold)),
              builder: (_) => BlocProvider.value(
                value: cubit,
                child: const SportEditorDialog(),
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text(SportsKeys.active.en), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'Running');
    await tester.enterText(find.byType(TextFormField).at(1), 'RUNNING');
    await tester.tap(find.byType(Switch).first);
    await tester.tap(find.text(SportsKeys.save.en).last);
    await tester.pumpAndSettle();

    expect(saved?.isActive, isFalse);
  });
}
