import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/recipe_card.dart';
import '../../core/widgets/section_title.dart';
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

  List<Recipe> popular = [];
  String name = 'Teman Rasa';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadHome();
  }

  Future<void> loadHome() async {
    final user = await authRepository.getCurrentUser();
    final popularData = await recipeRepository.getPopularRecipes();

    if (!mounted) return;

    setState(() {
      name = user?.name ?? 'Teman Rasa';
      popular = popularData;
      loading = false;
    });
  }

  Future<void> refreshHome() async {
    await loadHome();
  }

  void openSearchTab() {
    widget.onChangeTab?.call(1);
  }

  @override
  Widget build(BuildContext context) {
    final topRecipe = popular.isNotEmpty ? popular.first : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.spiceBrown,
                ),
              )
            : RefreshIndicator(
                onRefresh: refreshHome,
                color: AppColors.spiceBrown,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                  children: [
                    buildHeader(),
                    const SizedBox(height: 20),
                    if (topRecipe != null) _HeroRecommendation(recipe: topRecipe),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: _FeatureCard(
                            title: 'Buku Resep',
                            subtitle: 'Resep tradisional dan sejarahnya',
                            icon: Icons.menu_book_rounded,
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
                          child: _FeatureCard(
                            title: 'Peta Kuliner',
                            subtitle: 'Cari restoran bernuansa daerah',
                            icon: Icons.map_rounded,
                            onTap: openSearchTab,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _FeatureCard(
                            title: 'Tanya Dapur AI',
                            subtitle: 'Rekomendasi dari bahanmu',
                            icon: Icons.auto_awesome_rounded,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.aiRecommendation,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _FeatureCard(
                            title: 'Peta Rasa',
                            subtitle: 'Game asal makanan',
                            icon: Icons.public_rounded,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.petaRasaGame,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _FeatureCard(
                      title: 'Shake Random Recipe',
                      subtitle: 'Goyangkan HP untuk memilih resep acak',
                      icon: Icons.vibration_rounded,
                      full: true,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.shakeRandomRecipe,
                        );
                      },
                    ),
                    const SizedBox(height: 26),
                    const SectionTitle(title: 'Populer di Nusantara'),
                    const SizedBox(height: 12),
                    ...popular.map(
                      (recipe) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
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
                  ],
                ),
              ),
      ),
    );
  }

  Widget buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, $name',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Mau jelajah rasa Nusantara hari ini?',
                style: TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.cream,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.line),
          ),
          child: const Center(
            child: Text(
              '🍃',
              style: TextStyle(fontSize: 23),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroRecommendation extends StatelessWidget {
  final Recipe recipe;

  const _HeroRecommendation({
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 194,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          colors: [
            AppColors.darkBrown,
            AppColors.spiceBrown,
            AppColors.terracotta,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.spiceBrown.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 20,
            bottom: 8,
            child: Text(
              recipe.emoji,
              style: const TextStyle(fontSize: 88),
            ),
          ),
          Positioned(
            left: 22,
            top: 24,
            right: 130,
            child: Text(
              'Rekomendasi hari ini',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Positioned(
            left: 22,
            top: 54,
            right: 120,
            child: Text(
              recipe.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
              ),
            ),
          ),
          Positioned(
            left: 22,
            bottom: 22,
            child: FilledButton.tonalIcon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.recipeDetail,
                  arguments: recipe,
                );
              },
              icon: const Icon(Icons.restaurant_menu_rounded),
              label: const Text('Lihat Resep'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool full;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.full = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.line),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkBrown.withValues(alpha: 0.04),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: full ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: AppColors.spiceBrown,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}