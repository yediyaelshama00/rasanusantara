import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_keys.dart';
import '../models/culinary_place_model.dart';

class GeoapifyPlacesService {
  static const Map<String, List<String>> styleKeywords = {
    'Aceh': [
      'mie aceh',
      'aceh',
    ],
    'Sumatera Utara': [
      'batak',
      'lapo',
      'arsik',
      'saksang',
    ],
    'Sumatera Barat': [
      'padang',
      'minang',
      'rendang',
      'rumah makan padang',
    ],
    'Riau': [
      'melayu',
      'riau',
    ],
    'Kepulauan Riau': [
      'melayu',
      'tanjung pinang',
    ],
    'Jambi': [
      'tempoyak',
      'jambi',
    ],
    'Sumatera Selatan': [
      'pempek',
      'tekwan',
      'palembang',
    ],
    'Bengkulu': [
      'pendap',
      'bengkulu',
    ],
    'Lampung': [
      'seruit',
      'lampung',
    ],
    'Bangka Belitung': [
      'mie bangka',
      'bangka',
    ],
    'DKI Jakarta': [
      'betawi',
      'kerak telor',
      'soto betawi',
    ],
    'Banten': [
      'rabeg',
      'banten',
    ],
    'Jawa Barat': [
      'sunda',
      'sundanese',
      'nasi timbel',
      'karedok',
    ],
    'Jawa Tengah': [
      'soto kudus',
      'lumpia',
      'jawa tengah',
    ],
    'DI Yogyakarta': [
      'gudeg',
      'jogja',
      'yogyakarta',
      'sate klathak',
    ],
    'Jawa Timur': [
      'rawon',
      'pecel',
      'lamongan',
      'rujak cingur',
    ],
    'Bali': [
      'betutu',
      'sate lilit',
      'bali',
      'lawar',
    ],
    'Nusa Tenggara Barat': [
      'ayam taliwang',
      'plecing',
      'lombok',
    ],
    'Nusa Tenggara Timur': [
      'sei sapi',
      'ntt',
      'kupang',
    ],
    'Kalimantan Barat': [
      'choi pan',
      'singkawang',
    ],
    'Kalimantan Tengah': [
      'kalimantan tengah',
      'dayak',
    ],
    'Kalimantan Selatan': [
      'soto banjar',
      'banjar',
      'ketupat kandangan',
    ],
    'Kalimantan Timur': [
      'samarinda',
      'kalimantan timur',
    ],
    'Kalimantan Utara': [
      'tarakan',
      'kalimantan utara',
    ],
    'Sulawesi Utara': [
      'manado',
      'tinutuan',
      'rica rica',
    ],
    'Gorontalo': [
      'gorontalo',
      'binthe biluhuta',
    ],
    'Sulawesi Tengah': [
      'kaledo',
      'palu',
    ],
    'Sulawesi Barat': [
      'mandar',
      'sulawesi barat',
    ],
    'Sulawesi Selatan': [
      'coto makassar',
      'konro',
      'makassar',
      'coto',
    ],
    'Sulawesi Tenggara': [
      'sinonggi',
      'kendari',
    ],
    'Maluku': [
      'papeda',
      'maluku',
    ],
    'Maluku Utara': [
      'ternate',
      'maluku utara',
    ],
    'Papua': [
      'papeda',
      'papua',
    ],
    'Papua Barat': [
      'papeda',
      'manokwari',
    ],
    'Papua Tengah': [
      'papua',
    ],
    'Papua Selatan': [
      'papua',
    ],
    'Papua Pegunungan': [
      'papua',
    ],
    'Papua Barat Daya': [
      'sorong',
      'papua',
    ],
  };

  Future<List<CulinaryPlaceModel>> searchRestaurants({
    required String culinaryStyle,
    required double latitude,
    required double longitude,
    int radiusMeters = 75000,
  }) async {
    final keywords = styleKeywords[culinaryStyle] ?? [culinaryStyle];

    final Map<String, CulinaryPlaceModel> results = {};

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
      'limit': '50',
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
