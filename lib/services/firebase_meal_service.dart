import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseMealService {
  final CollectionReference _mealsCollection =
      FirebaseFirestore.instance.collection('meals');

  Future<void> saveMeal({
    required DateTime date,
    required String moment,
    required String mealName,
    required List<Map<String, dynamic>> ingredients,
  }) async {
    final dateKey = "${date.year}-${date.month}-${date.day}";

    await _mealsCollection
        .doc(dateKey)
        .set({
          moment: {
            'meal': mealName,
            'ingredients': ingredients,
          }
        }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getMeal(DateTime date) async {
    final dateKey = "${date.year}-${date.month}-${date.day}";
    final snapshot = await _mealsCollection.doc(dateKey).get();

    return snapshot.exists ? snapshot.data() as Map<String, dynamic> : null;
  }
}
