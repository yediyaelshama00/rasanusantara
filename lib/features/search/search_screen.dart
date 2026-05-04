import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../map/culinary_map_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final List<String> culinaryStyles = [
    'Sumatera Utara',
    'Sumatera Barat',
    'Yogyakarta',
    'Jawa Timur',
    'Bali',
    'Sulawesi Selatan',
    'Papua',
    'Palembang',
  ];

  final List<String> searchCities = [
    'Di Sekitarku',
    'Medan',
    'Padang',
    'Jakarta',
    'Yogyakarta',
    'Surabaya',
    'Denpasar',
    'Makassar',
    'Palembang',
    'Jayapura',
  ];

  String selectedStyle = 'Yogyakarta';
  String selectedCity = 'Di Sekitarku';

  void openCulinaryMap() {
    Navigator.pushNamed(
      context,
      AppRoutes.culinaryMap,
      arguments: CulinaryMapArgs(
        culinaryStyle: selectedStyle,
        cityName: selectedCity,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            const Text(
              'Peta Kuliner',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Cari restoran atau warung dengan nuansa kuliner daerah pilihanmu.',
              style: TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 20),
            buildMapCard(),
            const SizedBox(height: 22),
            buildInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget buildMapCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.darkBrown,
            AppColors.spiceBrown,
            AppColors.terracotta,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBrown.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.travel_explore_rounded,
                color: Colors.white,
                size: 30,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Cari Restoran di Peta',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 19,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih nuansa kuliner dan lokasi pencarian. Aplikasi akan menampilkan restoran yang cocok di peta.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          buildDropdown(
            label: 'Nuansa kuliner',
            value: selectedStyle,
            items: culinaryStyles,
            icon: Icons.restaurant_menu_rounded,
            onChanged: (value) {
              setState(() {
                selectedStyle = value ?? selectedStyle;
              });
            },
          ),
          const SizedBox(height: 10),
          buildDropdown(
            label: 'Lokasi pencarian',
            value: selectedCity,
            items: searchCities,
            icon: Icons.location_on_rounded,
            onChanged: (value) {
              setState(() {
                selectedCity = value ?? selectedCity;
              });
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              onPressed: openCulinaryMap,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.spiceBrown,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.map_rounded),
              label: const Text(
                'Lihat Restoran di Peta',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.74),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.ivory,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white,
              ),
              style: const TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w800,
              ),
              selectedItemBuilder: (context) {
                return items.map((item) {
                  return Row(
                    children: [
                      Icon(
                        icon,
                        color: Colors.white,
                        size: 19,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.line),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.spiceBrown,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Fitur ini menggunakan OpenStreetMap dan Geoapify Places API untuk mencari tempat makan berdasarkan lokasi dan nuansa kuliner daerah.',
              style: TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}