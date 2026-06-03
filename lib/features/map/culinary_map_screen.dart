import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/culinary_place_model.dart';
import '../../data/services/geoapify_places_service.dart';
import '../../data/repositories/auth_repository.dart';

class CulinaryMapArgs {
  final String culinaryStyle;

  const CulinaryMapArgs({
    required this.culinaryStyle,
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
  final authRepository = AuthRepository();
  String culinaryStyle = 'DI Yogyakarta';
  String currentLocationName = 'Lokasi Saat Ini';
  String? profileImagePath;

  bool isLoading = true;
  bool hasLoaded = false;
  String? errorMessage;

  LatLng center = const LatLng(-6.200000, 106.816666);
  LatLng? userLocation;
  List<CulinaryPlaceModel> places = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (hasLoaded) return;
    hasLoaded = true;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is CulinaryMapArgs) {
      culinaryStyle = args.culinaryStyle;
    }

    Future.microtask(() async {
      await loadUserProfile();
      await searchPlaces();
    });
  }

  Future<void> loadUserProfile() async {
  try {
    final user = await authRepository.getCurrentUser();

    if (!mounted) return;

    setState(() {
      profileImagePath = user?.photoPath;
    });
  } catch (_) {}
  }

  Future<void> loadLocationName(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) return;

      final place = placemarks.first;

      if (!mounted) return;

