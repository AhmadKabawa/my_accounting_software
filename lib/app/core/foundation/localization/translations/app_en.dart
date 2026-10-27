/// lib/core/localization/translations/en_US.dart

import 'package:accounting_software/app/core/foundation/localization/translations/app_keys.dart'
    show AppKeys;
import 'package:accounting_software/app/core/foundation/localization/translations/app_key.dart';

/// يجمع كل الترجمات الإنجليزية
final TranslationMap enUS = {
  ..._enAuth,
  ..._enFields,
  ..._enValidation,
  ..._enErrors,
  ..._enServerErrors,
  ..._enCommon,
  ..._enProfile,
  ..._enSuccess,
  ..._enOnBoarding,
  AppKeys.home: "home",
  AppKeys.chat: "chat",
  AppKeys.favorite: "favorite",
  AppKeys.person: "person",
};
/*
const Map<String, String> enUS = {
  ...enCommon,
  ...enValidation,
  ...enErrors,
  ...enServerErrors,
  ...enAuth,
  ...enFields,
  ...enProfile,
  ...enSuccess,
 
  // GLOBAL
  AppStrings.and: "and",
  AppStrings.skip: "Skip",
  AppStrings.done: "Done",
  AppStrings.submit: "Submit",
  AppStrings.appName: "T-Store",
  AppStrings.tContinue: "Continue",
  AppStrings.viewAll: "View All",
  AppStrings.account: "Account",

  // OnBoarding
  AppStrings.onBoardingTitle1: "Choose your product",
  AppStrings.onBoardingTitle2: "Select Payment Method",
  AppStrings.onBoardingTitle3: "Deliver at your door step",

  AppStrings.onBoardingSubTitle1:
      "Welcome to a World of Limitless Choices - Your Perfect Product Awaits!",
  AppStrings.onBoardingSubTitle2:
      "For Seamless Transactions, Choose Your Payment Path - Your Convenience, Our Priority!",
  AppStrings.onBoardingSubTitle3:
      "From Our Doorstep to Yours - Swift, Secure, and Contactless Delivery!",

  // Authentication Headings
  AppStrings.loginTitle: "Welcome back,",
  AppStrings.loginSubTitle:
      "Discover Limitless Choices and Unmatched Convenience.",
  AppStrings.signUpTitle: "Let's create your account",
  AppStrings.forgetPasswordTitle: "Forget password",
  AppStrings.forgetPasswordSubTitle:
      "Don't worry sometimes people can forget too, enter your email and we will send you a password reset link.",
  AppStrings.changeYourPasswordTitle: "Password Reset Email Sent",
  AppStrings.changeYourPasswordSubTitle:
      "Your Account Security is Our Priority! We've Sent You a Secure Link to Safely Change Your Password and Keep Your Account Protected.",
  AppStrings.confirmEmailTitle: "Verify your email address!",
  AppStrings.confirmEmail: "hmdy7486@gmail.com",
  AppStrings.confirmEmailSubTitle:
      "Congratulations! Your Account Awaits: Verify Your Email to Start Shopping and Experience a World of Unrivaled Deals and Personalized Offers.",
  };

 */
final TranslationMap _enAuth = {
  AppKeys.auth.rememberMe: "Remember me",
  AppKeys.auth.forgotPassword: "Forgot password?",
  AppKeys.auth.signIn: "Sign In",
  AppKeys.auth.createAccount: "Create Account",
  AppKeys.auth.sendMessage: "Send message to email",
  AppKeys.auth.continueGoogle: "Continue with Google",
  AppKeys.auth.orSignInWith: "Or sign in with",
  AppKeys.auth.orSignUpWith: "Or sign up with",
  AppKeys.auth.forgetPassword: "Forget password",
  AppKeys.auth.resendEmail: "Resend email",
  AppKeys.auth.registerTitle: "Create new account",
  AppKeys.auth.registerSubtitle: "Enter your details to get started",
};

