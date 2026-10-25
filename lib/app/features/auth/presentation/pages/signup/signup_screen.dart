import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
 
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    /*  appBar: AppBar(),
      body: SafeArea(
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            switch (state) {
              case Authenticated():
                context.pushReplacementNamed(AppRoutes.navigation);
              default:
            }
          },
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
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AuthKeys.registerSubtitle.tr(),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 32),
                    SignUpFormSection(),
                    const SizedBox(height: 32),
                    DividerWidget(text: AuthKeys.orSignUpWith.tr()),
                    SignMethodsSection(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
 */   );
  }
}
