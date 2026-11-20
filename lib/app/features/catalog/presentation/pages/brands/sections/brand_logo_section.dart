import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/features/catalog/presentation/cubit/brand_logo_upload_cubit.dart';
import 'package:accounting_software/app/features/catalog/presentation/localization/brands_keys.dart';
import 'package:accounting_software/app/features/catalog/presentation/pages/brands/widgets/brand_field_validators.dart';
import 'package:accounting_software/app/features/catalog/presentation/pages/brands/widgets/brand_logo.dart';

/// Editor section: logo preview, upload button, and the URL field.
///
/// Uploading stores the file in Storage and writes its public URL into
/// [logo], so the saved value is always a URL (`brands.logo`).
class BrandLogoSection extends StatelessWidget {
  const BrandLogoSection({super.key, required this.logo, required this.brandName});

  final TextEditingController logo;
  final TextEditingController brandName;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<BrandLogoUploadCubit>(),
    child: BlocConsumer<BrandLogoUploadCubit, BrandLogoUploadState>(
      listener: (context, state) {
        if (state is BrandLogoUploaded) logo.text = state.url;
      },
      builder: (context, state) {
        final uploading = state is BrandLogoUploading;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppText(BrandsKeys.logoSection, type: AppTextType.titleSmall),
            context.ui.spacing.gap(AppSpacing.sm),
            if (state is BrandLogoUploadFailed) ...[
              InlineBanner(
                messageKey: state.messageKey,
                variant: InlineBannerVariant.error,
              ),
              context.ui.spacing.gap(AppSpacing.sm),
            ],
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: logo,
              builder: (context, value, _) => Row(
                children: [
                  BrandLogoImage(url: value.text, label: brandName.text),
                  context.ui.spacing.gap(AppSpacing.smMd, axis: Axis.horizontal),
                  Expanded(
                    child: Wrap(
                      spacing: context.ui.spacing.sm,
                      runSpacing: context.ui.spacing.sm,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        AppButton(
                          value.text.trim().isEmpty
                              ? BrandsKeys.uploadLogo
                              : BrandsKeys.replaceLogo,
                          variant: AppButtonVariant.outlined,
                          size: AppButtonSize.small,
                          icon: AppIcons.upload,
                          isLoading: uploading,
                          onPressed: uploading
                              ? null
                              : context.read<BrandLogoUploadCubit>().pickAndUpload,
                        ),
                        if (value.text.trim().isNotEmpty)
                          AppIconButton(
                            AppIcons.delete,
                            tooltipKey: BrandsKeys.removeLogo,
                            onPressed: uploading ? null : logo.clear,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            context.ui.spacing.gap(AppSpacing.sm),
            AppTextField(
              controller: logo,
              labelKey: BrandsKeys.logo,
              hintKey: BrandsKeys.logoHint,
              keyboardType: TextInputType.url,
              validator: (v) => BrandFieldValidators.logo(context, v),
            ),
          ],
        );
      },
    ),
  );
}
