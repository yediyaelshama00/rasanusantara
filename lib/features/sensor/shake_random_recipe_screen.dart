import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/recipe_model.dart';
import '../../data/repositories/recipe_repository.dart';

class ShakeRandomRecipeScreen extends StatefulWidget {
  const ShakeRandomRecipeScreen({super.key});

  @override
  State<ShakeRandomRecipeScreen> createState() =>
      _ShakeRandomRecipeScreenState();
}

class _ShakeRandomRecipeScreenState extends State<ShakeRandomRecipeScreen> {
  final repository = RecipeRepository();
  final random = Random();

  StreamSubscription<AccelerometerEvent>? subscription;

  List<Recipe> recipes = [];
  Recipe? selected;

  DateTime lastShake = DateTime.fromMillisecondsSinceEpoch(0);
  double intensity = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    subscription = accelerometerEventStream().listen(_onAccelerometer);
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final data = await repository.getRecipes();

    if (!mounted) return;

    setState(() {
      recipes = data;
      loading = false;
    });
  }

  void _onAccelerometer(AccelerometerEvent event) {
    final value = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    if (!mounted) return;

    setState(() {
      intensity = value;
    });

    final now = DateTime.now();

    if (value > 18 &&
        now.difference(lastShake).inMilliseconds > 1200 &&
        recipes.isNotEmpty) {
      lastShake = now;

      setState(() {
        selected = recipes[random.nextInt(recipes.length)];
      });
    }
  }

  void _randomPick() {
    if (recipes.isEmpty) return;

    setState(() {
      selected = recipes[random.nextInt(recipes.length)];
    });
  }

  void _openRecipe(Recipe recipe) {
    Navigator.pushNamed(
      context,
      AppRoutes.recipeDetail,
      arguments: recipe,
    );
  }

  @override
  Widget build(BuildContext context) {
    final progressValue = (intensity / 25).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.spiceBrown,
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
                children: [
                  Row(
                    children: [
                      _IconButtonCircle(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'Random Resep',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.darkBrown,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 42),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _ShakeInfoCard(
                    progressValue: progressValue,
                    intensity: intensity,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _randomPick,
                      icon: const Icon(Icons.casino_outlined),
                      label: const Text(
                        'Pilih Manual',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.greenEnd,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: const BorderSide(
                            color: AppColors.greenShadow,
                            width: 1.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  if (selected == null)
                    const _EmptySelectedCard()
                  else
                    _SelectedRecipeCard(
                      recipe: selected!,
                      onTap: () => _openRecipe(selected!),
                    ),
                ],
              ),
      ),
    );
  }
}

class _ShakeInfoCard extends StatelessWidget {
  final double progressValue;
  final double intensity;

  const _ShakeInfoCard({
    required this.progressValue,
    required this.intensity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.spiceBrown,
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.cream,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.spiceBrown.withOpacity(0.35),
              ),
            ),
            child: const Icon(
              Icons.phone_iphone_rounded,
              color: AppColors.spiceBrown,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Goyangkan HP kamu',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Accelerometer akan memilih satu resep acak dari koleksi RasaNusantara.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w500,
              height: 1.4,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progressValue,
              backgroundColor: AppColors.cream,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.terracotta,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intensitas: ${intensity.toStringAsFixed(1)}',
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySelectedCard extends StatelessWidget {
  const _EmptySelectedCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 26, 18, 26),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.line,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.restaurant_menu_rounded,
            color: AppColors.spiceBrown,
            size: 42,
          ),
          SizedBox(height: 12),
          Text(
            'Belum ada resep terpilih',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Goyangkan perangkat atau tekan tombol pilih manual.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedRecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;

  const _SelectedRecipeCard({
    required this.recipe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.spiceBrown,
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.cream,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.spiceBrown.withOpacity(0.35),
              ),
            ),
            child: Center(
              child: Text(
                recipe.emoji,
                style: const TextStyle(fontSize: 52),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            recipe.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 23,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${recipe.province} • ${recipe.cookTimeMinutes} menit • ${recipe.difficulty}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.restaurant_menu_rounded),
              label: const Text(
                'Lihat Resep',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.spiceBrown,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconButtonCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButtonCircle({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.paper,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.line,
            ),
          ),
          child: Icon(
            icon,
            color: AppColors.spiceBrown,
            size: 21,
          ),
        ),
      ),
    );
  }
}