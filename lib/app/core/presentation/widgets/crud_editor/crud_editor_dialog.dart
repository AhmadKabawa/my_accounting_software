import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/localization/keys/template_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/core/presentation/state_management/bloc_effect_listener.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_form_dialog/app_form_dialog.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_editor/crud_editor_fields.dart';

enum CrudEditorMode { add, edit, duplicate }

class CrudEditorLabels {
  const CrudEditorLabels({
    required this.addTitle,
    required this.editTitle,
    required this.duplicateTitle,
    required this.subtitle,
    required this.save,
    required this.cancel,
  });

  final AppKey addTitle;
  final AppKey editTitle;
  final AppKey duplicateTitle;
  final AppKey subtitle;
  final AppKey save;
  final AppKey cancel;

  AppKey titleFor(CrudEditorMode mode) => switch (mode) {
    CrudEditorMode.add => addTitle,
    CrudEditorMode.edit => editTitle,
    CrudEditorMode.duplicate => duplicateTitle,
  };
}

sealed class CrudEditorOutcome {
  const CrudEditorOutcome();
}

final class CrudEditorSuccess extends CrudEditorOutcome {
  const CrudEditorSuccess();
}

final class CrudEditorFailure extends CrudEditorOutcome {
  const CrudEditorFailure(this.messageKey);

  final AppKey messageKey;
}

class CrudEditorScope {
  const CrudEditorScope({
    required this.formKey,
    required this.fields,
    required this.busy,
    required this.clearFailure,
    required this.changed,
  });

  final GlobalKey<FormState> formKey;
  final CrudEditorFields fields;
  final bool busy;
  final VoidCallback clearFailure;
  final VoidCallback changed;
}

/// Shared lifecycle and form shell for feature-specific CRUD editor fields.
///
/// The caller owns [fields] and must dispose it with its editor state.
class CrudEditorDialog<C extends BaseCubit<S, E>, S, E> extends StatefulWidget {
  const CrudEditorDialog({
    super.key,
    required this.cubit,
    required this.fields,
    required this.mode,
    required this.labels,
    required this.isSaving,
    required this.outcome,
    required this.onSave,
    required this.builder,
    this.extraBusy = false,
    this.extraDirty = false,
    this.onReset,
  });

  final C cubit;
  final CrudEditorFields fields;
  final CrudEditorMode mode;
  final CrudEditorLabels labels;
  final bool Function(S state) isSaving;
  final CrudEditorOutcome Function(E effect) outcome;
  final Future<void> Function() onSave;
  final Widget Function(BuildContext context, CrudEditorScope scope) builder;
  final bool extraBusy;
  final bool extraDirty;

  /// Restores feature-owned values that are not held by [CrudEditorFields].
  final VoidCallback? onReset;

  @override
  State<CrudEditorDialog<C, S, E>> createState() =>
      _CrudEditorDialogState<C, S, E>();
}

class _CrudEditorDialogState<C extends BaseCubit<S, E>, S, E>
    extends State<CrudEditorDialog<C, S, E>> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AppKey? _failure;

  @override
  void initState() {
    super.initState();
    widget.fields.addListener(_onFieldsChanged);
  }

  @override
  void didUpdateWidget(covariant CrudEditorDialog<C, S, E> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fields != widget.fields) {
      oldWidget.fields.removeListener(_onFieldsChanged);
      widget.fields.addListener(_onFieldsChanged);
    }
  }

  void _onFieldsChanged() {
    if (mounted) setState(() {});
  }

  void _clearFailure() {
    if (_failure == null || !mounted) return;
    setState(() => _failure = null);
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) return;
    await widget.onSave();
  }

  void _reset() {
    widget.fields.reset();
    widget.onReset?.call();
    if (!mounted) return;
    setState(() {
      _failure = null;
      // Recreate FormFieldState to clear validation messages without
      // overwriting externally owned controllers with empty initial values.
      _formKey = GlobalKey<FormState>();
    });
  }

  @override
  void dispose() {
    widget.fields.removeListener(_onFieldsChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<C, S>(
    bloc: widget.cubit,
    builder: (context, state) {
      final busy = widget.isSaving(state) || widget.extraBusy;
      final scope = CrudEditorScope(
        formKey: _formKey,
        fields: widget.fields,
        busy: busy,
        clearFailure: _clearFailure,
        changed: _onFieldsChanged,
      );
      return BlocEffectListener<E, C>(
        cubit: widget.cubit,
        onEffect: (context, effect) {
          switch (widget.outcome(effect)) {
            case CrudEditorSuccess():
              Navigator.of(context).pop(true);
            case CrudEditorFailure(:final messageKey):
              if (mounted) setState(() => _failure = messageKey);
          }
        },
        child: AppFormDialog(
          titleKey: widget.labels.titleFor(widget.mode),
          subtitleKey: widget.labels.subtitle,
          saveLabelKey: widget.labels.save,
          cancelLabelKey: widget.labels.cancel,
          resetLabelKey: widget.mode == CrudEditorMode.add
              ? TemplateKeys.clearContent
              : TemplateKeys.reset,
          resetMessageKey: widget.mode == CrudEditorMode.add
              ? TemplateKeys.clearFormConfirmation
              : TemplateKeys.resetFormConfirmation,
          onReset: _reset,
          busy: busy,
          saveEnabled: !busy,
          dirty: widget.fields.dirty || widget.extraDirty,
          errorKey: _failure,
          onSave: _save,
          child: Form(key: _formKey, child: widget.builder(context, scope)),
        ),
      );
    },
  );
}
