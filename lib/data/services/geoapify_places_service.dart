import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_keys.dart';
import '../models/culinary_place_model.dart';

class GeoapifyPlacesService {
final Map<String, List<String>> styleKeywords = const {
  'Sumatera Utara': [
    'lapo',
    'batak',
    'rumah makan batak',
    'masakan batak',
    'saksang',
    'arsik',
    'andaliman',
    'bpk',
    'makanan medan',
  ],
  'Sumatera Barat': [
    'padang',
    'rumah makan padang',
    'masakan padang',
    'rendang',
    'minang',
    'sate padang',
    'nasi padang',
  ],
  'Yogyakarta': [
    'gudeg',
    'jogja',
    'yogyakarta',
    'sate klatak',
    'bakpia',
  ],
  'Jawa Timur': [
    'rawon',
    'soto lamongan',
    'pecel madiun',
    'tahu tek',
    'jawa timur',
  ],
  'Bali': [
    'bali',
    'balinese food',
    'betutu',
    'ayam betutu',
    'sate lilit',
    'lawar',
  ],
  'Sulawesi Selatan': [
    'coto',
    'coto makassar',
    'konro',
    'sop konro',
    'makassar',
    'pisang ijo',
  ],
  'Papua': [
    'papua',
    'papeda',
    'ikan kuah kuning',
  ],
  'Palembang': [
    'pempek',
    'palembang',
    'tekwan',
    'model palembang',
  ],
};

  Future<List<CulinaryPlaceModel>> searchRestaurants({
    required String culinaryStyle,
    required double latitude,
    required double longitude,
    int radiusMeters = 30000,
  }) async {
    final keywords = styleKeywords[culinaryStyle] ?? [culinaryStyle];
    final results = <String, CulinaryPlaceModel>{};

    for (final keyword in keywords.take(4)) {
      final places = await _requestPlaces(
        keyword: keyword,
        latitude: latitude,
        longitude: longitude,
        radiusMeters: radiusMeters,
      );

      for (final place in places) {
        results[place.id] = place;
      }
    }

    if (results.isEmpty) {
      final fallback = await _requestPlaces(
        keyword: null,
        latitude: latitude,
        longitude: longitude,
        radiusMeters: radiusMeters,
      );

      for (final place in fallback) {
        results[place.id] = place;
      }
    }

    final list = results.values.where((item) {
      return item.latitude != 0 && item.longitude != 0;
    }).toList();

    list.sort((a, b) => a.distance.compareTo(b.distance));

    return list;
  }

  Future<List<CulinaryPlaceModel>> _requestPlaces({
    required String? keyword,
    required double latitude,
    required double longitude,
    required int radiusMeters,
  }) async {
    final params = <String, String>{
      'categories': 'catering.restaurant,catering.fast_food,catering.cafe',
      'filter': 'circle:$longitude,$latitude,$radiusMeters',
      'bias': 'proximity:$longitude,$latitude',
      'limit': '20',
      'lang': 'id',
      'apiKey': ApiKeys.geoapifyApiKey,
    };

    if (keyword != null && keyword.trim().isNotEmpty) {
      params['name'] = keyword;
    }

    final uri = Uri.https(
      'api.geoapify.com',
      '/v2/places',
      params,
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil data restoran');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final features = data['features'] as List<dynamic>? ?? [];

    return features.map((item) {
      return CulinaryPlaceModel.fromGeoapify(
        item as Map<String, dynamic>,
        matchedKeyword: keyword,
      );
    }).toList();
  }
}