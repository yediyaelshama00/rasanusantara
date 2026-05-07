import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../core/constants/app_colors.dart';

class PetaRasaGameScreen extends StatefulWidget {
  const PetaRasaGameScreen({super.key});

  @override
  State<PetaRasaGameScreen> createState() => _PetaRasaGameScreenState();
}

class _PetaRasaGameScreenState extends State<PetaRasaGameScreen> {
  static const int rows = 21;
  static const int cols = 19;

  final random = Random();

  final List<List<List<int>>> mazeTemplates = const [
    [
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 0, 1],
      [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 0, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 0, 1],
      [1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1],
      [1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1],
      [1, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1],
      [1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1],
      [0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0],
      [1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1],
      [1, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1],
      [1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1],
      [1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 0, 1],
      [1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1],
      [1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1],
      [1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1],
      [1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1],
      [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    ],
    [
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1],
      [1, 0, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 0, 1],
      [1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1],
      [1, 0, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1],
      [1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1],
      [1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1],
      [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1],
      [1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1],
      [0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0],
      [1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 0, 1, 1],
      [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1],
      [1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1],
      [1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1],
      [1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1],
      [1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1],
      [1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1],
      [1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1],
      [1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 0, 1],
      [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    ],
    [
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1],
      [1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0, 1],
      [1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1],
      [1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1],
      [1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1],
      [1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 0, 1],
      [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1],
      [1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1],
      [0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0],
      [1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1],
      [1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1],
      [1, 0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1],
      [1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 0, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 0, 1],
      [1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1],
      [1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1],
      [1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1],
      [1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1],
      [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    ],
  ];

  final Map<String, List<_FoodInfo>> islandFoods = const {
    'Sumatera': [
      _FoodInfo('Rendang', 'assets/images/rendang.png',
          'Masakan Minangkabau yang dimasak lama dengan santan dan rempah.'),
      _FoodInfo('Pempek', 'assets/images/pempek.png',
          'Kuliner Palembang berbahan ikan dan sagu, disajikan dengan cuko asam pedas.'),
      _FoodInfo('Mi Gomak', 'assets/images/mie_aceh.png',
          'Mi khas Sumatera Utara yang sering disebut spaghetti Batak karena bentuknya besar.'),
      _FoodInfo('Seruit', 'assets/images/seruit.png',
          'Hidangan ikan khas Lampung yang disajikan dengan sambal terasi dan tempoyak.'),
    ],
    'Jawa': [
      _FoodInfo('Gudeg', 'assets/images/gudeg.png',
          'Nangka muda yang dimasak lama dengan santan dan gula aren, ikon kuliner Yogyakarta.'),
      _FoodInfo('Rawon', 'assets/images/rawon.png',
          'Sup daging khas Jawa Timur dengan kuah hitam dari kluwek.'),
      _FoodInfo('Plecing Kangkung', 'assets/images/plecing_kangkung.png',
          'Sayuran rebus dengan sambal tomat pedas khas Lombok dan Jawa.'),
      _FoodInfo('Mie Aceh', 'assets/images/mie_aceh.png',
          'Mie berbumbu kari pekat dengan pilihan daging atau seafood.'),
    ],
    'Kalimantan': [
      _FoodInfo('Soto Banjar', 'assets/images/soto_banjar.png',
          'Soto khas Banjar dengan aroma rempah seperti kayu manis, cengkeh, dan kapulaga.'),
      _FoodInfo('Choi Pan', 'assets/images/choi_pan.png',
          'Kuliner akulturasi Tionghoa-Singkawang berisi bengkuang yang dikukus.'),
      _FoodInfo('Ketupat Kandangan', 'assets/images/ketupat_kandangan.png',
          'Hidangan khas Kalimantan Selatan dengan kuah santan gurih dan ikan haruan.'),
      _FoodInfo('Sop Konro', 'assets/images/sop_konro.png',
          'Sup iga khas Makassar dengan kuah hitam rempah yang pekat.'),
    ],
    'Sulawesi': [
      _FoodInfo('Coto Makassar', 'assets/images/coto_makassar.png',
          'Sup daging khas Makassar dengan bumbu kacang dan rempah kuat.'),
      _FoodInfo('Sop Konro', 'assets/images/sop_konro.png',
          'Sup iga khas Makassar dengan kuah hitam rempah yang pekat.'),
      _FoodInfo('Tinutuan', 'assets/images/tinutuan.png',
          'Bubur Manado berisi sayuran yang dikenal sebagai makanan sehat khas Sulawesi Utara.'),
      _FoodInfo(
          'Ikan Bakar Manokwari',
          'assets/images/ikan_bakar_manokwari.png',
          'Ikan bakar dengan sambal mentah pedas khas Papua Barat.'),
    ],
    'Bali & Nusa Tenggara': [
      _FoodInfo('Ayam Betutu', 'assets/images/ayam_betutu.png',
          'Masakan khas Bali dimasak dengan bumbu genep dan dibungkus daun, lalu dipanggang lama.'),
      _FoodInfo('Se\'i Sapi', 'assets/images/sei_sapi.png',
          'Daging asap khas Nusa Tenggara Timur dengan aroma khas dari proses pengasapan.'),
      _FoodInfo('Plecing Kangkung', 'assets/images/plecing_kangkung.png',
          'Sayuran rebus dengan sambal tomat pedas khas Lombok.'),
      _FoodInfo('Seruit', 'assets/images/seruit.png',
          'Hidangan ikan khas dengan sambal dan tempoyak yang segar.'),
    ],
    'Papua': [
      _FoodInfo('Papeda', 'assets/images/papeda.png',
          'Bubur sagu makanan pokok Papua, biasa disantap dengan ikan kuah kuning.'),
      _FoodInfo(
          'Ikan Bakar Manokwari',
          'assets/images/ikan_bakar_manokwari.png',
          'Ikan bakar khas Papua Barat dengan sambal mentah yang pedas.'),
      _FoodInfo('Sagu Lempeng', 'assets/images/sagu_lempeng.png',
          'Olahan sagu yang dibakar hingga kering, sering dimakan bersama teh.'),
      _FoodInfo('Ketupat Kandangan', 'assets/images/ketupat_kandangan.png',
          'Hidangan dengan kuah santan gurih khas nusantara timur.'),
    ],
  };

