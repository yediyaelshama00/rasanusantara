import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/recipe_model.dart';
import '../../../data/repositories/recipe_repository.dart';

class RecipeBookScreen extends StatefulWidget {
  const RecipeBookScreen({super.key});

  @override
  State<RecipeBookScreen> createState() => _RecipeBookScreenState();
}

class _RecipeBookScreenState extends State<RecipeBookScreen> {
  final recipeRepository = RecipeRepository();
  final searchController = TextEditingController();

  // Filter level 1: pulau
  final List<String> islands = [
    'Semua',
    'Sumatera',
    'Jawa',
    'Bali & Nusa Tenggara',
    'Kalimantan',
    'Sulawesi',
    'Papua',
  ];

  // Filter level 2: provinsi — muncul sesuai pulau yang dipilih
  final Map<String, List<String>> provincesByIsland = {
    'Sumatera': ['Aceh', 'Sumatera Barat', 'Sumatera Selatan', 'Lampung'],
    'Jawa': ['DI Yogyakarta', 'Jawa Timur', 'Jawa Tengah', 'Jawa Barat'],
    'Bali & Nusa Tenggara': ['Bali'],
    'Kalimantan': ['Kalimantan Selatan'],
    'Sulawesi': ['Sulawesi Selatan'],
    'Papua': ['Papua'],
  };

  String selectedIsland = 'Semua';
  String selectedProvince = 'Semua';
  String query = '';

  List<Recipe> recipes = [];
  List<Recipe> filtered = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadRecipes();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadRecipes() async {
    final data = await recipeRepository.getRecipes();
    if (!mounted) return;
    setState(() {
      recipes = data;
      filtered = data;
      loading = false;
    });
  }

  List<String> get currentProvinces {
    if (selectedIsland == 'Semua') return [];
    return ['Semua', ...?provincesByIsland[selectedIsland]];
  }

  void applyFilter() {
    final keyword = query.toLowerCase().trim();
    setState(() {
      filtered = recipes.where((r) {
        final matchKeyword = keyword.isEmpty ||
            r.name.toLowerCase().contains(keyword) ||
            r.province.toLowerCase().contains(keyword);

        final matchIsland =
            selectedIsland == 'Semua' || r.island == selectedIsland;

        final matchProvince =
            selectedProvince == 'Semua' || r.province == selectedProvince;

        return matchKeyword && matchIsland && matchProvince;
      }).toList();
    });
  }

  // Fakta budaya dari field description — tidak hardcode nama lagi
  String getCulturalFact(Recipe recipe) {
    return recipe.description;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: AppBar(title: const Text('Buku Resep')),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.spiceBrown))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
              children: [
                buildHeader(),
                const SizedBox(height: 18),
                buildSearchField(),
                const SizedBox(height: 14),
                buildIslandFilter(),
                if (currentProvinces.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  buildProvinceFilter(),
                ],
                const SizedBox(height: 22),
                Text(
                  _filterLabel(),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${filtered.length} resep ditemukan',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),
                if (filtered.isEmpty)
                  buildEmptyState()
                else
                  ...filtered.map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: buildRecipeBookCard(r),
                    ),
                  ),
              ],
            ),
    );
  }

  String _filterLabel() {
    if (selectedIsland == 'Semua') return 'Semua Resep Nusantara';
    if (selectedProvince == 'Semua') return 'Resep Pulau $selectedIsland';
    return 'Resep $selectedProvince';
  }

  Widget buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.darkBrown,
            AppColors.spiceBrown,
            AppColors.terracotta
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.menu_book_rounded,
                color: Colors.white, size: 34),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buku Resep Nusantara',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 5),
                Text(
                  'Jelajahi resep tradisional berdasarkan pulau dan daerah asalnya.',
                  style: TextStyle(
                      color: Color(0xFFFFE7CB),
                      fontWeight: FontWeight.w600,
                      height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSearchField() {
    return TextField(
      controller: searchController,
      onChanged: (v) {
        query = v;
        applyFilter();
      },
      decoration: const InputDecoration(
        hintText: 'Cari nama resep atau provinsi...',
        prefixIcon: Icon(Icons.search_rounded),
      ),
    );
  }

  Widget buildIslandFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pulau',
          style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.muted,
              fontSize: 12),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: islands.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => _FilterChip(
              label: islands[i],
              selected: selectedIsland == islands[i],
              onTap: () {
                setState(() {
                  selectedIsland = islands[i];
                  selectedProvince = 'Semua'; // reset provinsi
                });
                applyFilter();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget buildProvinceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Provinsi',
          style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.muted,
              fontSize: 12),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: currentProvinces.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => _FilterChip(
              label: currentProvinces[i],
              selected: selectedProvince == currentProvinces[i],
              onTap: () {
                setState(() => selectedProvince = currentProvinces[i]);
                applyFilter();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget buildRecipeBookCard(Recipe recipe) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, AppRoutes.recipeDetail,
          arguments: recipe),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.line),
          boxShadow: [
            BoxShadow(
                color: AppColors.darkBrown.withValues(alpha: 0.04),
                blurRadius: 18,
                offset: const Offset(0, 10)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(24)),
              child: Center(
                  child:
                      Text(recipe.emoji, style: const TextStyle(fontSize: 36))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.name,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink)),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: AppColors.terracotta),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${recipe.province} · ${recipe.island}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.muted,
                            fontWeight: FontWeight.w700,
                            fontSize: 12),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Text(
                    getCulturalFact(recipe),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                        fontSize: 12.5),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    buildMiniInfo(
                        Icons.timer_outlined, '${recipe.cookTimeMinutes} mnt'),
                    const SizedBox(width: 8),
                    buildMiniInfo(Icons.local_fire_department_outlined,
                        recipe.difficulty),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMiniInfo(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.ivory,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(children: [
        Icon(icon, size: 13, color: AppColors.spiceBrown),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.ink)),
      ]),
    );
  }

  Widget buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.line),
      ),
      child: const Column(children: [
        Text('📖', style: TextStyle(fontSize: 42)),
        SizedBox(height: 10),
        Text('Resep belum ditemukan',
            style: TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w900,
                fontSize: 16)),
        SizedBox(height: 5),
        Text('Coba pilih pulau lain atau ubah kata kunci pencarian.',
            textAlign: TextAlign.center,
            style:
                TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.spiceBrown : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: selected ? AppColors.spiceBrown : AppColors.line),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.muted,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
