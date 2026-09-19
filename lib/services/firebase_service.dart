import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔄 Enregistre un repas avec son nom et ses ingrédients (fusion)
  Future<void> saveMealData(DateTime date, String moment, String meal, List<Map<String, dynamic>> ingredients) async {
    final key = "${date.toIso8601String().split('T').first}";
    await _firestore.collection('meals').doc(key).set({
      moment: {
        'meal': meal,
        'ingredients': ingredients,
      }
    }, SetOptions(merge: true));
  }

  /// ❌ Supprime un repas (midi/soir) ou tout le document si vide
  Future<void> deleteMealData(DateTime date, String moment) async {
    final key = "${date.toIso8601String().split('T').first}";
    final doc = _firestore.collection('meals').doc(key);
    final snapshot = await doc.get();

    if (snapshot.exists) {
      final data = snapshot.data();
      data?.remove(moment);
      if (data == null || data.isEmpty) {
        await doc.delete();
      } else {
        await doc.set(data);
      }
    }
  }

  /// 🔁 Récupère tous les repas enregistrés
  Future<Map<DateTime, Map<String, dynamic>>> getAllMeals() async {
    final snapshot = await _firestore.collection('meals').get();
    final Map<DateTime, Map<String, dynamic>> result = {};

    for (var doc in snapshot.docs) {
      final parts = doc.id.split('-'); // id = yyyy-mm-dd
      if (parts.length == 3) {
        final date = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
        result[date] = doc.data();
      }
    }

    return result;
  }

  /// 💾 Sauvegarde une liste hebdomadaire complète (avec cases cochées)
  Future<void> saveWeeklyList(String weekKey, List<Map<String, dynamic>> items) async {
    await _firestore.collection('weekly_lists').doc(weekKey).set({
      'items': items,
    });
  }

  /// ❌ Supprime complètement une liste hebdomadaire si vide
  Future<void> deleteWeeklyList(String weekKey) async {
    await _firestore.collection('weekly_lists').doc(weekKey).delete();
  }

  /// 🔄 Exposition du Firestore pour d'autres usages (lecture brute)
  FirebaseFirestore get firestore => _firestore;
}
