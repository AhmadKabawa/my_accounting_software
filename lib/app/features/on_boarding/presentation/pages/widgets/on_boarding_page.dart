import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:accounting_software/app/features/on_boarding/data/model/on_boarding_model.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({super.key, required this.onBoardingModel});
  final OnBoardingModel onBoardingModel;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Image(
            width: 400 * .8,
            height: 800 * .6,
            image: AssetImage(onBoardingModel.image),
          ),
          Text(
            onBoardingModel.title.tr(),
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),
          Text(
            onBoardingModel.description.tr(),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
