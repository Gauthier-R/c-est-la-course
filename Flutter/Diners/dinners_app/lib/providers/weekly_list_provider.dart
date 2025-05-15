import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';

class WeeklyListProvider extends ChangeNotifier {
  final Map<String, List<Map<String, dynamic>>> _weeklyLists = {};
  final FirebaseService _firebase = FirebaseService();

  Map<String, List<Map<String, dynamic>>> get allWeeklyLists => _weeklyLists;

  String get currentWeekKey {
    final now = DateTime.now();
    return _getWeekKey(now);
  }

  List<Map<String, dynamic>> getList(String weekKey) {
    return _weeklyLists.putIfAbsent(weekKey, () => []);
  }

  void addIngredientToWeek(DateTime date, String name, int quantity) {
    final weekKey = _getWeekKey(date);
    final list = _weeklyLists.putIfAbsent(weekKey, () => []);

    final existing = list.indexWhere((item) => item['name'] == name);
    if (existing != -1) {
      list[existing]['quantity'] += quantity;
    } else {
      list.add({'name': name, 'quantity': quantity, 'checked': false});
    }
    notifyListeners();
  }

  void updateList(String weekKey, List<Map<String, dynamic>> items) {
    _weeklyLists[weekKey] = items;
    _firebase.saveWeeklyList(weekKey, items);
    notifyListeners();
  }

  void toggleCheck(String weekKey, int index) {
    final list = _weeklyLists[weekKey];
    if (list != null && index < list.length) {
      list[index]['checked'] = !(list[index]['checked'] ?? false);
      _firebase.saveWeeklyList(weekKey, list);
      notifyListeners();
    }
  }

  void clearAllLists() {
    _weeklyLists.clear();
    notifyListeners();
  }

  void updateAll(Map<String, List<Map<String, dynamic>>> newWeeklyLists) {
    _weeklyLists.clear();
    _weeklyLists.addAll(newWeeklyLists);
    notifyListeners();
  }

  String _getWeekKey(DateTime date) {
    final weekYear = DateFormat('yyyy').format(date);
    final weekNumber = ((date.difference(DateTime(date.year, 1, 1)).inDays + DateTime(date.year, 1, 1).weekday) / 7).ceil();
    return "$weekYear-W$weekNumber";
  }

  Future<void> loadFromFirebase() async {
    final snapshot = await _firebase.firestore.collection('weekly_lists').get();
    for (var doc in snapshot.docs) {
      final key = doc.id;
      final items = List<Map<String, dynamic>>.from(doc.data()['items'] ?? []);
      _weeklyLists[key] = items;
    }
    notifyListeners();
  }

  void addOrUpdateIngredient(String weekKey, Map<String, dynamic> ingredient) {
    final list = _weeklyLists.putIfAbsent(weekKey, () => []);
    final index = list.indexWhere((item) =>
        item['name'] == ingredient['name'] &&
        item['id'] == ingredient['id']); // 🔁 Comparaison par nom + id

    if (index != -1) {
      list[index]['quantity'] = ingredient['quantity'];
      list[index]['checked'] = ingredient['checked'];
    } else {
      list.add(ingredient);
    }
    _firebase.saveWeeklyList(weekKey, list);
    notifyListeners();
  }

  void removeIngredientsFromWeeklyList(DateTime date, List<Map<String, dynamic>> ingredientsToRemove) {
  final weekKey = _getWeekKey(date);
  final list = _weeklyLists[weekKey];
  if (list == null) return;

  print("🔎 Avant suppression dans liste [$weekKey] : $list");

  for (var ingredient in ingredientsToRemove) {
    final id = ingredient['id'];
    if (id != null) {
      list.removeWhere((item) => item['id'] == id && item['name'] == ingredient['name']);
    }
  }

  print("✅ Liste mise à jour : $list");

  if (list.isEmpty) {
    _weeklyLists.remove(weekKey);
    _firebase.deleteWeeklyList(weekKey);
  } else {
    _firebase.saveWeeklyList(weekKey, list);
  }

  notifyListeners();
}

}
