import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_form_dialog/app_form_dialog.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/catalog_attribute.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/cubit/attribute_form/attribute_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/cubit/attribute_lookups/attribute_lookups_cubit.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/dialogs/attribute_editor_dialog.dart';
Future<bool?> showAttributeEditor(BuildContext context, {CatalogAttribute? attribute, bool duplicate = false}) =>
    showAppFormDialog<bool>(context, (_) => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AttributeFormCubit>()),
        BlocProvider(create: (_) => sl<AttributeLookupsCubit>()..load()),
      ],
      child: AttributeEditorDialog(attribute: attribute, duplicate: duplicate),
    ));