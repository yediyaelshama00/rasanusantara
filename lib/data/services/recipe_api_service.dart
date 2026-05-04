import 'dart:convert';
import 'dart:io';
import '../models/recipe_model.dart';

class RecipeApiService {
  final String baseUrl;

  const RecipeApiService({required this.baseUrl});

  Future<List<Recipe>> fetchRecipes() async {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse('$baseUrl/recipes'));
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    client.close();
    if (response.statusCode < 200 || response.statusCode >= 300) throw Exception('Gagal memuat resep dari API');
    final data = jsonDecode(body) as List<dynamic>;
    return data.map((item) => Recipe.fromMap(Map<String, Object?>.from(item as Map))).toList();
  }

  Future<String> askRecommendation(String prompt) async {
    final client = HttpClient();
    final request = await client.postUrl(Uri.parse('$baseUrl/ai/recommend'));
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode({'prompt': prompt}));
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    client.close();
    if (response.statusCode < 200 || response.statusCode >= 300) throw Exception('Gagal meminta rekomendasi AI');
    final data = jsonDecode(body) as Map<String, dynamic>;
    return data['answer']?.toString() ?? '';
  }
}
