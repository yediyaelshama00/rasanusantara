import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';
import '../models/cooking_schedule_model.dart';
import '../models/recipe_model.dart';

class RecipeRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<Recipe>> getRecipes() async {
    final db = await _db.database;
    final rows = await db.query('recipes', orderBy: 'name ASC');
    return rows.map(Recipe.fromMap).toList();
  }

  Future<List<Recipe>> getPopularRecipes() async {
    final db = await _db.database;
    final rows = await db.query('recipes', limit: 5);
    return rows.map(Recipe.fromMap).toList();
  }

  Future<List<Recipe>> searchRecipes({String keyword = '', String island = '', String ingredient = '', String difficulty = ''}) async {
    final db = await _db.database;
    final where = <String>[];
    final args = <Object>[];

    if (keyword.trim().isNotEmpty) {
      where.add('(name LIKE ? OR province LIKE ? OR description LIKE ?)');
      args.add('%${keyword.trim()}%');
      args.add('%${keyword.trim()}%');
      args.add('%${keyword.trim()}%');
    }

    if (island.isNotEmpty) {
      where.add('island = ?');
      args.add(island);
    }

    if (ingredient.isNotEmpty) {
      where.add('ingredients LIKE ?');
      args.add('%$ingredient%');
    }

    if (difficulty.isNotEmpty) {
      where.add('difficulty = ?');
      args.add(difficulty);
    }

    final rows = await db.query(
      'recipes',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'name ASC',
    );

    return rows.map(Recipe.fromMap).toList();
  }

  Future<List<Recipe>> getRecipesByIsland(String island) async {
    final db = await _db.database;
    final rows = await db.query('recipes', where: 'island = ?', whereArgs: [island], orderBy: 'name ASC');
    return rows.map(Recipe.fromMap).toList();
  }

  Future<bool> isFavorite(int userId, int recipeId) async {
    final db = await _db.database;
    final rows = await db.query('favorites', where: 'user_id = ? AND recipe_id = ?', whereArgs: [userId, recipeId], limit: 1);
    return rows.isNotEmpty;
  }

  Future<void> toggleFavorite(int userId, int recipeId) async {
    final db = await _db.database;
    final exists = await isFavorite(userId, recipeId);
    if (exists) {
      await db.delete('favorites', where: 'user_id = ? AND recipe_id = ?', whereArgs: [userId, recipeId]);
    } else {
      await db.insert('favorites', {'user_id': userId, 'recipe_id': recipeId}, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future<List<Recipe>> getFavoriteRecipes(int userId) async {
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT r.* FROM recipes r
      INNER JOIN favorites f ON f.recipe_id = r.id
      WHERE f.user_id = ?
      ORDER BY f.created_at DESC
    ''', [userId]);
    return rows.map(Recipe.fromMap).toList();
  }

  Future<void> addSearchHistory(int userId, String keyword) async {
    if (keyword.trim().isEmpty) return;
    final db = await _db.database;
    await db.insert('search_history', {'user_id': userId, 'keyword': keyword.trim()});
  }

  Future<void> addSchedule(int userId, int recipeId, DateTime cookingTime, String note) async {
    final db = await _db.database;
    await db.insert('cooking_schedules', {
      'user_id': userId,
      'recipe_id': recipeId,
      'cooking_time': cookingTime.toIso8601String(),
      'note': note,
    });
  }

  Future<List<CookingSchedule>> getSchedules(int userId) async {
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT 
        s.id AS schedule_id,
        s.user_id,
        s.recipe_id,
        s.cooking_time,
        s.note,
        r.id,
        r.name,
        r.province,
        r.island,
        r.description,
        r.ingredients,
        r.steps,
        r.cook_time_minutes,
        r.difficulty,
        r.estimated_cost,
        r.emoji
      FROM cooking_schedules s
      INNER JOIN recipes r ON r.id = s.recipe_id
      WHERE s.user_id = ?
      ORDER BY s.cooking_time ASC
    ''', [userId]);

    return rows.map((row) {
      return CookingSchedule(
        id: row['schedule_id'] as int,
        userId: row['user_id'] as int,
        recipeId: row['recipe_id'] as int,
        cookingTime: row['cooking_time'] as String,
        note: row['note'] as String? ?? '',
        recipe: Recipe.fromMap(row),
      );
    }).toList();
  }

  Future<void> deleteSchedule(int id) async {
    final db = await _db.database;
    await db.delete('cooking_schedules', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> cleanupExpiredSchedules(int userId) async {
    final db = await _db.database;
    final now = DateTime.now().toIso8601String();
    await db.delete(
      'cooking_schedules',
      where: 'user_id = ? AND cooking_time <= ?',
      whereArgs: [userId, now],
    );
  }

  Future<void> saveFeedback({required int userId, required String impression, required String suggestion}) async {
    final db = await _db.database;
    await db.insert('feedbacks', {
      'user_id': userId,
      'impression': impression.trim(),
      'suggestion': suggestion.trim(),
    });
  }
}
