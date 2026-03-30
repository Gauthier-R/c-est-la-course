class Recipe {
  final String id;
  final String name;
  final String type; // e.g. 'Entrée', 'Plat', 'Dessert'
  final String season; // e.g. 'Eté', 'Hiver', 'Les deux'
  final String time; // e.g. '- 15 min', '- 1h', '+ 1h'
  final String description;
  final String? imageBase64;
  final List<Map<String, dynamic>> ingredients; // {name, quantity, unit}

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
      imageBase64: map['imageBase64'],
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
