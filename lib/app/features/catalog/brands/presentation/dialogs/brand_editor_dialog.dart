import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/bloc_effect_listener.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_form_dialog/app_form_dialog.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_draft.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/utility/brand_slug_from.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brand_form/brand_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brand_form/brand_form_effect.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brand_logo_upload/brand_logo_upload_cubit.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brand_logo_upload/brand_logo_upload_state.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/sections/brand_details_section.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/sections/brand_identity_section.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/sections/brand_logo_section.dart';

/// Opens the shared brand editor and owns the form/upload Cubit lifetimes.
Future<bool?> showBrandEditor(BuildContext context, {Brand? brand}) =>
    showAppFormDialog<bool>(
      context,
      (_) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => sl<BrandFormCubit>()),
          BlocProvider(create: (_) => sl<BrandLogoUploadCubit>()),
        ],
        child: BrandEditorDialog(brand: brand),
      ),
    );

/// Add/edit dialog for one brand.
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
  bool _slugTouched = false;
  bool _settingSlug = false;

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
    _slugTouched = brand != null;
    _name = TextEditingController(text: _initialName);
    _slug = TextEditingController(text: _initialSlug);
    _logo = TextEditingController(text: _initialLogo);
    _description = TextEditingController(text: _initialDescription);
    _name.addListener(_onChanged);
    _slug.addListener(_onChanged);
    _logo.addListener(_onChanged);
    _description.addListener(_onChanged);
  }

  void _onChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _onNameChanged(String value) {
    if (!mounted) return;
    setState(() => _failure = null);
    if (widget.brand == null && !_slugTouched) {
      _setSlug(brandSlugFrom(value));
    }
  }

  void _onSlugChanged(String value) {
    if (_settingSlug || _slugTouched || !mounted) return;
    setState(() => _slugTouched = true);
  }

  void _setSlug(String value) {
    _settingSlug = true;
    _slug.text = value;
    _settingSlug = false;
  }

  void _regenerateSlug() {
    final generated = brandSlugFrom(_name.text);
    if (generated.isEmpty) return;
    setState(() => _slugTouched = false);
    _setSlug(generated);
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

  Future<void> _save() async {
    if (_key.currentState?.validate() != true) return;
    await context.read<BrandFormCubit>().save(
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
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<BrandFormCubit, BrandFormStatus>(
        builder: (context, formStatus) =>
            BlocBuilder<BrandLogoUploadCubit, BrandLogoUploadState>(
              builder: (context, logoState) {
                final busy =
                    formStatus == BrandFormStatus.saving || logoState.isBusy;

                return BlocEffectListener<BrandFormEffect, BrandFormCubit>(
                  onEffect: (context, effect) {
                    switch (effect) {
                      case BrandSavedEffect():
                        Navigator.of(context).pop(true);
                      case BrandSaveFailedEffect(:final messageKey):
                        setState(() => _failure = messageKey);
                    }
                  },
                  child: AppFormDialog(
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
                            onNameChanged: _onNameChanged,
                            onSlugChanged: _onSlugChanged,
                            showSlugHint:
                                _name.text.trim().isNotEmpty &&
                                brandSlugFrom(_name.text).isEmpty,
                            onRegenerateSlug:
                                _slugTouched &&
                                    brandSlugFrom(_name.text).isNotEmpty
                                ? _regenerateSlug
                                : null,
                          ),
                          BrandLogoSection(logo: _logo, brandName: _name),
                          BrandDetailsSection(description: _description),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      );
}
