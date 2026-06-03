import 'dart:convert';
import 'dart:io';
import '../models/recipe_model.dart';

class AiRecipeService {
  final String apiKey;

  AiRecipeService({required this.apiKey});

  static const String _baseUrl =
      'https://openrouter.ai/api/v1/chat/completions';

  String _availableRecipes = '';

  void setAvailableRecipes(String recipeNames) {
    _availableRecipes = recipeNames;
  }

  String get _systemPrompt => '''
  Kamu adalah "Tanya Dapur AI", asisten kuliner Nusantara yang ramah dan berpengetahuan luas.

  Tugasmu:
  1. Merekomendasikan resep masakan tradisional Indonesia berdasarkan bahan yang dimiliki user
  2. Menjawab pertanyaan seputar masakan, rempah, dan budaya kuliner Indonesia
  3. Memberikan tips memasak yang praktis

  ${_availableRecipes.isNotEmpty ? 'Daftar resep yang tersedia di aplikasi: $_availableRecipes. Jika merekomendasikan resep, UTAMAKAN resep dari daftar ini.' : ''}

  Aturan:
  - Selalu jawab dalam Bahasa Indonesia yang ramah dan natural
  - Fokus pada masakan Nusantara, tapi boleh jawab pertanyaan masakan lain sambil tetap menghubungkan ke kuliner Indonesia
  - Jika user menyebut bahan, rekomendasikan 2-3 resep Nusantara yang cocok beserta alasannya
  - Jawaban singkat dan padat, maksimal 3-4 kalimat per poin
  - Gunakan emoji sesekali agar lebih hidup
  - Jangan gunakan markdown bold/italic, tulis biasa saja
  ''';

  final List<Map<String, dynamic>> _history = [];

  /// Kirim pesan dengan history — AI ingat konteks sebelumnya
  Future<String> chat(String userMessage) async {
    _history.add({'role': 'user', 'content': userMessage});

    final body = jsonEncode({
      'model': 'openai/gpt-oss-120b', // model yang digunakan
      'messages': [
        {'role': 'system', 'content': _systemPrompt},
        ..._history,
      ],
      'max_tokens': 512,
      'temperature': 0.7,
    });

    try {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 10);
      final req = await client.postUrl(Uri.parse(_baseUrl));
      req.headers.contentType = ContentType.json;
      req.headers.set('Authorization', 'Bearer $apiKey');
      req.write(body);
      final res = await req.close().timeout(const Duration(seconds: 15));
      final responseBody = await res.transform(utf8.decoder).join();
      client.close();

      if (res.statusCode != 200) {
        print('STATUS CODE: ${res.statusCode}');
        print('ERROR BODY: $responseBody');
        _history.removeLast();
        return 'Maaf, terjadi kesalahan. Coba lagi ya!';
      }

      final data = jsonDecode(responseBody) as Map<String, dynamic>;
      final text = data['choices']?[0]?['message']?['content'] as String? ??
          'Maaf, aku tidak bisa menjawab sekarang.';

      _history.add({'role': 'assistant', 'content': text});
      return text;
    } catch (e) {
      print('AI Error: $e');
      _history.removeLast();
      return 'Koneksi bermasalah. Pastikan internetmu aktif ya!';
    }
  }

  /// Kirim bahan sebagai prompt terstruktur
  Future<String> recommendFromIngredients(List<String> ingredients) async {
    final ingredientList = ingredients.join(', ');
    final prompt = 'Aku punya bahan-bahan ini: $ingredientList. '
        'Resep masakan Nusantara apa yang bisa aku buat? '
        'Sebutkan 2-3 rekomendasi beserta alasan singkatnya.';
    return chat(prompt);
  }

  /// Reset history (misal saat user mulai sesi baru)
  void clearHistory() {
    _history.clear();
  }

  List<Recipe> extractMatchingRecipes(
      String aiResponse, List<Recipe> dbRecipes) {
    final responseLower = aiResponse.toLowerCase();
    final matched = <Recipe>[];

    for (final recipe in dbRecipes) {
      final nameLower = recipe.name.toLowerCase();

      // Cocokkan nama penuh dulu — ini paling akurat
      if (responseLower.contains(nameLower)) {
        matched.add(recipe);
        continue;
      }

      // Pencocokan per kata HANYA untuk resep nama satu kata
      // misal "Rendang", "Papeda", "Pempek", "Rawon", "Seruit"
      final nameWords = nameLower.split(' ');
      if (nameWords.length == 1 && nameWords[0].length >= 4) {
        if (responseLower.contains(nameWords[0])) {
          matched.add(recipe);
        }
      }
    }

    return matched;
  }
}
