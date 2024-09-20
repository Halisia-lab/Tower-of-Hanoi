import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hanoi_tower/components/level_item.dart';
import 'package:hanoi_tower/services/firestore_service.dart';
import 'package:hanoi_tower/services/level_service.dart';

class LevelsScreen extends StatelessWidget {
  const LevelsScreen({super.key});

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
              padding: Platform.isIOS
                  ? (orientation == Orientation.portrait
                      ? const EdgeInsets.only(top: 70, left: 3, right: 3)
                      : const EdgeInsets.only(top: 30, left: 50, right: 20))
                  : (orientation == Orientation.portrait
                      ? const EdgeInsets.only(top: 30, left: 3, right: 3)
                      : const EdgeInsets.only(top: 30, left: 10, right: 10)),
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(31, 0, 0, 0)),
                      child: const Padding(
                        padding: EdgeInsets.all(15.0),
                        child: Text(
                          textAlign: TextAlign.center,
                          "Unlocked Levels",
                          style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontWeight: FontWeight.bold,
                              fontSize: 25),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: FutureBuilder(
                        future: getOrCreateUserId(),
                        builder: (context, snapshotID) {
                          if (snapshotID.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (!snapshotID.hasData ||
                              snapshotID.data!.isEmpty ||
                              snapshotID.hasError) {
                            return const Center(
                              child: Text(
                                  'A problem has occured. Please contact support for help.'),
                            );
                          }
                          return StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection("users")
                                .doc(snapshotID.data)
                                .collection("levels")
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty ||
                                  snapshot.hasError) {
                                return const Center(
                                  child: Text(
                                      'A problem has occured. Please contact support for help.'),
                                );
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
                                            levelResults['level'],
                                            levelResults['attempts']),
                                        levelNumber: levelResults['level']),
                                  if (!snapshot.data!.docs.any((doc) =>
                                      doc['attempts'] == 0 &&
                                      doc['time'] == 0 &&
                                      doc['level'] == 1))
                                    LevelItem(
                                        isCompleted: false,
                                        levelNumber:
                                            snapshot.data!.docs.length + 1)
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                // ),
              ),
            ),
          );
        },
      ),
    );
  }
}
