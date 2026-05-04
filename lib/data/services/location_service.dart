import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/utils/region_mapper.dart';

class LocationInfo {
  final String label;
  final String province;
  final String island;
  final double? latitude;
  final double? longitude;

  const LocationInfo({
    required this.label,
    required this.province,
    required this.island,
    this.latitude,
    this.longitude,
  });
}

class LocationService {
  static const LocationInfo fallback = LocationInfo(
    label: 'Yogyakarta',
    province: 'DI Yogyakarta',
    island: 'Jawa',
  );

  LocationInfo getDefaultLocationInfo() {
    return fallback;
  }

  Future<LocationInfo> getCurrentLocationInfo() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled().timeout(
        const Duration(seconds: 3),
        onTimeout: () => false,
      );

      if (!serviceEnabled) {
        return fallback;
      }

      var permission = await Geolocator.checkPermission().timeout(
        const Duration(seconds: 3),
        onTimeout: () => LocationPermission.denied,
      );

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission().timeout(
          const Duration(seconds: 8),
          onTimeout: () => LocationPermission.denied,
        );
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return fallback;
      }

      Position? position = await Geolocator.getLastKnownPosition();

      position ??= await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      ).timeout(
        const Duration(seconds: 8),
      );

      final places = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () => [],
      );

      final place = places.isNotEmpty ? places.first : null;

      final province = place?.administrativeArea?.trim().isNotEmpty == true
          ? place!.administrativeArea!
          : fallback.province;

      final city = place?.subAdministrativeArea?.trim().isNotEmpty == true
          ? place!.subAdministrativeArea!
          : province;

      final island = RegionMapper.fromProvince(province);

      return LocationInfo(
        label: city,
        province: province,
        island: island,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      return fallback;
    }
  }
}