  List<List<int>> maze = [];
  List<_Enemy> enemies = [];

  String? island;
  int score = 0;
  int lives = 3;
  int timeLeft = 150;
  int foundFood = 0;
  int mapIndex = 0;

  int playerX = 9;
  int playerY = 15;
  int dirX = 0;
  int dirY = 0;
  int nextDirX = 0;
  int nextDirY = 0;

  bool running = false;
  bool paused = false;
  bool finished = false;
  bool win = false;
  bool gyroEnabled = false;

  // FIX: dedicated flag to prevent re-entrant dialog calls while one is open.
  bool _showingFoodDialog = false;

  // FIX: queue of collected foods waiting to be shown, so no collection is
  // ever lost even if two foods are somehow hit in quick succession.
  final List<_FoodInfo> _pendingFoods = [];

  Offset joystickOffset = Offset.zero;
  DateTime lastGyroMove = DateTime.now();

  Timer? gameTimer;
  Timer? clockTimer;
  StreamSubscription<GyroscopeEvent>? gyroscopeSubscription;

  List<_FoodInfo> get currentFoods => islandFoods[island] ?? [];

  @override
  void dispose() {
    gameTimer?.cancel();
    clockTimer?.cancel();
    stopGyroscopeControl();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Maze helpers
  // ─────────────────────────────────────────────────────────────────────────

  List<List<int>> generateRandomMaze() {
    mapIndex = random.nextInt(mazeTemplates.length);
    return mazeTemplates[mapIndex].map((row) => List<int>.from(row)).toList();
  }

  List<_Cell> getAvailableCells() {
    final cells = <_Cell>[];
    for (int y = 0; y < maze.length; y++) {
      for (int x = 0; x < maze[y].length; x++) {
        if (maze[y][x] == 0) cells.add(_Cell(x, y));
      }
    }
    return cells;
  }

  void placePlayerRandomly() {
    final candidates = getAvailableCells()
      ..removeWhere(
          (c) => c.x < 2 || c.x > cols - 3 || c.y < 2 || c.y > rows - 3)
      ..shuffle(random);
    final chosen =
        candidates.isNotEmpty ? candidates.first : const _Cell(9, 15);
    playerX = chosen.x;
    playerY = chosen.y;
  }

  void placeFoodsRandomly() {
    final candidates = getAvailableCells()
      ..removeWhere((c) => (c.x - playerX).abs() + (c.y - playerY).abs() < 6)
      ..shuffle(random);
    for (int i = 0; i < currentFoods.length && i < candidates.length; i++) {
      maze[candidates[i].y][candidates[i].x] = 2;
    }
  }

  void placeEnemiesRandomly() {
    final candidates = getAvailableCells()
      ..removeWhere((c) => (c.x - playerX).abs() + (c.y - playerY).abs() < 7)
      ..shuffle(random);
    enemies = [];
    final count = 2 + random.nextInt(2);
    for (int i = 0; i < count && i < candidates.length; i++) {
      enemies.add(_Enemy(candidates[i].x, candidates[i].y));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Game lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  void startGame(String selectedIsland) {
    gameTimer?.cancel();
    clockTimer?.cancel();

    setState(() {
      island = selectedIsland;
      maze = generateRandomMaze();
      score = 0;
      lives = 3;
      timeLeft = 150;
      foundFood = 0;
      playerX = 9;
      playerY = 15;
      dirX = 0;
      dirY = 0;
      nextDirX = 0;
      nextDirY = 0;
      joystickOffset = Offset.zero;
      running = true;
      paused = false;
      finished = false;
      win = false;
      _showingFoodDialog = false;
      _pendingFoods.clear();

      placePlayerRandomly();
      placeFoodsRandomly();
      placeEnemiesRandomly();
    });

    gameTimer =
        Timer.periodic(const Duration(milliseconds: 150), (_) => tickGame());
    clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!running || paused || finished) return;
      if (timeLeft <= 1) {
        finishGame(false);
        return;
      }
      setState(() => timeLeft--);
    });

    if (gyroEnabled) startGyroscopeControl();
  }

