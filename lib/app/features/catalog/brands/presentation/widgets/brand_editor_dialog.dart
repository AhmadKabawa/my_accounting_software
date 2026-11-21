import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_form_dialog/app_form_dialog.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_draft.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/failures/brand_failures.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brand_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brand_logo_upload_cubit.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/sections/brand_details_section.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/sections/brand_identity_section.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/sections/brand_logo_section.dart';

/// Add/edit dialog for one brand. Opened with form and logo-upload Cubits.
class BrandEditorDialog extends StatefulWidget {
  const BrandEditorDialog({super.key, this.brand});

  final Brand? brand;

  @override
  State<BrandEditorDialog> createState() => _BrandEditorDialogState();
}

class _BrandEditorDialogState extends State<BrandEditorDialog> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _slug;
  late final TextEditingController _logo;
  late final TextEditingController _description;
  late final String _initialName;
  late final String _initialSlug;
  late final String _initialLogo;
  late final String _initialDescription;
  AppKey? _failure;

  bool get _dirty =>
      _name.text != _initialName ||
      _slug.text != _initialSlug ||
      _logo.text != _initialLogo ||
      _description.text != _initialDescription;

  @override
  void initState() {
    super.initState();
    final brand = widget.brand;
    _initialName = brand?.name ?? '';
    _initialSlug = brand?.slug ?? '';
    _initialLogo = brand?.logo ?? '';
    _initialDescription = brand?.description ?? '';
    _name = TextEditingController(text: _initialName);
    _slug = TextEditingController(text: _initialSlug);
    _logo = TextEditingController(text: _initialLogo);
    _description = TextEditingController(text: _initialDescription);
    for (final controller in [_name, _slug, _logo, _description]) {
      controller.addListener(_onChanged);
    }
  }

  void _onChanged() {
    if (!mounted) return;
    setState(() => _failure = null);
  }

  @override
  void dispose() {
    for (final controller in [_name, _slug, _logo, _description]) {
      controller
        ..removeListener(_onChanged)
        ..dispose();
    }
    super.dispose();
  }

  String _slugify(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');

  Future<void> _save() async {
    if (_key.currentState?.validate() != true) return;
    final result = await context.read<BrandFormCubit>().save(
      id: widget.brand?.id,
      draft: BrandDraft(
        name: _name.text.trim(),
        slug: _slug.text.trim(),
        logo: _logo.text.trim().isEmpty ? null : _logo.text.trim(),
        description: _description.text.trim().isEmpty
            ? null
            : _description.text.trim(),
      ),
    );
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _failure = failure is BrandDuplicateFailure
            ? BrandsKeys.duplicateError
            : failure.messageKey;
      }),
      (_) => Navigator.of(context).pop(true),
    );
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<BrandFormCubit, BrandFormState>(
        builder: (context, formState) =>
            BlocBuilder<BrandLogoUploadCubit, BrandLogoUploadState>(
              builder: (context, logoState) {
                final busy = formState is BrandFormSaving ||
                    logoState is BrandLogoUploading;
                return AppFormDialog(
                  titleKey: widget.brand == null
                      ? BrandsKeys.add
                      : BrandsKeys.edit,
                  subtitleKey: BrandsKeys.editorSubtitle,
                  saveLabelKey: BrandsKeys.save,
                  cancelLabelKey: BrandsKeys.cancel,
                  busy: busy,
                  saveEnabled: !busy,
                  dirty: _dirty,
                  errorKey: _failure,
                  onSave: _save,
                  child: Form(
                    key: _key,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        BrandIdentitySection(
                          name: _name,
                          slug: _slug,
                          onNameChanged: (value) {
                            if (_slug.text.isEmpty) {
                              _slug.text = _slugify(value);
                            }
                          },
                        ),
                        BrandLogoSection(logo: _logo, brandName: _name),
                        BrandDetailsSection(description: _description),
                      ],
                    ),
                  ),
                );
              },
            ),
      );
}
