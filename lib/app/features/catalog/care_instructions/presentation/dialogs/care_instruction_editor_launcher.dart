import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_form_dialog/app_form_dialog.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/presentation/cubit/care_instruction_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/presentation/dialogs/care_instruction_editor_dialog.dart';

Future<bool?> showCareInstructionEditor(BuildContext context, {CareInstruction? item}) =>
    showAppFormDialog<bool>(
      context,
      (_) => BlocProvider(
        create: (_) => sl<CareInstructionFormCubit>(),
        child: CareInstructionEditorDialog(item: item),
      ),
    );
