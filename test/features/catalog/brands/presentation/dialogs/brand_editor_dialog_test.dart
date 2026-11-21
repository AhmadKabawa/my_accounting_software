import 'dart:async';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/platform/image_picker/image_picker_port.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_form_dialog/app_form_dialog.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/failures/brand_failures.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/create_brand_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/update_brand_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/upload_brand_logo_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brand_form/brand_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brand_logo_upload/brand_logo_upload_cubit.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/dialogs/brand_editor_dialog.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';
import '../../../../../helpers/localized_app.dart';
import '../../support/fake_brands_repository.dart';

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
                    BlocProvider(
                      create: (_) => BrandLogoUploadCubit(
                        uploadLogo: UploadBrandLogoUseCase(repository),
                        picker: picker ?? _Picker(() async => null),
                      ),
                    ),
                  ],
                  child: BrandEditorDialog(brand: brand),
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
    await _pumpEditor(
      tester,
      repository,
      onResult: (value) => result = value,
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'Vaude Store');
    await tester.pump();
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField).at(1)).controller!.text,
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

    expect(tester.widget<TextFormField>(fields.at(1)).controller!.text, 'manual-slug');
    await tester.tap(find.text(BrandsKeys.regenerateSlug.en));
    await tester.pump();
    expect(tester.widget<TextFormField>(fields.at(1)).controller!.text, 'second-name');
  });

  testWidgets('Arabic name stays without transliteration and shows guidance', (
    tester,
  ) async {
    await _pumpEditor(tester, FakeBrandsRepository());
    await tester.enterText(find.byType(TextFormField).at(0), 'ماركة عربية');
    await tester.pump();

    expect(tester.widget<TextFormField>(find.byType(TextFormField).at(1)).controller!.text, isEmpty);
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
    expect(tester.widget<TextFormField>(find.byType(TextFormField).at(1)).controller!.text, 'stable-slug');
  });

  testWidgets('duplicate save failure shows the duplicate banner and stays open', (
    tester,
  ) async {
    final repository = FakeBrandsRepository()
      ..onCreateBrand = (_) async => const Left(BrandDuplicateFailure());
    await _pumpEditor(tester, repository);
    await tester.enterText(find.byType(TextFormField).at(0), 'Duplicate');
    await tester.tap(find.text(BrandsKeys.save.en));
    await tester.pumpAndSettle();

    expect(find.text(BrandsKeys.duplicateError.en), findsOneWidget);
    expect(find.byType(AppFormDialog), findsOneWidget);
  });

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
    await tester.tap(find.text(BrandsKeys.uploadLogo.en));
    await tester.pumpAndSettle();
    expect(find.text(BrandsKeys.uploadLogo.en), findsOneWidget);
    expect(find.text(BrandsKeys.replaceLogo.en), findsNothing);
  });

  testWidgets('upload success updates the logo value and replaces action', (
    tester,
  ) async {
    final repository = FakeBrandsRepository();
    final picker = _Picker(() async => PickedImage(
      bytes: Uint8List.fromList([1, 2, 3]),
      fileName: 'logo.png',
      mimeType: 'image/png',
    ));
    await _pumpEditor(tester, repository, picker: picker);
    await tester.tap(find.text(BrandsKeys.uploadLogo.en));
    await tester.pumpAndSettle();
    expect(find.text(BrandsKeys.replaceLogo.en), findsOneWidget);
    expect(find.byTooltip(BrandsKeys.removeLogo.en), findsOneWidget);
  });

  testWidgets('upload failure shows an inline banner', (tester) async {
    final repository = FakeBrandsRepository()
      ..uploadResult = const Left(_Failure());
    final picker = _Picker(() async => PickedImage(
      bytes: Uint8List.fromList([1, 2, 3]),
      fileName: 'logo.png',
      mimeType: 'image/png',
    ));
    await _pumpEditor(tester, repository, picker: picker);
    await tester.tap(find.text(BrandsKeys.uploadLogo.en));
    await tester.pumpAndSettle();
    expect(find.text(BrandsKeys.saveError.en), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
