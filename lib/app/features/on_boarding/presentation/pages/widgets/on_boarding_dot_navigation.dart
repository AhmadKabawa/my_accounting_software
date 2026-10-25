// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:accounting_software/app/features/on_boarding/presentation/cubit/on_boarding_cubit.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// class OnBoardingDotNavigation extends StatelessWidget {
//   final PageController pageController;
//   const OnBoardingDotNavigation({super.key, required this.pageController});
//   @override
//   Widget build(BuildContext context) {
//     // final dark = THelperFunctions.isDarkMode(context);

//     return PositionedDirectional(
//       bottom: 56.0 + 25,
//       start: 24.0,
//       child: SmoothPageIndicator(
//         controller: pageController,
//         count: 3,
//         axisDirection: Axis.horizontal,
//         onDotClicked: (index) {
//           context.read<OnBoardingCubit>().changePage(index);
//           pageController.animateToPage(
//             index,
//             duration: Duration(milliseconds: 400),
//             curve: Curves.ease,
//           );
//         },
//         effect: ExpandingDotsEffect(
//           dotHeight: 6,
//           dotColor: Theme.of(context).colorScheme.primary.withAlpha(125),
//           activeDotColor: Theme.of(context).colorScheme.primary,
//         ),
//       ),
//     );
//   }
// }
