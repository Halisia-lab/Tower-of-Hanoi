import 'package:flutter/material.dart';

class TitleWindow extends StatelessWidget {
  final String text;
  const TitleWindow({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color.fromARGB(31, 0, 0, 0)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Text(
          textAlign: TextAlign.center,
          text,
          style: const TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontWeight: FontWeight.bold,
              fontSize: 25),
        ),
      ),
    );
  }
}
