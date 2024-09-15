import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hanoi_tower/services/level_service.dart';
import 'package:hanoi_tower/services/sound_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

Future<String> getOrCreateUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  
  // Vérifier si un UID existe déjà
  String? uid = prefs.getString('user_uid');

  if (uid == null) {
    // Si aucun UID, en générer un nouveau
    var uuid = Uuid();
    uid = uuid.v4();

    // Sauvegarder l'UID dans les préférences pour les futurs lancements
    await prefs.setString('user_uid', uid);
    print("UID généré : $uid");
  } else {
    print("UID existant récupéré : $uid");
  }

  return uid;
}

Future<void> checkAndInitializeLevel(String collectionName, String documentId, Map<String, dynamic> defaultData) async {
  String uid = await getOrCreateUserId();
  FirebaseFirestore.instance
      .collection('users')  
      .doc(uid)             
      .collection('levels') 
      .doc(documentId);     
}

saveLevelData(int counter, int level, int time) async {
    String uid = await getOrCreateUserId();
    FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("levels")
        .doc(level.toString())
        .set({
      "attempts": counter,
      "level": level,
      "time": time
    }).onError((e, _) => print("Error writing document: $e"));
  }

  makeLevelCompleted(int counter, int level, int time) async {
    saveLevelData(counter, level, time);
    await playWinSound();
  }

  makeLevelCompletedWithExtraAttempts(int counter, int level, int time) async {
    String uid = await getOrCreateUserId();
    final ref =
        FirebaseFirestore.instance.doc("/users/$uid/levels/$level");
    final snapshot = await ref.get();

    if (snapshot.exists) {
      if (!isLevelCompleted(level, snapshot.data()!["attempts"])) {
        saveLevelData(counter, level, time);
      }
    } else {
      saveLevelData(counter, level, time);
    }
    await playCloseSound();
  }