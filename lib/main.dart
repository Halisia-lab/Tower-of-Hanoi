import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hanoi_tower/components/splash_screen.dart';
import 'dart:math';
import 'dart:core';
import 'components/stick.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MaterialApp(
    initialRoute: '/splash',
    routes: {
      '/splash': (context) => const SplashScreen(),
      '/home': (context) => const MyApp(),
    },
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

int initialDiskNumber = 4;
final stopwatch = Stopwatch();

class _MyHomePageState extends State<MyHomePage> with ChangeNotifier {
  List<int> leftDiskNumbers =
      List.generate(initialDiskNumber, (index) => index + 1, growable: true);
  List<int> middleDiskNumbers = [];
  List<int> rightDiskNumbers = [];
  int counter = 0;
  num bestCounter = pow(2, initialDiskNumber) - 1;
  bool gameStarted = false;
  bool gamePaused = false;
  int currentLevel = 1;

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

  saveLevelData() {
    CollectionReference achievementsCollection =
        FirebaseFirestore.instance.collection("Achievements");
    achievementsCollection.add({
      "attempts": counter,
      "level": currentLevel,
      "time": stopwatch.elapsed.inSeconds
    });
  }

  makeLevelCompleted() async {
    saveLevelData();
    await playWinSound();
  }

  makeLevelCompletedWithExtraAttempts() async {
    saveLevelData();
    await playCloseSound();
  }

  playWinSound() async {
    final player = AudioPlayer();
    await player.play(AssetSource("sounds/win2.mp3"),
        mode: PlayerMode.mediaPlayer);
  }

  playCloseSound() async {
    final player = AudioPlayer();
    await player.play(AssetSource("sounds/win.mp3"),
        mode: PlayerMode.mediaPlayer);
  }

  playClickSound() async {
    final player = AudioPlayer();
    await player.play(AssetSource("sounds/click.mp3"),
        mode: PlayerMode.mediaPlayer);
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

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 1, 21, 48),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/city2.jpeg"),
              opacity: 0.3,
              fit: BoxFit.fill,
            ),
          ),
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
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
                          ? makeLevelCompleted()
                          : makeLevelCompletedWithExtraAttempts(),
                      builder: (context, snapshot) {
                        return underBestCounter()
                            ? AlertDialog(
                                surfaceTintColor: Colors.white,
                                title: const Text(
                                  'YOU WON !',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 44, 138, 0),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30),
                                  textAlign: TextAlign.center,
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
                                            fontSize: 20,
                                            color: Color.fromARGB(
                                                255, 167, 112, 3))),
                                    onPressed: () {
                                      setState(() {
                                        currentLevel++;
                                        initialDiskNumber++;
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
                                title: const Text(
                                  'YOU ARE CLOSE !',
                                  style: TextStyle(
                                      fontSize: 24,
                                      color: Color.fromARGB(255, 88, 88, 88),
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
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
                                          fontSize: 20,
                                          color:
                                              Color.fromARGB(255, 167, 112, 3)),
                                    ),
                                    onPressed: () {
                                      endGame();
                                      restart();
                                    },
                                  ),
                                ],
                              );
                      }),
                Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
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
        ),
      ),
    );
  }
}
