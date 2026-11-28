import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_form_dialog/app_form_dialog.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/entity/collection.dart';
import 'package:accounting_software/app/features/catalog/collections/presentation/cubit/collections_form/collection_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/collections/presentation/dialogs/collections_editor_dialog.dart';

Future<bool?> showCollectionEditor(
  BuildContext context, {
  CatalogCollection? item,
  bool duplicate = false,
}) => showAppFormDialog<bool>(
  context,
  (_) => BlocProvider(
    create: (_) => sl<CollectionFormCubit>(),
    child: CollectionEditorDialog(item: item),
  ),
);
