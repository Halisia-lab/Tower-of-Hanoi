import 'package:flutter/material.dart';
import 'package:hanoi_tower/main.dart';

class LevelItem extends StatelessWidget {
  final int levelNumber;
  final bool isCompleted;

  const LevelItem({super.key, required this.isCompleted, required this.levelNumber});

  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
            onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyHomePage(title: "Level $levelNumber",level: levelNumber),
          ),
        ),//, arguments: {'level': levelNumber}
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: [
             Image(
              image: isCompleted ? const AssetImage("assets/images/light_on.png") : const AssetImage("assets/images/light_off.png"),
              width: 50,
            ),
            Text(
              levelNumber.toString(),
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25),
            )
          ],
        ),
      ),
    );
  }
}
