 import 'package:freezed_annotation/freezed_annotation.dart';
part 'splash_state.freezed.dart';
@freezed
 sealed  class SplashState with _$SplashState {
 

  const SplashState._();
   const factory SplashState.initial() = SplashInitial;
  const factory SplashState.loading() = SplashLoading;
  const factory SplashState.done() = SplashDone;

 
}

 