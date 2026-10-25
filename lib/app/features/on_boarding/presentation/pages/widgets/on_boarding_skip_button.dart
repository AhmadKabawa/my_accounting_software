// import 'package:flutter/material.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:accounting_software/app/core/foundation/localization/translations/app_strings.dart';
// import 'package:accounting_software/app/features/on_boarding/presentation/cubit/on_boarding_cubit.dart';
// import 'package:accounting_software/app/features/on_boarding/data/model/on_boarding_model.dart';

// class OnBoardingSkipButton extends StatelessWidget {
//   final PageController pageController;
//   const OnBoardingSkipButton({super.key, required this.pageController});

//   @override
//   Widget build(BuildContext context) {
//     return PositionedDirectional(
//       top: 56.0,
//       end: 24,
//       child: TextButton(
//         onPressed: () {
//           pageController.animateToPage(
//             onboardingData.length - 1,
//             duration: Duration(milliseconds: 400),
//             curve: Curves.ease,
//           );
//           context.read<OnBoardingCubit>().skipOnboarding();
//         },
//         child: Text(AppStrings.skip.tr()),
//       ),
//     );
//   }
// }
