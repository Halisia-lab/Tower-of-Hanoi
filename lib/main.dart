import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hanoi_tower/screens/levels_screen.dart';
import 'package:hanoi_tower/screens/splash_screen.dart';
import 'package:hanoi_tower/services/firestore_service.dart';
import 'package:hanoi_tower/services/route_service.dart';
import 'package:hanoi_tower/services/sound_service.dart';
import 'dart:math';
import 'dart:core';
import 'components/stick.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  checkAndInitializeLevel('Levels', '1', {
    'attempts': 0,
    'time': 0,
    'level': 1,
  });

  getOrCreateUserId();

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
  int level = 1;

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page', level: level),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title, required this.level});
  final String title;
  int level;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

final stopwatch = Stopwatch();

class _MyHomePageState extends State<MyHomePage> with ChangeNotifier {
  late List<int> leftDiskNumbers =
      List.generate(widget.level + 1, (index) => index + 1, growable: true);
  late int initialDiskNumber = widget.level + 1;
  List<int> middleDiskNumbers = [];
  List<int> rightDiskNumbers = [];
  int counter = 0;
  late num bestCounter = pow(2, widget.level + 1) - 1;
  bool gameStarted = false;
  bool gamePaused = false;

  addDiskWithNumber(int diskNumber, Stick source, Stick destination) {
    setState(() {
      increaseCounter();
      destination.diskNumbers.add(diskNumber);
      destination.diskNumbers.sort((a, b) => a.compareTo(b));
      source.diskNumbers.removeWhere((element) => element == diskNumber);
      playClickSound();
    });
  }

  increaseCounter() {
    setState(() {
      counter++;
    });
  }

  startGame() {
    if (!gameStarted) {
      gameStarted = true;
      stopwatch.start();
    }
  }

  endGame() {
    gameStarted = false;
    stopwatch.stop();
  }

  restart() {
    setState(() {
      gamePaused = false;
      counter = 0;
      stopwatch.reset();
      leftDiskNumbers = List.generate(initialDiskNumber, (index) => index + 1,
          growable: true);
      middleDiskNumbers = [];
      rightDiskNumbers = [];
    });
  }

  pause() {
    setState(() {
      gamePaused = true;
      stopwatch.stop();
    });
  }

  play() {
    setState(() {
      gamePaused = false;
      stopwatch.start();
    });
  }

  underBestCounter() => counter <= bestCounter;

  

