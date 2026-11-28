import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_editor/crud_editor.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/localization/size_systems_keys.dart';
import 'package:accounting_software/app/features/catalog/size_systems/shared/domain/range/size_range_generator.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/presentation/cubit/size_range/size_range_cubit.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/presentation/cubit/size_range/size_range_effect.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/presentation/dialogs/size_editor_labels.dart';

typedef _RangeResult = ({SizeRangePlan? plan, SizeRangeError? error});

/// Generate-by-range dialog: from / to / step / code prefix with a live
/// preview of the rows before anything is saved (CAT07-SZ-AC3).
class SizeRangeDialog extends StatefulWidget {
  const SizeRangeDialog({
    super.key,
    required this.sizeGroupId,
    required this.existingCodes,
    required this.firstSortOrder,
  });

  final int sizeGroupId;
  final Set<String> existingCodes;
  final int firstSortOrder;

  @override
  State<SizeRangeDialog> createState() => _SizeRangeDialogState();
}

class _SizeRangeDialogState extends State<SizeRangeDialog> {
  late final CrudEditorFields _fields;

  TextEditingController get _from => _fields['from'];
  TextEditingController get _to => _fields['to'];
  TextEditingController get _step => _fields['step'];
  TextEditingController get _prefix => _fields['prefix'];

  @override
  void initState() {
    super.initState();
    _fields = CrudEditorFields(
      initialValues: const {'from': '', 'to': '', 'step': '1', 'prefix': ''},
    );
  }

  @override
  void dispose() {
    _fields.dispose();
    super.dispose();
  }

  SizeRangeSpec? _spec() {
    final from = Decimal.tryParse(_from.text.trim());
    final to = Decimal.tryParse(_to.text.trim());
    final step = Decimal.tryParse(_step.text.trim());
    if (from == null || to == null || step == null) return null;
    return SizeRangeSpec(
      from: from,
      to: to,
      step: step,
      codePrefix: _prefix.text,
    );
  }

  /// The plan for the current inputs, or the validation error to show.
  _RangeResult _plan() {
    final spec = _spec();
    if (spec == null) return (plan: null, error: null);
    return SizeRangeGenerator.plan(
      spec: spec,
      existingCodes: widget.existingCodes,
      firstSortOrder: widget.firstSortOrder,
    ).fold<_RangeResult>(
      (error) => (plan: null, error: error),
      (plan) => (plan: plan, error: null),
    );
  }

  String? _rangeError(BuildContext context, SizeRangeError? error) =>
      switch (error) {
        SizeRangeError.reversed => SizeSystemsKeys.rangeReversed.tr(
          context: context,
        ),
        SizeRangeError.stepNotPositive => SizeSystemsKeys.rangeStepPositive.tr(
          context: context,
        ),
        SizeRangeError.tooManyRows => SizeSystemsKeys.rangeTooMany.tr(
          context: context,
        ),
        null => null,
      };

  String? _number(BuildContext context, String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return SizeSystemsKeys.required.tr(context: context);
    if (Decimal.tryParse(text) == null) {
      return SizeSystemsKeys.numberFormat.tr(context: context);
    }
    return null;
  }

  Future<void> _save() {
    final plan = _plan().plan;
    return context.read<SizeRangeCubit>().save(
      sizeGroupId: widget.sizeGroupId,
      rows: plan?.rows ?? const [],
    );
  }

  @override
  Widget build(BuildContext context) =>
      CrudEditorDialog<SizeRangeCubit, SizeRangeStatus, SizeRangeEffect>(
        cubit: context.read<SizeRangeCubit>(),
        fields: _fields,
        mode: CrudEditorMode.add,
        labels: sizeRangeEditorLabels,
        isSaving: (status) => status == SizeRangeStatus.saving,
        outcome: (effect) => switch (effect) {
          SizeRangeSavedEffect() => const CrudEditorSuccess(),
          SizeRangeFailedEffect(:final messageKey) => CrudEditorFailure(
            messageKey,
          ),
        },
        onSave: _save,
        onReset: () {},
        builder: (context, scope) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _from,
              labelKey: SizeSystemsKeys.rangeFrom,
              onChanged: (_) => scope.clearFailure(),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textDirection: TextDirection.ltr,
              validator: (value) => _number(context, value),
            ),
            context.ui.spacing.gap(AppSpacing.sm),
            AppTextField(
              controller: _to,
              labelKey: SizeSystemsKeys.rangeTo,
              onChanged: (_) => scope.clearFailure(),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textDirection: TextDirection.ltr,
              validator: (value) =>
                  _number(context, value) ??
                  _rangeError(context, _plan().error),
            ),
            context.ui.spacing.gap(AppSpacing.sm),
            AppTextField(
              controller: _step,
              labelKey: SizeSystemsKeys.rangeStep,
              onChanged: (_) => scope.clearFailure(),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textDirection: TextDirection.ltr,
              validator: (value) {
                final invalid = _number(context, value);
                if (invalid != null) return invalid;
                final step = Decimal.tryParse(value!.trim());
                return step != null && step <= Decimal.zero
                    ? SizeSystemsKeys.rangeStepPositive.tr(context: context)
                    : null;
              },
            ),
            context.ui.spacing.gap(AppSpacing.sm),
            AppTextField(
              controller: _prefix,
              labelKey: SizeSystemsKeys.rangePrefix,
              onChanged: (_) => scope.clearFailure(),
              textDirection: TextDirection.ltr,
            ),
            context.ui.spacing.gap(AppSpacing.md),
            ListenableBuilder(
              listenable: Listenable.merge([_from, _to, _step, _prefix]),
              builder: (context, _) => _RangePreview(result: _plan()),
            ),
          ],
        ),
      );
}

class _RangePreview extends StatelessWidget {
  const _RangePreview({required this.result});

  final _RangeResult result;

  @override
  Widget build(BuildContext context) {
    final plan = result.plan;
    if (plan == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(SizeSystemsKeys.rangePreview, type: AppTextType.titleSmall),
        context.ui.spacing.gap(AppSpacing.xs),
        AppText(SizeSystemsKeys.rangeCount),
        AppText.raw(plan.rows.length.toString()),
        if (plan.rows.isNotEmpty) ...[
          context.ui.spacing.gap(AppSpacing.xs),
          AppText.raw(plan.rows.map((row) => row.name).join('  ·  ')),
        ],
        if (plan.skippedCodes.isNotEmpty) ...[
          context.ui.spacing.gap(AppSpacing.sm),
          AppText(SizeSystemsKeys.rangeSkipped),
          AppText.raw(plan.skippedCodes.join('  ·  ')),
        ],
      ],
    );
  }
}