  void startGyroscopeControl() {
    gyroscopeSubscription?.cancel();
    gyroscopeSubscription = gyroscopeEventStream().listen((event) {
      if (!gyroEnabled || !running || paused || finished) return;
      final now = DateTime.now();
      if (now.difference(lastGyroMove).inMilliseconds < 220) return;
      const threshold = 1.2;
      if (event.x.abs() < threshold && event.y.abs() < threshold) return;
      if (event.x.abs() > event.y.abs()) {
        setDirection(0, event.x > 0 ? 1 : -1);
      } else {
        setDirection(event.y > 0 ? 1 : -1, 0);
      }
      lastGyroMove = now;
    });
  }

  void stopGyroscopeControl() {
    gyroscopeSubscription?.cancel();
    gyroscopeSubscription = null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Game tick
  // ─────────────────────────────────────────────────────────────────────────

  void tickGame() {
    // FIX: also stop ticking while a food dialog is showing.
    if (!running || paused || finished || _showingFoodDialog) return;

    movePlayer();
    collectCell(); // may add to _pendingFoods and set paused=true
    moveEnemies();
    checkEnemyCollision();

    if (mounted && !finished) setState(() {});
  }

  void movePlayer() {
    final nextX = wrappedX(playerX + nextDirX);
    final nextY = playerY + nextDirY;
    if (canMove(nextX, nextY)) {
      dirX = nextDirX;
      dirY = nextDirY;
    }

    final targetX = wrappedX(playerX + dirX);
    final targetY = playerY + dirY;
    if (canMove(targetX, targetY)) {
      playerX = targetX;
      playerY = targetY;
    }
  }

  void moveEnemies() {
    for (final enemy in enemies) {
      final directions = [
        const _Direction(1, 0),
        const _Direction(-1, 0),
        const _Direction(0, 1),
        const _Direction(0, -1),
      ]..shuffle(random);

      final possible = directions
          .where((d) => canMove(wrappedX(enemy.x + d.x), enemy.y + d.y))
          .toList();
      if (possible.isEmpty) continue;

      possible.sort((a, b) {
        final distA = (wrappedX(enemy.x + a.x) - playerX).abs() +
            (enemy.y + a.y - playerY).abs();
        final distB = (wrappedX(enemy.x + b.x) - playerX).abs() +
            (enemy.y + b.y - playerY).abs();
        return distA.compareTo(distB);
      });

      final selected = random.nextInt(100) < 55
          ? possible.first
          : possible[random.nextInt(possible.length)];
      enemy.x = wrappedX(enemy.x + selected.x);
      enemy.y = enemy.y + selected.y;
    }
  }

  // FIX: collectCell no longer calls showFoodDialog directly.
  // Instead it queues the food and schedules _drainFoodQueue via
  // addPostFrameCallback, which runs safely after the current frame is done —
  // completely outside the Timer callback.
  void collectCell() {
    final cell = maze[playerY][playerX];

    if (cell == 0) {
      maze[playerY][playerX] = -1;
      score += 10;
      return;
    }

    if (cell == 2) {
      maze[playerY][playerX] = -1;
      score += 500;

      final index = foundFood;
      foundFood++;

      if (index < currentFoods.length) {
        _pendingFoods.add(currentFoods[index]);

        // Pause the game world immediately so enemies stop moving.
        paused = true;

        // Schedule dialog display on the next frame – safe to call Navigator.
        WidgetsBinding.instance.addPostFrameCallback((_) => _drainFoodQueue());
      }
    }
  }

  // FIX: processes the pending food queue one at a time, sequentially awaiting
  // each dialog before showing the next.
  Future<void> _drainFoodQueue() async {
    // Guard: don't start a new drain if one is already running.
    if (_showingFoodDialog) return;

    while (_pendingFoods.isNotEmpty) {
      if (!mounted || finished) return;

      final food = _pendingFoods.removeAt(0);
      _showingFoodDialog = true;

      await showFoodDialog(food);

      _showingFoodDialog = false;

      if (!mounted || finished) return;

      // Check win condition after each dialog.
      if (foundFood >= currentFoods.length) {
        finishGame(true);
        return;
      }
    }

    // All dialogs shown — resume the game.
    if (mounted && !finished) {
      setState(() => paused = false);
    }
  }

  void checkEnemyCollision() {
    for (final enemy in enemies) {
      if (enemy.x == playerX && enemy.y == playerY) {
        lives--;
        if (lives <= 0) {
          finishGame(false);
        } else {
          dirX = 0;
          dirY = 0;
          nextDirX = 0;
          nextDirY = 0;
          joystickOffset = Offset.zero;
          placePlayerRandomly();
          placeEnemiesRandomly();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Kena penjaga rempah! Nyawa berkurang.'),
              duration: Duration(milliseconds: 900),
            ));
          }
        }
        break;
      }
    }
  }

  bool canMove(int x, int y) {
    if (y < 0 || y >= rows) return false;
    return maze[y][x] != 1;
  }

  int wrappedX(int x) {
    if (x < 0) return cols - 1;
    if (x >= cols) return 0;
    return x;
  }

  void setDirection(int x, int y) {
    if (!mounted) return;
    setState(() {
      nextDirX = x;
      nextDirY = y;
    });
  }

  void updateJoystick(Offset localPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final delta = localPosition - center;
    final maxDistance = min(size.width, size.height) * 0.34;
    final limited = delta.distance > maxDistance
        ? Offset.fromDirection(delta.direction, maxDistance)
        : delta;
    setState(() => joystickOffset = limited);
    if (limited.distance < 8) return;
    if (limited.dx.abs() > limited.dy.abs()) {
      setDirection(limited.dx > 0 ? 1 : -1, 0);
    } else {
      setDirection(0, limited.dy > 0 ? 1 : -1);
    }
  }

  void resetJoystick() => setState(() => joystickOffset = Offset.zero);

  // ─────────────────────────────────────────────────────────────────────────
  // Food dialog
  // FIX: now a clean async method that just shows one dialog and returns.
  // All flow control lives in _drainFoodQueue.
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> showFoodDialog(_FoodInfo food) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Container(
            width: 320,
            decoration: BoxDecoration(
              color: AppColors.paper,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.spiceBrown, width: 2.6),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x30000000),
                    blurRadius: 20,
                    offset: Offset(0, 10)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Gambar makanan ──────────────────────────────────────
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(26)),
                      child: Image.asset(
                        food.imagePath,
                        height: 170,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 170,
                          decoration: const BoxDecoration(
                            color: AppColors.cream,
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(26)),
                          ),
                          child: const Center(
                            child: Text('🍽️', style: TextStyle(fontSize: 52)),
                          ),
                        ),
                      ),
                    ),
                    // Overlay gradient supaya ribbon terbaca di atas gambar
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 56,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Color(0xCC000000), Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                    // Badge "+500 poin" di pojok kanan atas
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.greenEnd,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(
                                color: AppColors.greenShadow,
                                offset: Offset(0, 3)),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded,
                                color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text('+500 Poin',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    // Nama makanan di overlay bawah gambar
                    Positioned(
                      bottom: 10,
                      left: 14,
                      right: 14,
                      child: Text(
                        food.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 8)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Konten teks ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Label "Makanan Khas Nusantara"
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.cream,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.spiceBrown.withOpacity(0.28)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.emoji_food_beverage_rounded,
                                size: 13, color: AppColors.spiceBrown),
                            const SizedBox(width: 5),
                            Text(
                              'Makanan Khas $island',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.spiceBrown,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        food.description,
                        style: const TextStyle(
                          color: AppColors.softChocolate,
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // ── Tombol lanjutkan ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.greenEnd,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: const BorderSide(
                            color: AppColors.greenShadow, width: 1.5),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_arrow_rounded, size: 20),
                        SizedBox(width: 6),
                        Text('Lanjutkan Ekspedisi',
                            style: TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Game end
  // ─────────────────────────────────────────────────────────────────────────

  void finishGame(bool value) {
    gameTimer?.cancel();
    clockTimer?.cancel();
    if (!mounted) return;
    setState(() {
      finished = true;
      running = false;
      paused = false;
      win = value;
      dirX = 0;
      dirY = 0;
      nextDirX = 0;
      nextDirY = 0;
      joystickOffset = Offset.zero;
    });
  }

  void backToMenu() {
    gameTimer?.cancel();
    clockTimer?.cancel();
    stopGyroscopeControl();
    setState(() {
      island = null;
      running = false;
      paused = false;
      finished = false;
      win = false;
      score = 0;
      lives = 3;
      timeLeft = 150;
      foundFood = 0;
      joystickOffset = Offset.zero;
      maze = [];
      enemies = [];
      _showingFoodDialog = false;
      _pendingFoods.clear();
    });
  }

  void handleSwipeEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond;
    if (velocity.dx.abs() < 80 && velocity.dy.abs() < 80) return;
    if (velocity.dx.abs() > velocity.dy.abs()) {
      setDirection(velocity.dx > 0 ? 1 : -1, 0);
    } else {
      setDirection(0, velocity.dy > 0 ? 1 : -1);
    }
  }

  void toggleGyro() {
    final value = !gyroEnabled;
    setState(() => gyroEnabled = value);
    if (value)
      startGyroscopeControl();
    else
      stopGyroscopeControl();
  }

  void showInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        decoration: BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.line),
          boxShadow: const [
            BoxShadow(
                color: Color(0x22000000), blurRadius: 18, offset: Offset(0, 10))
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(mainAxisSize: MainAxisSize.min, children: const [
            Icon(Icons.info_outline_rounded,
                color: AppColors.spiceBrown, size: 34),
            SizedBox(height: 12),
            Text('Cara Main',
                style: TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 21)),
            SizedBox(height: 12),
            Text(
              'Cari hadiah makanan khas di dalam labirin, hindari penjaga rempah, lalu kumpulkan semua hadiah agar misi selesai. Kamu bisa bermain dengan swipe, joystick, atau kontrol rotasi HP.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w500,
                  height: 1.55,
                  fontSize: 14),
            ),
          ]),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: island == null && !finished ? buildMenu() : buildGame(),
      ),
    );
  }

  Widget buildMenu() {
    final islands = islandFoods.keys.toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        children: [
          buildTopBar(
              title: 'Peta Rasa',
              subtitle: 'Mini game kuliner Nusantara',
              showBack: true),
          const SizedBox(height: 18),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                    decoration: BoxDecoration(
                      color: AppColors.paper,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.spiceBrown, width: 2),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x18000000),
                            blurRadius: 14,
                            offset: Offset(0, 7))
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: AppColors.cream,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.spiceBrown.withOpacity(0.28)),
                          ),
                          child: const Center(
                              child:
                                  Text('🟡', style: TextStyle(fontSize: 38))),
                        ),
                        const SizedBox(height: 16),
                        const Text('Pac-Man Nusantara',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppColors.ink,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5)),
                        const SizedBox(height: 8),
                        const Text(
                            'Pilih pulau, temukan makanan khas, dan hindari penjaga rempah.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppColors.muted,
                                fontWeight: FontWeight.w500,
                                height: 1.45,
                                fontSize: 13.5)),
                        const SizedBox(height: 20),
                        Column(
                          children: islands
                              .map((item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _GlossyButton(
                                        label: item,
                                        onTap: () => startGame(item)),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGame() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            children: [
              buildTopBar(
                  title: island ?? 'Peta Rasa',
                  subtitle: 'Map ${mapIndex + 1}',
                  showBack: false),
              const SizedBox(height: 10),
              buildStatsAndGyro(),
              const SizedBox(height: 10),
              Expanded(
                child: LayoutBuilder(builder: (context, area) {
                  const bottomControlHeight = 108.0;
                  const bottomGap = 4.0;
                  final boardAvailableHeight = max(
                      120.0, area.maxHeight - bottomControlHeight - bottomGap);
                  final boardWidth =
                      min(area.maxWidth, boardAvailableHeight * cols / rows);
                  final boardHeight = boardWidth * rows / cols;
                  final frameWidth = boardWidth + 12;
                  final frameHeight = boardHeight + 12;

                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: frameWidth,
                          height: frameHeight,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.paper,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                                color: AppColors.spiceBrown, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                  color: Color(0x18000000),
                                  blurRadius: 12,
                                  offset: Offset(0, 7))
                            ],
                          ),
                          child: GestureDetector(
                            onPanEnd: finished ? null : handleSwipeEnd,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: SizedBox(
                                width: boardWidth,
                                height: boardHeight,
                                child: CustomPaint(
                                  size: Size(boardWidth, boardHeight),
                                  painter: _MazePainter(
                                    maze: maze,
                                    playerX: playerX,
                                    playerY: playerY,
                                    dirX: dirX,
                                    dirY: dirY,
                                    enemies: enemies,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: bottomGap),
                        buildBottomControlOnly(),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        if (finished) buildFinishOverlay(),
      ],
    );
  }

  Widget buildTopBar(
      {required String title,
      required String subtitle,
      required bool showBack}) {
    return SizedBox(
      height: 52,
      child: Row(children: [
        _RoundIconButton(
          icon: showBack ? Icons.arrow_back_rounded : Icons.close_rounded,
          onTap: showBack ? () => Navigator.pop(context) : backToMenu,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.paper,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(children: [
              const Text('🧭', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                  const SizedBox(height: 1),
                  Text(subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.muted,
                          fontWeight: FontWeight.w500,
                          fontSize: 10.5)),
                ],
              )),
            ]),
          ),
        ),
        const SizedBox(width: 10),
        _RoundIconButton(icon: Icons.info_outline_rounded, onTap: showInfo),
      ]),
    );
  }

  Widget buildStatsAndGyro() {
    return SizedBox(
      height: 42,
      child: Row(children: [
        Expanded(child: buildStats()),
        const SizedBox(width: 6),
        buildGyroTopChip(),
      ]),
    );
  }

  Widget buildStats() {
    return Row(children: [
      Expanded(child: _StatBox(label: 'Skor', value: '$score')),
      const SizedBox(width: 4),
      Expanded(child: _StatBox(label: 'Nyawa', value: '$lives')),
      const SizedBox(width: 4),
      Expanded(child: _StatBox(label: 'Waktu', value: '${timeLeft}s')),
      const SizedBox(width: 4),
      Expanded(
          child: _StatBox(
              label: 'Hadiah', value: '$foundFood/${currentFoods.length}')),
    ]);
  }

  Widget buildGyroTopChip() {
    return GestureDetector(
      onTap: toggleGyro,
      child: Container(
        width: 58,
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: gyroEnabled ? AppColors.cream : AppColors.paper,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: gyroEnabled
                  ? AppColors.spiceBrown.withOpacity(0.35)
                  : AppColors.line),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.screen_rotation_alt_rounded,
              color: gyroEnabled ? AppColors.spiceBrown : AppColors.muted,
              size: 15),
          const SizedBox(height: 1),
          Text(gyroEnabled ? 'ON' : 'OFF',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: gyroEnabled ? AppColors.spiceBrown : AppColors.muted,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  Widget buildBottomControlOnly() {
    return SizedBox(
      height: 108,
      width: double.infinity,
      child: Center(
          child: _JoystickController(
              offset: joystickOffset,
              onChanged: updateJoystick,
              onEnd: resetJoystick)),
    );
  }

  Widget buildFinishOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.20),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.line),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 20,
                  offset: Offset(0, 12))
            ],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(win ? '🎉' : '💥', style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(win ? 'Misi $island Selesai!' : 'Misi Gagal',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 21)),
            const SizedBox(height: 10),
            Text(
              win
                  ? 'Semua rahasia rasa berhasil ditemukan. Skor akhir kamu $score.'
                  : 'Nyawa habis atau waktu selesai. Coba ekspedisi lagi.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.muted,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                  fontSize: 14),
            ),
            const SizedBox(height: 22),
            _GlossyButton(label: 'Kembali ke Menu', onTap: backToMenu),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────────────────────────────────────

