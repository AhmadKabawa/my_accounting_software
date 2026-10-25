import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
 
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
   /*   body: SafeArea(
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            switch (state) {
              case Authenticated():
                context.pushReplacementNamed(AppRoutes.navigation);
              default:
            }
          },
          child: Center(
            child: BlocEffectListener<AuthCubit, AuthState, AuthEffect>(
              onEffect: (context, effect) {
                switch (effect) {
                  case ShowErrorMessage(:final message):
                    AppMessageHelper.showMessage(
                      context,
                      message: message.tr(),
                      type: MessageType.error,
                    );

                  case ShowSuccessMessage(:final message):
                    AppMessageHelper.showMessage(
                      context,
                      message: message.tr(),
                      type: MessageType.success,
                    );

                  case NavigateToForgotPassword():
                    context.pushNamed(AppRoutes.forgotPassword);
                }
              },
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const LoginHeaderSection(),
                      const LoginFormSection(),
                      DividerWidget(text: AuthKeys.orSignInWith.tr()),
                      const SizedBox(height: 16),
                      const SignMethodsSection(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),*/
    );
  }
}
