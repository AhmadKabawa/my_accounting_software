import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/catalog_tag.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/catalog_tag_draft.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/usecase/create_tag_use_case.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/usecase/update_tag_use_case.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/cubit/tag_form/tag_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/dialogs/tag_editor_launcher.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/localization/tags_keys.dart';
import '../../../../helpers/localized_app.dart';

class _CreateTag extends Mock implements CreateTagUseCase {}

class _UpdateTag extends Mock implements UpdateTagUseCase {}

class _FlashMessages extends Mock implements FlashMessages {}

void main() {
  setUpAll(() {
    useTranslations(const Locale('en'));
    registerFallbackValue(const CatalogTagDraft(name: '', slug: ''));
  });

  testWidgets('tag editor switch reaches the form cubit draft', (tester) async {
    final create = _CreateTag();
    final update = _UpdateTag();
    final flash = _FlashMessages();
    CatalogTagDraft? saved;
    when(() => create(any())).thenAnswer((invocation) async {
      saved = invocation.positionalArguments.single as CatalogTagDraft;
      return Right<Failure, CatalogTag>(
        const CatalogTag(
          id: 9,
          name: 'New Arrival',
          slug: 'new-arrival',
          isActive: false,
        ),
      );
    });
    await sl.reset();
    final cubit = TagFormCubit(
      createTag: create,
      updateTag: update,
      flashMessages: flash,
    );
    sl.registerFactory<TagFormCubit>(() => cubit);
    addTearDown(() async => sl.reset());
    await tester.pumpWidget(
      buildTestApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showTagEditor(context),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text(TagsKeys.active.en), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'New Arrival');
    await tester.enterText(find.byType(TextFormField).at(1), 'new-arrival');
    await tester.tap(find.byType(Switch).first);
    await tester.tap(find.text(TagsKeys.save.en).last);
    await tester.pumpAndSettle();

    expect(saved?.isActive, isFalse);
  });
}
