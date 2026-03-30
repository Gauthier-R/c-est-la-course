import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe.dart';

class RecipeProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Recipe> _recipes = [];
  List<Recipe> get recipes => _recipes;

  RecipeProvider() {
    _startLiveSync();
  }

  void _startLiveSync() {
    _firestore.collection('recipes').snapshots().listen((snapshot) {
      _recipes = snapshot.docs.map((doc) => Recipe.fromMap(doc.id, doc.data())).toList();
      notifyListeners();
    });
  }

  Future<void> addRecipe(Recipe recipe) async {
    final ref = recipe.id.isNotEmpty
        ? _firestore.collection('recipes').doc(recipe.id)
        : _firestore.collection('recipes').doc();
    await ref.set(recipe.toMap());
  }

  Future<void> updateRecipe(Recipe recipe) async {
    final ref = _firestore.collection('recipes').doc(recipe.id);
    await ref.update(recipe.toMap());
  }

  Future<void> deleteRecipe(String id) async {
    await _firestore.collection('recipes').doc(id).delete();
  }
}
