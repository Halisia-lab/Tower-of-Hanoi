import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:hanoi_tower/main.dart';
import 'package:hanoi_tower/screens/levels_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        body: AnimatedSplashScreen.withScreenFunction(
         backgroundColor: const Color.fromARGB(255, 240, 233, 207),
          splash: 'assets/images/splash_screen.png',
          screenFunction: () async {
            return const LevelsScreen();
          },
          splashTransition: SplashTransition.scaleTransition,
          splashIconSize: 400,
        ),
      ),
    );
  }
}
