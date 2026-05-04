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
  State<ShakeRandomRecipeScreen> createState() => _ShakeRandomRecipeScreenState();
}

class _ShakeRandomRecipeScreenState extends State<ShakeRandomRecipeScreen> {
  final repository = RecipeRepository();
  final random = Random();
  StreamSubscription<AccelerometerEvent>? subscription;
  List<Recipe> recipes = [];
  Recipe? selected;
  DateTime lastShake = DateTime.fromMillisecondsSinceEpoch(0);
  double intensity = 0;

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
    setState(() => recipes = data);
  }

  void _onAccelerometer(AccelerometerEvent event) {
    final value = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    if (!mounted) return;
    setState(() => intensity = value);
    final now = DateTime.now();
    if (value > 18 && now.difference(lastShake).inMilliseconds > 1200 && recipes.isNotEmpty) {
      lastShake = now;
      setState(() => selected = recipes[random.nextInt(recipes.length)]);
    }
  }

  void _randomPick() {
    if (recipes.isEmpty) return;
    setState(() => selected = recipes[random.nextInt(recipes.length)]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shake Random Recipe')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.darkBrown, AppColors.spiceBrown, AppColors.terracotta], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(34),
            ),
            child: Column(
              children: [
                const Text('📱', style: TextStyle(fontSize: 58)),
                const SizedBox(height: 14),
                const Text('Goyangkan HP kamu', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text('Accelerometer akan memilih resep acak dari database RasaNusantara.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withValues(alpha: 0.82), fontWeight: FontWeight.w600, height: 1.4)),
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    minHeight: 12,
                    value: (intensity / 25).clamp(0, 1),
                    backgroundColor: Colors.white.withValues(alpha: 0.20),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.turmeric),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: _randomPick,
            icon: const Icon(Icons.casino_outlined),
            label: const Text('Pilih Manual'),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(54), foregroundColor: AppColors.spiceBrown, side: const BorderSide(color: AppColors.line), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), textStyle: const TextStyle(fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 24),
          if (selected == null)
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: AppColors.line)),
              child: const Column(
                children: [
                  Text('🍃', style: TextStyle(fontSize: 46)),
                  SizedBox(height: 12),
                  Text('Belum ada resep terpilih', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.ink, fontSize: 18)),
                  SizedBox(height: 6),
                  Text('Goyangkan perangkat atau tekan tombol pilih manual.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600)),
                ],
              ),
            )
          else
            _SelectedRecipeCard(recipe: selected!),
        ],
      ),
    );
  }
}

class _SelectedRecipeCard extends StatelessWidget {
  final Recipe recipe;

  const _SelectedRecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), border: Border.all(color: AppColors.line), boxShadow: [BoxShadow(color: AppColors.darkBrown.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Column(
        children: [
          Text(recipe.emoji, style: const TextStyle(fontSize: 72)),
          const SizedBox(height: 10),
          Text(recipe.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.ink)),
          const SizedBox(height: 6),
          Text('${recipe.province} • ${recipe.cookTimeMinutes} menit • ${recipe.difficulty}', style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.detail, arguments: recipe),
            icon: const Icon(Icons.restaurant_menu_rounded),
            label: const Text('Lihat Resep'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.spiceBrown, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
          ),
        ],
      ),
    );
  }
}
