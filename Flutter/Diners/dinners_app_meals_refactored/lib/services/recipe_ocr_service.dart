import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Résultat du parsing OCR par l'IA d'une recette
class OcrRecipeResult {
  final String? name;
  final String? description;
  final String? time;
  final List<Map<String, dynamic>> ingredients;
  final int detectedFields;

  const OcrRecipeResult({
    this.name,
    this.description,
    this.time,
    this.ingredients = const [],
    this.detectedFields = 0,
  });
}

class RecipeOcrService {
  // CLÉ API HARDCODÉE POUR LE PROTOTYPAGE :
  // Attention: pour un usage en production, il vaut mieux stocker cette clé sur un serveur
  // Firebase Remote Config, ou via des variables d'environnement.
  static const String _apiKey = 'AIzaSyDKvoEuk51QOhgEi_gp_tjHGz_fXHQDY_k';

  /// Analyse une ou plusieurs images via Gemini et retourne les données structurées.
  /// Si plusieurs images sont passées, l'IA les traite comme les pages d'une même recette.
  static Future<OcrRecipeResult> analyze(List<File> imageFiles) async {
    if (imageFiles.isEmpty) return const OcrRecipeResult();

    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );

    final introPrompt = imageFiles.length > 1
        ? 'Tu reçois ${imageFiles.length} images qui sont les différentes pages ou parties d\'une même recette de cuisine (souvent manuscrite). Analyse-les toutes ensemble pour reconstituer la recette complète.'
        : 'Tu reçois une image d\'une recette de cuisine (souvent manuscrite). Analyse-la attentivement.';

    final prompt = '''
$introPrompt

Tu es un assistant culinaire expert. Ton but est de lire attentivement ces images et d'en extraire les informations de manière très précise.

Tu dois impérativement retourner un objet JSON avec la structure exacte suivante :
{
  "name": "Nom du plat (capitalisé, null si introuvable)",
  "time": "Durée de préparation (doit être exactement l'une de ces 3 valeurs: '- 15 min', '- 1h', '+ 1h' - choisis la plus proche - null si indétectable)",
  "description": "Les instructions et étapes de préparation avec des retours à la ligne, formatées proprement. null si aucune instruction n'est lisible.",
  "ingredients": [
    {
      "name": "Nom de l'ingrédient au singulier, première lettre majuscule",
      "quantity": entier proportionnel (ex: si 1/2, mets 1 ou 0. Si 1.5, mets 1. Essaie de prioriser les entiers),
      "unit": "Unité exacte. Utilise 'g', 'kg', 'ml', 'cl', 'L', 'c.à.s', 'c.à.c', 'pincée'. Si aucune unité logique, utilise 'QT'."
    }
  ]
}

Si tu détectes des erreurs manifestes d'orthographe (comme un 'l' cursif pris pour un 'P' ex: 'Papin' au lieu de 'Lapin'), corrige-les intelligemment pour que ça ait un sens culinaire. 
Assure-toi que la liste `ingredients` retranscrive bien tout ce qui est détecté, avec des textes en français correct.
''';

    try {
      // Construct multi-part content with all images
      final parts = <Part>[TextPart(prompt)];
      for (final imageFile in imageFiles) {
        final imageBytes = await imageFile.readAsBytes();
        parts.add(DataPart('image/jpeg', imageBytes));
      }

      final content = [Content.multi(parts)];
      final response = await model.generateContent(content);
      return _parseJsonResponse(response.text ?? '{}');
    } catch (e) {
      debugPrint('Erreur Gemini : $e');
      // Return empty result in case of total failure
      return const OcrRecipeResult();
    }
  }

  static OcrRecipeResult _parseJsonResponse(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      
      final String? name = decoded['name'] as String?;
      final String? time = decoded['time'] as String?;
      final String? description = decoded['description'] as String?;
      
      final List<Map<String, dynamic>> finalIngredients = [];
      int detectedFields = 0;

      if (name != null && name.isNotEmpty) detectedFields++;
      if (time != null && time.isNotEmpty) detectedFields++;
      if (description != null && description.isNotEmpty) detectedFields++;

      if (decoded['ingredients'] != null) {
        final rawIngredients = decoded['ingredients'] as List<dynamic>;
        for (var rawIng in rawIngredients) {
          if (rawIng is Map<String, dynamic>) {
            final ingName = rawIng['name']?.toString() ?? 'Inconnu';
            final qtyNum = rawIng['quantity'];
            final int qty = (qtyNum is int) ? qtyNum : (qtyNum is double ? qtyNum.toInt() : 1);
            final String unit = rawIng['unit']?.toString() ?? 'QT';
            
            finalIngredients.add({
              'name': ingName,
              'quantity': qty > 0 ? qty : 1,
              'unit': unit,
            });
          }
        }
        if (finalIngredients.isNotEmpty) detectedFields++;
      }

      return OcrRecipeResult(
        name: name,
        time: time,
        description: description,
        ingredients: finalIngredients,
        detectedFields: detectedFields,
      );
    } catch (e) {
      debugPrint('Erreur lors du parsing JSON de Gemini : $e');
      return const OcrRecipeResult();
    }
  }
}
