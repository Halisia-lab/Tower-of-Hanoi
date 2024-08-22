import 'package:flutter/material.dart';

class Disk extends StatefulWidget {
  final int number;
  final bool isFeedback;
  const Disk( {super.key, required this.number, required this.isFeedback,});

  @override
  State<Disk> createState() => _DiskState();
}

class _DiskState extends State<Disk> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: widget.number * 10 + 60,
      decoration:  BoxDecoration(
          color: widget.isFeedback ? Colors.black : const Color.fromARGB(255, 42, 42, 42),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: Center(
          child: Text(
        widget.number.toString(),
        style: const TextStyle(
            color: Color.fromARGB(255, 203, 98, 0),
            fontSize: 16,
            fontWeight: FontWeight.bold),
      )),
    );
  }
}
