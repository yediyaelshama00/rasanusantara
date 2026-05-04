import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/culinary_place_model.dart';
import '../../data/services/geoapify_places_service.dart';

class CulinaryMapArgs {
  final String culinaryStyle;
  final String cityName;

  const CulinaryMapArgs({
    required this.culinaryStyle,
    required this.cityName,
  });
}

class CulinaryMapScreen extends StatefulWidget {
  const CulinaryMapScreen({super.key});

  @override
  State<CulinaryMapScreen> createState() => _CulinaryMapScreenState();
}

class _CulinaryMapScreenState extends State<CulinaryMapScreen> {
  final mapController = MapController();
  final placesService = GeoapifyPlacesService();

  final Map<String, LatLng> cityCenters = const {
    'Jakarta': LatLng(-6.200000, 106.816666),
    'Medan': LatLng(3.595196, 98.672226),
    'Padang': LatLng(-0.947083, 100.417181),
    'Yogyakarta': LatLng(-7.795580, 110.369492),
    'Surabaya': LatLng(-7.250445, 112.768845),
    'Denpasar': LatLng(-8.670458, 115.212631),
    'Makassar': LatLng(-5.147665, 119.432732),
    'Palembang': LatLng(-2.976074, 104.775431),
    'Jayapura': LatLng(-2.591602, 140.668999),
  };

  String culinaryStyle = 'Yogyakarta';
  String cityName = 'Di Sekitarku';

  bool isLoading = true;
  bool hasLoaded = false;
  String? errorMessage;

  LatLng center = const LatLng(-6.200000, 106.816666);
  List<CulinaryPlaceModel> places = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (hasLoaded) return;
    hasLoaded = true;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is CulinaryMapArgs) {
      culinaryStyle = args.culinaryStyle;
      cityName = args.cityName;
    }

    Future.microtask(searchPlaces);
  }

  Future<void> searchPlaces() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      places = [];
    });

    try {
      if (cityName == 'Di Sekitarku') {
        final position = await getCurrentPosition();
        center = LatLng(position.latitude, position.longitude);
      } else {
        center = cityCenters[cityName] ?? const LatLng(-6.200000, 106.816666);
      }

      final result = await placesService.searchRestaurants(
        culinaryStyle: culinaryStyle,
        latitude: center.latitude,
        longitude: center.longitude,
      );

      if (!mounted) return;

      setState(() {
        places = result;
        if (places.isNotEmpty) {
          center = LatLng(places.first.latitude, places.first.longitude);
        }
      });

      mapController.move(center, places.isEmpty ? 12 : 14);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Restoran belum ditemukan. Coba pilih lokasi lain.';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Layanan lokasi belum aktif');
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
      ),
    ).timeout(
      const Duration(seconds: 10),
    );
  }

  List<Marker> get markers {
    return places.map((place) {
      return Marker(
        point: LatLng(place.latitude, place.longitude),
        width: 48,
        height: 48,
        child: GestureDetector(
          onTap: () => showPlaceSheet(place),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.spiceBrown,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkBrown.withValues(alpha: 0.22),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.restaurant_rounded,
              color: Colors.white,
              size: 23,
            ),
          ),
        ),
      );
    }).toList();
  }

  void showPlaceSheet(CulinaryPlaceModel place) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.ivory,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                place.name,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                place.address,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(
                    Icons.near_me_rounded,
                    color: AppColors.terracotta,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    place.distance > 0
                        ? '${place.distance} meter dari pusat pencarian'
                        : 'Jarak belum tersedia',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
              if (place.matchedKeyword != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Kata kunci: ${place.matchedKeyword}',
                    style: const TextStyle(
                      color: AppColors.spiceBrown,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Column(
          children: [
            buildHeader(),
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: center,
                      initialZoom: 12,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.rasanusantara',
                      ),
                      MarkerLayer(
                        markers: markers,
                      ),
                    ],
                  ),
                  if (isLoading) buildLoading(),
                  if (errorMessage != null) buildError(),
                  if (!isLoading && places.isNotEmpty) buildResultPanel(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        color: AppColors.ivory,
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBrown.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 4),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.spiceBrown,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.map_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Peta Kuliner',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$culinaryStyle • $cityName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLoading() {
    return Container(
      color: Colors.black.withValues(alpha: 0.08),
      child: const Center(
        child: Card(
          color: AppColors.ivory,
          elevation: 0,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.spiceBrown,
                  ),
                ),
                SizedBox(width: 14),
                Text(
                  'Mencari restoran...',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildError() {
    return Positioned(
      left: 18,
      right: 18,
      top: 18,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.ivory,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkBrown.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.info_rounded,
              color: AppColors.terracotta,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                errorMessage ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildResultPanel() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 14,
      height: 128,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        scrollDirection: Axis.horizontal,
        itemCount: places.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final place = places[index];

          return GestureDetector(
            onTap: () {
              final target = LatLng(place.latitude, place.longitude);
              mapController.move(target, 16);
              showPlaceSheet(place);
            },
            child: Container(
              width: 270,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.ivory,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkBrown.withValues(alpha: 0.16),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.restaurant_rounded,
                      color: AppColors.spiceBrown,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          place.address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            height: 1.25,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.near_me_rounded,
                              size: 16,
                              color: AppColors.terracotta,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              place.distance > 0 ? '${place.distance} m' : 'Terdekat',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}