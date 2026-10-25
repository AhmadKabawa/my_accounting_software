// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';

// import 'package:accounting_software/app/core/foundation/constants/image_constants.dart';
// import 'package:accounting_software/app/core/foundation/localization/translations/app_strings.dart';
// import 'package:accounting_software/app/core/presentation/responsive/engine/app_enums.dart';
// import 'package:accounting_software/app/core/presentation/theme/logic/theme_extension.dart';

// class LoginHeaderSection extends StatelessWidget {
//   const LoginHeaderSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Image(
//           height: MediaQuery.of(context).size.height * 0.25,
//           image: AssetImage(
//             context.themeValue(
//               dark: AppImages.lightAppLogo,
//               light: AppImages.darkAppLogo,
//             ),
//           ),
//         ),
//         Text(
//           AppStrings.loginTitle.tr(),
//           style: context.textTheme.headlineMedium,
//         ),
//         SizedBox(height: AppSpacing.sm.value),
//         Text(
//           AppStrings.loginSubTitle.tr(),
//           style: context.textTheme.bodyMedium,
//         ),
//       ],
//     );
//   }
// }
