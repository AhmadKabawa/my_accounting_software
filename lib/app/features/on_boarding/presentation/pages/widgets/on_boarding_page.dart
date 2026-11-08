import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:accounting_software/app/features/on_boarding/data/model/on_boarding_model.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({super.key, required this.onBoardingModel});
  final OnBoardingModel onBoardingModel;

  @override
  Widget build(BuildContext context) {
    final gap = context.ui.spacing.gap(AppSpacing.md, axis: Axis.vertical);
    return Padding(
      padding: context.ui.padding.all(AppSpacing.lg),
      child: Column(
        children: [
          // The image takes the space the page has, instead of a fixed size.
          Expanded(
            child: Image(
              fit: BoxFit.contain,
              image: AssetImage(onBoardingModel.image),
            ),
          ),
          AppText(
            onBoardingModel.title,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          gap,
          AppText(
            onBoardingModel.description,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