final TranslationMap _enCommon = {
  AppKeys.common.retry: "Retry",
  AppKeys.common.cancel: "Cancel",
  AppKeys.common.confirm: "Confirm",
  AppKeys.common.save: "Save",
  AppKeys.common.loading: "Loading...",
  AppKeys.common.success: "Success",
  AppKeys.common.unknownError: "An unexpected error occurred",
  AppKeys.common.optional: "Optional",
};
final TranslationMap _enValidation = {
  AppKeys.valid.required: "This field is required",
  AppKeys.valid.emailRequired: "Email is required",
  AppKeys.valid.emailInvalid: "Invalid email address",
  AppKeys.valid.passwordRequired: "Password is required",
  AppKeys.valid.passwordMinLength:
      "Password must be at least @length characters",
  AppKeys.valid.passwordNeedsUpper:
      "Must contain at least one uppercase letter",
  AppKeys.valid.passwordNeedsNumber: "Must contain at least one number",
  AppKeys.valid.passwordNeedsSpecial:
      "Must contain at least one special character",
  AppKeys.valid.passwordsNotMatch: "Passwords do not match",
  AppKeys.valid.nameRequired: "Name is required",
  AppKeys.valid.nameMinLength: "Name must be at least @length characters",
  AppKeys.valid.phoneInvalid: "Invalid phone number",
  AppKeys.valid.fieldMinLength: "Must be at least @length characters",
  AppKeys.valid.fieldMaxLength: "Must not exceed @length characters",
};
final TranslationMap _enErrors = {
  AppKeys.errors.network: "No internet connection",
  AppKeys.errors.timeout: "Request timeout, please try again",
  AppKeys.errors.server: "Server error, please try again",
  AppKeys.errors.unauthorized: "Your session has expired, please login again",
  AppKeys.errors.forbidden: "You don't have permission for this action",
  AppKeys.errors.notFound: "Requested resource not found",
  AppKeys.errors.validation: "Please check your input",
  AppKeys.errors.cache: "Cache error",
  AppKeys.errors.permission: "You don't have permission for this action",
  AppKeys.errors.unexpected: "An unexpected error occurred",
  AppKeys.errors.cancelled: "Operation cancelled",
  AppKeys.errors.googleSignIn: "Google sign in failed",
  AppKeys.errors.badRequest: "Bad request",
  AppKeys.errors.conflict: "Data conflict",
  AppKeys.errors.serviceUnavailable: "Service unavailable",
  AppKeys.errors.unknown: "Unknown error",
};
final TranslationMap _enServerErrors = {
  AppKeys.server.emailAlreadyExists: "Email already exists",
  AppKeys.server.emailNotFound: "Email not found",
  AppKeys.server.invalidCredentials: "Invalid email or password",
  AppKeys.server.accountDisabled: "Account disabled, contact support",
  AppKeys.server.tooManyAttempts: "Too many attempts, try again later",
  AppKeys.server.passwordIncorrect: "Current password is incorrect",
  AppKeys.server.tokenExpired: "Reset link has expired",
  AppKeys.server.tokenInvalid: "Invalid reset link",
  AppKeys.server.userNotFound: "User not found",
  AppKeys.server.phoneAlreadyExists: "Phone number already exists",
  AppKeys.server.unauthenticated: "Please login",
  AppKeys.server.unverifiedEmail: "Please verify your email first",
};

final TranslationMap _enFields = {
  AppKeys.fields.email: "Email",
  AppKeys.fields.firstName: "First name",
  AppKeys.fields.lastName: "Last name",
  AppKeys.fields.password: "Password",
  AppKeys.fields.confirmPassword: "Confirm password",
  AppKeys.fields.fullName: "Full name",
  AppKeys.fields.phone: "Phone number",
  AppKeys.fields.bio: "Bio",
  AppKeys.fields.currentPassword: "Current password",
  AppKeys.fields.newPassword: "New password",
};

final TranslationMap _enProfile = {
  AppKeys.profile.title: "Profile",
  AppKeys.profile.edit: "Edit profile",
  AppKeys.profile.saveChanges: "Save changes",
  AppKeys.profile.changePassword: "Change password",
  AppKeys.profile.updateButton: "Update",
  AppKeys.profile.userNumber: "User #@number",
};

final TranslationMap _enOnBoarding = {
  AppKeys.onBoarding.title1: "Choose your product",
  AppKeys.onBoarding.title2: "Select Payment Method",
  AppKeys.onBoarding.title3: "Deliver at your door step",
  AppKeys.onBoarding.subTitle1:
      "Welcome to a World of Limitless Choices - Your Perfect Product Awaits!",
  AppKeys.onBoarding.subTitle2:
      "For Seamless Transactions, Choose Your Payment Path - Your Convenience, Our Priority!",
  AppKeys.onBoarding.subTitle3:
      "From Our Doorstep to Yours - Swift, Secure, and Contactless Delivery!",
};

final TranslationMap _enSuccess = {
  AppKeys.success.signin: "Successfully signed in",
  AppKeys.success.signup: "Account created successfully",
  AppKeys.success.signout: "Successfully signed out",
  AppKeys.success.sendMessageToEmail: "We've sent you a message to your email",
};
