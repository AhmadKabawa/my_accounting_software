import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_form_dialog/app_form_dialog.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/cubit/sport_form/sport_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/dialogs/sport_editor_dialog.dart';

/// Opens the sport editor and owns the form Cubit lifetime.
Future<bool?> showSportEditor(
  BuildContext context, {
  Sport? sport,
  bool duplicate = false,
}) {
  final seed = duplicate && sport != null
      ? sportDuplicateSeed(context, sport)
      : null;
  return showAppFormDialog<bool>(
    context,
    (_) => BlocProvider(
      create: (_) => sl<SportFormCubit>(),
      child: SportEditorDialog(
        sport: duplicate ? null : sport,
        seed: seed,
        duplicate: duplicate,
      ),
    ),
  );
}
