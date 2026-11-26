import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
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
          width: 560,
          child: switch (state.status) {
            OptionSetOptionsStatus.initial || OptionSetOptionsStatus.loading =>
              const Center(child: CircularProgressIndicator()),
            OptionSetOptionsStatus.failed => InlineBanner(
              messageKey: state.failure?.messageKey ?? OptionSetsKeys.loadError,
              variant: InlineBannerVariant.error,
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
                    padding: const EdgeInsets.all(24),
                    child: AppText(OptionSetsKeys.emptyOptions),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: state.options.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final option = state.options[index];
                        return ListTile(
                          title: AppText.raw(option.name),
                          subtitle: AppText.raw(option.code),
                          trailing: canManage
                              ? Wrap(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: OptionSetsKeys.editOption.tr(
                                        context: context,
                                      ),
                                      onPressed:
                                          state.status ==
                                              OptionSetOptionsStatus.saving
                                          ? null
                                          : () => _edit(context, option),
                                      icon: const Icon(Icons.edit_outlined),
                                    ),
                                    IconButton(
                                      tooltip: option.isActive
                                          ? OptionSetsKeys.deactivate.tr(
                                              context: context,
                                            )
                                          : OptionSetsKeys.activate.tr(
                                              context: context,
                                            ),
                                      onPressed:
                                          state.status ==
                                              OptionSetOptionsStatus.saving
                                          ? null
                                          : () => context
                                                .read<OptionSetOptionsCubit>()
                                                .setActive(
                                                  optionId: option.id,
                                                  isActive: !option.isActive,
                                                ),
                                      icon: Icon(
                                        option.isActive
                                            ? Icons.toggle_on
                                            : Icons.toggle_off,
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
          TextFormField(
            controller: _name,
            decoration: InputDecoration(
              labelText: OptionSetsKeys.optionName.tr(context: context),
            ),
            validator: (value) => value?.trim().isEmpty ?? true
                ? OptionSetsKeys.required.tr(context: context)
                : null,
          ),
          TextFormField(
            controller: _code,
            decoration: InputDecoration(
              labelText: OptionSetsKeys.code.tr(context: context),
            ),
            validator: (value) => value?.trim().isEmpty ?? true
                ? OptionSetsKeys.required.tr(context: context)
                : null,
          ),
          TextFormField(
            controller: _sortOrder,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: OptionSetsKeys.sortOrder.tr(context: context),
            ),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(OptionSetsKeys.cancel.tr(context: context)),
      ),
      FilledButton(
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
        child: Text(OptionSetsKeys.save.tr(context: context)),
      ),
    ],
  );
}
