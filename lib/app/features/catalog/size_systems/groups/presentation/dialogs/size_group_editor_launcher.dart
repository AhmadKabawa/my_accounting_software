import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_form_dialog/app_form_dialog.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/entity/gender_option.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/entity/size_group.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/presentation/cubit/size_group_form/size_group_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/presentation/dialogs/size_group_editor_dialog.dart';

/// [genders] are passed in because the dialog route does not inherit the
/// screen's providers.
Future<bool?> showSizeGroupEditor(
  BuildContext context, {
  required int sizeSystemId,
  required List<GenderOption> genders,
  SizeGroup? group,
}) => showAppFormDialog<bool>(
  context,
  (_) => BlocProvider(
    create: (_) => sl<SizeGroupFormCubit>(),
    child: SizeGroupEditorDialog(
      sizeSystemId: sizeSystemId,
      genders: genders,
      group: group,
    ),
  ),
);