      setState(() {
        currentLocationName =
            '${place.subAdministrativeArea ?? place.locality ?? ''}, '
            '${place.administrativeArea ?? ''}';
      });
    } catch (_) {}
  }

  Future<void> openGoogleMaps(CulinaryPlaceModel place) async {
    final query = Uri.encodeComponent(
      '${place.name} ${place.address}',
    );

    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> searchPlaces() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      places = [];
    });

    try {
      final position = await getCurrentPosition();

      center = LatLng(
        position.latitude,
        position.longitude,
      );
      
      userLocation = center;

      await loadLocationName(
        position.latitude,
        position.longitude,
      );

      final result = await placesService.searchRestaurants(
        culinaryStyle: culinaryStyle,
        latitude: center.latitude,
        longitude: center.longitude,
      );

      if (!mounted) return;

      setState(() {
        places = result;

        if (places.isNotEmpty) {
          center = LatLng(
            places.first.latitude,
            places.first.longitude,
          );
        }
      });

      mapController.move(
        center,
        places.isEmpty ? 12 : 14,
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage =
            'Restoran bernuansa $culinaryStyle belum ditemukan di sekitar lokasi Anda.';
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
    final result = <Marker>[];

    if (userLocation != null) {
      result.add(
        Marker(
          point: userLocation!,
          width: 60,
          height: 60,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: ClipOval(
              child: profileImagePath != null &&
                      profileImagePath!.isNotEmpty &&
                      File(profileImagePath!).existsSync()
                  ? Image.file(
                      File(profileImagePath!),
                      fit: BoxFit.cover,
                    )
                  : const Icon(
                      Icons.person_pin_circle,
                      color: Colors.white,
                      size: 34,
                    ),
            ),
          ),
        ),
      );
    }

    result.addAll(
      places.map((place) {
        return Marker(
          point: LatLng(place.latitude, place.longitude),
          width: 52,
          height: 52,
          child: GestureDetector(
            onTap: () => showPlaceSheet(place),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.greenEnd,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                  BoxShadow(
                    color: AppColors.greenShadow,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.restaurant_rounded,
                color: Colors.white,
                size: 25,
              ),
            ),
          ),
        );
      }),
    );

    return result;
  }

  void showPlaceSheet(CulinaryPlaceModel place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          margin: const EdgeInsets.all(14),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppColors.spiceBrown,
              width: 2.6,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x30000000),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _RibbonTitle(text: 'Detail Restoran'),
                const SizedBox(height: 18),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.spiceBrown,
                      width: 2.4,
                    ),
                  ),
                  child: const Icon(
                    Icons.restaurant_rounded,
                    color: AppColors.spiceBrown,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  place.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  place.address,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                _InfoBox(
                  icon: Icons.near_me_rounded,
                  title: 'Jarak',
                  value: place.distance > 0
                      ? '${place.distance} meter dari pusat pencarian'
                      : 'Jarak belum tersedia',
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => openGoogleMaps(place),
                    icon: const Icon(Icons.navigation_rounded),
                    label: const Text('Buka di Google Maps'),
                  ),
                ),
                if (place.matchedKeyword != null) ...[
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            buildHeader(),
            const SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: _MapFrame(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: FlutterMap(
                          mapController: mapController,
                          options: MapOptions(
                            initialCenter: center,
                            initialZoom: 12,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName:
                                  'com.example.rasanusantara',
                            ),
                            MarkerLayer(
                              markers: markers,
                            ),
                          ],
                        ),
                      ),
                      if (isLoading) buildLoading(),
                      if (errorMessage != null) buildError(),
                      if (!isLoading &&
                          errorMessage == null &&
                          places.isEmpty)
                        buildEmptyResult(),
                      if (!isLoading && places.isNotEmpty) buildResultPanel(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      child: Column(
        children: [
          Row(
            children: [
              _SmallRoundButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.pop(context),
              ),
              const Expanded(
                child: _TopTitle(),
              ),
              const SizedBox(width: 46),
            ],
          ),
          const SizedBox(height: 18),
          _GamePanel(
            label: 'Lokasi Kuliner',
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 36, 18, 18),
              child: Row(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.spiceBrown,
                        width: 2.3,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x24000000),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.map_rounded,
                      color: AppColors.spiceBrown,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 14),
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
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '$culinaryStyle • $currentLocationName',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _SmallRoundButton(
                    icon: Icons.refresh_rounded,
                    onTap: isLoading ? null : searchPlaces,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLoading() {
    return Container(
      color: Colors.black.withValues(alpha: 0.10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.spiceBrown,
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 14,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: const Row(
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
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildError() {
    return Positioned(
      left: 14,
      right: 14,
      top: 16,
      child: _FloatingMessage(
        icon: Icons.info_rounded,
        message: errorMessage ?? '',
        danger: true,
      ),
    );
  }

  Widget buildEmptyResult() {
    return const Positioned(
      left: 14,
      right: 14,
      top: 16,
      child: _FloatingMessage(
        icon: Icons.search_off_rounded,
        message: 'Belum ada restoran yang cocok di lokasi ini.',
      ),
    );
  }

  Widget buildResultPanel() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 14,
      height: 138,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
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
              width: 276,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.paper,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.spiceBrown,
                  width: 2.2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x2A000000),
                    blurRadius: 16,
                    offset: Offset(0, 8),
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
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.spiceBrown,
                        width: 2,
                      ),
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
                            fontSize: 15.5,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          place.address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            height: 1.25,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            const Icon(
                              Icons.near_me_rounded,
                              size: 16,
                              color: AppColors.terracotta,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              place.distance > 0
                                  ? '${place.distance} m'
                                  : 'Terdekat',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: AppColors.ink,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.spiceBrown,
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

class _TopTitle extends StatelessWidget {
  const _TopTitle();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Peta Kuliner',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.darkBrown,
          fontSize: 31,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.8,
        ),
      ),
    );
  }
}

class _MapFrame extends StatelessWidget {
  final Widget child;

  const _MapFrame({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.spiceBrown,
          width: 2.8,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 14,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: child,
      ),
    );
  }
}

class _GamePanel extends StatelessWidget {
  final String label;
  final Widget child;

  const _GamePanel({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppColors.spiceBrown,
            width: 2.8,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 14,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            Positioned(
              top: -15,
              left: 14,
              right: 14,
              child: _Ribbon(label: label),
            ),
          ],
        ),
      ),
    );
  }
}

class _Ribbon extends StatelessWidget {
  final String label;

  const _Ribbon({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(minWidth: 112),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.ribbonGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.ribbonShadow,
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x24000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _RibbonTitle extends StatelessWidget {
  final String text;

  const _RibbonTitle({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 130),
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.ribbonGradient,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.ribbonShadow,
          width: 1.2,
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 18,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

class _SmallRoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _SmallRoundButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.45 : 1,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.greenEnd,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2.4,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.greenShadow,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 23,
          ),
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoBox({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.spiceBrown.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.spiceBrown,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.spiceBrown,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final bool danger;

  const _FloatingMessage({
    required this.icon,
    required this.message,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.terracotta : AppColors.spiceBrown;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color,
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 14,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
