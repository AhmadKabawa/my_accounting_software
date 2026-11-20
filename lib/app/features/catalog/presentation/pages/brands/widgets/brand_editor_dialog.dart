import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/features/catalog/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/domain/entity/brand_draft.dart';
import 'package:accounting_software/app/features/catalog/domain/failures/brand_failures.dart';
import 'package:accounting_software/app/features/catalog/presentation/cubit/brand_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/presentation/localization/brands_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Add/edit dialog for one brand. Opened with a `BrandFormCubit` provider.
class BrandEditorDialog extends StatefulWidget {
  const BrandEditorDialog({this.brand});
  final Brand? brand;
  @override
  State<BrandEditorDialog> createState() => BrandEditorDialogState();
}

class BrandEditorDialogState extends State<BrandEditorDialog> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _name, _slug, _logo, _description;
  bool _saving = false;
  AppKey? _failure;

  @override
  void initState() {
    super.initState();
    final b = widget.brand;
    _name = TextEditingController(text: b?.name ?? '');
    _slug = TextEditingController(text: b?.slug ?? '');
    _logo = TextEditingController(text: b?.logo ?? '');
    _description = TextEditingController(text: b?.description ?? '');
  }

  @override
  void dispose() {
    _name.dispose(); _slug.dispose(); _logo.dispose(); _description.dispose();
    super.dispose();
  }

  String _slugify(String s) => s.trim().toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');

  Future<void> _save() async {
    if (_saving || !_key.currentState!.validate()) return;
    setState(() { _saving = true; _failure = null; });
    final result = await context.read<BrandFormCubit>().save(
      id: widget.brand?.id,
      draft: BrandDraft(
        name: _name.text.trim(), slug: _slug.text.trim(),
        logo: _logo.text.trim().isEmpty ? null : _logo.text.trim(),
        description: _description.text.trim().isEmpty ? null : _description.text.trim(),
      ),
    );
    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _saving = false;
        _failure = f is BrandDuplicateFailure ? BrandsKeys.duplicateError : f.messageKey;
      }),
      (_) => Navigator.of(context).pop(true),
    );
  }

  @override
  Widget build(BuildContext context) => Dialog(
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: context.ui.size.width(AppComponentSize.cardWidth) * 2,
        maxHeight: context.ui.size.height(AppComponentSize.cardHeight) * 3,
      ),
      child: Padding(
        padding: context.ui.padding.all(AppSpacing.md),
        child: Form(
          key: _key,
          child: SingleChildScrollView(child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppText(widget.brand == null ? BrandsKeys.add : BrandsKeys.edit,
                type: AppTextType.titleLarge),
              context.ui.spacing.gap(AppSpacing.xs),
              AppText(BrandsKeys.editorSubtitle, type: AppTextType.bodySmall),
              context.ui.spacing.gap(AppSpacing.md),
              if (_failure != null) ...[
                InlineBanner(messageKey: _failure!, variant: InlineBannerVariant.error),
                context.ui.spacing.gap(AppSpacing.smMd),
              ],
              AppTextField(controller: _name, labelKey: BrandsKeys.brandName,
                validator: (v) {
                  final s = v?.trim() ?? '';
                  if (s.isEmpty) return BrandsKeys.required.tr(context: context);
                  if (s.length > 150) return BrandsKeys.nameTooLong.tr(context: context);
                  return null;
                },
                onChanged: (v) {
                  if (_slug.text.isEmpty) _slug.text = _slugify(v);
                  if (_failure != null) setState(() => _failure = null);
                }),
              context.ui.spacing.gap(AppSpacing.smMd),
              AppTextField(controller: _slug, labelKey: BrandsKeys.slug,
                validator: (v) {
                  final s = v?.trim() ?? '';
                  if (s.isEmpty) return BrandsKeys.slugRequired.tr(context: context);
                  if (s.length > 150) return BrandsKeys.slugTooLong.tr(context: context);
                  if (!RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(s)) {
                    return BrandsKeys.slugFormat.tr(context: context);
                  }
                  return null;
                }),
              context.ui.spacing.gap(AppSpacing.smMd),
              AppTextField(controller: _logo, labelKey: BrandsKeys.logo,
                keyboardType: TextInputType.url,
                validator: (v) {
                  final s = v?.trim() ?? '';
                  if (s.isEmpty) return null;
                  if (s.length > 500) return BrandsKeys.logoTooLong.tr(context: context);
                  final u = Uri.tryParse(s);
                  if (u == null || !u.hasScheme ||
                      (u.scheme != 'http' && u.scheme != 'https') || u.host.isEmpty) {
                    return BrandsKeys.invalidLogoUrl.tr(context: context);
                  }
                  return null;
                }),
              context.ui.spacing.gap(AppSpacing.smMd),
              AppTextField(controller: _description, labelKey: BrandsKeys.description, maxLines: 3),
              context.ui.spacing.gap(AppSpacing.md),
              Wrap(alignment: WrapAlignment.end, spacing: context.ui.spacing.sm, children: [
                AppButton(BrandsKeys.cancel, variant: AppButtonVariant.text,
                  onPressed: _saving ? null : () => Navigator.of(context).pop(false)),
                AppButton(BrandsKeys.save, isLoading: _saving,
                  onPressed: _saving ? null : _save),
              ]),
            ],
          )),
        ),
      ),
    ),
  );
}
