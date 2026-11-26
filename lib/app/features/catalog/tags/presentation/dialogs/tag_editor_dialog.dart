import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/foundation/validation/slug.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_editor/crud_editor.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/catalog_tag.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/catalog_tag_draft.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/cubit/tag_form/tag_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/cubit/tag_form/tag_form_effect.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/dialogs/tag_editor_labels.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/sections/tag_identity_section.dart';

export 'tag_duplicate_seed.dart' show tagDuplicateSeed;

class TagEditorDialog extends StatefulWidget {
  const TagEditorDialog({
    super.key,
    this.tag,
    this.seed,
    this.duplicate = false,
  }) : assert(!duplicate || (tag == null && seed != null));

  final CatalogTag? tag;
  final CatalogTagDraft? seed;
  final bool duplicate;

  @override
  State<TagEditorDialog> createState() => _TagEditorDialogState();
}

class _TagEditorDialogState extends State<TagEditorDialog> {
  late final CrudEditorFields _fields;
  bool _slugTouched = false;
  bool _settingSlug = false;

  TextEditingController get _name => _fields['name'];
  TextEditingController get _slug => _fields['slug'];

  @override
  void initState() {
    super.initState();
    final tag = widget.tag;
    final seed = widget.seed;
    // An existing tag keeps its slug; a duplicate seed already has its own.
    _slugTouched = tag != null || seed != null;
    _fields = CrudEditorFields(
      initialValues: {
        'name': seed?.name ?? tag?.name ?? '',
        'slug': seed?.slug ?? tag?.slug ?? '',
      },
    );
    if (widget.duplicate) {
      for (final controller in [_name, _slug]) {
        controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: controller.text.length,
        );
      }
    }
  }

  @override
  void dispose() {
    _fields.dispose();
    super.dispose();
  }

  void _setSlug(String value) {
    _settingSlug = true;
    _slug.text = value;
    _settingSlug = false;
  }

  void _onNameChanged(String value, CrudEditorScope scope) {
    scope.clearFailure();
    if (!_slugTouched) _setSlug(Slug.from(value));
  }

  void _onSlugChanged(CrudEditorScope scope) {
    if (_settingSlug || _slugTouched) return;
    _slugTouched = true;
    scope.changed();
  }

  void _regenerateSlug(CrudEditorScope scope) {
    final generated = Slug.from(_name.text);
    if (generated.isEmpty) return;
    _slugTouched = false;
    _setSlug(generated);
    scope
      ..clearFailure()
      ..changed();
  }

  Future<void> _save() => context.read<TagFormCubit>().save(
    id: widget.tag?.id,
    draft: CatalogTagDraft(
      name: _name.text.trim(),
      slug: _slug.text.trim(),
      isActive: widget.seed?.isActive ?? widget.tag?.isActive ?? true,
    ),
  );

  @override
  Widget build(BuildContext context) =>
      CrudEditorDialog<TagFormCubit, TagFormStatus, TagFormEffect>(
        cubit: context.read<TagFormCubit>(),
        fields: _fields,
        mode: widget.duplicate
            ? CrudEditorMode.duplicate
            : widget.tag == null
            ? CrudEditorMode.add
            : CrudEditorMode.edit,
        labels: tagEditorLabels,
        isSaving: (status) => status == TagFormStatus.saving,
        outcome: (effect) => switch (effect) {
          TagSavedEffect() => const CrudEditorSuccess(),
          TagSaveFailedEffect(:final messageKey) => CrudEditorFailure(
            messageKey,
          ),
        },
        onSave: _save,
        onReset: () => _slugTouched = widget.tag != null || widget.seed != null,
        builder: (context, scope) => TagIdentitySection(
          name: _name,
          slug: _slug,
          onNameChanged: (value) => _onNameChanged(value, scope),
          onSlugChanged: (_) => _onSlugChanged(scope),
          showSlugHint:
              _name.text.trim().isNotEmpty && Slug.from(_name.text).isEmpty,
          onRegenerateSlug: _slugTouched && Slug.from(_name.text).isNotEmpty
              ? () => _regenerateSlug(scope)
              : null,
        ),
      );
}
