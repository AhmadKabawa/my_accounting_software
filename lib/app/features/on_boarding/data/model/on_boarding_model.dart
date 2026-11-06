import 'package:accounting_software/app/core/foundation/constants/image_constants.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/features/on_boarding/presentation/localization/onboarding_keys.dart';

class OnBoardingModel {
  final AppKey title;
  final AppKey description;
  final String image;

  OnBoardingModel({
    required this.title,
    required this.description,
    required this.image,
  });
}

final List<OnBoardingModel> onboardingData = [
  OnBoardingModel(
    title: OnboardingKeys.title1,
    description: OnboardingKeys.subTitle1,
    image: AppPathImages.onBoardingImage1,
  ),
  OnBoardingModel(
    title: OnboardingKeys.title2,
    description: OnboardingKeys.subTitle2,
    image: AppPathImages.onBoardingImage2,
  ),
  OnBoardingModel(
    title: OnboardingKeys.title3,
    description: OnboardingKeys.subTitle3,
    image: AppPathImages.onBoardingImage3,
  ),
];
