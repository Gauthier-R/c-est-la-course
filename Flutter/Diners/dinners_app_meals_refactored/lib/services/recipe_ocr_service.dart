import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Résultat du parsing OCR par l'IA d'une recette
class OcrRecipeResult {
  final String? name;
  final String? description;
  final String? time;
  final String? type;
  final List<Map<String, dynamic>> ingredients;
  final int detectedFields;

  const OcrRecipeResult({
    this.name,
    this.description,
    this.time,
    this.type,
    this.ingredients = const [],
    this.detectedFields = 0,
  });

  @override
  String toString() =>
      'OcrRecipeResult(name=$name, type=$type, time=$time, '
      'description=${description != null ? "${description!.length} chars" : "null"}, '
      'ingredients=${ingredients.length}, detected=$detectedFields)';
}

class RecipeOcrService {
  // CLÉ API HARDCODÉE POUR LE PROTOTYPAGE :
  // Attention: pour un usage en production, il vaut mieux stocker cette clé sur un serveur
  // Firebase Remote Config, ou via des variables d'environnement.
  static const String _apiKey = 'AIzaSyDKvoEuk51QOhgEi_gp_tjHGz_fXHQDY_k';

  /// Analyse une ou plusieurs images via Gemini et retourne les données structurées.
  /// Si plusieurs images sont passées, l'IA les traite comme les pages d'une même recette.
  /// Nombre max de tentatives en cas d'erreur "recitation"
  static const int _maxRecitationRetries = 2;

  static Future<OcrRecipeResult> analyze(List<File> imageFiles) async {
    if (imageFiles.isEmpty) return const OcrRecipeResult();

    // Préparer les images en bytes une seule fois
    final imageDataList = <Uint8List>[];
    for (final imageFile in imageFiles) {
      final bytes = await imageFile.readAsBytes();
      imageDataList.add(bytes);
    }

    // Essai avec gemini-2.5-flash (avec retry sur erreur "recitation")
    for (int attempt = 1; attempt <= _maxRecitationRetries; attempt++) {
      try {
        final result = await _tryAnalyze(
          modelName: 'gemini-2.5-flash',
          imageDataList: imageDataList,
          imageCount: imageFiles.length,
        );
        if (result.detectedFields >= 2) return result;

        debugPrint('⚠️ OCR: gemini-2.5-flash n\'a détecté que ${result.detectedFields} champ(s). '
            'Tentative avec gemini-2.0-flash...');
        break; // Pas une erreur recitation, on passe au fallback
      } catch (e) {
        final isRecitation = e.toString().contains('recitation');
        debugPrint('⚠️ OCR: Échec gemini-2.5-flash (tentative $attempt): $e');

        if (isRecitation && attempt < _maxRecitationRetries) {
          debugPrint('🔄 OCR: Erreur de récitation détectée, retry dans 2s...');
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }
        break; // Erreur non-recitation ou dernière tentative
      }
    }

    // Fallback avec gemini-2.0-flash
    try {
      return await _tryAnalyze(
        modelName: 'gemini-2.0-flash',
        imageDataList: imageDataList,
        imageCount: imageFiles.length,
      );
    } catch (e) {
      debugPrint('❌ OCR: Échec aussi avec gemini-2.0-flash: $e');
      return const OcrRecipeResult();
    }
  }

  static Future<OcrRecipeResult> _tryAnalyze({
    required String modelName,
    required List<Uint8List> imageDataList,
    required int imageCount,
  }) async {
    final model = GenerativeModel(
      model: modelName,
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.4, // Température modérée pour favoriser la reformulation (évite le filtre "recitation")
      ),
    );

    final prompt = _buildPrompt(imageCount);

    final parts = <Part>[TextPart(prompt)];
    for (final imageData in imageDataList) {
      parts.add(DataPart('image/jpeg', imageData));
    }

    final content = [Content.multi(parts)];

    debugPrint('🔍 OCR: Envoi de $imageCount image(s) à $modelName...');
    final response = await model.generateContent(content);
    final rawText = response.text ?? '';

    debugPrint('📦 OCR ($modelName) réponse brute (${rawText.length} chars):\n'
        '${rawText.substring(0, rawText.length > 500 ? 500 : rawText.length)}'
        '${rawText.length > 500 ? "..." : ""}');

