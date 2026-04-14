import 'dart:convert';
import 'dart:typed_data';

class Recipe {
  final String id;
  final String name;
  final String type; // e.g. 'Entrée', 'Plat', 'Dessert'
  final String season; // e.g. 'Eté', 'Hiver', 'Les deux'
  final String time; // e.g. '- 15 min', '- 1h', '+ 1h'
  final String description;
  final String? imageBase64;
  final List<Map<String, dynamic>> ingredients; // {name, quantity, unit}

  // Cache lazy pour l'image décodée
  Uint8List? _cachedBytes;
  bool _decoded = false;
  Uint8List? get imageBytes {
    if (_decoded) return _cachedBytes;
    _decoded = true;
    if (imageBase64 != null && imageBase64!.isNotEmpty) {
      try {
        var str = imageBase64!;
        if (str.startsWith('data:image')) str = str.split(',').last;
        _cachedBytes = base64Decode(str);
      } catch (_) {}
    }
    return _cachedBytes;
  }

  Recipe({
    required this.id,
    required this.name,
    required this.type,
    required this.season,
    required this.time,
    required this.description,
    this.imageBase64,
    required this.ingredients,
  });

  factory Recipe.fromMap(String id, Map<String, dynamic> map) {
    return Recipe(
      id: id,
      name: map['name'] ?? '',
      type: map['type'] ?? 'Plat',
      season: map['season'] ?? 'Les deux',
      time: map['time'] ?? '- 1h',
      description: map['description'] ?? '',
      imageBase64: map['imageBase64'] as String?,
      ingredients: List<Map<String, dynamic>>.from(map['ingredients'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'season': season,
      'time': time,
      'description': description,
      if (imageBase64 != null) 'imageBase64': imageBase64,
      'ingredients': ingredients,
    };
  }
}