class _MazePainter extends CustomPainter {
  final List<List<int>> maze;
  final int playerX;
  final int playerY;
  final int dirX;
  final int dirY;
  final List<_Enemy> enemies;

  const _MazePainter({
    required this.maze,
    required this.playerX,
    required this.playerY,
    required this.dirX,
    required this.dirY,
    required this.enemies,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (maze.isEmpty) return;

    final tileW = size.width / _PetaRasaGameScreenState.cols;
    final tileH = size.height / _PetaRasaGameScreenState.rows;

    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFF050714));

    final wallFill = Paint()..color = const Color(0xFF06183B);
    final wallStroke = Paint()
      ..color = const Color(0xFF2E66FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = min(tileW, tileH) * 0.10;
    final dotPaint = Paint()..color = const Color(0xFFFFB28C);
    final playerPaint = Paint()..color = const Color(0xFFFFE438);
    final mouthPaint = Paint()..color = const Color(0xFF050714);

    for (var r = 0; r < maze.length; r++) {
      for (var c = 0; c < maze[r].length; c++) {
        final value = maze[r][c];
        final rect = Rect.fromLTWH(c * tileW, r * tileH, tileW, tileH);

        if (value == 1) {
          final rr = RRect.fromRectAndRadius(
              rect.deflate(0.8), Radius.circular(min(tileW, tileH) * 0.24));
          canvas.drawRRect(rr, wallFill);
          canvas.drawRRect(rr, wallStroke);
        } else if (value == 0) {
          canvas.drawCircle(rect.center, min(tileW, tileH) * 0.09, dotPaint);
        } else if (value == 2) {
          drawEmoji(canvas, '🎁', rect.center, min(tileW, tileH) * 0.74);
        }
      }
    }

    for (final enemy in enemies) {
      drawEmoji(
          canvas,
          '🌶️',
          Offset(enemy.x * tileW + tileW / 2, enemy.y * tileH + tileH / 2),
          min(tileW, tileH) * 0.82);
    }

    final pc = Offset(playerX * tileW + tileW / 2, playerY * tileH + tileH / 2);
    final radius = min(tileW, tileH) * 0.42;

    canvas.drawCircle(pc + Offset(0, radius * 0.22), radius * 0.95,
        Paint()..color = const Color(0x55000000));
    canvas.drawCircle(pc, radius, playerPaint);
    canvas.drawCircle(pc - Offset(radius * 0.20, radius * 0.22), radius * 0.15,
        Paint()..color = const Color(0xFFFFF59D));

    final direction = Offset(
      dirX == 0 && dirY == 0 ? 1 : dirX.toDouble(),
      dirX == 0 && dirY == 0 ? 0 : dirY.toDouble(),
    );
    final mouth = Path()..moveTo(pc.dx, pc.dy);
    if (direction.dx > 0) {
      mouth
        ..lineTo(pc.dx + radius, pc.dy - radius * 0.45)
        ..lineTo(pc.dx + radius, pc.dy + radius * 0.45);
    } else if (direction.dx < 0) {
      mouth
        ..lineTo(pc.dx - radius, pc.dy - radius * 0.45)
        ..lineTo(pc.dx - radius, pc.dy + radius * 0.45);
    } else if (direction.dy > 0) {
      mouth
        ..lineTo(pc.dx - radius * 0.45, pc.dy + radius)
        ..lineTo(pc.dx + radius * 0.45, pc.dy + radius);
    } else {
      mouth
        ..lineTo(pc.dx - radius * 0.45, pc.dy - radius)
        ..lineTo(pc.dx + radius * 0.45, pc.dy - radius);
    }
    mouth.close();
    canvas.drawPath(mouth, mouthPaint);
  }

