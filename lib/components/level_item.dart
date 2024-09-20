import 'package:flutter/material.dart';
import 'package:hanoi_tower/screens/game_screen.dart';

class LevelItem extends StatelessWidget {
  final int levelNumber;
  final bool isCompleted;

  const LevelItem(
      {super.key, required this.isCompleted, required this.levelNumber});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              GameScreen(title: "Level $levelNumber", level: levelNumber),
        ),
      ), //, arguments: {'level': levelNumber}
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            Image(
              image: isCompleted
                  ? const AssetImage("assets/images/gold.png")
                  : const AssetImage("assets/images/silver.png"),
              width: 70
            ),
            Positioned(
              top: 28,
              child: Text(
                levelNumber.toString(),
                style: TextStyle(
                    color: isCompleted
                        ? const Color.fromARGB(255, 150, 4, 4)
                        : const Color.fromARGB(255, 17, 74, 145),
                    fontWeight: FontWeight.bold,
                    fontSize: 35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
