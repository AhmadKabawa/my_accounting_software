import 'package:equatable/equatable.dart';

/// A single data state (the page being shown), so it is one Equatable class
/// rather than a sealed hierarchy.
final class OnBoardingState extends Equatable {
  const OnBoardingState({this.currentIndexPage = 0});

  final int currentIndexPage;

  OnBoardingState copyWith({int? currentIndexPage}) =>
      OnBoardingState(currentIndexPage: currentIndexPage ?? this.currentIndexPage);

  @override
  List<Object?> get props => [currentIndexPage];
}
