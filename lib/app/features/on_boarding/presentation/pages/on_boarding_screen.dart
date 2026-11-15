import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/features/on_boarding/presentation/cubit/on_boarding_cubit.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("on boarding"),
            ElevatedButton(
              onPressed: () {
                context.read<OnBoardingCubit>().nextPage();
              },
              child: Text("next"),
            ),
          ],
        ),
      ),
    );
  }
}

/*
class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  late final PageController pageController;
  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //  final onBoardingCubit = context.read<OnBoardingCubit>();

    return Scaffold(
      body:
          BlocEffectListener<
            OnBoardingCubit,
            OnBoardingState,
            OnBoardingEffect
          >(
            onEffect: (context, effect) => switch (effect) {
              NavigateToHome() => context.pushNamed(AuthRoutes.login.name),
            },

            child: Stack(
              children: [
                PageView.builder(
                  itemCount: onboardingData.length,
                  controller: pageController,
                  onPageChanged: (index) {
                    context.read<OnBoardingCubit>().changePage(index);
                  },
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) =>
                      OnBoardingPage(onBoardingModel: onboardingData[index]),
                ),

                OnBoardingSkipButton(pageController: pageController),
                OnBoardingDotNavigation(pageController: pageController),
                OnBoardingNextButton(pageController: pageController),
              ],
            ),
          ),
    );
  }
}

      // BlocConsumer<OnBoardingCubit, OnBoardingState>(
      // listener: (context, state) => state is OnBoardingFinished
      //     ? Navigator.of(context).pushNamed(AuthRoutes.login.name)
      //     : null,
      // builder: (context, state) {}
*/
