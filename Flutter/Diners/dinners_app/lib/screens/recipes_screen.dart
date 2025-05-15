import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});

  String _getWeekKey(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return DateFormat('yyyy-MM-dd').format(monday);
  }

  Future<void> addTestIngredient() async {
    final date = DateTime.now();
    final weekKey = _getWeekKey(date);
    final docRef = FirebaseFirestore.instance.collection('weekly_lists').doc(weekKey);
    final snapshot = await docRef.get();
    List items = List.from(snapshot.data()?['items'] ?? []);

    final testIngredient = {
      'name': 'TestIngrédient',
      'quantity': 1,
      'id': '${DateFormat('yyyy-MM-dd').format(date)}-midi',
      'checked': false
    };

    items.add(testIngredient);
    await docRef.set({'items': items});
    debugPrint('✅ Ingrédient ajouté à weekly_lists : $testIngredient');
  }

  Future<void> clearWeeklyList() async {
    final date = DateTime.now();
    final weekKey = _getWeekKey(date);
    final docRef = FirebaseFirestore.instance.collection('weekly_lists').doc(weekKey);
    await docRef.delete();
    debugPrint('🗑 Liste hebdomadaire supprimée.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recettes')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: addTestIngredient,
              child: const Text('Ajouter ingrédient test à weekly_lists'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: clearWeeklyList,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Supprimer la liste hebdomadaire'),
            ),
          ],
        ),
      ),
    );
  }
}
