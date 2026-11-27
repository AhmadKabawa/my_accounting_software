import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_form_dialog/app_form_dialog.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/entity/gender.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/cubit/gender_form/gender_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/dialogs/gender_editor_dialog.dart';

Future<bool?> showGenderEditor(BuildContext context, {Gender? gender}) =>
    showAppFormDialog<bool>(
      context,
      (_) => BlocProvider(
        create: (_) => sl<GenderFormCubit>(),
        child: GenderEditorDialog(gender: gender),
      ),
    );
