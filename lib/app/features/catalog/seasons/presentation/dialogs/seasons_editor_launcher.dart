import 'package:flutter/season.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_form_dialog/app_form_dialog.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/entity/season.dart';
import 'package:accounting_software/app/features/catalog/seasons/presentation/cubit/seasons_form/season_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/seasons/presentation/dialogs/seasons_editor_dialog.dart';

Future<bool?> showSeasonEditor(
  BuildContext context, {
  CatalogSeason? item,
  bool duplicate = false,
}) => showAppFormDialog<bool>(
  context,
  (_) => BlocProvider(
    create: (_) => sl<SeasonFormCubit>(),
    child: SeasonEditorDialog(item: item),
  ),
);
