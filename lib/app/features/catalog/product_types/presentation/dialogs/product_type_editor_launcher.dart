import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_form_dialog/app_form_dialog.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/cubit/product_type_form/product_type_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/dialogs/product_type_editor_dialog.dart';

Future<bool?> showProductTypeEditor(
  BuildContext context, {
  ProductType? productType,
}) => showAppFormDialog<bool>(
  context,
  (_) => BlocProvider(
    create: (_) => sl<ProductTypeFormCubit>(),
    child: ProductTypeEditorDialog(productType: productType),
  ),
);
