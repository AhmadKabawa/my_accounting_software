// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:accounting_software/app/core/foundation/localization/translations/app_strings.dart';
// import 'package:accounting_software/app/core/routing/navigator_extensions.dart';
// import 'package:accounting_software/app/core/routing/routes.dart';
// import 'package:accounting_software/app/core/utils/helper/app_message_helpers.dart';
// import 'package:accounting_software/app/core/foundation/validator/form_validator.dart';
// import 'package:accounting_software/app/features/auth/presentation/cubit/auth_cubit.dart';
// import 'package:accounting_software/app/features/auth/presentation/pages/login/widgets/customCheck_box.dart';

// class LoginFormSection extends StatefulWidget {
//   const LoginFormSection({super.key});

//   @override
//   State<LoginFormSection> createState() => _LoginFormSectionState();
// }

// class _LoginFormSectionState extends State<LoginFormSection> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _rememberMe = true;
//   bool _obscurePassword = true;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   void _handleLogin() {
//     if (_formKey.currentState!.validate()) {
//       context.read<AuthCubit>().signInWithEmailEvent(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     context.locale;
//     return BlocBuilder<AuthCubit, AuthState>(
//       builder: (context, state) {
//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 32),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 // Email Field
//                 TextFormField(
//                   controller: _emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   decoration: InputDecoration(
//                     prefixIcon: const Icon(Iconsax.direct_right),
//                     labelText: FieldKeys.email.tr(),
//                   ),
//                   validator: (value) {
//                     return AppValidator.validate(value, [
//                       ValidationRule.required,
//                       ValidationRule.email,
//                     ]);
//                   },
//                 ),

//                 const SizedBox(height: 16),

//                 // Password Field
//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: _obscurePassword,
//                   decoration: InputDecoration(
//                     prefixIcon: const Icon(Iconsax.password_check),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _obscurePassword = !_obscurePassword;
//                         });
//                       },
//                     ),
//                     labelText: FieldKeys.password.tr(),
//                   ),
//                   validator: (value) {
//                     return AppValidator.validate(value, [
//                       ValidationRule.required,
//                     ]);
//                   },
//                 ),

//                 const SizedBox(height: 8),

//                 // Remember Me & Forgot Password Row
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     CustomCheckBox(
//                       title: AuthKeys.rememberMe.tr(),
//                       onChanged: (value) {
//                         setState(() {
//                           _rememberMe = value ?? false;
//                         });
//                       },
//                       checkvalue: _rememberMe,
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         context.pushNamed(AppRoutes.forgotPassword);
//                       },
//                       child: Text(AuthKeys.forgotPassword.tr()),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 32),

//                 // Sign In Button
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: state is AuthLoading
//                         ? null
//                         : () {
//                             AppMessageHelper.hideKeyboard();
//                             _handleLogin();
//                           },
//                     child: state is AuthLoading
//                         ? Text(CommonKeys.loading.tr())
//                         : Text(AuthKeys.signIn.tr()),
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 // Create Account Button
//                 SizedBox(
//                   width: double.infinity,
//                   child: OutlinedButton(
//                     onPressed: () {
//                       context.pushNamed(AppRoutes.signup);
//                     },
//                     child: Text(AuthKeys.createAccount.tr()),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
