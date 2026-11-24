import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_form_dialog/app_form_dialog.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/color_form/color_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/dialogs/color_editor_dialog.dart';

/// Opens the color editor and owns the form Cubit lifetime.
Future<bool?> showColorEditor(
  BuildContext context, {
  CatalogColor? color,
  bool duplicate = false,
}) {
  final seed = duplicate && color != null
      ? colorDuplicateSeed(context, color)
      : null;
  return showAppFormDialog<bool>(
    context,
    (_) => BlocProvider(
      create: (_) => sl<ColorFormCubit>(),
      child: ColorEditorDialog(
        color: duplicate ? null : color,
        seed: seed,
        duplicate: duplicate,
      ),
    ),
  );
}
