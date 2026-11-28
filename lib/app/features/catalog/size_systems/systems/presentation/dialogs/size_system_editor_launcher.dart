import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_form_dialog/app_form_dialog.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/entity/size_system.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/presentation/cubit/size_system_form/size_system_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/presentation/dialogs/size_system_editor_dialog.dart';

Future<bool?> showSizeSystemEditor(
  BuildContext context, {
  SizeSystem? system,
}) => showAppFormDialog<bool>(
  context,
  (_) => BlocProvider(
    create: (_) => sl<SizeSystemFormCubit>(),
    child: SizeSystemEditorDialog(system: system),
  ),
);
