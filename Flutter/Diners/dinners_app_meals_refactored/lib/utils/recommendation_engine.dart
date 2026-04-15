// 🧠 Moteur de recommandation de repas
// Algorithme basé sur : saison, fréquence passée, temps de préparation
import '../models/recipe.dart';

class RecipeScore {
  final Recipe recipe;
  final double score;
  final String reason; // Explication courte ex: "Peu préparé · De saison"

  const RecipeScore({required this.recipe, required this.score, required this.reason});
}

class MealRecommendationEngine {
  // ─── Saison actuelle ───────────────────────────────────────────────────────
  static String getCurrentSeason() {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) return 'Printemps';
    if (month >= 6 && month <= 8) return 'Été';
    if (month >= 9 && month <= 11) return 'Automne';
    return 'Hiver';
  }

  // ─── Valeurs possibles dans recipe.season ─────────────────────────────────
  static const _seasonAliases = {
    'Été': ['Été', 'Ete', 'été', 'ete'],
    'Hiver': ['Hiver', 'hiver'],
    'Printemps': ['Printemps', 'printemps'],
    'Automne': ['Automne', 'automne'],
    'Les deux': ['Les deux', 'Toutes saisons', 'les deux', 'toutes saisons', 'Tout', 'tout'],
  };

  static String _normalizeSeason(String raw) {
    for (final entry in _seasonAliases.entries) {
      if (entry.value.any((v) => raw.trim().toLowerCase() == v.toLowerCase())) {
        return entry.key;
      }
    }
    return 'Les deux';
  }

  // ─── Score saison (0..3) ──────────────────────────────────────────────────
  static double _seasonScore(Recipe recipe) {
    final current = getCurrentSeason();
    final recipeSeason = _normalizeSeason(recipe.season);
    if (recipeSeason == 'Les deux') return 2.0;
    if (recipeSeason == current) return 3.0;
    // Opposé
    const opposites = {'Été': 'Hiver', 'Hiver': 'Été', 'Printemps': 'Automne', 'Automne': 'Printemps'};
    if (opposites[current] == recipeSeason) return 0.0;
    return 1.0; // saison adjacente
  }

  // ─── Score Nouveauté (0..1) ───────────────────────────────────────────────
  static double _noveltyScore(Recipe recipe) {
    if (recipe.createdAt == null) return 0.0;
    final daysSinceCreation = DateTime.now().difference(recipe.createdAt!).inDays;
    if (daysSinceCreation < 14) return 1.0; // Bonus léger pour les recettes très récentes
    if (daysSinceCreation < 30) return 0.5;
    return 0.0;
  }

  // ─── Score popularité (0..0.5) ───────────────────────────────────────────
  static double _popularityScore(int count) {
    if (count >= 10) return 0.5; // Grand classique
    if (count >= 5)  return 0.3; // Plat régulier
    if (count >= 2)  return 0.1; // Apprécié
    return 0.0;
  }

  // ─── Score récence (-5..3.5) — moins récemment = score plus élevé ─────────
  static double _recencyScore(Recipe recipe, Map<String, dynamic> historyEntry) {
    final lastCooked = historyEntry['lastDate'] as DateTime?;
    if (lastCooked == null) return 3.5; // Jamais fait, ou très vieux : score max

    final daysSinceLastCook = DateTime.now().difference(lastCooked).inDays;
    
    // Fait dans le futur ou aujourd'hui/hier : on pénalise lourdement
    if (daysSinceLastCook < 4) return -5.0; 
    if (daysSinceLastCook < 7) return 0.0;
    if (daysSinceLastCook < 14) return 1.0;
    if (daysSinceLastCook < 30) return 2.0;
    
    return 3.5; // Fait il y a plus d'un mois : on relance la proposition
  }

  // ─── Score temps de préparation (0..2) ────────────────────────────────────
  // En semaine : courts favorisés, le WE : longs autorisés
  static double _prepTimeScore(Recipe recipe, {required bool isWeekend}) {
    final t = recipe.time.trim().toLowerCase();
    // Ordres : - 15 min < - 30 min < - 1h < + 1h
    if (t.contains('15')) return isWeekend ? 1.5 : 2.0;  // court
    if (t.contains('30')) return isWeekend ? 1.5 : 1.5;  // moyen-court
    if (t.contains('1h') && t.startsWith('-')) return isWeekend ? 2.0 : 1.0; // moyen
    if (t.contains('1h') && t.startsWith('+')) return isWeekend ? 2.0 : 0.5; // long
    return 1.0; // inconnu
  }

  // ─── Raison humaine ───────────────────────────────────────────────────────
  static String _buildReason(Recipe recipe, Map<String, dynamic> historyEntry) {
    final parts = <String>[];
    final lastCooked = historyEntry['lastDate'] as DateTime?;
    final count = historyEntry['count'] as int? ?? 0;
    
    if (lastCooked == null) {
      if (recipe.createdAt != null && DateTime.now().difference(recipe.createdAt!).inDays < 14) {
         parts.add('Nouvelle recette');
      } else {
         parts.add('À redécouvrir');
      }
    } else {
      if (count >= 10) parts.add('Grand classique');
      else {
        final daysSince = DateTime.now().difference(lastCooked).inDays;
        if (daysSince > 45) parts.add('Pas mangé depuis un moment');
      }
    }

    final season = _normalizeSeason(recipe.season);
    if (season == getCurrentSeason()) parts.add('De saison');
    else if (season == 'Les deux') parts.add('Toutes saisons');

    final t = recipe.time.trim().toLowerCase();
    if (t.contains('15')) parts.add('Très rapide');
    else if (t.contains('30')) parts.add('Rapide');
    else if (t.contains('+')) parts.add('Pour le weekend');

    return parts.isEmpty ? 'Recommandé' : parts.take(2).join(' · ');
  }

  // ─── Trouve la date la plus récente et le nombre de fois planifiée ────────
  static Map<String, Map<String, dynamic>> buildRecipeHistory(Map<String, Map<String, dynamic>> cachedMeals) {
    final Map<String, Map<String, dynamic>> history = {};
    final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
    
    for (final dateKey in cachedMeals.keys) {
      if (dateKey.startsWith('20') && !dateKey.contains('W')) {
        try {
          final DateTime mealDate = DateTime.parse(dateKey);
          final dayData = cachedMeals[dateKey]!;
          
          for (final moment in ['midi', 'soir']) {
            final mealName = (dayData[moment]?['meal'] as String? ?? '').toLowerCase().trim();
            if (mealName.isNotEmpty) {
              final entry = history.putIfAbsent(mealName, () => {'lastDate': null, 'count': 0});
              
              // On ne compte pour le bonus que si c'est récent (6 mois)
              if (mealDate.isAfter(sixMonthsAgo)) {
                entry['count'] = (entry['count'] as int) + 1;
              }
              
              final existingDate = entry['lastDate'] as DateTime?;
              if (existingDate == null || mealDate.isAfter(existingDate)) {
                entry['lastDate'] = mealDate;
              }
            }
          }
        } catch (_) {}
      }
    }
    return history;
  }

  // ─── Point d'entrée principal ─────────────────────────────────────────────
  /// Retourne les recettes d'un [type] données, triées par score décroissant.
  /// [isWeekend] indique si on recommande pour un repas de week-end.
  static List<RecipeScore> recommend({
    required List<Recipe> recipes,
    required Map<String, Map<String, dynamic>> recipeHistory,
    required String type, // 'Plat', 'Entrée', 'Dessert'
    bool isWeekend = false,
    int topN = 6,
  }) {
    final filtered = recipes.where((r) => r.type == type).toList();
    final scored = filtered.map((recipe) {
      final name = recipe.name.toLowerCase().trim();
      final historyEntry = recipeHistory[name] ?? {'lastDate': null, 'count': 0};
      
      // Calcul du score de base
      double baseScore = _seasonScore(recipe)
          + _recencyScore(recipe, historyEntry)
          + _noveltyScore(recipe)
          + _popularityScore(historyEntry['count'] as int? ?? 0)
          + _prepTimeScore(recipe, isWeekend: isWeekend);
          
      // Ajout d'une très légère variance aléatoire (0.0 à 0.3) 
      final randomVariance = (DateTime.now().millisecond % 30) / 100.0;
      final finalScore = baseScore + randomVariance;

      return RecipeScore(
        recipe: recipe,
        score: finalScore,
        reason: _buildReason(recipe, historyEntry),
      );
    }).toList();

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(topN).toList();
  }
}
