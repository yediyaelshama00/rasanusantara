class Recipe {
  final int? id;
  final String name;
  final String province;
  final String island;
  final String description;
  final String ingredients;
  final String steps;
  final int cookTimeMinutes;
  final String difficulty;
  final int estimatedCost;
  final String imagePath;
  final int baseServings; // <-- BARU: jumlah porsi dasar resep ini

  const Recipe({
    this.id,
    required this.name,
    required this.province,
    required this.island,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.cookTimeMinutes,
    required this.difficulty,
    required this.estimatedCost,
    required this.imagePath,
    this.baseServings = 4, // default 4 porsi jika tidak diisi
  });

  factory Recipe.fromMap(Map<String, Object?> map) {
    return Recipe(
      id: map['id'] as int?,
      name: map['name'] as String,
      province: map['province'] as String,
      island: map['island'] as String,
      description: map['description'] as String,
      ingredients: map['ingredients'] as String,
      steps: map['steps'] as String,
      cookTimeMinutes: map['cook_time_minutes'] as int,
      difficulty: map['difficulty'] as String,
      estimatedCost: map['estimated_cost'] as int,
      imagePath: map['image_path'] as String,
      baseServings: (map['base_servings'] as int?) ?? 4,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'province': province,
      'island': island,
      'description': description,
      'ingredients': ingredients,
      'steps': steps,
      'cook_time_minutes': cookTimeMinutes,
      'difficulty': difficulty,
      'estimated_cost': estimatedCost,
      'image_path': imagePath,
      'base_servings': baseServings,
    };
  }
}