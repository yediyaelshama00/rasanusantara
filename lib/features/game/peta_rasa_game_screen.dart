import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/food_game_model.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../data/services/location_service.dart';

class PetaRasaGameScreen extends StatefulWidget {
  const PetaRasaGameScreen({super.key});

  @override
  State<PetaRasaGameScreen> createState() => _PetaRasaGameScreenState();
}

class _PetaRasaGameScreenState extends State<PetaRasaGameScreen> {
  final recipeRepository = RecipeRepository();
  final locationService = LocationService();
  final random = Random();

  List<FoodGameItem> items = [];
  FoodGameItem? current;

  String locationLabel = 'Mode default';
  String localIsland = 'Jawa';

  int score = 0;
  int question = 0;
  int seconds = 60;

  Timer? timer;

  bool finished = false;
  bool detectingLocation = false;

  String feedback = 'Tarik makanan ke daerah asalnya.';

  final regions = const [
    'Sumatera',
    'Jawa',
    'Kalimantan',
    'Sulawesi',
    'Bali & Nusa Tenggara',
    'Papua',
  ];

  @override
  void initState() {
    super.initState();
    _loadWithoutLocation();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _loadWithoutLocation() async {
    final recipes = await recipeRepository.getRecipes();
    final gameItems = recipes
        .map(
          (recipe) => FoodGameItem(
            name: recipe.name,
            province: recipe.province,
            island: recipe.island,
            emoji: recipe.emoji,
          ),
        )
        .toList();

    gameItems.shuffle();

    if (!mounted) return;

    setState(() {
      items = gameItems;
      current = gameItems.first;
      locationLabel = 'Mode default';
      localIsland = 'Jawa';
    });

    _startTimer();
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      detectingLocation = true;
    });

    final locationInfo = await locationService.getCurrentLocationInfo();

    if (!mounted) return;

