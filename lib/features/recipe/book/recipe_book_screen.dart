import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/recipe_image.dart';
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
    'Semua', 'Sumatera', 'Jawa', 'Bali & Nusa Tenggara',
    'Kalimantan', 'Sulawesi', 'Papua',
  ];

  final Map<String, List<String>> provincesByIsland = {
    'Sumatera': ['Aceh', 'Sumatera Barat', 'Sumatera Selatan', 'Lampung', 'Riau'],
    'Jawa': ['DI Yogyakarta', 'Jawa Timur', 'Jawa Tengah', 'Jawa Barat', 'Banten'],
    'Bali & Nusa Tenggara': ['Bali', 'Nusa Tenggara Barat', 'Nusa Tenggara Timur'],
    'Kalimantan': ['Kalimantan Selatan', 'Kalimantan Barat', 'Kalimantan Timur'],
    'Sulawesi': ['Sulawesi Selatan', 'Sulawesi Utara', 'Sulawesi Tengah'],
    'Papua': ['Papua', 'Papua Barat', 'Papua Pegunungan'],
  };

  String selectedIsland   = 'Semua';
  String selectedProvince = 'Semua';
  String query            = '';

  List<Recipe> recipes  = [];
  List<Recipe> filtered = [];
  bool loading          = true;

  @override
  void initState() { super.initState(); loadRecipes(); }

  @override
  void dispose() { searchController.dispose(); super.dispose(); }

  Future<void> loadRecipes() async {
    final data = await recipeRepository.getRecipes();
    if (!mounted) return;
    setState(() { recipes = data; filtered = data; loading = false; });
  }

  List<String> get currentProvinces {
    if (selectedIsland == 'Semua') return [];
    return ['Semua', ...?provincesByIsland[selectedIsland]];
  }

  void applyFilter() {
    final keyword = query.toLowerCase().trim();
    setState(() {
      filtered = recipes.where((r) {
        final matchKeyword  = keyword.isEmpty ||
            r.name.toLowerCase().contains(keyword) ||
            r.province.toLowerCase().contains(keyword);
        final matchIsland   = selectedIsland   == 'Semua' || r.island   == selectedIsland;
        final matchProvince = selectedProvince == 'Semua' || r.province == selectedProvince;
        return matchKeyword && matchIsland && matchProvince;
      }).toList();
    });
  }

  String _filterLabel() {
    if (selectedIsland == 'Semua') return 'Semua Resep Nusantara';
    if (selectedProvince == 'Semua') return 'Resep Pulau $selectedIsland';
    return 'Resep $selectedProvince';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.ivory))
            : RefreshIndicator(
                onRefresh: loadRecipes,
                color: AppColors.spiceBrown,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
                  children: [
                    Row(children: [
                      _SmallRoundButton(icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.pop(context)),
                      const Expanded(child: _TopTitle()),
                      const SizedBox(width: 46),
                    ]),
                    const SizedBox(height: 22),
                    _buildHeader(),
                    const SizedBox(height: 22),
                    _buildSearchAndFilterPanel(),
                    const SizedBox(height: 22),
                    _ResultTitlePanel(title: _filterLabel(), count: filtered.length),
                    const SizedBox(height: 16),
                    if (filtered.isEmpty)
                      _buildEmptyState()
                    else
                      ...filtered.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _buildRecipeCard(r),
                      )),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return _GamePanel(
      label: 'Buku Resep',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 36, 18, 18),
        child: Row(children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: AppColors.cream, shape: BoxShape.circle,
              border: Border.all(color: AppColors.spiceBrown, width: 2.2),
              boxShadow: const [BoxShadow(color: Color(0x24000000), blurRadius: 10, offset: Offset(0, 5))],
            ),
            child: const Icon(Icons.menu_book_rounded, color: AppColors.spiceBrown, size: 32),
          ),
          const SizedBox(width: 14),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Buku Resep Nusantara', maxLines: 2, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppColors.ink, fontSize: 18,
                    fontWeight: FontWeight.w900, height: 1.15, letterSpacing: -0.4)),
            SizedBox(height: 6),
            Text('Jelajahi resep tradisional berdasarkan pulau dan daerah asalnya.',
                style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700,
                    height: 1.4, fontSize: 12.5)),
          ])),
        ]),
      ),
    );
  }

  Widget _buildSearchAndFilterPanel() {
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
              onChanged: (v) { query = v; applyFilter(); },
            ),
            const SizedBox(height: 16),
            const _FilterLabel(text: 'Pulau'),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8,
              children: islands.map((island) => _FilterChip(
                label: island, selected: selectedIsland == island,
                onTap: () {
                  setState(() { selectedIsland = island; selectedProvince = 'Semua'; });
                  applyFilter();
                },
              )).toList(),
            ),
            if (currentProvinces.isNotEmpty) ...[
              const SizedBox(height: 14),
              const _FilterLabel(text: 'Provinsi'),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8,
                children: currentProvinces.map((prov) => _FilterChip(
                  label: prov, selected: selectedProvince == prov,
                  onTap: () { setState(() => selectedProvince = prov); applyFilter(); },
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Card tanpa background putih — langsung di atas paper ──────────────────
  Widget _buildRecipeCard(Recipe recipe) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, AppRoutes.recipeDetail, arguments: recipe),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.spiceBrown, width: 2.4),
            boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 5))],
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Gambar langsung, tanpa card putih pembungkus
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: RecipeImage(
                  imagePath: recipe.imagePath,
                  width: 88, height: 88,
                  fit: BoxFit.cover, borderRadius: 18,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(recipe.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
                            color: AppColors.ink, height: 1.15, letterSpacing: -0.3)),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.location_on_outlined, size: 13, color: AppColors.terracotta),
                      const SizedBox(width: 3),
                      Expanded(child: Text('${recipe.province} • ${recipe.island}',
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.muted,
                              fontWeight: FontWeight.w700, fontSize: 12))),
                    ]),
                    const SizedBox(height: 6),
                    Text(recipe.description, maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600,
                            height: 1.35, fontSize: 12)),
                    const SizedBox(height: 8),
                    Wrap(spacing: 6, runSpacing: 6, children: [
                      _MiniChip(Icons.timer_outlined, '${recipe.cookTimeMinutes} mnt'),
                      _MiniChip(Icons.local_fire_department_outlined, recipe.difficulty),
                    ]),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, color: AppColors.spiceBrown, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const _GamePanel(
      label: 'Kosong',
      child: Padding(
        padding: EdgeInsets.fromLTRB(18, 44, 18, 26),
        child: Column(children: [
          Icon(Icons.menu_book_outlined, size: 54, color: AppColors.spiceBrown),
          SizedBox(height: 14),
          Text('Resep belum ditemukan', textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w900, fontSize: 18)),
          SizedBox(height: 6),
          Text('Coba pilih pulau lain atau ubah kata kunci pencarian.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700, height: 1.4)),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────────────────────────

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MiniChip(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.spiceBrown.withOpacity(0.22))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: AppColors.spiceBrown),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(fontSize: 11, color: AppColors.spiceBrown, fontWeight: FontWeight.w800)),
    ]),
  );
}

