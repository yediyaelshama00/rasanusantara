import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/recipe_card.dart';
import '../../core/widgets/recipe_image.dart';
import '../../data/models/recipe_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/recipe_repository.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int index)? onChangeTab;

  const HomeScreen({super.key, this.onChangeTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final recipeRepository = RecipeRepository();
  final authRepository = AuthRepository();

  static const int profileTabIndex = 4;

  Recipe? recommendation;
  List<Recipe> others = [];
  String name = 'Teman Rasa';
  String? photoPath;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadHome();
  }

  Future<void> loadHome() async {
    try {
      final user = await authRepository.getCurrentUser();
      final allRecipes = await recipeRepository.getRecipes();
      if (!mounted) return;

      if (allRecipes.isEmpty) {
        setState(() {
          name = user?.name ?? 'Teman Rasa';
          photoPath = user?.photoPath;
          loading = false;
        });
        return;
      }

      final now = DateTime.now();
      final seed = now.year * 1000 + now.month * 100 + now.day;
      final shuffled = List<Recipe>.from(allRecipes)..shuffle(Random(seed));

      setState(() {
        name = user?.name ?? 'Teman Rasa';
        photoPath = user?.photoPath;
        recommendation = shuffled.first;
        others = shuffled.skip(1).take(5).toList();
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  Future<void> refreshHome() async => loadHome();
  void openSearchTab() => widget.onChangeTab?.call(1);
  void openProfileTab() => widget.onChangeTab?.call(profileTabIndex);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.ivory))
            : RefreshIndicator(
                onRefresh: refreshHome,
                color: AppColors.spiceBrown,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),
                  children: [
                    const _TopTitle(),
                    const SizedBox(height: 18),
                    _buildWelcomePanel(),
                    const SizedBox(height: 22),

                    // Hero rekomendasi
                    if (recommendation != null) ...[
                      _GameHeroPanel(
                        recipe: recommendation!,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.recipeDetail,
                          arguments: recommendation,
                        ),
                      ),
                      const SizedBox(height: 22),
                    ],

                    // Baris menu 1
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _GameMenuPanel(
                              label: 'Buku Resep',
                              icon: Icons.menu_book_rounded,
                              description: 'Resep tradisional dan sejarahnya',
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.recipeBook),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _GameMenuPanel(
                              label: 'Peta Kuliner',
                              icon: Icons.map_rounded,
                              description: 'Cari restoran bernuansa daerah',
                              onTap: openSearchTab,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // FIX: jarak antar baris menu diperbesar dari 14 → 22
                    const SizedBox(height: 22),

                    // Baris menu 2
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _GameMenuPanel(
                              label: 'Pac-Man Nusantara',
                              icon: Icons.sports_esports_rounded,
                              description:
                                  'Kumpulkan makanan khas Nusantara dalam labirin',
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.petaRasaGame),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _GameMenuPanel(
                              label: 'Random Resep',
                              icon: Icons.casino_rounded,
                              description: 'Goyangkan HP untuk resep acak',
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.shakeRandomRecipe),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),
                    const _GameSectionTitle(title: 'Jelajah Resep Nusantara'),
                    const SizedBox(height: 14),

                    if (others.isEmpty)
                      const _EmptyGamePanel()
                    else
                      ...others.map(
                        (recipe) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          // _RecipePanelWrapper langsung jadi satu-satunya
                          // container — tidak ada card putih di dalamnya.
                          child: _RecipePanelWrapper(
                            child: RecipeCard(
                              recipe: recipe,
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.recipeDetail,
                                arguments: recipe,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildWelcomePanel() {
    return _BoardPanel(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, $name 👋',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Mau jelajah rasa Nusantara hari ini?',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: openProfileTab,
            child: _ProfileAvatar(photoPath: photoPath),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero panel — gambar nyata dari recipe.imagePath, bukan emoji
// ─────────────────────────────────────────────────────────────────────────────

class _GameHeroPanel extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;

  const _GameHeroPanel({required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.spiceBrown, width: 2.8),
          boxShadow: const [
            BoxShadow(
                color: Color(0x26000000), blurRadius: 14, offset: Offset(0, 7)),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 34, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Teks
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.terracotta.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.terracotta.withOpacity(0.30)),
                          ),
                          child: const Text(
                            'Pilihan Hari Ini ✨',
                            style: TextStyle(
                              color: AppColors.terracotta,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          recipe.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(children: [
                          const Icon(Icons.location_on_outlined,
                              size: 13, color: AppColors.terracotta),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              '${recipe.province} • ${recipe.island}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.greenEnd,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: AppColors.greenShadow, width: 1.4),
                            boxShadow: const [
                              BoxShadow(
                                  color: AppColors.greenShadow,
                                  offset: Offset(0, 3)),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.restaurant_menu_rounded,
                                  size: 14, color: Colors.white),
                              SizedBox(width: 6),
                              Text('Lihat Resep',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Gambar — rounded rectangle, bukan circle/emoji
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.spiceBrown, width: 2.2),
                      ),
                      child: RecipeImage(
                        imagePath: recipe.imagePath,
                        width: 104,
                        height: 104,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Ribbon
            const Positioned(
              top: -15,
              left: 14,
              right: 14,
              child: _Ribbon(label: 'Rekomendasi'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private widgets
// ─────────────────────────────────────────────────────────────────────────────

class _TopTitle extends StatelessWidget {
  const _TopTitle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(minWidth: 220),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.ribbonStart, AppColors.ribbonEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.ribbonShadow, width: 1.3),
          boxShadow: const [
            BoxShadow(
                color: Color(0x30000000), blurRadius: 12, offset: Offset(0, 5)),
          ],
        ),
        child: const Text(
          'Rasa Nusantara',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? photoPath;
  const _ProfileAvatar({required this.photoPath});

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoPath != null &&
        photoPath!.isNotEmpty &&
        File(photoPath!).existsSync();
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: AppColors.paper,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.spiceBrown, width: 2.6),
        boxShadow: const [
          BoxShadow(
              color: Color(0x30000000), blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: ClipOval(
        child: hasPhoto
            ? Image.file(File(photoPath!),
                width: 62, height: 62, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.person_rounded,
                    color: AppColors.spiceBrown, size: 32))
            : const Icon(Icons.person_rounded,
                color: AppColors.spiceBrown, size: 32),
      ),
    );
  }
}

class _GameMenuPanel extends StatelessWidget {
  final String label;
  final IconData icon;
  final String description;
  final VoidCallback onTap;

  const _GameMenuPanel({
    required this.label,
    required this.icon,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _GamePanel(
      label: label,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 34, 14, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.cream,
                shape: BoxShape.circle,
                border:
                    Border.all(color: AppColors.spiceBrown, width: 2),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 6,
                      offset: Offset(0, 2)),
                ],
              ),
              child: Icon(icon, color: AppColors.spiceBrown, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GamePanel extends StatelessWidget {
  final String label;
  final Widget child;
  final VoidCallback? onTap;

  const _GamePanel({required this.label, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    final panel = Container(
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.spiceBrown, width: 2.8),
        boxShadow: const [
          BoxShadow(
              color: Color(0x26000000), blurRadius: 14, offset: Offset(0, 7)),
        ],
      ),
      child: Stack(clipBehavior: Clip.none, children: [
        child,
        Positioned(
            top: -15,
            left: 14,
            right: 14,
            child: _Ribbon(label: label)),
      ]),
    );

    if (onTap == null) return panel;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
          borderRadius: BorderRadius.circular(28), onTap: onTap, child: panel),
    );
  }
}

class _BoardPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const _BoardPanel({required this.child, required this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.spiceBrown, width: 2.8),
        boxShadow: const [
          BoxShadow(
              color: Color(0x26000000), blurRadius: 14, offset: Offset(0, 7)),
        ],
      ),
      child: child,
    );
  }
}

class _Ribbon extends StatelessWidget {
  final String label;
  const _Ribbon({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(minWidth: 112),
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.ribbonGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.ribbonShadow, width: 1.2),
          boxShadow: const [
            BoxShadow(
                color: Color(0x24000000), blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900)),
      ),
    );
  }
}

class _GameSectionTitle extends StatelessWidget {
  final String title;
  const _GameSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
          child: Container(
              height: 2,
              decoration: BoxDecoration(
                  color: AppColors.spiceBrown.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(999)))),
      const SizedBox(width: 10),
      _Ribbon(label: title),
      const SizedBox(width: 10),
      Expanded(
          child: Container(
              height: 2,
              decoration: BoxDecoration(
                  color: AppColors.spiceBrown.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(999)))),
    ]);
  }
}

class _RecipePanelWrapper extends StatelessWidget {
  final Widget child;
  const _RecipePanelWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.spiceBrown, width: 2.4),
        boxShadow: const [
          BoxShadow(
              color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: child,
    );
  }
}

class _EmptyGamePanel extends StatelessWidget {
  const _EmptyGamePanel();

  @override
  Widget build(BuildContext context) {
    return _GamePanel(
      label: 'Info',
      child: const Padding(
        padding: EdgeInsets.fromLTRB(18, 30, 18, 16),
        child: Row(children: [
          Text('🍽️', style: TextStyle(fontSize: 30)),
          SizedBox(width: 12),
          Expanded(
              child: Text('Belum ada resep yang tersedia saat ini.',
                  style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w800))),
        ]),
      ),
    );
  }
}