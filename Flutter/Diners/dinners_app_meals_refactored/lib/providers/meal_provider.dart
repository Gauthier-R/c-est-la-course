// 🔄 MealProvider mis à jour avec prise en compte correcte de la date, du weekKey et de l'unité pour chaque ingrédient

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:dinners_app/utils/date_format.dart';

class MealProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DateTime _selectedDay = DateTime.now();
  DateTime get selectedDay => _selectedDay;

  void selectDay(DateTime day) {
    _selectedDay = DateTime(day.year, day.month, day.day);
    notifyListeners();
  }

  String _getDateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
  String _getWeekKey(DateTime date) => getWeekKey(date);

  final Map<String, Map<String, dynamic>> _cachedMeals = {};

  void startLiveSync() {
    _firestore.collection('meals').snapshots().listen((snapshot) {
      final updatedKeys = snapshot.docs.map((doc) => doc.id).toSet();
      final existingKeys = _cachedMeals.keys.toSet();

      bool hasChanged = false;

      for (final doc in snapshot.docs) {
        final oldData = _cachedMeals[doc.id];
        final newData = doc.data();
        if (oldData == null || oldData.toString() != newData.toString()) {
          _cachedMeals[doc.id] = newData;
          hasChanged = true;
        }
      }

      final removedKeys = existingKeys.difference(updatedKeys);
      for (final key in removedKeys) {
        _cachedMeals.remove(key);
        hasChanged = true;
      }

      if (hasChanged) notifyListeners();
    });
  }

  Stream<Map<String, dynamic>> getMealsForDate(DateTime date) {
    final key = _getDateKey(date);
    return _firestore.collection('meals').doc(key).snapshots().map((doc) {
      final data = doc.data() ?? {};
      _cachedMeals[key] = data;
      return data;
    });
  }

  Map<String, String> get selectedMeals => {
    'midi': _cachedMeals[_getDateKey(_selectedDay)]?['midi']?['meal'] ?? '',
    'soir': _cachedMeals[_getDateKey(_selectedDay)]?['soir']?['meal'] ?? '',
  };

  Future<void> saveMeal({
    required DateTime date,
    required String moment,
    required String meal,
    required List<Map<String, dynamic>> ingredients,
  }) async {
    final key = _getDateKey(date);
    ingredients = ingredients.map((ingredient) {
      return {
        ...ingredient,
        'unit': ingredient['unit'] ?? 'QT',
      };
    }).toList();

    await _firestore.collection('meals').doc(key).set({
      moment: {
        'meal': meal,
        'ingredients': ingredients,
      }
    }, SetOptions(merge: true));

    _cachedMeals[key] ??= {};
    _cachedMeals[key]![moment] = {
      'meal': meal,
      'ingredients': ingredients,
    };
    notifyListeners();
  }

  Future<void> deleteMeal(DateTime date, String moment) async {
    final key = _getDateKey(date);
    final ref = _firestore.collection('meals').doc(key);
    final snapshot = await ref.get();
    if (!snapshot.exists) return;

    final data = snapshot.data();
    data?.remove(moment);

    if (data == null || data.isEmpty) {
      await ref.delete();
      _cachedMeals.remove(key);
    } else {
      await ref.set(data);
      _cachedMeals[key] = data;
    }
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getWeeklyIngredients(DateTime referenceDay) async {
    final start = referenceDay.subtract(Duration(days: referenceDay.weekday - 1));
    final weekDates = List.generate(7, (i) => _getDateKey(start.add(Duration(days: i))));

    final List<Map<String, dynamic>> allIngredients = [];
    for (final dateStr in weekDates) {
      final data = _cachedMeals[dateStr];
      if (data == null) continue;
      for (final moment in ['midi', 'soir']) {
        final entry = data[moment];
        if (entry != null && entry['ingredients'] != null) {
          final ingredients = List<Map<String, dynamic>>.from(
            (entry['ingredients'] as List).map((e) => Map<String, dynamic>.from(e))
          );
          for (final ing in ingredients) {
            ing['moment'] = moment;
            ing['date'] = DateFormat('yyyy-MM-dd').parse(dateStr);
          }
          allIngredients.addAll(ingredients);
        }
      }
    }

    final weekKey = _getWeekKey(referenceDay);
    final weeklyDoc = await _firestore.collection('meals').doc(weekKey).get();
    final weeklyData = weeklyDoc.data();
    if (weeklyData != null && weeklyData['extras'] != null) {
      final extras = List<Map<String, dynamic>>.from(
        (weeklyData['extras'] as List).map((e) => Map<String, dynamic>.from(e))
      );
      allIngredients.addAll(extras);
    }
    return allIngredients;
  }

  Future<void> addWeeklyExtra(String weekKey, String name, int quantity, [String unit = 'QT']) async {
    final ref = _firestore.collection('meals').doc(weekKey);
    final snapshot = await ref.get();
    final data = snapshot.data() ?? {};

    final List<dynamic> currentExtras = data['extras'] ?? [];

    final DateTime weekStart = _getStartOfWeekFromWeekKey(weekKey);

    currentExtras.add({
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'checked': false,
      'moment': 'extra',
      'date': weekStart.toIso8601String(),
      'weekKey': weekKey,
    });

    await ref.set({'extras': currentExtras}, SetOptions(merge: true));

    _cachedMeals[weekKey] ??= {};
    _cachedMeals[weekKey]!['extras'] = currentExtras;

    notifyListeners();
  }


  Future<void> toggleIngredientChecked(Map<String, dynamic> ingredient, bool checked) async {
    if (ingredient.containsKey('date') && ingredient.containsKey('moment') && ingredient['moment'] != 'extra') {
      final dynamic rawDate = ingredient['date'];
      final DateTime date = rawDate is Timestamp ? rawDate.toDate() : rawDate as DateTime;
      final String moment = ingredient['moment'];
      final String name = ingredient['name'];
      final int quantity = ingredient['quantity'];

      final key = _getDateKey(date);
      final ref = _firestore.collection('meals').doc(key);
      final snapshot = await ref.get();
      if (!snapshot.exists) return;

      final data = snapshot.data();
      final momentData = data?[moment];
      if (momentData == null || momentData['ingredients'] == null) return;

      final ingredients = List<Map<String, dynamic>>.from(
        (momentData['ingredients'] as List).map((e) => Map<String, dynamic>.from(e))
      );

      final index = ingredients.indexWhere(
        (item) => item['name'] == name && item['quantity'] == quantity
      );

      if (index == -1) return;

      ingredients[index]['checked'] = checked;

      await ref.set({
        moment: {
          'meal': momentData['meal'],
          'ingredients': ingredients,
        }
      }, SetOptions(merge: true));

      _cachedMeals[key]?[moment] = {
        'meal': momentData['meal'],
        'ingredients': ingredients,
      };
    } else {
      final String name = ingredient['name'];
      final int quantity = ingredient['quantity'];

      final dynamic rawDate = ingredient['date'];
      DateTime date;

      try {
        date = rawDate is Timestamp ? rawDate.toDate() : DateTime.parse(rawDate.toString());
        print('🧭 [TOGGLE] Date parsée avec succès: \$date');
      } catch (_) {
        date = DateTime.now();
        print('⚠️ [TOGGLE] Échec de parsing de date → fallback: \$date');
      }

      final String weekKey = ingredient['weekKey'] ?? _getWeekKey(date);
      print('📆 [TOGGLE] weekKey calculé: \$weekKey');

      final ref = _firestore.collection('meals').doc(weekKey);
      final snapshot = await ref.get();
      if (!snapshot.exists) return;

      final data = snapshot.data();
      final existing = data?['extras'] ?? [];

      final updated = List<Map<String, dynamic>>.from(
        (existing as List).map((e) => Map<String, dynamic>.from(e))
      );

      final index = updated.indexWhere((item) => item['name'] == name && item['quantity'] == quantity);
      if (index != -1) {
        updated[index]['checked'] = checked;
      }

      await ref.set({'extras': updated}, SetOptions(merge: true));
      _cachedMeals[weekKey] ??= {};
      _cachedMeals[weekKey]!['extras'] = updated;
    }

    notifyListeners();
  }

  DateTime _getStartOfWeekFromWeekKey(String weekKey) {
    final match = RegExp(r'^(\d{4})-W(\d{2})\$').firstMatch(weekKey);
    if (match != null) {
      final year = int.parse(match.group(1)!);
      final week = int.parse(match.group(2)!);
      final firstThursday = DateTime(year, 1, 4);
      final startOfWeek = firstThursday.subtract(Duration(days: firstThursday.weekday - 1));
      return startOfWeek.add(Duration(days: (week - 1) * 7));
    }
    return DateTime.now();
  }

  DateTime getStartOfIsoWeek(int year, int weekNumber) {
    final jan4 = DateTime(year, 1, 4); // Le 4 janvier est toujours dans la première semaine ISO
    final startOfFirstWeek = jan4.subtract(Duration(days: jan4.weekday - 1)); // va au lundi de cette semaine
    return startOfFirstWeek.add(Duration(days: (weekNumber - 1) * 7));
  }


  List<Map<String, dynamic>> getIngredientsForDate(DateTime date, String moment) {
    final key = _getDateKey(date);
    return List<Map<String, dynamic>>.from(
      _cachedMeals[key]?[moment]?['ingredients'] ?? []);
  }

  Color? getDotColor(DateTime day) {
    final key = _getDateKey(day);
    final data = _cachedMeals[key];
    if (data == null) return null;
    final hasMidi = data['midi'] != null && data['midi']['meal'] != null && data['midi']['meal'].toString().trim().isNotEmpty;
    final hasSoir = data['soir'] != null && data['soir']['meal'] != null && data['soir']['meal'].toString().trim().isNotEmpty;

    if (hasMidi && hasSoir) return Colors.green;
    if (hasMidi || hasSoir) return Colors.orange;
    return null;
  }

  Map<String, String> selectedMealsFor(DateTime date) {
    final key = _getDateKey(date);
    return {
      'midi': _cachedMeals[key]?['midi']?['meal'] ?? '',
      'soir': _cachedMeals[key]?['soir']?['meal'] ?? '',
    };
  }

  List<DateTime> getAllMealDates() {
    final now = DateTime.now();
    return _cachedMeals.keys
      .map((id) => DateFormat('yyyy-MM-dd').parse(id))
      .where((date) => date.isBefore(DateTime(now.year, now.month, now.day)))
      .toList();
  }

  List<DateTime> getAllUsedWeekStarts() {
  final now = DateTime.now();
  final dayFormat = DateFormat('yyyy-MM-dd');
  final weekFormat = RegExp(r'^\d{4}-W\d{2}$');

  final Set<String> seenWeeks = {};

  print('🔍 [DEBUG] Clés trouvées dans _cachedMeals :');
  _cachedMeals.forEach((key, value) {
    print('→ $key : $value');
  });

  for (final key in _cachedMeals.keys) {
    if (weekFormat.hasMatch(key)) {
      // Cas d’un document type "2025-W15"
      final extras = _cachedMeals[key]?['extras'];
      if (extras is List && extras.isNotEmpty) {
        seenWeeks.add(key);
        print('✅ Ajouté via extras : $key');
      }
    } else {
      try {
        final date = dayFormat.parse(key);
        final midi = _cachedMeals[key]?['midi']?['ingredients'];
        final soir = _cachedMeals[key]?['soir']?['ingredients'];
        final hasIngredients = (midi is List && midi.isNotEmpty) || (soir is List && soir.isNotEmpty);
        if (hasIngredients) {
          final wk = getWeekKey(date);
          seenWeeks.add(wk);
          print('✅ Ajouté via midi/soir : $wk (source : $key)');
        }
      } catch (e) {
        print('❌ Erreur de parsing pour la clé : $key');
      }
    }
  }

  print('📅 [DEBUG] seenWeeks avant conversion : $seenWeeks');

  return seenWeeks
    .map((key) {
      try {
        final monday = getStartOfWeekFromKey(key);
        print('📆 Conversion $key → $monday');
        return monday;
      } catch (e) {
        print('⚠️ Erreur de conversion $key : $e');
        return null;
      }
    })
    .whereType<DateTime>()
    .where((date) => date.isBefore(DateTime(now.year, now.month, now.day)))
    .toList()
  ..sort((a, b) => b.compareTo(a));

} 



  Future<void> preloadAllMeals() async {
    final snapshot = await _firestore.collection('meals').get();
    for (final doc in snapshot.docs) {
      _cachedMeals[doc.id] = doc.data();
    }
    notifyListeners();
  }

  void updateMealAndIngredients(DateTime date, String moment, String meal, List<Map<String, dynamic>> ingredients) {
    saveMeal(date: date, moment: moment, meal: meal, ingredients: ingredients);
  }

  Future<void> updateExtrasForWeek(String weekKey, List<Map<String, dynamic>> extras) async {
    extras = extras.map((ingredient) {
      return {
        ...ingredient,
        'unit': ingredient['unit'] ?? 'QT',
      };
    }).toList();

    await _firestore.collection('meals').doc(weekKey).set({'extras': extras}, SetOptions(merge: true));
    _cachedMeals[weekKey] ??= {};
    _cachedMeals[weekKey]!['extras'] = extras;
    notifyListeners();
  }

}
