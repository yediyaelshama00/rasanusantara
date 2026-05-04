import 'recipe_model.dart';

class CookingSchedule {
  final int? id;
  final int userId;
  final int recipeId;
  final String cookingTime;
  final String note;
  final Recipe? recipe;

  const CookingSchedule({
    this.id,
    required this.userId,
    required this.recipeId,
    required this.cookingTime,
    required this.note,
    this.recipe,
  });

  factory CookingSchedule.fromMap(Map<String, Object?> map) {
    return CookingSchedule(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      recipeId: map['recipe_id'] as int,
      cookingTime: map['cooking_time'] as String,
      note: map['note'] as String? ?? '',
      recipe: map.containsKey('name') ? Recipe.fromMap(map) : null,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'recipe_id': recipeId,
      'cooking_time': cookingTime,
      'note': note,
    };
  }
}
