import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/localization/categories_keys.dart';

class CategoriesFlatResultsNote extends StatelessWidget {
  const CategoriesFlatResultsNote({super.key});

  @override
  Widget build(BuildContext context) => const InlineBanner(
    messageKey: CategoriesKeys.flatResultsNote,
    variant: InlineBannerVariant.info,
  );
}
