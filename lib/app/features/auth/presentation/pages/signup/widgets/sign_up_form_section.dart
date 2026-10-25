// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:accounting_software/app/core/foundation/localization/translations/app_strings.dart';
// import 'package:accounting_software/app/core/foundation/validator/form_validator.dart';
// import 'package:accounting_software/app/core/utils/helper/app_message_helpers.dart';
// import 'package:accounting_software/app/features/auth/presentation/cubit/auth_cubit.dart';

// class SignUpFormSection extends StatefulWidget {
//   const SignUpFormSection({super.key});

//   @override
//   State<SignUpFormSection> createState() => _SignUpFormSectionState();
// }

// class _SignUpFormSectionState extends State<SignUpFormSection> {
//   final _formKey = GlobalKey<FormState>();
//   bool _obscurePassword = true;
//   bool _obscureConfirmPassword = true;

//   final TextEditingController _firstNameController = TextEditingController();
//   final TextEditingController _lastNameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController =
//       TextEditingController();

//   @override
//   void dispose() {
//     _firstNameController.dispose();
//     _lastNameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   void _handleRegistration() {
//     if (_formKey.currentState!.validate()) {
//       context.read<AuthCubit>().signUpWithEmailEvent(
//         email: _emailController.text.trim().toLowerCase(),
//         password: _passwordController.text.trim(),
//         fullName:
//             '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
//         phone: _phoneController.text.trim().isEmpty
//             ? null
//             : _phoneController.text.trim(),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: _formKey,
//       child: Column(
//         children: [
//           // First Name & Last Name Row
//           Row(
//             children: [
//               Expanded(
//                 child: TextFormField(
//                   controller: _firstNameController,
//                   validator: (value) {
//                     return AppValidator.validate(value, [
//                       ValidationRule.required,
//                     ]);
//                   },
//                   decoration: InputDecoration(
//                     prefixIcon: const Icon(Iconsax.user),
//                     labelText: FieldKeys.firstName.tr(),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: TextFormField(
//                   controller: _lastNameController,
//                   validator: (value) {
//                     return AppValidator.validate(value, [
//                       ValidationRule.required,
//                     ]);
//                   },
//                   decoration: InputDecoration(
//                     prefixIcon: const Icon(Iconsax.user),
//                     labelText: FieldKeys.lastName.tr(),
//                   ),
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 16),

//           // Email Field
//           TextFormField(
//             keyboardType: TextInputType.emailAddress,
//             controller: _emailController,
//             validator: (value) {
//               return AppValidator.validate(value, [
//                 ValidationRule.required,
//                 ValidationRule.email,
//               ]);
//             },
//             decoration: InputDecoration(
//               prefixIcon: const Icon(Iconsax.direct),
//               labelText: FieldKeys.email.tr(),
//             ),
//           ),

//           const SizedBox(height: 16),

//           // Phone Field (Optional)
//           TextFormField(
//             keyboardType: TextInputType.phone,
//             controller: _phoneController,
//             validator: (value) {
//               if (value != null && value.isNotEmpty) {
//                 return AppValidator.validate(value, [ValidationRule.phone]);
//               }
//               return null;
//             },
//             decoration: InputDecoration(
//               prefixIcon: const Icon(Iconsax.call),
//               labelText:
//                   '${FieldKeys.phone.tr()} (${CommonKeys.optional.tr()})',
//             ),
//           ),

//           const SizedBox(height: 16),

//           // Password Field
//           TextFormField(
//             keyboardType: TextInputType.visiblePassword,
//             controller: _passwordController,
//             validator: (value) {
//               return AppValidator.validate(value, [
//                 ValidationRule.required,
//                 ValidationRule.password,
//               ]);
//             },
//             obscureText: _obscurePassword,
//             decoration: InputDecoration(
//               prefixIcon: const Icon(Iconsax.password_check),
//               suffixIcon: IconButton(
//                 icon: Icon(_obscurePassword ? Iconsax.eye_slash : Iconsax.eye),
//                 onPressed: () {
//                   setState(() {
//                     _obscurePassword = !_obscurePassword;
//                   });
//                 },
//               ),
//               labelText: FieldKeys.password.tr(),
//             ),
//           ),

//           const SizedBox(height: 16),

//           // Confirm Password Field
//           TextFormField(
//             keyboardType: TextInputType.visiblePassword,
//             controller: _confirmPasswordController,
//             validator: (value) {
//               return AppValidator.validate(
//                 value,
//                 [ValidationRule.required],
//                 params: {ValidationRule.match: _passwordController.text},
//               );
//             },
//             obscureText: _obscureConfirmPassword,
//             decoration: InputDecoration(
//               prefixIcon: const Icon(Iconsax.password_check),
//               suffixIcon: IconButton(
//                 icon: Icon(
//                   _obscureConfirmPassword ? Iconsax.eye_slash : Iconsax.eye,
//                 ),
//                 onPressed: () {
//                   setState(() {
//                     _obscureConfirmPassword = !_obscureConfirmPassword;
//                   });
//                 },
//               ),
//               labelText: FieldKeys.confirmPassword.tr(),
//             ),
//           ),

//           const SizedBox(height: 16),

//           // Create Account Button
//           SizedBox(
//             width: double.infinity,
//             child: BlocBuilder<AuthCubit, AuthState>(
//               builder: (context, state) {
//                 return ElevatedButton(
//                   onPressed: state is AuthLoading
//                       ? null
//                       : () {
//                           AppMessageHelper.hideKeyboard();
//                           _handleRegistration();
//                         },
//                   child: state is AuthLoading
//                       ? Text(CommonKeys.loading.tr())
//                       : Text(AuthKeys.createAccount.tr()),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
