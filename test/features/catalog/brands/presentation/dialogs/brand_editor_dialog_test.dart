import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/keys/template_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/platform/image_picker/image_picker_port.dart';
import 'package:accounting_software/app/core/platform/file_drop/file_drop_target.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_form_dialog/app_form_dialog.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_switch/app_switch.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_draft.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/failures/brand_failures.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/create_brand_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/update_brand_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/upload_brand_logo_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brand_form/brand_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/dialogs/brand_editor_dialog.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';
import '../../../../../helpers/localized_app.dart';
import '../../support/fake_brands_repository.dart';

class _PassThroughDropAdapter implements FileDropTargetAdapter {
  const _PassThroughDropAdapter();

  @override
  Widget build({
    required Widget child,
    required DroppedImagesCallback onFilesDropped,
    required ValueChanged<bool> onHover,
  }) => child;
}

class _Picker implements ImagePickerPort {
  _Picker(this.handler);
  final Future<PickedImage?> Function() handler;

  @override
  Future<PickedImage?> pickImage() => handler();
}

class _Failure extends Failure {
  const _Failure() : super(messageKey: BrandsKeys.saveError);
}

Future<void> _pumpEditor(
  WidgetTester tester,
  FakeBrandsRepository repository, {
  Brand? brand,
  BrandDraft? seed,
  bool duplicate = false,
  ImagePickerPort? picker,
  ValueChanged<bool?>? onResult,
  Size size = const Size(1280, 900),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    buildTestApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async {
              final result = await showAppFormDialog<bool>(
                context,
                (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (_) => BrandFormCubit(
                        createBrand: CreateBrandUseCase(repository),
                        updateBrand: UpdateBrandUseCase(repository),
                        flashMessages: FlashMessages(),
                      ),
                    ),
                  ],
                  child: BrandEditorDialog(
                    brand: brand,
                    seed: seed,
                    duplicate: duplicate,
                    logoUploader: UploadBrandLogoUseCase(repository).call,
                    logoPicker: picker ?? _Picker(() async => null),
                    logoDropTargetAdapter: const _PassThroughDropAdapter(),
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

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  testWidgets('successful save closes with true and auto-generates slug', (
    tester,
  ) async {
    final repository = FakeBrandsRepository();
    bool? result;
    await _pumpEditor(tester, repository, onResult: (value) => result = value);

    await tester.enterText(find.byType(TextFormField).at(0), 'Vaude Store');
    await tester.pump();
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).at(1))
          .controller!
          .text,
      'vaude-store',
    );
    await tester.tap(find.text(BrandsKeys.save.en));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('slug stops auto-updating after manual edit and can regenerate', (
    tester,
  ) async {
    await _pumpEditor(tester, FakeBrandsRepository());
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'First Name');
    await tester.pump();
    await tester.enterText(fields.at(1), 'manual-slug');
    await tester.pump();
    await tester.enterText(fields.at(0), 'Second Name');
    await tester.pump();

    expect(
      tester.widget<TextFormField>(fields.at(1)).controller!.text,
      'manual-slug',
    );
    await tester.tap(find.text(BrandsKeys.regenerateSlug.en));
    await tester.pump();
    expect(
      tester.widget<TextFormField>(fields.at(1)).controller!.text,
      'second-name',
    );
  });

  testWidgets('Arabic name stays without transliteration and shows guidance', (
    tester,
  ) async {
    await _pumpEditor(tester, FakeBrandsRepository());
    await tester.enterText(find.byType(TextFormField).at(0), 'ماركة عربية');
    await tester.pump();

    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).at(1))
          .controller!
          .text,
      isEmpty,
    );
    expect(find.text(BrandsKeys.slugLatinHint.en), findsOneWidget);
  });

  testWidgets('editing a brand does not replace its existing slug', (
    tester,
  ) async {
    const brand = Brand(
      id: 7,
      name: 'Original',
      slug: 'stable-slug',
      logo: 'https://cdn.test/old.png',
      isActive: true,
      productCount: 0,
    );
    await _pumpEditor(tester, FakeBrandsRepository(), brand: brand);
    await tester.enterText(find.byType(TextFormField).at(0), 'Changed name');
    await tester.pump();
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).at(1))
          .controller!
          .text,
      'stable-slug',
    );
  });

  testWidgets(
    'duplicate save failure shows the duplicate banner and stays open',
    (tester) async {
      final repository = FakeBrandsRepository()
        ..onCreateBrand = (_) async => const Left(BrandDuplicateFailure());
      await _pumpEditor(tester, repository);
      await tester.enterText(find.byType(TextFormField).at(0), 'Duplicate');
      await tester.tap(find.text(BrandsKeys.save.en));
      await tester.pumpAndSettle();

      expect(find.text(BrandsKeys.duplicateError.en), findsOneWidget);
      expect(find.byType(AppFormDialog), findsOneWidget);
    },
  );

  testWidgets('saving prevents Escape and system back from closing', (
    tester,
  ) async {
    final pending = Completer<Either<Failure, Brand>>();
    final repository = FakeBrandsRepository()
      ..onCreateBrand = (_) => pending.future;
    await _pumpEditor(tester, repository);
    await tester.enterText(find.byType(TextFormField).at(0), 'Busy');
    await tester.tap(find.text(BrandsKeys.save.en));
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(find.byType(AppFormDialog), findsOneWidget);
    pending.complete(Right(FakeBrandsRepository.brand));
    await tester.pumpAndSettle();
  });

  testWidgets('upload cancellation leaves logo unchanged', (tester) async {
    final repository = FakeBrandsRepository();
    final picker = _Picker(() async => null);
    await _pumpEditor(tester, repository, picker: picker);
    await tester.ensureVisible(find.text(BrandsKeys.uploadLogo.en));
    await tester.tap(find.text(BrandsKeys.uploadLogo.en));
    await tester.pumpAndSettle();
    expect(find.text(BrandsKeys.uploadLogo.en), findsOneWidget);
    expect(find.text(BrandsKeys.replaceLogo.en), findsNothing);
  });

  testWidgets('upload success updates the logo value and replaces action', (
    tester,
  ) async {
    final repository = FakeBrandsRepository();
    final picker = _Picker(
      () async => PickedImage(
        bytes: Uint8List.fromList([
          0x89,
          0x50,
          0x4e,
          0x47,
          0x0d,
          0x0a,
          0x1a,
          0x0a,
        ]),
        fileName: 'logo.png',
        mimeType: 'image/png',
      ),
    );
    await _pumpEditor(tester, repository, picker: picker);
    await tester.tap(find.text(BrandsKeys.uploadLogo.en));
    await tester.pumpAndSettle();
    expect(repository.lastUpload, isNotNull);
    expect(find.text(BrandsKeys.replaceLogo.en), findsOneWidget);
    expect(find.byTooltip(BrandsKeys.removeLogo.en), findsOneWidget);
  });

  testWidgets('upload failure shows an inline banner', (tester) async {
    final repository = FakeBrandsRepository()
      ..uploadResult = const Left(_Failure());
    final picker = _Picker(
      () async => PickedImage(
        bytes: Uint8List.fromList([
          0x89,
          0x50,
          0x4e,
          0x47,
          0x0d,
          0x0a,
          0x1a,
          0x0a,
        ]),
        fileName: 'logo.png',
        mimeType: 'image/png',
      ),
    );
    await _pumpEditor(tester, repository, picker: picker);
    await tester.tap(find.text(BrandsKeys.uploadLogo.en));
    await tester.pumpAndSettle();
    expect(repository.lastUpload, isNotNull);
    expect(find.text(BrandsKeys.saveError.en), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ordinary save failure stays open and only name edits clear it', (
    tester,
  ) async {
    final repository = FakeBrandsRepository()
      ..onCreateBrand = (_) async => const Left(_Failure());
    await _pumpEditor(tester, repository);
    await tester.enterText(find.byType(TextFormField).at(0), 'Failed brand');
    await tester.tap(find.text(BrandsKeys.save.en));
    await tester.pumpAndSettle();

    expect(find.text(BrandsKeys.saveError.en), findsOneWidget);
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'Changed description',
    );
    await tester.pump();
    expect(find.text(BrandsKeys.saveError.en), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'Changed name');
    await tester.pump();
    expect(find.text(BrandsKeys.saveError.en), findsNothing);
  });

  testWidgets('clean cancel closes immediately', (tester) async {
    bool? cleanResult;
    await _pumpEditor(
      tester,
      FakeBrandsRepository(),
      onResult: (value) => cleanResult = value,
    );
    await tester.tap(find.text(BrandsKeys.cancel.en));
    await tester.pumpAndSettle();

    expect(cleanResult, isFalse);
    expect(find.byType(AppFormDialog), findsNothing);
  });

  testWidgets('dirty cancel asks before closing', (tester) async {
    await _pumpEditor(tester, FakeBrandsRepository());
    await tester.enterText(find.byType(TextFormField).at(0), 'Unsaved');
    await tester.pump();
    await tester.tap(find.text(BrandsKeys.cancel.en));
    await tester.pumpAndSettle();

    expect(find.text(TemplateKeys.unsavedChanges.en), findsOneWidget);
    expect(find.byType(AppFormDialog), findsOneWidget);
  });

  testWidgets('save is disabled while the logo picker is active', (
    tester,
  ) async {
    final pendingPick = Completer<PickedImage?>();
    final picker = _Picker(() => pendingPick.future);
    await _pumpEditor(tester, FakeBrandsRepository(), picker: picker);
    await tester.tap(find.text(BrandsKeys.uploadLogo.en));
    await tester.pump();

    final save = tester.widget<AppButton>(
      find.widgetWithText(AppButton, BrandsKeys.save.en),
    );
    expect(save.onPressed, isNull);
    pendingPick.complete(null);
    await tester.pumpAndSettle();
  });

  testWidgets('removing an existing logo saves null', (tester) async {
    const brand = Brand(
      id: 7,
      name: 'Original',
      slug: 'stable-slug',
      logo: 'https://cdn.test/old.png',
      isActive: true,
      productCount: 0,
    );
    BrandDraft? savedDraft;
    final repository = FakeBrandsRepository()
      ..onUpdateBrand = (id, draft) async {
        savedDraft = draft;
        return Right(brand);
      };
    await _pumpEditor(tester, repository, brand: brand);

    await tester.ensureVisible(find.text(BrandsKeys.removeLogo.en));
    await tester.tap(find.text(BrandsKeys.removeLogo.en));
    await tester.pump();
    await tester.tap(find.text(BrandsKeys.save.en));
    await tester.pumpAndSettle();

    expect(savedDraft?.logo, isNull);
  });

  testWidgets('editing exposes status and changing it makes the form dirty', (
    tester,
  ) async {
    const brand = Brand(
      id: 7,
      name: 'Original',
      slug: 'stable-slug',
      isActive: true,
      productCount: 0,
    );
    await _pumpEditor(tester, FakeBrandsRepository(), brand: brand);
    expect(find.byType(AppSwitch), findsOneWidget);
    await tester.ensureVisible(find.byType(Switch));
    await tester.tap(find.byType(Switch));
    await tester.pump();
    await tester.tap(find.text(BrandsKeys.cancel.en));
    await tester.pumpAndSettle();
    expect(find.text(TemplateKeys.unsavedChanges.en), findsOneWidget);
  });

  testWidgets('editing saves a changed status through the brand PATCH', (
    tester,
  ) async {
    const brand = Brand(
      id: 7,
      name: 'Original',
      slug: 'stable-slug',
      isActive: true,
      productCount: 0,
    );
    BrandDraft? savedDraft;
    final repository = FakeBrandsRepository()
      ..onUpdateBrand = (id, draft) async {
        savedDraft = draft;
        return Right(brand);
      };
    await _pumpEditor(tester, repository, brand: brand);
    await tester.ensureVisible(find.byType(Switch));
    await tester.tap(find.byType(Switch));
    await tester.pump();
    await tester.ensureVisible(find.text(BrandsKeys.save.en));
    await tester.tap(find.text(BrandsKeys.save.en));
    await tester.pumpAndSettle();
    expect(savedDraft?.isActive, isFalse);
  });

  testWidgets('editor renders without overflow at phone, tablet and desktop', (
    tester,
  ) async {
    for (final size in [
      const Size(360, 800),
      const Size(800, 900),
      const Size(1280, 900),
    ]) {
      await _pumpEditor(tester, FakeBrandsRepository(), size: size);
      expect(find.byType(AppFormDialog), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text(BrandsKeys.cancel.en));
      await tester.pumpAndSettle();
    }
  });
  testWidgets('duplicate seed copies editable fields and builds a new slug', (
    tester,
  ) async {
    const source = Brand(
      id: 9,
      name: 'Original',
      slug: 'original',
      logo: 'https://cdn.test/shared.png',
      description: 'Source description',
      isActive: false,
      productCount: 3,
    );
    await _pumpEditor(tester, FakeBrandsRepository());
    final seed = brandDuplicateSeed(
      tester.element(find.byType(Scaffold).first),
      source,
    );
    expect(seed.name, 'Original (Copy)');
    expect(seed.slug, 'original-copy');
    expect(seed.description, 'Source description');
    expect(seed.logo, source.logo);
    expect(seed.isActive, isFalse);
  });

  testWidgets(
    'duplicate editor starts clean with name selected and auto-generates slug',
    (tester) async {
      const seed = BrandDraft(
        name: 'Original (Copy)',
        slug: 'original-copy',
        logo: 'https://cdn.test/shared.png',
        description: 'Source description',
        isActive: false,
      );
      await _pumpEditor(
        tester,
        FakeBrandsRepository(),
        seed: seed,
        duplicate: true,
      );
      final nameField = tester.widget<TextFormField>(
        find.byType(TextFormField).at(0),
      );
      expect(nameField.controller!.selection.baseOffset, 0);
      expect(
        nameField.controller!.selection.extentOffset,
        'Original (Copy)'.length,
      );
      expect(
        tester.widget<EditableText>(find.byType(EditableText).first).autofocus,
        isTrue,
      );
      expect(nameField.controller!.text, 'Original (Copy)');
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).at(1))
            .controller!
            .text,
        'original-copy',
      );
      await tester.enterText(find.byType(TextFormField).at(0), 'New brand');
      await tester.pump();
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).at(1))
            .controller!
            .text,
        'new-brand',
      );
    },
  );

  testWidgets(
    'closing an untouched duplicate does not ask for unsaved confirmation',
    (tester) async {
      const seed = BrandDraft(
        name: 'Original (Copy)',
        slug: 'original-copy',
        description: 'Source description',
        isActive: false,
      );
      await _pumpEditor(
        tester,
        FakeBrandsRepository(),
        seed: seed,
        duplicate: true,
      );
      await tester.tap(find.text(BrandsKeys.cancel.en));
      await tester.pumpAndSettle();
      expect(find.text(TemplateKeys.unsavedChanges.en), findsNothing);
      expect(find.byType(AppFormDialog), findsNothing);
    },
  );

  testWidgets('duplicate saves through create and copies non-unique values', (
    tester,
  ) async {
    const seed = BrandDraft(
      name: 'Original (Copy)',
      slug: 'original-copy',
      logo: 'https://cdn.test/shared.png',
      description: 'Source description',
      isActive: false,
    );
    BrandDraft? created;
    final repository = FakeBrandsRepository()
      ..onCreateBrand = (draft) async {
        created = draft;
        return Right(FakeBrandsRepository.brand);
      };
    await _pumpEditor(tester, repository, seed: seed, duplicate: true);
    await tester.enterText(find.byType(TextFormField).at(0), 'Final copy');
    await tester.tap(find.text(BrandsKeys.save.en));
    await tester.pumpAndSettle();
    expect(created?.name, 'Final copy');
    expect(created?.slug, 'final-copy');
    expect(created?.description, 'Source description');
    expect(created?.logo, 'https://cdn.test/shared.png');
    expect(created?.isActive, isFalse);
  });

  testWidgets(
    'edit mode shows status switch and saves the changed status in the draft',
    (tester) async {
      BrandDraft? updated;
      final repository = FakeBrandsRepository()
        ..onUpdateBrand = (id, draft) async {
          updated = draft;
          return Right(FakeBrandsRepository.brand);
        };
      await _pumpEditor(tester, repository, brand: FakeBrandsRepository.brand);
      expect(find.byType(AppSwitch), findsOneWidget);
      expect(tester.widget<AppSwitch>(find.byType(AppSwitch)).value, isTrue);
      await tester.ensureVisible(find.byType(Switch));
      await tester.tap(find.byType(Switch));
      await tester.pump();
      expect(tester.widget<AppSwitch>(find.byType(AppSwitch)).value, isFalse);
      await tester.tap(find.text(BrandsKeys.save.en));
      await tester.pumpAndSettle();
      expect(updated?.isActive, isFalse);
    },
  );
}
