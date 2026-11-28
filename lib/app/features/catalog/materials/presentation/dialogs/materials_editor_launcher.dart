import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_form_dialog/app_form_dialog.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/entity/material.dart';
import 'package:accounting_software/app/features/catalog/materials/presentation/cubit/materials_form/material_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/materials/presentation/dialogs/materials_editor_dialog.dart';

Future<bool?> showMaterialEditor(
  BuildContext context, {
  CatalogMaterial? item,
  bool duplicate = false,
}) => showAppFormDialog<bool>(
  context,
  (_) => BlocProvider(
    create: (_) => sl<MaterialFormCubit>(),
    child: MaterialEditorDialog(item: item),
  ),
);
