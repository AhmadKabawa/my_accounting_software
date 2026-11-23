import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_confirm_dialog/crud_confirmations.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brands_list/brands_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/dialogs/brand_editor_dialog.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';

/// The record flows of the brands list: editor, duplicate, delete and status.
/// Each reads the list Cubit from [context], so the screen only wires them.
abstract final class BrandsListActions {
  static Future<void> edit(BuildContext context, [Brand? brand]) async {
    final saved = await showBrandEditor(context, brand: brand);
    if (saved == true && context.mounted) {
      await context.read<BrandsListCubit>().onBrandSaved(isNew: brand == null);
    }
  }

  static Future<void> duplicate(BuildContext context, Brand brand) async {
    final saved = await showBrandEditor(context, brand: brand, duplicate: true);
    if (saved == true && context.mounted) {
      await context.read<BrandsListCubit>().onBrandSaved(isNew: true);
    }
  }

  static Future<void> delete(BuildContext context, Brand brand) {
    final cubit = context.read<BrandsListCubit>();
    return CrudConfirmations.delete(
      context,
      titleKey: BrandsKeys.delete,
      messageKey: BrandsKeys.confirmDelete,
      targetName: brand.name,
      onDelete: () => cubit.delete(brand),
    );
  }

  static Future<void> toggleStatus(BuildContext context, Brand brand) {
    final cubit = context.read<BrandsListCubit>();
    return CrudConfirmations.status(
      context,
      isActive: brand.isActive,
      targetName: brand.name,
      titleKey: BrandsKeys.deactivateTitle,
      messageKey: BrandsKeys.deactivateMessage,
      onActivate: () => cubit.activate(brand.id),
      onDeactivate: () => cubit.deactivate(brand.id),
    );
  }
}
