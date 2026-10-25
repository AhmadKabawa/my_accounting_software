// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:accounting_software/app/core/foundation/constants/image_constants.dart';
// import 'package:accounting_software/app/core/foundation/localization/translations/app_strings.dart';
// import 'package:accounting_software/app/core/routing/navigator_extensions.dart';
// import 'package:accounting_software/app/core/routing/routes.dart';
// import 'package:accounting_software/app/core/presentation/responsive/responsive_helper.dart';

// class VerifyEmailView extends StatelessWidget {
//   const VerifyEmailView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         actions: [
//           IconButton(
//             onPressed: () {
//               context.pushReplacementNamed(AppRoutes.login);
//             },
//             icon: const Icon(CupertinoIcons.clear),
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           child: Padding(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               children: [
//                 Image(
//                   width: MediaQuery.of(context).size.width * 0.6,
//                   image: const AssetImage(AppImages.deliveredEmailIllustration),
//                 ),
//                 const SizedBox(height: 32),
//                 Text(
//                   AppStrings.confirmEmailTitle,
//                   style: Theme.of(context).textTheme.headlineMedium,
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   AppStrings.confirmEmail,
//                   style: Theme.of(context).textTheme.labelLarge,
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   AppStrings.confirmEmailSubTitle,
//                   style: Theme.of(context).textTheme.labelMedium,
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 32),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       // context.pushReplacementNamed(
//                       //   AppRoutes.emailVerifiedSuccessfully,
//                       // );
//                     },
//                     child: const Text(AppStrings.tContinue),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 SizedBox(
//                   width: double.infinity,
//                   child: TextButton(
//                     onPressed: () {},
//                     child: Text(AuthKeys.resendEmail.tr()),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
