import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hanoi_tower/components/level_item.dart';
import 'package:hanoi_tower/utils/is_level_completed.dart.dart';

class LevelsScreen extends StatelessWidget {
  const LevelsScreen({super.key});

  // getLevels() async {
  //   CollectionReference achievementsCollection =
  //       await FirebaseFirestore.instance.collection("Achievements").snapshots()
  //   achievementsCollection.doc()
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/wood.jpeg"),
                opacity: 0.8,
                fit: BoxFit.fill,
              ),
            ),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Padding(
                padding:  Platform.isIOS ? (orientation == Orientation.portrait ? const EdgeInsets.only(top:70, left:3, right:3) : const EdgeInsets.only(top:30, left:50, right:20) ) : (orientation == Orientation.portrait ? const EdgeInsets.only(top:30, left:3, right:3) : const EdgeInsets.only(top:30, left:10, right:10)) ,
                child: StreamBuilder(
                    stream:
                        FirebaseFirestore.instance.collection("Levels").snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
              
                      if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty ||
                          snapshot.hasError) {
                        return const Center(child: Text('No data available.'));
                      }
              
                      return Wrap(
                        spacing: 10,//orientation == Orientation.portrait ? MediaQuery.of(context).size.width /10 : 20,
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
                          LevelItem(
                              isCompleted: false,
                              levelNumber: snapshot.data!.docs.length + 1)
                        ],
                      );
                    }),
              ),
          );
        }
      ),
    );
  }
}
