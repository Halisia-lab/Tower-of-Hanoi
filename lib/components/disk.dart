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
      height: 35,
      width: widget.number * 10 + 40,
      decoration:  BoxDecoration(
          color: widget.isFeedback ?  const Color.fromARGB(255, 152,83,56) : const Color.fromARGB(255,241,234,205) ,
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: Center(
          child: Text(
        widget.number.toString(),
        style:  TextStyle(
            color: widget.isFeedback ? Colors.white :const Color.fromARGB(255,113,213,184),
            fontSize: 18,
            fontWeight: FontWeight.bold),
      )),
    );
  }
}
