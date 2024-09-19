import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hanoi_tower/components/level_item.dart';
import 'package:hanoi_tower/services/firestore_service.dart';
import 'package:hanoi_tower/services/level_service.dart';

class LevelsScreen extends StatelessWidget {
  const LevelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Unlocked Levels",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 19),
        ),
        backgroundColor: const Color.fromARGB(255, 191, 143, 101),
        leading: null,
        automaticallyImplyLeading: false,
      ),
      body: OrientationBuilder(builder: (context, orientation) {
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
                    ? const EdgeInsets.only(top: 30, left: 3, right: 3)
                    : const EdgeInsets.only(top: 30, left: 50, right: 20))
                : (orientation == Orientation.portrait
                    ? const EdgeInsets.only(top: 20, left: 3, right: 3)
                    : const EdgeInsets.only(top: 30, left: 10, right: 10)),
            child: FutureBuilder(
                future: getOrCreateUserId(),
                builder: (context, snapshotID) {
                  print(snapshotID.data);
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
                              child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty ||
                            snapshot.hasError) {
                          return const Center(
                              child: Text('No data available.'));
                        }

                        return Wrap(
                          spacing:
                              10, //orientation == Orientation.portrait ? MediaQuery.of(context).size.width /10 : 20,
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
                                  levelNumber: snapshot.data!.docs.length + 1)
                          ],
                        );
                      });
                }),
          ),
        );
      }),
    );
  }
}
