import 'package:accounting_software/app/core/presentation/widgets/crud_editor/crud_editor.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/localization/size_systems_keys.dart';

const sizeEditorLabels = CrudEditorLabels(
  addTitle: SizeSystemsKeys.addSize,
  editTitle: SizeSystemsKeys.editSize,
  duplicateTitle: SizeSystemsKeys.duplicateTitle,
  subtitle: SizeSystemsKeys.editorSubtitle,
  save: SizeSystemsKeys.save,
  cancel: SizeSystemsKeys.cancel,
);

const sizeRangeEditorLabels = CrudEditorLabels(
  addTitle: SizeSystemsKeys.generateTitle,
  editTitle: SizeSystemsKeys.generateTitle,
  duplicateTitle: SizeSystemsKeys.generateTitle,
  subtitle: SizeSystemsKeys.rangePreview,
  save: SizeSystemsKeys.save,
  cancel: SizeSystemsKeys.cancel,
);