    return _parseJsonResponse(rawText);
  }

  static String _buildPrompt(int imageCount) {
    final introPrompt = imageCount > 1
        ? 'Tu reçois $imageCount images qui sont les différentes pages ou parties d\'une même recette de cuisine. Analyse-les toutes ensemble pour reconstituer la recette complète.'
        : 'Tu reçois une image d\'une recette de cuisine.';

    return '''
$introPrompt

INSTRUCTIONS CRITIQUES :
1. L'image peut être orientée dans n'importe quel sens (portrait, paysage, à l'envers). Regarde attentivement l'orientation du texte avant de lire.
2. L'image peut contenir du texte imprimé (magazine, livre, site web imprimé) ET/OU du texte manuscrit (écriture à la main). Traite les deux cas.
3. Si l'image contient un article de magazine ou de journal, lis TOUTES les sections (titre, ingrédients, étapes, infos pratiques, etc.), même si elles sont dans des colonnes ou encadrés différents.
4. Si tu vois des notes manuscrites ajoutées à un texte imprimé, intègre aussi ces informations.

Tu dois retourner un objet JSON avec la structure exacte suivante. Remplis TOUS les champs que tu peux détecter :

{
  "name": "Nom du plat (capitalisé). null UNIQUEMENT si aucun nom n'est détectable.",
  "type": "Le type de plat. Doit être EXACTEMENT l'une de ces valeurs : 'Entrée', 'Plat', 'Dessert'. Déduis-le du contenu si ce n'est pas explicite. Défaut : 'Plat'.",
  "time": "Durée de préparation. Doit être EXACTEMENT l'une de ces 3 valeurs : '- 15 min', '- 1h', '+ 1h'. Choisis la plus proche en additionnant temps de préparation et cuisson si les deux sont indiqués. Défaut : '- 1h'.",
  "description": "Les instructions et étapes de préparation, reformulées proprement avec des retours à la ligne (\\n) entre chaque étape. Si les étapes sont numérotées dans l'original, conserve cette numérotation. null UNIQUEMENT si aucune instruction n'est lisible.",
  "ingredients": [
    {
      "name": "Nom de l'ingrédient (singulier, première lettre majuscule)",
      "quantity": 1,
      "unit": "g"
    }
  ]
}

RÈGLES POUR LES INGRÉDIENTS :
- "quantity" doit être un nombre (ex: 1, 0.5, 1.5, 200). Ne pas arrondir à l'entier si une décimale est présente.
- "unit" doit être l'une de ces valeurs exactes : "g", "kg", "ml", "cl", "L", "c.à.s", "c.à.c", "pincée", "QT"
- Si l'ingrédient a un nombre d'unités (ex: "4 tomates", "2 oeufs"), utilise la quantité comme nombre et "QT" comme unité
- Si aucune quantité n'est indiquée, mets quantity=1 et unit="QT"
- IMPORTANT : extrais TOUS les ingrédients visibles, même si partiellement lisibles. Corrige l'orthographe si nécessaire.

RÈGLES DE REFORMULATION :
- Pour le champ "description", REFORMULE les étapes avec tes propres mots. Ne copie JAMAIS le texte mot pour mot.
- Réécris les instructions de manière claire et concise, en gardant le sens mais en changeant la formulation.
- Ceci est essentiel pour respecter les droits d'auteur.

IMPORTANT : Ne retourne QUE le JSON, sans texte avant ou après. Pas de commentaires, pas de markdown.
''';
  }

  static OcrRecipeResult _parseJsonResponse(String rawResponse) {
    try {
      // Nettoyage de la réponse
      String jsonString = rawResponse.trim();

      // Supprimer d'éventuels BOM ou caractères invisibles
      jsonString = jsonString.replaceAll('\u{FEFF}', '');

      // Supprimer les blocs markdown ```json ... ```
      final jsonBlockRegex = RegExp(r'```(?:json)?\s*\n?([\s\S]*?)\n?```');
      final match = jsonBlockRegex.firstMatch(jsonString);
      if (match != null) {
        jsonString = match.group(1)!.trim();
        debugPrint('📝 OCR: JSON extrait d\'un bloc markdown');
      }

      // Si la réponse commence par du texte avant le {, tronquer
      final firstBrace = jsonString.indexOf('{');
      if (firstBrace > 0) {
        debugPrint('📝 OCR: Texte avant le JSON supprimé ($firstBrace chars)');
        jsonString = jsonString.substring(firstBrace);
      }

      // Si la réponse contient du texte après le dernier }, tronquer
      final lastBrace = jsonString.lastIndexOf('}');
      if (lastBrace >= 0 && lastBrace < jsonString.length - 1) {
        jsonString = jsonString.substring(0, lastBrace + 1);
      }

      // Supprimer les virgules traînantes avant } ou ]
      jsonString = jsonString.replaceAll(RegExp(r',\s*([}\]])'), r'$1');

      if (jsonString.isEmpty || !jsonString.startsWith('{')) {
        debugPrint('❌ OCR: La réponse nettoyée n\'est pas du JSON valide');
        return const OcrRecipeResult();
      }

      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      
      final String? name = _cleanString(decoded['name']);
      final String? type = _cleanString(decoded['type']);
      final String? time = _normalizeTime(decoded['time']);
      final String? description = _cleanString(decoded['description']);
      
      final List<Map<String, dynamic>> finalIngredients = [];
      int detectedFields = 0;

      if (name != null && name.isNotEmpty) detectedFields++;
      if (time != null && time.isNotEmpty) detectedFields++;
      if (description != null && description.isNotEmpty) detectedFields++;

      if (decoded['ingredients'] != null) {
        final rawIngredients = decoded['ingredients'] as List<dynamic>;
        for (var rawIng in rawIngredients) {
          if (rawIng is Map<String, dynamic>) {
            final ingName = rawIng['name']?.toString().trim() ?? 'Inconnu';
            if (ingName.isEmpty || ingName == 'Inconnu') continue;

            final qtyRaw = rawIng['quantity'];
            double qty;
            if (qtyRaw is num) {
              qty = qtyRaw.toDouble();
            } else if (qtyRaw is String) {
              qty = double.tryParse(qtyRaw.replaceAll(',', '.')) ?? 1.0;
            } else {
              qty = 1.0;
            }

            final String unit = _normalizeUnit(rawIng['unit']?.toString() ?? 'QT');
            
            finalIngredients.add({
              'name': ingName[0].toUpperCase() + ingName.substring(1),
              'quantity': qty > 0 ? qty : 1,
              'unit': unit,
            });
          }
        }
        if (finalIngredients.isNotEmpty) detectedFields++;
      }

      final result = OcrRecipeResult(
        name: name,
        time: time,
        type: type,
        description: description,
        ingredients: finalIngredients,
        detectedFields: detectedFields,
      );

      debugPrint('✅ OCR: Résultat parsé: $result');
      return result;
    } catch (e, stackTrace) {
      debugPrint('❌ OCR: Erreur lors du parsing JSON: $e');
      debugPrint('Stack: $stackTrace');
      debugPrint('Réponse brute: ${rawResponse.substring(0, rawResponse.length > 300 ? 300 : rawResponse.length)}');
      return const OcrRecipeResult();
    }
  }

  /// Nettoie une chaîne (null/empty → null)
  static String? _cleanString(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
  }

  /// Normalise le temps vers l'une des 3 valeurs acceptées
  static String? _normalizeTime(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim().toLowerCase();
    if (s.isEmpty) return null;

    // Mapping direct
    if (s == '- 15 min' || s == '-15 min' || s == '- 15min') return '- 15 min';
    if (s == '- 1h' || s == '-1h' || s == '- 1 h') return '- 1h';
    if (s == '+ 1h' || s == '+1h' || s == '+ 1 h') return '+ 1h';

    // Essayer d'extraire un nombre de minutes
    final minuteMatch = RegExp(r'(\d+)\s*min').firstMatch(s);
    if (minuteMatch != null) {
      final minutes = int.parse(minuteMatch.group(1)!);
      if (minutes <= 15) return '- 15 min';
      if (minutes <= 60) return '- 1h';
      return '+ 1h';
    }

    // Essayer d'extraire un nombre d'heures
    final hourMatch = RegExp(r'(\d+)\s*h').firstMatch(s);
    if (hourMatch != null) {
      final hours = int.parse(hourMatch.group(1)!);
      if (hours <= 1) return '- 1h';
      return '+ 1h';
    }

    return '- 1h'; // Défaut
  }

  /// Normalise l'unité vers l'une des valeurs acceptées
  static String _normalizeUnit(String raw) {
    final s = raw.trim().toLowerCase();
    const validUnits = ['g', 'kg', 'ml', 'cl', 'l', 'c.à.s', 'c.à.c', 'pincée', 'qt'];
    const normalizedUnits = ['g', 'kg', 'ml', 'cl', 'L', 'c.à.s', 'c.à.c', 'pincée', 'QT'];

    // Mapping avec synonymes
    final synonyms = {
      'gramme': 'g', 'grammes': 'g',
      'kilogramme': 'kg', 'kilogrammes': 'kg', 'kilo': 'kg', 'kilos': 'kg',
      'millilitre': 'ml', 'millilitres': 'ml',
      'centilitre': 'cl', 'centilitres': 'cl',
      'litre': 'L', 'litres': 'L',
      'cuillère à soupe': 'c.à.s', 'cuillères à soupe': 'c.à.s',
      'cas': 'c.à.s', 'c.a.s': 'c.à.s', 'càs': 'c.à.s',
      'cuil. à soupe': 'c.à.s', 'cuill. à soupe': 'c.à.s',
      'cuillère à café': 'c.à.c', 'cuillères à café': 'c.à.c',
      'cac': 'c.à.c', 'c.a.c': 'c.à.c', 'càc': 'c.à.c',
      'cuil. à café': 'c.à.c', 'cuill. à café': 'c.à.c',
      'pincée': 'pincée', 'pincées': 'pincée',
      'unité': 'QT', 'unités': 'QT', 'pièce': 'QT', 'pièces': 'QT',
    };

    // Vérifier correspondance directe (case insensitive)
    final idx = validUnits.indexOf(s);
    if (idx >= 0) return normalizedUnits[idx];

    // Vérifier synonymes
    if (synonyms.containsKey(s)) return synonyms[s]!;

    return 'QT'; // Défaut
  }
}