class _TopTitle extends StatelessWidget {
  const _TopTitle();
  @override
  Widget build(BuildContext context) => const Center(
    child: Text('Buku Resep', textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.darkBrown, fontSize: 31,
            fontWeight: FontWeight.w900, letterSpacing: -0.8)),
  );
}

class _ResultTitlePanel extends StatelessWidget {
  final String title;
  final int count;
  const _ResultTitlePanel({required this.title, required this.count});

  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Container(height: 2, decoration: BoxDecoration(
        color: AppColors.spiceBrown.withOpacity(0.45), borderRadius: BorderRadius.circular(999)))),
    const SizedBox(width: 10),
    Container(
      constraints: const BoxConstraints(maxWidth: 230),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AppColors.ribbonGradient,
            begin: Alignment.topCenter, end: Alignment.bottomCenter),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.ribbonShadow, width: 1.2),
        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Column(children: [
        Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text('$count resep ditemukan', maxLines: 1, overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w800)),
      ]),
    ),
    const SizedBox(width: 10),
    Expanded(child: Container(height: 2, decoration: BoxDecoration(
        color: AppColors.spiceBrown.withOpacity(0.45), borderRadius: BorderRadius.circular(999)))),
  ]);
}

class _FilterLabel extends StatelessWidget {
  final String text;
  const _FilterLabel({required this.text});
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.ink, fontSize: 13));
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.greenEnd : AppColors.cream,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: selected ? AppColors.greenShadow : AppColors.spiceBrown,
            width: selected ? 1.8 : 1.3),
        boxShadow: selected
            ? const [BoxShadow(color: AppColors.greenShadow, offset: Offset(0, 3))]
            : null,
      ),
      child: Text(label, style: TextStyle(
          color: selected ? Colors.white : AppColors.spiceBrown,
          fontWeight: FontWeight.w900, fontSize: 13)),
    ),
  );
}

class _GameTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final ValueChanged<String>? onChanged;
  const _GameTextField({required this.controller, required this.hint,
      required this.icon, this.onChanged});

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller, onChanged: onChanged,
    decoration: InputDecoration(
      hintText: hint, filled: true, fillColor: AppColors.cream,
      prefixIcon: Icon(icon, color: AppColors.spiceBrown),
      hintStyle: TextStyle(color: AppColors.muted.withOpacity(0.70), fontWeight: FontWeight.w700),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.spiceBrown, width: 1.5)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.spiceBrown.withOpacity(0.35), width: 1.4)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.spiceBrown, width: 1.9)),
    ),
  );
}

class _GamePanel extends StatelessWidget {
  final String label;
  final Widget child;
  const _GamePanel({required this.label, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.paper, borderRadius: BorderRadius.circular(28),
      border: Border.all(color: AppColors.spiceBrown, width: 2.8),
      boxShadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 14, offset: Offset(0, 7))],
    ),
    child: Stack(clipBehavior: Clip.none, children: [
      child,
      Positioned(top: -15, left: 14, right: 14, child: _Ribbon(label: label)),
    ]),
  );
}

class _Ribbon extends StatelessWidget {
  final String label;
  const _Ribbon({required this.label});
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      constraints: const BoxConstraints(minWidth: 112),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AppColors.ribbonGradient,
            begin: Alignment.topCenter, end: Alignment.bottomCenter),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.ribbonShadow, width: 1.2),
        boxShadow: const [BoxShadow(color: Color(0x24000000), blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Text(label, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
    ),
  );
}

class _SmallRoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _SmallRoundButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Opacity(opacity: onTap == null ? 0.45 : 1,
      child: Container(width: 46, height: 46,
        decoration: BoxDecoration(color: AppColors.greenEnd, shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.4),
            boxShadow: const [BoxShadow(color: AppColors.greenShadow, offset: Offset(0, 3))]),
        child: Icon(icon, color: Colors.white, size: 23),
      ),
    ),
  );
}