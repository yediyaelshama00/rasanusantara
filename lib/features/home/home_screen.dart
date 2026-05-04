import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/recipe_card.dart';
import '../../data/models/recipe_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/recipe_repository.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int index)? onChangeTab;

  const HomeScreen({
    super.key,
    this.onChangeTab,
  });

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
          recommendation = null;
          others = [];
          loading = false;
        });
        return;
      }

      final now = DateTime.now();
      final seed = now.year * 1000 + now.month * 100 + now.day;

      final shuffled = List<Recipe>.from(allRecipes)
        ..shuffle(Random(seed));

      setState(() {
        name = user?.name ?? 'Teman Rasa';
        photoPath = user?.photoPath;
        recommendation = shuffled.first;
        others = shuffled.skip(1).take(5).toList();
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  Future<void> refreshHome() async {
    await loadHome();
  }

  void openSearchTab() {
    widget.onChangeTab?.call(1);
  }

  void openProfileTab() {
    widget.onChangeTab?.call(profileTabIndex);
  }

  @override
  Widget build(BuildContext context) {
    final topRecipe = recommendation;

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
                onRefresh: refreshHome,
                color: AppColors.spiceBrown,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),
                  children: [
                    const _TopTitle(),
                    const SizedBox(height: 18),
                    _buildWelcomePanel(),
                    const SizedBox(height: 24),

                    if (topRecipe != null) _GameHeroPanel(recipe: topRecipe),

                    const SizedBox(height: 22),

                    Row(
                      children: [
                        Expanded(
                          child: _GameMenuPanel(
                            label: 'Buku Resep',
                            icon: Icons.menu_book_rounded,
                            description: 'Resep tradisional dan sejarahnya',
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.recipeBook,
                              );
                            },
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

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: _GameMenuPanel(
                            label: 'Peta Rasa',
                            icon: Icons.sports_esports_rounded,
                            description: 'Main tebak asal makanan',
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.petaRasaGame,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _GameMenuPanel(
                            label: 'Random Resep',
                            icon: Icons.casino_rounded,
                            description: 'Goyangkan HP untuk resep acak',
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.shakeRandomRecipe,
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    _WideGamePanel(
                      label: 'Explore',
                      title: 'Jelajahi Semua Resep',
                      subtitle:
                          'Temukan masakan Nusantara favoritmu dari berbagai daerah.',
                      icon: Icons.restaurant_menu_rounded,
                      buttonText: 'Buka Resep',
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.recipeBook,
                        );
                      },
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
                          child: _RecipePanelWrapper(
                            child: RecipeCard(
                              recipe: recipe,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.recipeDetail,
                                  arguments: recipe,
                                );
                              },
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
                  'Halo, $name',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Mau jelajah rasa Nusantara hari ini?',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w800,
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

class _TopTitle extends StatelessWidget {
  const _TopTitle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 220,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.ribbonStart,
              AppColors.ribbonEnd,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.ribbonShadow,
            width: 1.3,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x30000000),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
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

  const _ProfileAvatar({
    required this.photoPath,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoPath != null &&
        photoPath!.isNotEmpty &&
        File(photoPath!).existsSync();

    return Container(
      width: 66,
      height: 66,
      decoration: BoxDecoration(
        color: AppColors.paper,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.spiceBrown,
          width: 2.6,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: hasPhoto
            ? Image.file(
                File(photoPath!),
                width: 66,
                height: 66,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return const Center(
                    child: Icon(
                      Icons.person_rounded,
                      color: AppColors.spiceBrown,
                      size: 38,
                    ),
                  );
                },
              )
            : const Center(
                child: Icon(
                  Icons.person_rounded,
                  color: AppColors.spiceBrown,
                  size: 38,
                ),
              ),
      ),
    );
  }
}

class _GameHeroPanel extends StatelessWidget {
  final Recipe recipe;

  const _GameHeroPanel({
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    return _GamePanel(
      label: 'Rekomendasi',
      height: 220,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 32, 18, 18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilihan Hari Ini',
                    style: TextStyle(
                      color: AppColors.terracotta,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    recipe.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      height: 1.08,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Coba resep populer khas Nusantara yang cocok untuk hari ini.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.recipeDetail,
                          arguments: recipe,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.greenEnd,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: const BorderSide(
                            color: AppColors.greenShadow,
                            width: 1.6,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Lihat Resep',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.paper,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.spiceBrown,
                  width: 2.4,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  recipe.emoji,
                  style: const TextStyle(fontSize: 56),
                ),
              ),
            ),
          ],
        ),
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
      height: 162,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 34, 16, 16),
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.paper,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.spiceBrown,
                  width: 2.2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: AppColors.spiceBrown,
                size: 29,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WideGamePanel extends StatelessWidget {
  final String label;
  final String title;
  final String subtitle;
  final IconData icon;
  final String buttonText;
  final VoidCallback onTap;

  const _WideGamePanel({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _GamePanel(
      label: label,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 34, 18, 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: AppColors.paper,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.spiceBrown,
                  width: 2.3,
                ),
              ),
              child: Icon(
                icon,
                color: AppColors.spiceBrown,
                size: 31,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 38,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.greenEnd,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(
                            color: AppColors.greenShadow,
                            width: 1.4,
                          ),
                        ),
                      ),
                      child: Text(
                        buttonText,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
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
}

class _GamePanel extends StatelessWidget {
  final String label;
  final double? height;
  final Widget child;
  final VoidCallback? onTap;

  const _GamePanel({
    required this.label,
    required this.child,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final panel = Container(
      height: height,
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
    );

    if (onTap == null) return panel;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: panel,
      ),
    );
  }
}

class _BoardPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _BoardPanel({
    required this.child,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
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
      child: child,
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
          gradient: const LinearGradient(
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

class _GameSectionTitle extends StatelessWidget {
  final String title;

  const _GameSectionTitle({
    required this.title,
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
        _Ribbon(label: title),
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

class _RecipePanelWrapper extends StatelessWidget {
  final Widget child;

  const _RecipePanelWrapper({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(25),
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
      child: child,
    );
  }
}

class _EmptyGamePanel extends StatelessWidget {
  const _EmptyGamePanel();

  @override
  Widget build(BuildContext context) {
    return const _GamePanel(
      label: 'Info',
      height: 112,
      child: Padding(
        padding: EdgeInsets.fromLTRB(18, 30, 18, 16),
        child: Row(
          children: [
            Text(
              '🍽️',
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Belum ada resep yang tersedia saat ini.',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}