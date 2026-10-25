import 'package:freezed_annotation/freezed_annotation.dart';

part   'on_boarding_state.freezed.dart';

@freezed
sealed class OnBoardingState with _$OnBoardingState  {
 

  const factory  OnBoardingState( { @Default(0) int currentIndexPage})= _OnBoardingState;
factory OnBoardingState.initial() => const OnBoardingState(currentIndexPage:   0);
 
}

 
 
