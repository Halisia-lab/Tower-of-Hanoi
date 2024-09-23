import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: AlertDialog(
          title:
              Text('A problem has occured. Please contact support for help.')),
    );
  }
}
