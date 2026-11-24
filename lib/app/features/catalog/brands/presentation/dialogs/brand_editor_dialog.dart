import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_editor/crud_editor.dart';
import 'package:accounting_software/app/core/foundation/image/image_upload_cubit.dart';
import 'package:accounting_software/app/core/platform/image_picker/image_picker_port.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_draft.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/utility/brand_slug_from.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brand_form/brand_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brand_form/brand_form_effect.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/dialogs/brand_editor_labels.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/widgets/brand_editor_fields_view.dart';

export 'brand_duplicate_seed.dart' show brandDuplicateSeed;

class BrandEditorDialog extends StatefulWidget {
  const BrandEditorDialog({
    super.key,
    this.brand,
    this.seed,
    required this.logoUploader,
    this.logoPicker,
    this.duplicate = false,
  }) : assert(!duplicate || (brand == null && seed != null));

  final Brand? brand;
  final BrandDraft? seed;
  final ImageUploader logoUploader;
  final ImagePickerPort? logoPicker;
  final bool duplicate;

  @override
  State<BrandEditorDialog> createState() => _BrandEditorDialogState();
}

class _BrandEditorDialogState extends State<BrandEditorDialog> {
  late final CrudEditorFields _fields;
  late final bool _initialActive;
  bool _active = true;
  bool _slugTouched = false;
  bool _settingSlug = false;
  bool _logoBusy = false;

  TextEditingController get _name => _fields['name'];
  TextEditingController get _slug => _fields['slug'];
  TextEditingController get _logo => _fields['logo'];
  TextEditingController get _description => _fields['description'];

  @override
  void initState() {
    super.initState();
    final brand = widget.brand;
    final seed = widget.seed;
    _initialActive = seed?.isActive ?? brand?.isActive ?? true;
    _active = _initialActive;
    _slugTouched = brand != null;
    _fields = CrudEditorFields(
      initialValues: {
        'name': seed?.name ?? brand?.name ?? '',
        'slug': seed?.slug ?? brand?.slug ?? '',
        'logo': seed?.logo ?? brand?.logo ?? '',
        'description': seed?.description ?? brand?.description ?? '',
      },
    );
    if (widget.duplicate) {
      _name.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _name.text.length,
      );
    }
  }

  @override
  void dispose() {
    _fields.dispose();
    super.dispose();
  }

  void _onLogoBusyChanged(bool busy) {
    if (!mounted || _logoBusy == busy) return;
    setState(() => _logoBusy = busy);
  }

  void _setSlug(String value) {
    _settingSlug = true;
    _slug.text = value;
    _settingSlug = false;
  }

  void _onNameChanged(String value, CrudEditorScope scope) {
    scope.clearFailure();
    if (widget.brand == null && !_slugTouched) {
      _setSlug(brandSlugFrom(value));
    }
  }

  void _onSlugChanged(CrudEditorScope scope) {
    if (_settingSlug || _slugTouched) return;
    _slugTouched = true;
    scope.changed();
  }

  void _regenerateSlug(CrudEditorScope scope) {
    final generated = brandSlugFrom(_name.text);
    if (generated.isEmpty) return;
    _slugTouched = false;
    _setSlug(generated);
    scope
      ..clearFailure()
      ..changed();
  }

  Future<void> _save() => context.read<BrandFormCubit>().save(
    id: widget.brand?.id,
    draft: BrandDraft(
      name: _name.text.trim(),
      slug: _slug.text.trim(),
      logo: _logo.text.trim().isEmpty ? null : _logo.text.trim(),
      description: _description.text.trim().isEmpty
          ? null
          : _description.text.trim(),
      // PATCH sends status only when it changed in the editor.
      isActive: widget.brand == null || _active != widget.brand!.isActive
          ? _active
          : null,
    ),
  );

  @override
  Widget build(BuildContext context) =>
      CrudEditorDialog<BrandFormCubit, BrandFormStatus, BrandFormEffect>(
        cubit: context.read<BrandFormCubit>(),
        fields: _fields,
        mode: widget.duplicate
            ? CrudEditorMode.duplicate
            : widget.brand == null
            ? CrudEditorMode.add
            : CrudEditorMode.edit,
        labels: brandEditorLabels,
        isSaving: (status) => status == BrandFormStatus.saving,
        outcome: (effect) => switch (effect) {
          BrandSavedEffect() => const CrudEditorSuccess(),
          BrandSaveFailedEffect(:final messageKey) => CrudEditorFailure(
            messageKey,
          ),
        },
        onSave: _save,
        extraBusy: _logoBusy,
        extraDirty: _active != _initialActive,
        builder: (context, scope) => BrandEditorFieldsView(
          name: _name,
          slug: _slug,
          logo: _logo,
          logoUploader: widget.logoUploader,
          logoPicker: widget.logoPicker,
          onLogoBusyChanged: _onLogoBusyChanged,
          description: _description,
          onNameChanged: (value) => _onNameChanged(value, scope),
          onSlugChanged: (_) => _onSlugChanged(scope),
          showSlugHint:
              _name.text.trim().isNotEmpty &&
              brandSlugFrom(_name.text).isEmpty,
          nameAutofocus: widget.duplicate,
          onRegenerateSlug:
              _slugTouched && brandSlugFrom(_name.text).isNotEmpty
              ? () => _regenerateSlug(scope)
              : null,
          active: _active,
          activeLabelKey: widget.brand == null
              ? BrandsKeys.activeOnCreate
              : BrandsKeys.active,
          onActiveChanged: scope.busy
              ? null
              : (value) {
                  setState(() => _active = value);
                  scope
                    ..clearFailure()
                    ..changed();
                },
        ),
      );
}
