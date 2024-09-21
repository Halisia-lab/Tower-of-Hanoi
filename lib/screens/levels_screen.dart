import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hanoi_tower/components/error_dialog.dart';
import 'package:hanoi_tower/components/level_grid.dart';
import 'package:hanoi_tower/components/title_window.dart';
import 'package:hanoi_tower/services/firestore_service.dart';

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
                    const TitleWindow(text: "Unlocked Levels"),
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
                            return const ErrorDialog();
                          }
                          return LevelGrid(userId: snapshotID.data!);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
