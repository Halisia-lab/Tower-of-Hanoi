import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hanoi_tower/components/error_dialog.dart';
import 'package:hanoi_tower/components/level_item.dart';
import 'package:hanoi_tower/services/level_service.dart';

class LevelGrid extends StatelessWidget {
  final String userId;
  const LevelGrid({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("levels")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData ||
            snapshot.data!.docs.isEmpty ||
            snapshot.hasError) {
          return const ErrorDialog();
        }

        return Wrap(
          spacing: 10,
          runSpacing: 20,
          runAlignment: WrapAlignment.start,
          alignment: WrapAlignment.spaceAround,
          direction: Axis.horizontal,
          children: [
            for (var levelResults in snapshot.data!.docs)
              LevelItem(
                  isCompleted: isLevelCompleted(
                      levelResults['level'], levelResults['attempts']),
                  levelNumber: levelResults['level']),
            if (!snapshot.data!.docs.any((doc) =>
                doc['attempts'] == 0 && doc['time'] == 0 && doc['level'] == 1))
              LevelItem(
                  isCompleted: false,
                  levelNumber: snapshot.data!.docs.length + 1)
          ],
        );
      },
    );
  }
}