  void drawEmoji(Canvas canvas, String emoji, Offset center, double size) {
    final painter = TextPainter(
      text: TextSpan(text: emoji, style: TextStyle(fontSize: size)),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
        canvas, center - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _MazePainter oldDelegate) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.line),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w500,
                  fontSize: 8)),
          const SizedBox(height: 1),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 11)),
        ]),
      ),
    );
  }
}

class _JoystickController extends StatelessWidget {
  final Offset offset;
  final void Function(Offset localPosition, Size size) onChanged;
  final VoidCallback onEnd;
  const _JoystickController(
      {required this.offset, required this.onChanged, required this.onEnd});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      height: 104,
      child: LayoutBuilder(builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          onPanDown: (d) => onChanged(d.localPosition, size),
          onPanUpdate: (d) => onChanged(d.localPosition, size),
          onPanEnd: (_) => onEnd(),
          onPanCancel: onEnd,
          child: Stack(alignment: Alignment.center, children: [
            Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.paper,
                    border: Border.all(color: AppColors.line),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x18000000),
                          blurRadius: 10,
                          offset: Offset(0, 5))
                    ])),
            Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.cream,
                    border: Border.all(color: AppColors.line))),
            Transform.translate(
              offset: offset * 0.72,
              child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.greenEnd,
                      border: Border.all(color: Colors.white, width: 2.4),
                      boxShadow: const [
                        BoxShadow(
                            color: AppColors.greenShadow, offset: Offset(0, 3))
                      ]),
                  child: const Icon(Icons.control_camera_rounded,
                      color: Colors.white, size: 20)),
            ),
          ]),
        );
      }),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});

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
                border: Border.all(color: AppColors.line)),
            child: Icon(icon, color: AppColors.spiceBrown, size: 22)),
      ),
    );
  }
}

class _GlossyButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GlossyButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.greenEnd,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: AppColors.greenShadow, width: 1.3)),
        ),
        child: Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data classes
// ─────────────────────────────────────────────────────────────────────────────

class _FoodInfo {
  final String name;
  final String imagePath;
  final String description;
  const _FoodInfo(this.name, this.imagePath, this.description);
}

class _Enemy {
  int x;
  int y;
  _Enemy(this.x, this.y);
}

class _Direction {
  final int x;
  final int y;
  const _Direction(this.x, this.y);
}

class _Cell {
  final int x;
  final int y;
  const _Cell(this.x, this.y);
}
