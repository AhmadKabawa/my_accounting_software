import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_draft.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/cubit/option_set_options/option_set_options_cubit.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/cubit/option_set_options/option_set_options_state.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/localization/option_sets_keys.dart';

class OptionSetOptionsDialog extends StatelessWidget {
  const OptionSetOptionsDialog({super.key, required this.optionSet});
  final OptionSet optionSet;

  Future<void> _edit(BuildContext context, [CatalogOption? option]) async {
    final draft = await showDialog<CatalogOptionDraft>(
      context: context,
      builder: (_) => _OptionEditorDialog(option: option),
    );
    if (draft == null || !context.mounted) return;
    await context.read<OptionSetOptionsCubit>().saveOption(
      optionId: option?.id,
      draft: draft,
    );
  }

  @override
  Widget build(BuildContext context) {
    final canManage = context.watch<AccessCubit>().can(
      Permissions.masterData.manage,
    );
    return BlocBuilder<OptionSetOptionsCubit, OptionSetOptionsState>(
      builder: (context, state) => AlertDialog(
        title: AppText.raw(optionSet.name),
        content: SizedBox(
          width: context.ui.size.width(AppComponentSize.formDialogWidth),
          child: switch (state.status) {
            OptionSetOptionsStatus.initial || OptionSetOptionsStatus.loading =>
              const Center(child: CircularProgressIndicator()),
            OptionSetOptionsStatus.failed => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InlineBanner(
                  messageKey: state.failure?.messageKey ?? OptionSetsKeys.loadError,
                  variant: InlineBannerVariant.error,
                ),
                AppButton(
                  CatalogUiKeys.retry,
                  variant: AppButtonVariant.text,
                  onPressed: () => context.read<OptionSetOptionsCubit>().load(optionSet.id),
                ),
              ],
            ),
            OptionSetOptionsStatus.ready ||
            OptionSetOptionsStatus.saving => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.failure != null)
                  InlineBanner(
                    messageKey: state.failure!.messageKey,
                    variant: InlineBannerVariant.error,
                  ),
                if (state.options.isEmpty)
                  Padding(
                    padding: context.ui.padding.all(AppSpacing.lg),
                    child: AppText(OptionSetsKeys.emptyOptions),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: state.options.length,
                      separatorBuilder: (_, _) => Divider(
                        height: context.ui.spacing.value(AppSpacing.xs),
                      ),
                      itemBuilder: (context, index) {
                        final option = state.options[index];
                        return ListTile(
                          title: AppText.raw(option.name),
                          subtitle: AppText.raw(option.code),
                          trailing: canManage
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AppIconButton(
                                      AppIcons.edit,
                                      tooltipKey: OptionSetsKeys.editOption,
                                      onPressed: state.status == OptionSetOptionsStatus.saving
                                          ? null
                                          : () => _edit(context, option),
                                    ),
                                    AppIconButton(
                                      option.isActive ? AppIcons.block : AppIcons.restore,
                                      tooltipKey: option.isActive
                                          ? OptionSetsKeys.deactivate
                                          : OptionSetsKeys.activate,
                                      onPressed: state.status == OptionSetOptionsStatus.saving
                                          ? null
                                          : () => context.read<OptionSetOptionsCubit>().setActive(
                                                optionId: option.id,
                                                isActive: !option.isActive,
                                              ),
                                    ),
                                  ],
                                )
                              : AppText(
                                  option.isActive
                                      ? OptionSetsKeys.active
                                      : OptionSetsKeys.inactive,
                                ),
                        );
                      },
                    ),
                  ),
                if (state.status == OptionSetOptionsStatus.saving)
                  const LinearProgressIndicator(),
              ],
            ),
          },
        ),
        actions: [
          if (canManage)
            AppButton(
              OptionSetsKeys.addOption,
              onPressed: state.status == OptionSetOptionsStatus.saving
                  ? null
                  : () => _edit(context),
            ),
          AppButton(
            OptionSetsKeys.cancel,
            variant: AppButtonVariant.text,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _OptionEditorDialog extends StatefulWidget {
  const _OptionEditorDialog({this.option});
  final CatalogOption? option;

  @override
  State<_OptionEditorDialog> createState() => _OptionEditorDialogState();
}

class _OptionEditorDialogState extends State<_OptionEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _code;
  late final TextEditingController _sortOrder;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.option?.name ?? '');
    _code = TextEditingController(text: widget.option?.code ?? '');
    _sortOrder = TextEditingController(
      text: (widget.option?.sortOrder ?? 0).toString(),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _sortOrder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: AppText(
      widget.option == null
          ? OptionSetsKeys.addOption
          : OptionSetsKeys.editOption,
    ),
    content: Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            controller: _name,
            labelKey: OptionSetsKeys.optionName,
            validator: (value) => value?.trim().isEmpty ?? true
                ? OptionSetsKeys.required.tr(context: context)
                : null,
          ),
          context.ui.spacing.gap(AppSpacing.sm),
          AppTextField(
            controller: _code,
            labelKey: OptionSetsKeys.code,
            textDirection: TextDirection.ltr,
            validator: (value) => value?.trim().isEmpty ?? true
                ? OptionSetsKeys.required.tr(context: context)
                : null,
          ),
          context.ui.spacing.gap(AppSpacing.sm),
          AppTextField(
            controller: _sortOrder,
            labelKey: OptionSetsKeys.sortOrder,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    ),
    actions: [
      AppButton(
        OptionSetsKeys.cancel,
        variant: AppButtonVariant.text,
        onPressed: () => Navigator.pop(context),
      ),
      AppButton(
        OptionSetsKeys.save,
        onPressed: () {
          if (!_formKey.currentState!.validate()) return;
          Navigator.pop(
            context,
            CatalogOptionDraft(
              name: _name.text.trim(),
              code: _code.text.trim(),
              sortOrder: int.tryParse(_sortOrder.text.trim()) ?? 0,
            ),
          );
        },
      ),
    ],
  );
}