    setState(() {
      locationLabel = locationInfo.label;
      localIsland = locationInfo.island;
      detectingLocation = false;
    });
  }

  void _startTimer() {
    timer?.cancel();
    seconds = 60;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        seconds--;
        if (seconds <= 0) {
          _finish();
        }
      });
    });
  }

  void _finish() {
    timer?.cancel();
    finished = true;
  }

  void _reset() {
    setState(() {
      items.shuffle();
      current = items.first;
      score = 0;
      question = 0;
      seconds = 60;
      finished = false;
      feedback = 'Tarik makanan ke daerah asalnya.';
    });

    _startTimer();
  }

  void _drop(String region, FoodGameItem item) {
    if (finished) return;

    final correct = item.island == region;

    setState(() {
      if (correct) {
        score += localIsland == region ? 15 : 10;
        feedback = 'Benar! ${item.name} berasal dari ${item.province}.';
      } else {
        score = max(0, score - 3);
        feedback = 'Belum tepat. Hint: ${item.name} berasal dari ${item.province}.';
      }

      question++;

      if (question >= 8) {
        _finish();
      } else {
        current = items[question % items.length];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Rasa Nusantara'),
      ),
      body: current == null
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.spiceBrown,
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
              children: [
                Container(
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
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '$locationLabel • challenge dekat $localIsland',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.86),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: detectingLocation ? null : _useCurrentLocation,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.55),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          icon: detectingLocation
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.my_location_rounded),
                          label: Text(
                            detectingLocation ? 'Mendeteksi lokasi...' : 'Gunakan lokasi saya',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          _ScoreBox(
                            label: 'Skor',
                            value: '$score',
                          ),
                          const SizedBox(width: 10),
                          _ScoreBox(
                            label: 'Waktu',
                            value: '${seconds}s',
                          ),
                          const SizedBox(width: 10),
                          _ScoreBox(
                            label: 'Soal',
                            value: '${min(question + 1, 8)}/8',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                if (finished)
                  _FinishCard(
                    score: score,
                    onReset: _reset,
                  )
                else
                  _FoodDraggable(
                    item: current!,
                  ),
                const SizedBox(height: 18),
                Text(
                  feedback,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  height: 430,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(34),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _MapPainter(),
                        ),
                      ),
                      Positioned(
                        left: 4,
                        top: 110,
                        child: _MapTarget(
                          region: 'Sumatera',
                          width: 132,
                          height: 116,
                          onDrop: _drop,
                        ),
                      ),
                      Positioned(
                        left: 112,
                        top: 248,
                        child: _MapTarget(
                          region: 'Jawa',
                          width: 140,
                          height: 70,
                          onDrop: _drop,
                        ),
                      ),
                      Positioned(
                        left: 142,
                        top: 110,
                        child: _MapTarget(
                          region: 'Kalimantan',
                          width: 132,
                          height: 118,
                          onDrop: _drop,
                        ),
                      ),
                      Positioned(
                        right: 32,
                        top: 160,
                        child: _MapTarget(
                          region: 'Sulawesi',
                          width: 104,
                          height: 120,
                          onDrop: _drop,
                        ),
                      ),
                      Positioned(
                        right: 90,
                        bottom: 26,
                        child: _MapTarget(
                          region: 'Bali & Nusa Tenggara',
                          width: 170,
                          height: 58,
                          onDrop: _drop,
                        ),
                      ),
                      Positioned(
                        right: 4,
                        top: 76,
                        child: _MapTarget(
                          region: 'Papua',
                          width: 124,
                          height: 94,
                          onDrop: _drop,
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

class _ScoreBox extends StatelessWidget {
  final String label;
  final String value;

  const _ScoreBox({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.20),
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.70),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodDraggable extends StatelessWidget {
  final FoodGameItem item;

  const _FoodDraggable({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<FoodGameItem>(
      data: item,
      feedback: Material(
        color: Colors.transparent,
        child: _FoodCard(
          item: item,
          dragging: true,
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: _FoodCard(
          item: item,
        ),
      ),
      child: _FoodCard(
        item: item,
      ),
    );
  }
}

class _FoodCard extends StatelessWidget {
  final FoodGameItem item;
  final bool dragging;

  const _FoodCard({
    required this.item,
    this.dragging = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBrown.withValues(alpha: dragging ? 0.16 : 0.07),
            blurRadius: dragging ? 26 : 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Center(
              child: Text(
                item.emoji,
                style: const TextStyle(fontSize: 34),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tarik makanan ini',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.name,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ke pulau atau wilayah asalnya',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.open_with_rounded,
            color: AppColors.spiceBrown,
          ),
        ],
      ),
    );
  }
}

class _MapTarget extends StatelessWidget {
  final String region;
  final double width;
  final double height;
  final void Function(String region, FoodGameItem item) onDrop;

  const _MapTarget({
    required this.region,
    required this.width,
    required this.height,
    required this.onDrop,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<FoodGameItem>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) => onDrop(region, details.data),
      builder: (context, candidate, rejected) {
        final active = candidate.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: active
                ? AppColors.turmeric.withValues(alpha: 0.30)
                : AppColors.cream.withValues(alpha: 0.64),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: active ? AppColors.terracotta : AppColors.line,
              width: active ? 2 : 1,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                region,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.spiceBrown,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FinishCard extends StatelessWidget {
  final int score;
  final VoidCallback onReset;

  const _FinishCard({
    required this.score,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          const Text(
            '🎉',
            style: TextStyle(fontSize: 44),
          ),
          const SizedBox(height: 8),
          const Text(
            'Permainan selesai',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Skor akhir kamu: $score',
            style: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.replay_rounded),
            label: const Text('Main Lagi'),
          ),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.leaf.withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(8, 122, 125, 70),
        const Radius.circular(38),
      ),
      paint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(120, 266, 140, 32),
        const Radius.circular(24),
      ),
      paint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(154, 126, 104, 82),
        const Radius.circular(36),
      ),
      paint,
    );

    canvas.drawOval(
      Rect.fromLTWH(
        size.width - 140,
        174,
        94,
        86,
      ),
      paint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width - 260,
          size.height - 58,
          180,
          22,
        ),
        const Radius.circular(20),
      ),
      paint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width - 118,
          92,
          110,
          56,
        ),
        const Radius.circular(28),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}