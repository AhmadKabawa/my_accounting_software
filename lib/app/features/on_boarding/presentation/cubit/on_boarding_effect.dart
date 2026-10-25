import 'package:freezed_annotation/freezed_annotation.dart';

part 'on_boarding_effect.freezed.dart';

@freezed
class OnBoardingEffect with _$OnBoardingEffect {
  const factory OnBoardingEffect.navigateHome() = NavigateToHome;
}