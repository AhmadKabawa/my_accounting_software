import 'package:accounting_software/app/core/foundation/constants/image_constants.dart';
import 'package:accounting_software/app/core/foundation/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/foundation/localization/translations/app_keys.dart';

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
    title: AppKeys.onBoarding.title1,
    description: AppKeys.onBoarding.subTitle1,
    image: AppPathImages.onBoardingImage1,
  ),
  OnBoardingModel(
    title: AppKeys.onBoarding.title2,
    description: AppKeys.onBoarding.subTitle2,
    image: AppPathImages.onBoardingImage2,
  ),
  OnBoardingModel(
    title: AppKeys.onBoarding.title3,
    description: AppKeys.onBoarding.subTitle3,
    image: AppPathImages.onBoardingImage3,
  ),
];
