// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:accounting_software/app/core/foundation/localization/translations/localization_extension.dart';

// import 'package:accounting_software/app/features/on_boarding/presentation/cubit/on_boarding_cubit.dart';

// class OnBoardingNextButton extends StatelessWidget {
//   final PageController pageController;
//   const OnBoardingNextButton({super.key, required this.pageController});
//   @override
//   Widget build(BuildContext context) {
//     // final state = context.watch<OnBoardingCubit>().state;

//     return PositionedDirectional(
//       bottom: 56 + 25,
//       end: 24,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(shape: const CircleBorder()),
//         onPressed: (() {
//           context.read<OnBoardingCubit>().nextPage();

//           // pageController.jumpToPage(state.currentIndexPage + 1);
//           pageController.nextPage(
//             duration: Duration(milliseconds: 400),
//             curve: Curves.ease,
//           );
//           //  emit(OnBoardingChanged(index));
//         }),
//         child: Row(
//           children: [
//             Icon(
//               context.directionalIcon(rtl: Iconsax.previous, ltr: Iconsax.next),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
