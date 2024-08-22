import 'package:flutter/material.dart';
import 'package:hanoi_tower/components/splash_screen.dart';
import 'dart:math';
import 'dart:core';
import 'components/stick.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
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

  // This widget is the root of your application.
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

int initialDiskNumber = 3;
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

  playWinSound() async {
    final player = AudioPlayer();
    await player.play(AssetSource("sounds/win2.mp3"),
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

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 1,21,48),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/city2.jpeg"),
            opacity: 0.3,
            fit: BoxFit.fill,
          ),
        ),
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            Positioned(
              bottom: 40,
              right: 0,
              left: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  stick1,
                  stick2,
                  stick3,
                ],
              ),
            ),
            if (stick3.diskNumbers.length == initialDiskNumber)
              FutureBuilder(
                  future: playWinSound(),
                  builder: (context, snapshot) {
                    if (underBestCounter()) {
                      snapshot.data;
                    }
                    return AlertDialog(
                      surfaceTintColor: Colors.white,
                      title: const Text(
                        'YOU WON !',
                        style: TextStyle(
                            color: Color.fromARGB(255, 41, 41, 41),
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Text(
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
                            'Restart',
                            style: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 167, 112, 3)),
                          ),
                          onPressed: () {
                            endGame();
                            restart();
                          },
                        ),
                        TextButton(
                          child: const Text('Next step',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 167, 112, 3))),
                          onPressed: () {
                            setState(() {
                              initialDiskNumber++;
                              bestCounter = pow(2, initialDiskNumber) - 1;
                              endGame();
                              restart();
                            });
                          },
                        ),
                      ],
                    );
                  }),
            //  Column(
            //       mainAxisAlignment: MainAxisAlignment.spaceAround,
            //       crossAxisAlignment: CrossAxisAlignment.center,
            //       children: [
            //         Stack(
            //           alignment: AlignmentDirectional.center,
            //           children: [
            //             const Image(image: AssetImage("images/window.webp",)),
            //             Text(
            //               "${counter.toString()} / ${bestCounter.toString()}",
            //               style: const TextStyle(
            //                   fontSize: 40,
            //                   fontWeight: FontWeight.bold,
            //                   color: Colors.white
            //                   // color:
            //                   //     underBestCounter() ? Colors.green : Colors.orange
            //                   ),
            //             ),
            //           ],
            //         ),
            //         ElevatedButton(
            //           style: ButtonStyle(
            //               minimumSize:
            //                   MaterialStateProperty.all(const Size(50, 50))),
            //           child: const Icon(Icons.restart_alt),
            //           onPressed: () => restart(),
            //         ),
            //       ]),

            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Align(
                alignment: Alignment.topCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all(4),
                          surfaceTintColor:
                              MaterialStateProperty.all(Colors.white),
                          foregroundColor: MaterialStateProperty.all(
                              Color.fromARGB(255, 152,83,56),
                              ),
                          minimumSize:
                              MaterialStateProperty.all(const Size(50, 50))),
                      child: Icon(gamePaused ? Icons.play_arrow : Icons.pause),
                      onPressed: () => gamePaused ? play() : pause(),
                    ),
                    Container(
                      height: 150,
                      width: 230,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(
                                "assets/images/window.webp",
                              ),
                              fit: BoxFit.fitHeight)
                          ),
                      child: Center(
                        child: Text(
                         // "${counter.toString()}",
                           "${counter.toString()} / ${bestCounter.toString()}",
                          style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white
                              // color:
                              //     underBestCounter() ? Colors.green : Colors.orange
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
                              Color.fromARGB(255, 152,83,56),),
                          minimumSize:
                              MaterialStateProperty.all(const Size(50, 50))),
                      child: const Icon(Icons.restart_alt),
                      onPressed: () => restart(),
                    ),
                  ],
                ),
              ),
            ),

            // Positioned(
            //   left: 0,
            //   right: 0,
            //   bottom: 0,
            //   child: Image.asset("images/background_light.webp", height: MediaQuery.of(context).size.height,width: MediaQuery.of(context).size.width,),
            // ),
          ],
        ),
      ),
    );
  }
}
