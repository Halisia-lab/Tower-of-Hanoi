import 'dart:core';

import 'package:hanoi_tower/screens/game_screen.dart';

import 'firebase_options.dart';

import 'package:flutter/material.dart';
import 'package:hanoi_tower/screens/levels_screen.dart';
import 'package:hanoi_tower/screens/splash_screen.dart';
import 'package:hanoi_tower/services/firestore_service.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await getOrCreateUserId().then((id) => {
        checkAndInitializeLevel("levels", "1", {
          'attempts': 0,
          'time': 0,
          'level': 1,
        })
      });
}

void main() async {
  initializeApp();

  runApp(MaterialApp(
    initialRoute: '/splash',
    routes: {
      '/splash': (context) => const SplashScreen(),
      '/levels': (context) => const LevelsScreen(),
      '/home': (context) => MyApp(),
    },
  ));
}

class MyApp extends StatelessWidget {
 // int level = 1;
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      home: GameScreen(title: 'Tower of Hanoi', level: 1),
    );
  }
}
