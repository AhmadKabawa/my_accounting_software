import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_form_dialog/app_form_dialog.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brand_form/brand_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/dialogs/brand_editor_dialog.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/upload_brand_logo_use_case.dart';

/// Opens the shared brand editor and owns the form/upload Cubit lifetimes.
Future<bool?> showBrandEditor(
  BuildContext context, {
  Brand? brand,
  bool duplicate = false,
}) {
  final seed = duplicate && brand != null
      ? brandDuplicateSeed(context, brand)
      : null;
  return showAppFormDialog<bool>(
    context,
    (_) => MultiBlocProvider(
      providers: [BlocProvider(create: (_) => sl<BrandFormCubit>())],
      child: BrandEditorDialog(
        brand: duplicate ? null : brand,
        seed: seed,
        duplicate: duplicate,
        logoUploader: sl<UploadBrandLogoUseCase>().call,
      ),
    ),
  );
}
