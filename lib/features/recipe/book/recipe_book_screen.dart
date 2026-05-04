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

  final List<String> islands = [
    'Semua',
    'Sumatera',
    'Jawa',
    'Bali & Nusa Tenggara',
    'Kalimantan',
    'Sulawesi',
    'Papua',
  ];

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
      filtered = recipes.where((recipe) {
        final matchKeyword = keyword.isEmpty ||
            recipe.name.toLowerCase().contains(keyword) ||
            recipe.province.toLowerCase().contains(keyword);

        final matchIsland =
            selectedIsland == 'Semua' || recipe.island == selectedIsland;

        final matchProvince =
            selectedProvince == 'Semua' || recipe.province == selectedProvince;

        return matchKeyword && matchIsland && matchProvince;
      }).toList();
    });
  }

  String getCulturalFact(Recipe recipe) {
    return recipe.description;
  }

  String _filterLabel() {
    if (selectedIsland == 'Semua') return 'Semua Resep Nusantara';
    if (selectedProvince == 'Semua') return 'Resep Pulau $selectedIsland';
    return 'Resep $selectedProvince';
  }

  void _back() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.ivory,
                ),
              )
            : RefreshIndicator(
                onRefresh: loadRecipes,
                color: AppColors.spiceBrown,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
                  children: [
                    Row(
                      children: [
                        _SmallRoundButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: _back,
                        ),
                        const Expanded(
                          child: _TopTitle(),
                        ),
                        const SizedBox(width: 46),
                      ],
                    ),
                    const SizedBox(height: 22),
                    buildHeader(),
                    const SizedBox(height: 24),
                    buildSearchAndFilterPanel(),
                    const SizedBox(height: 24),
                    _ResultTitlePanel(
                      title: _filterLabel(),
                      count: filtered.length,
                    ),
                    const SizedBox(height: 18),
                    if (filtered.isEmpty)
                      buildEmptyState()
                    else
                      ...filtered.map(
                        (recipe) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: buildRecipeBookCard(recipe),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget buildHeader() {
    return _GamePanel(
      label: 'Buku Resep',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 36, 18, 18),
        child: Row(
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: AppColors.cream,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.spiceBrown,
                  width: 2.4,
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
                Icons.menu_book_rounded,
                color: AppColors.spiceBrown,
                size: 34,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buku Resep Nusantara',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                      letterSpacing: -0.4,
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'Jelajahi resep tradisional berdasarkan pulau dan daerah asalnya.',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w800,
                      height: 1.4,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSearchAndFilterPanel() {
    return _GamePanel(
      label: 'Cari & Filter',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 34, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GameTextField(
              controller: searchController,
              hint: 'Cari nama resep atau provinsi...',
              icon: Icons.search_rounded,
              onChanged: (value) {
                query = value;
                applyFilter();
              },
            ),
            const SizedBox(height: 18),
            const _FilterLabel(text: 'Pulau'),
            const SizedBox(height: 10),
            buildIslandFilter(),
            if (currentProvinces.isNotEmpty) ...[
              const SizedBox(height: 16),
              const _FilterLabel(text: 'Provinsi'),
              const SizedBox(height: 10),
              buildProvinceFilter(),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildIslandFilter() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: islands.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          return _FilterChip(
            label: islands[index],
            selected: selectedIsland == islands[index],
            onTap: () {
              setState(() {
                selectedIsland = islands[index];
                selectedProvince = 'Semua';
              });

              applyFilter();
            },
          );
        },
      ),
    );
  }

  Widget buildProvinceFilter() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: currentProvinces.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          return _FilterChip(
            label: currentProvinces[index],
            selected: selectedProvince == currentProvinces[index],
            onTap: () {
              setState(() {
                selectedProvince = currentProvinces[index];
              });

              applyFilter();
            },
          );
        },
      ),
    );
  }

  Widget buildRecipeBookCard(Recipe recipe) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.recipeDetail,
            arguments: recipe,
          );
        },
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.spiceBrown,
              width: 2.4,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.58),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.spiceBrown.withOpacity(0.18),
                width: 1.2,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.spiceBrown,
                      width: 2.2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      recipe.emoji,
                      style: const TextStyle(fontSize: 36),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink,
                          height: 1.15,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 15,
                            color: AppColors.terracotta,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${recipe.province} · ${recipe.island}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Text(
                        getCulturalFact(recipe),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          buildMiniInfo(
                            Icons.timer_outlined,
                            '${recipe.cookTimeMinutes} mnt',
                          ),
                          buildMiniInfo(
                            Icons.local_fire_department_outlined,
                            recipe.difficulty,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.spiceBrown,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMiniInfo(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.spiceBrown.withOpacity(0.24),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: AppColors.spiceBrown,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyState() {
    return const _GamePanel(
      label: 'Kosong',
      child: Padding(
        padding: EdgeInsets.fromLTRB(18, 44, 18, 26),
        child: Column(
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 54,
              color: AppColors.spiceBrown,
            ),
            SizedBox(height: 14),
            Text(
              'Resep belum ditemukan',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Coba pilih pulau lain atau ubah kata kunci pencarian.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w800,
                height: 1.4,
              ),
            ),
          ],
        ),
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
        'Buku Resep',
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

class _ResultTitlePanel extends StatelessWidget {
  final String title;
  final int count;

  const _ResultTitlePanel({
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              color: AppColors.spiceBrown.withOpacity(0.45),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          constraints: const BoxConstraints(maxWidth: 230),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 9,
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
                color: Color(0x22000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$count resep ditemukan',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              color: AppColors.spiceBrown.withOpacity(0.45),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterLabel extends StatelessWidget {
  final String text;

  const _FilterLabel({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w900,
        color: AppColors.ink,
        fontSize: 13,
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.greenEnd : AppColors.cream,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.greenShadow : AppColors.spiceBrown,
            width: selected ? 1.8 : 1.3,
          ),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: AppColors.greenShadow,
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.spiceBrown,
            fontWeight: FontWeight.w900,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _GameTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final ValueChanged<String>? onChanged;

  const _GameTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(
          icon,
          color: AppColors.spiceBrown,
        ),
        hintStyle: TextStyle(
          color: AppColors.muted.withOpacity(0.70),
          fontWeight: FontWeight.w700,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.spiceBrown,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: AppColors.spiceBrown.withOpacity(0.38),
            width: 1.4,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.spiceBrown,
            width: 1.9,
          ),
        ),
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