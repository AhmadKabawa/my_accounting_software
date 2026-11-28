import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_form_dialog/app_form_dialog.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/domain/entity/catalog_size.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/presentation/cubit/size_form/size_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/presentation/dialogs/size_editor_dialog.dart';

Future<bool?> showSizeEditor(
  BuildContext context, {
  required int sizeGroupId,
  CatalogSize? size,
}) => showAppFormDialog<bool>(
  context,
  (_) => BlocProvider(
    create: (_) => sl<SizeFormCubit>(),
    child: SizeEditorDialog(sizeGroupId: sizeGroupId, size: size),
  ),
);
