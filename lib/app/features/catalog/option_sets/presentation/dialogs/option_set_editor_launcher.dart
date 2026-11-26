import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_form_dialog/app_form_dialog.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/cubit/option_set_form/option_set_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/dialogs/option_set_editor_dialog.dart';

Future<bool?> showOptionSetEditor(
  BuildContext context, {
  OptionSet? optionSet,
}) => showAppFormDialog<bool>(
  context,
  (_) => BlocProvider(
    create: (_) => sl<OptionSetFormCubit>(),
    child: OptionSetEditorDialog(optionSet: optionSet),
  ),
);