  @override
  Widget build(BuildContext context) {
    Stick stick1 = Stick(
      diskNumbers: leftDiskNumbers,
      startGame: startGame,
      onDragEnd: addDiskWithNumber,
      name: "one",
      gamePaused: gamePaused,
    );
    Stick stick2 = Stick(
      diskNumbers: middleDiskNumbers,
      startGame: startGame,
      onDragEnd: addDiskWithNumber,
      name: "two",
      gamePaused: gamePaused,
    );
    Stick stick3 = Stick(
      diskNumbers: rightDiskNumbers,
      startGame: startGame,
      onDragEnd: addDiskWithNumber,
      name: "three",
      gamePaused: gamePaused,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 30,
          ), // Different icon for back button
          onPressed: () {
            Navigator.of(context).push(createRoute());
          },
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 1, 21, 48),
      body: OrientationBuilder(builder: (context, orientation) {
        return Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/city2.jpeg"),
              opacity: 0.7,
              fit: BoxFit.cover,
            ),
          ),
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: orientation == Orientation.portrait
                ? const EdgeInsets.only(bottom: 40.0)
                : const EdgeInsets.only(bottom: 15.0),
            child: Stack(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    stick1,
                    stick2,
                    stick3,
                  ],
                ),
                if (stick3.diskNumbers.length == initialDiskNumber)
                  FutureBuilder(
                      future: underBestCounter()
                          ? makeLevelCompleted(counter, widget.level, stopwatch.elapsed.inSeconds)
                          : makeLevelCompletedWithExtraAttempts(counter, widget.level, stopwatch.elapsed.inSeconds),
                      builder: (context, snapshot) {
                        return underBestCounter()
                            ? AlertDialog(
                                surfaceTintColor: Colors.white,
                                title: const Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 15.0),
                                      child: Image(image: AssetImage("assets/images/gold.png"), width: 30,),
                                    ),
                                    Text(
                                      'YOU WON !',
                                      style: TextStyle(
                                          color: Color.fromARGB(255, 44, 138, 0),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: <Widget>[
                                      Text(
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                        stopwatch.elapsed.inSeconds >= 60
                                            ? 'TIME: ${stopwatch.elapsed.inMinutes}min ${stopwatch.elapsed.inSeconds - 60 * stopwatch.elapsed.inMinutes}s'
                                            : 'TIME: ${stopwatch.elapsed.inSeconds}s',
                                      ),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('NEXT STEP',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Color.fromARGB(
                                                255, 167, 112, 3))),
                                    onPressed: () {
                                      setState(() {
                                        widget.level++;
                                        initialDiskNumber =
                                            initialDiskNumber + 1;
                                        bestCounter =
                                            pow(2, initialDiskNumber) - 1;
                                        endGame();
                                        restart();
                                      });
                                    },
                                  ),
                                ],
                              )
                            : AlertDialog(
                                surfaceTintColor: Colors.white,
                                title: const Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 15.0),
                                      child: Image(image: AssetImage("assets/images/silver.png"), width: 30,),
                                    ),
                                     Text(
                                      'YOU ARE CLOSE !',
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Color.fromARGB(255, 88, 88, 88),
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: <Widget>[
                                      Text(
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                        stopwatch.elapsed.inSeconds >= 60
                                            ? 'Time: ${stopwatch.elapsed.inMinutes}min ${stopwatch.elapsed.inSeconds - 60 * stopwatch.elapsed.inMinutes}s'
                                            : 'Time: ${stopwatch.elapsed.inSeconds}s',
                                      ),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text(
                                      'RESTART',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color:
                                              Color.fromARGB(255, 88, 88, 88)),
                                    ),
                                    onPressed: () {
                                      endGame();
                                      restart();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('NEXT STEP',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Color.fromARGB(
                                                255, 167, 112, 3))),
                                    onPressed: () {
                                      setState(() {
                                        widget.level++;
                                        initialDiskNumber =
                                            initialDiskNumber + 1;
                                        bestCounter =
                                            pow(2, initialDiskNumber) - 1;
                                        endGame();
                                        restart();
                                      });
                                    },
                                  ),
                                ],
                              );
                      }),
                Padding(
                  padding: Platform.isIOS
                      ? (orientation == Orientation.portrait
                          ? const EdgeInsets.only(top: 70, left: 3, right: 3)
                          : const EdgeInsets.only(top: 30, left: 50, right: 20))
                      : (orientation == Orientation.portrait
                          ? const EdgeInsets.only(top: 30, left: 3, right: 3)
                          : const EdgeInsets.only(
                              top: 30, left: 10, right: 10)),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 10, right: 10, top: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(
                                elevation: MaterialStateProperty.all(4),
                                surfaceTintColor:
                                    MaterialStateProperty.all(Colors.white),
                                foregroundColor: MaterialStateProperty.all(
                                  const Color.fromARGB(255, 152, 83, 56),
                                ),
                                minimumSize: MaterialStateProperty.all(
                                    const Size(50, 50))),
                            child: Icon(
                                gamePaused ? Icons.play_arrow : Icons.pause),
                            onPressed: () => gamePaused ? play() : pause(),
                          ),
                          Container(
                            height: 90,
                            width: 180,
                            decoration: const BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                      "assets/images/window.webp",
                                    ),
                                    fit: BoxFit.fitHeight)),
                            child: Center(
                              child: Text(
                                "${counter.toString()} / ${bestCounter.toString()}",
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                                elevation: MaterialStateProperty.all(4),
                                surfaceTintColor:
                                    MaterialStateProperty.all(Colors.white),
                                foregroundColor: MaterialStateProperty.all(
                                  const Color.fromARGB(255, 152, 83, 56),
                                ),
                                minimumSize: MaterialStateProperty.all(
                                    const Size(50, 50))),
                            child: const Icon(Icons.restart_alt),
                            onPressed: () => restart(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
