// ✅ meal_provider.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import 'weekly_list_provider.dart';

class MealProvider extends ChangeNotifier {
  final Map<DateTime, Map<String, String>> _meals = {};
  final Map<DateTime, Map<String, List<Map<String, dynamic>>>> _ingredients = {};
  final FirebaseService _firebase = FirebaseService();
  DateTime _selectedDay = DateTime.now();

  DateTime get selectedDay => _selectedDay;

  Map<String, String> get selectedMeals =>
      _meals[_normalizeDate(_selectedDay)] ?? {'midi': '', 'soir': ''};

  void selectDay(DateTime day) {
    _selectedDay = _normalizeDate(day);
    notifyListeners();
  }

  void updateMealForDate(DateTime day, String moment, String meal) {
    final date = _normalizeDate(day);
    _meals[date] ??= {};
    _meals[date]![moment] = meal;
    _firebase.saveMealData(date, moment, meal, _ingredients[date]?[moment] ?? []);
    notifyListeners();
  }

  void updateIngredientsForDate(DateTime day, String moment, List<Map<String, dynamic>> ingredients) {
    final date = _normalizeDate(day);
    _ingredients[date] ??= {};
    _ingredients[date]![moment] = ingredients;
    _firebase.saveMealData(date, moment, _meals[date]?[moment] ?? '', ingredients);
    notifyListeners();
  }

  void updateMealAndIngredients(
    DateTime date,
    String moment,
    String meal,
    List<Map<String, dynamic>> ingredients,
    WeeklyListProvider weeklyListProvider,
  ) {
    updateMealForDate(date, moment, meal);
    updateIngredientsForDate(date, moment, ingredients);

    final weekYear = DateFormat('yyyy').format(date);
    final weekNumber = ((date.difference(DateTime(date.year, 1, 1)).inDays + DateTime(date.year, 1, 1).weekday) / 7).ceil();
    final weekKey = "$weekYear-W$weekNumber";
    final mealId = "${date.toIso8601String().split('T').first}-$moment";

    for (var ingredient in ingredients) {
      final name = ingredient['name'];
      final quantity = ingredient['quantity'] ?? 1;
      final checked = ingredient['checked'] ?? false;

      if (name != null && name.toString().trim().isNotEmpty && quantity > 0) {
        weeklyListProvider.addOrUpdateIngredient(weekKey, {
          'id': mealId,
          'name': name,
          'quantity': quantity,
          'checked': checked
        });
      }
    }
  }

  void deleteMeal(DateTime date, String moment, [WeeklyListProvider? weeklyListProvider]) async {
    print("🟥 Bouton Supprimer activé !");
    final normalized = _normalizeDate(date);
    final mealId = "${DateFormat('yyyy-MM-dd').format(normalized)}-$moment";

    List<Map<String, dynamic>> removedIngredients = [];

    try {
      final firebaseMeals = await _firebase.getAllMeals();
      final data = firebaseMeals[normalized];
      if (data != null && data[moment] != null && data[moment]['ingredients'] != null) {
        removedIngredients = List<Map<String, dynamic>>.from(
          (data[moment]['ingredients'] as List).map((e) => Map<String, dynamic>.from(e))
        );
        print("📡 Récupérés depuis Firebase : $removedIngredients");
      }
    } catch (e) {
      print("❌ Erreur récupération Firebase : $e");
    }

    // Ajouter l’ID pour bien filtrer dans weekly_lists
    for (var ing in removedIngredients) {
      ing['id'] = mealId;
    }

    // Supprimer en local
    _meals[normalized]?.remove(moment);
    _ingredients[normalized]?.remove(moment);

    // Supprimer dans Firestore
    await _firebase.deleteMealData(normalized, moment);

    // Supprimer dans weekly_lists via provider
    if (weeklyListProvider != null && removedIngredients.isNotEmpty) {
      print("🟨 Suppression dans weekly_lists de : $removedIngredients");
      weeklyListProvider.removeIngredientsFromWeeklyList(normalized, removedIngredients);
    }

    notifyListeners();
  }



  void toggleIngredientChecked(DateTime day, String moment, int index, bool checked) {
    final date = _normalizeDate(day);
    if (_ingredients[date]?[moment] != null && _ingredients[date]![moment]!.length > index) {
      _ingredients[date]![moment]![index]['checked'] = checked;
      _firebase.saveMealData(date, moment, _meals[date]?[moment] ?? '', _ingredients[date]![moment]!);
      notifyListeners();
    }
  }

  Map<String, String> selectedMealsFor(DateTime day) {
    return _meals[_normalizeDate(day)] ?? {'midi': '', 'soir': ''};
  }

  List<Map<String, dynamic>> getIngredientsForDate(DateTime day, String moment) {
    final date = _normalizeDate(day);
    return _ingredients[date]?[moment] ?? [];
  }

  Color? getDotColor(DateTime day) {
    final meals = _meals[_normalizeDate(day)];
    if (meals == null) return null;
    final hasLunch = meals['midi'] != null && meals['midi']!.isNotEmpty;
    final hasDinner = meals['soir'] != null && meals['soir']!.isNotEmpty;

    if (hasLunch && hasDinner) return const Color(0xFF7ED957);
    if (hasLunch || hasDinner) return const Color(0xFFF58020);
    return null;
  }

  Map<String, List<Map<String, dynamic>>> generateWeeklyIngredientLists() {
    final Map<String, List<Map<String, dynamic>>> weeklyLists = {};

    _ingredients.forEach((date, mealsMap) {
      final weekYear = DateFormat('yyyy').format(date);
      final weekNumber = ((date.difference(DateTime(date.year, 1, 1)).inDays + DateTime(date.year, 1, 1).weekday) / 7).ceil();
      final weekKey = "$weekYear-W$weekNumber";

      weeklyLists.putIfAbsent(weekKey, () => []);

      for (var ingredientList in mealsMap.values) {
        for (var ingredient in ingredientList) {
          final existingIndex = weeklyLists[weekKey]!.indexWhere((i) => i['name'] == ingredient['name']);
          if (existingIndex != -1) {
            weeklyLists[weekKey]![existingIndex]['quantity'] += ingredient['quantity'] ?? 1;
          } else {
            weeklyLists[weekKey]!.add({
              'name': ingredient['name'],
              'quantity': ingredient['quantity'] ?? 1,
              'checked': ingredient['checked'] ?? false,
            });
          }
        }
      }
    });

    return weeklyLists;
  }

  Future<void> loadMealsFromFirebase() async {
    final firebaseMeals = await _firebase.getAllMeals();
    for (var entry in firebaseMeals.entries) {
      final date = entry.key;
      final data = entry.value;
      _meals[date] = {};
      _ingredients[date] = {};

      for (var moment in ['midi', 'soir']) {
        final mealData = data[moment];
        if (mealData != null) {
          _meals[date]![moment] = mealData['meal'] ?? '';
          _ingredients[date]![moment] = List<Map<String, dynamic>>.from(mealData['ingredients'] ?? []);
        }
      }
    }
    notifyListeners();
  }

  DateTime _normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);
}
