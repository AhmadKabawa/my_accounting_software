import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_form_dialog/app_form_dialog.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/catalog_tag.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/cubit/tag_form/tag_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/dialogs/tag_editor_dialog.dart';

/// Opens the tag editor and owns the form Cubit lifetime.
Future<bool?> showTagEditor(
  BuildContext context, {
  CatalogTag? tag,
  bool duplicate = false,
}) {
  final seed = duplicate && tag != null
      ? tagDuplicateSeed(context, tag)
      : null;
  return showAppFormDialog<bool>(
    context,
    (_) => BlocProvider(
      create: (_) => sl<TagFormCubit>(),
      child: TagEditorDialog(
        tag: duplicate ? null : tag,
        seed: seed,
        duplicate: duplicate,
      ),
    ),
  );
}
