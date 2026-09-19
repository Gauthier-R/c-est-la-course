import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe.dart';

class RecipeProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Recipe> _recipes = [];
  List<Recipe> get recipes => _recipes;

  String? _groupId;
  StreamSubscription? _syncSubscription;

  CollectionReference<Map<String, dynamic>> _getRecipesCollection() {
    if (_groupId == null || _groupId!.isEmpty) {
      throw Exception("RecipeProvider requires a valid groupId");
    }
    return _firestore.collection('groups').doc(_groupId).collection('recipes');
  }

  void updateGroupId(String? newGroupId) {
    if (_groupId != newGroupId) {
      _groupId = newGroupId;
      _recipes.clear();
      _syncSubscription?.cancel();
      if (_groupId != null && _groupId!.isNotEmpty) {
        _startLiveSync();
      } else {
        notifyListeners();
      }
    }
  }

  void _startLiveSync() {
    _syncSubscription?.cancel();
    _syncSubscription = _getRecipesCollection().snapshots().listen((snapshot) {
      _recipes = snapshot.docs.map((doc) => Recipe.fromMap(doc.id, doc.data())).toList();
      notifyListeners();
    });
  }

  Future<void> addRecipe(Recipe recipe) async {
    final ref = recipe.id.isNotEmpty
        ? _getRecipesCollection().doc(recipe.id)
        : _getRecipesCollection().doc();
    await ref.set(recipe.toMap());
  }

  Future<void> updateRecipe(Recipe recipe) async {
    final ref = _getRecipesCollection().doc(recipe.id);
    await ref.update(recipe.toMap());
  }

  Future<void> deleteRecipe(String id) async {
    await _getRecipesCollection().doc(id).delete();
  }
}

