class CulinaryPlaceModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int distance;
  final String? matchedKeyword;

  const CulinaryPlaceModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distance,
    this.matchedKeyword,
  });

  factory CulinaryPlaceModel.fromGeoapify(
    Map<String, dynamic> feature, {
    String? matchedKeyword,
  }) {
    final properties = feature['properties'] as Map<String, dynamic>? ?? {};
    final geometry = feature['geometry'] as Map<String, dynamic>? ?? {};
    final coordinates = geometry['coordinates'] as List<dynamic>? ?? [];

    final lonFromGeometry = coordinates.isNotEmpty ? (coordinates[0] as num?)?.toDouble() : null;
    final latFromGeometry = coordinates.length > 1 ? (coordinates[1] as num?)?.toDouble() : null;

    final latitude = (properties['lat'] as num?)?.toDouble() ?? latFromGeometry ?? 0;
    final longitude = (properties['lon'] as num?)?.toDouble() ?? lonFromGeometry ?? 0;

    final name = properties['name']?.toString().trim();
    final addressLine1 = properties['address_line1']?.toString().trim();
    final formatted = properties['formatted']?.toString().trim();

    return CulinaryPlaceModel(
      id: properties['place_id']?.toString() ?? '$latitude,$longitude',
      name: name?.isNotEmpty == true ? name! : addressLine1?.isNotEmpty == true ? addressLine1! : 'Restoran',
      address: formatted?.isNotEmpty == true ? formatted! : addressLine1?.isNotEmpty == true ? addressLine1! : 'Alamat belum tersedia',
      latitude: latitude,
      longitude: longitude,
      distance: (properties['distance'] as num?)?.toInt() ?? 0,
      matchedKeyword: matchedKeyword,
    );
  }
}