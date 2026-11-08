/// One-time signals from the cubit to the screen.
sealed class OnBoardingEffect {
  const OnBoardingEffect();
}

final class NavigateToHome extends OnBoardingEffect {
  const NavigateToHome();
}
