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

  // ─── Score fréquence (0..3) — moins cuisiné = score plus élevé ───────────
  static double _frequencyScore(Recipe recipe, Map<String, int> cookCount) {
    final count = cookCount[recipe.name.toLowerCase().trim()] ?? 0;
    if (count == 0) return 3.0;
    if (count == 1) return 2.5;
    if (count == 2) return 2.0;
    if (count <= 4) return 1.5;
    if (count <= 7) return 1.0;
    if (count <= 10) return 0.5;
    return 0.0;
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
  static String _buildReason(Recipe recipe, Map<String, int> cookCount) {
    final parts = <String>[];
    final count = cookCount[recipe.name.toLowerCase().trim()] ?? 0;
    if (count == 0) parts.add('Jamais préparé');
    else if (count <= 2) parts.add('Peu préparé');

    final season = _normalizeSeason(recipe.season);
    if (season == getCurrentSeason()) parts.add('De saison');
    else if (season == 'Les deux') parts.add('Toutes saisons');

    final t = recipe.time.trim().toLowerCase();
    if (t.contains('15')) parts.add('Très rapide');
    else if (t.contains('30')) parts.add('Rapide');
    else if (t.contains('+')) parts.add('Pour le weekend');

    return parts.isEmpty ? 'Recommandé' : parts.take(2).join(' · ');
  }

  // ─── Compte les occurrences dans l'historique ─────────────────────────────
  static Map<String, int> buildCookCount(Map<String, Map<String, dynamic>> cachedMeals) {
    final Map<String, int> count = {};
    for (final dayData in cachedMeals.values) {
      for (final moment in ['midi', 'soir']) {
        final mealName = (dayData[moment]?['meal'] as String? ?? '').toLowerCase().trim();
        if (mealName.isNotEmpty) {
          count[mealName] = (count[mealName] ?? 0) + 1;
        }
      }
    }
    return count;
  }

  // ─── Point d'entrée principal ─────────────────────────────────────────────
  /// Retourne les recettes d'un [type] données, triées par score décroissant.
  /// [isWeekend] indique si on recommande pour un repas de week-end.
  static List<RecipeScore> recommend({
    required List<Recipe> recipes,
    required Map<String, int> cookCount,
    required String type, // 'Plat', 'Entrée', 'Dessert'
    bool isWeekend = false,
    int topN = 6,
  }) {
    final filtered = recipes.where((r) => r.type == type).toList();
    final scored = filtered.map((recipe) {
      final score = _seasonScore(recipe)
          + _frequencyScore(recipe, cookCount)
          + _prepTimeScore(recipe, isWeekend: isWeekend);
      return RecipeScore(
        recipe: recipe,
        score: score,
        reason: _buildReason(recipe, cookCount),
      );
    }).toList();

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(topN).toList();
  }
}
