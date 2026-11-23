import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_confirm_dialog/crud_confirmations.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/colors_list/colors_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/dialogs/color_editor_dialog.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/localization/colors_keys.dart';

/// The record flows of the colors list: editor, duplicate, delete and status.
/// Each reads the list Cubit from [context], so the screen only wires them.
abstract final class ColorsListActions {
  static Future<void> edit(BuildContext context, [CatalogColor? color]) async {
    final saved = await showColorEditor(context, color: color);
    if (saved == true && context.mounted) {
      await context.read<ColorsListCubit>().onColorSaved(isNew: color == null);
    }
  }

  static Future<void> duplicate(
    BuildContext context,
    CatalogColor color,
  ) async {
    final saved = await showColorEditor(context, color: color, duplicate: true);
    if (saved == true && context.mounted) {
      await context.read<ColorsListCubit>().onColorSaved(isNew: true);
    }
  }

  static Future<void> delete(BuildContext context, CatalogColor color) {
    final cubit = context.read<ColorsListCubit>();
    return CrudConfirmations.delete(
      context,
      titleKey: ColorsKeys.deleteTitle,
      messageKey: ColorsKeys.deleteMessage,
      messageArgs: {'name': color.name},
      targetName: color.name,
      onDelete: () => cubit.delete(color),
    );
  }

  static Future<void> toggleStatus(BuildContext context, CatalogColor color) {
    final cubit = context.read<ColorsListCubit>();
    return CrudConfirmations.status(
      context,
      isActive: color.isActive,
      targetName: color.name,
      titleKey: ColorsKeys.deactivateTitle,
      messageKey: ColorsKeys.deactivateMessage,
      onActivate: () => cubit.activate(color.id),
      onDeactivate: () => cubit.deactivate(color.id),
    );
  }
}
