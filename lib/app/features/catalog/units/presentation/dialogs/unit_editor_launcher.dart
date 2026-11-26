import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_form_dialog/app_form_dialog.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/catalog_unit.dart';
import 'package:accounting_software/app/features/catalog/units/presentation/cubit/unit_form/unit_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/units/presentation/dialogs/unit_editor_dialog.dart';

Future<bool?> showUnitEditor(BuildContext context, {CatalogUnit? unit}) =>
    showAppFormDialog<bool>(
      context,
      (_) => BlocProvider(
        create: (_) => sl<UnitFormCubit>(),
        child: UnitEditorDialog(unit: unit),
      ),
    );
