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
      _FoodInfo(
        'Rendang',
        '🍱',
        'Masakan Minangkabau yang dimasak lama dengan santan dan rempah. Rendang melambangkan kesabaran dan ketekunan.',
      ),
      _FoodInfo(
        'Pempek',
        '🐟',
        'Kuliner Palembang berbahan ikan dan sagu, disajikan dengan cuko asam pedas.',
      ),
      _FoodInfo(
        'Mi Gomak',
        '🍜',
        'Mi khas Sumatera Utara yang sering disebut spaghetti Batak karena bentuknya besar dan bumbunya kuat.',
      ),
      _FoodInfo(
        'Bika Ambon',
        '🥮',
        'Kue bertekstur bersarang dari Medan yang memiliki aroma harum dan rasa manis legit.',
      ),
    ],
    'Jawa': [
      _FoodInfo(
        'Gudeg',
        '🍲',
        'Nangka muda yang dimasak lama dengan santan dan gula aren, menjadi ikon kuliner Yogyakarta.',
      ),
      _FoodInfo(
        'Sate Madura',
        '🍢',
        'Sate berbumbu kacang dari Madura yang populer di banyak daerah Indonesia.',
      ),
      _FoodInfo(
        'Rawon',
        '🥘',
        'Sup daging khas Jawa Timur dengan kuah hitam dari kluwek.',
      ),
      _FoodInfo(
        'Pecel',
        '🥗',
        'Sayuran rebus dengan sambal kacang, dikenal luas di Jawa Timur dan Jawa Tengah.',
      ),
    ],
    'Kalimantan': [
      _FoodInfo(
        'Soto Banjar',
        '🥣',
        'Soto khas Banjar dengan aroma rempah seperti kayu manis, cengkeh, dan kapulaga.',
      ),
      _FoodInfo(
        'Choi Pan',
        '🥟',
        'Kuliner akulturasi Tionghoa-Singkawang berisi bengkuang yang dikukus.',
      ),
      _FoodInfo(
        'Ketupat Kandangan',
        '🍛',
        'Hidangan khas Kalimantan Selatan dengan kuah santan gurih dan ikan haruan.',
      ),
      _FoodInfo(
        'Juhu Singkah',
        '🌿',
        'Masakan Dayak berbahan umbut rotan muda dengan cita rasa khas hutan Kalimantan.',
      ),
    ],
    'Sulawesi': [
      _FoodInfo(
        'Coto Makassar',
        '🥘',
        'Sup daging khas Makassar dengan bumbu kacang dan rempah kuat.',
      ),
      _FoodInfo(
        'Es Pisang Ijo',
        '🍨',
        'Pisang berbalut adonan hijau disajikan dengan bubur sumsum dan sirup.',
      ),
      _FoodInfo(
        'Sop Konro',
        '🍖',
        'Sup iga khas Makassar dengan kuah hitam rempah yang pekat.',
      ),
      _FoodInfo(
        'Tinutuan',
        '🥣',
        'Bubur Manado berisi sayuran yang dikenal sebagai makanan sehat khas Sulawesi Utara.',
      ),
    ],
    'Papua': [
      _FoodInfo(
        'Papeda',
        '🥣',
        'Bubur sagu yang menjadi makanan pokok di Papua dan Maluku, biasa disantap dengan ikan kuah kuning.',
      ),
      _FoodInfo(
        'Ikan Bakar Manokwari',
        '🐟',
        'Ikan bakar khas Papua Barat dengan sambal mentah yang pedas.',
      ),
      _FoodInfo(
        'Sagu Lempeng',
        '🍘',
        'Olahan sagu yang dibakar hingga kering dan sering dimakan bersama teh atau kopi.',
      ),
      _FoodInfo(
        'Udang Selingkuh',
        '🦐',
        'Kuliner khas Wamena dengan bentuk capit besar seperti kepiting.',
      ),
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

  List<List<int>> generateRandomMaze() {
    mapIndex = random.nextInt(mazeTemplates.length);
    final selected = mazeTemplates[mapIndex];
    return selected.map((row) => List<int>.from(row)).toList();
  }

  List<_Cell> getAvailableCells() {
    final cells = <_Cell>[];

    for (int y = 0; y < maze.length; y++) {
      for (int x = 0; x < maze[y].length; x++) {
        if (maze[y][x] == 0) {
          cells.add(_Cell(x, y));
        }
      }
    }

    return cells;
  }

  void placePlayerRandomly() {
    final candidates = getAvailableCells();

    candidates.removeWhere((cell) {
      return cell.x < 2 || cell.x > cols - 3 || cell.y < 2 || cell.y > rows - 3;
    });

    candidates.shuffle(random);

    final chosen = candidates.isNotEmpty ? candidates.first : const _Cell(9, 15);

    playerX = chosen.x;
    playerY = chosen.y;
  }

  void placeFoodsRandomly() {
    final candidates = getAvailableCells();

    candidates.removeWhere((cell) {
      return (cell.x - playerX).abs() + (cell.y - playerY).abs() < 6;
    });

    candidates.shuffle(random);

    for (int i = 0; i < currentFoods.length && i < candidates.length; i++) {
      final cell = candidates[i];
      maze[cell.y][cell.x] = 2;
    }
  }

  void placeEnemiesRandomly() {
    final candidates = getAvailableCells();

    candidates.removeWhere((cell) {
      return (cell.x - playerX).abs() + (cell.y - playerY).abs() < 7;
    });

    candidates.shuffle(random);

    enemies = [];

    final enemyCount = 2 + random.nextInt(2);

    for (int i = 0; i < enemyCount && i < candidates.length; i++) {
      final cell = candidates[i];
      enemies.add(_Enemy(cell.x, cell.y));
    }
  }

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

      placePlayerRandomly();
      placeFoodsRandomly();
      placeEnemiesRandomly();
    });

    gameTimer = Timer.periodic(const Duration(milliseconds: 150), (_) {
      tickGame();
    });

    clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!running || paused || finished) return;

      if (timeLeft <= 1) {
        finishGame(false);
        return;
      }

      setState(() {
        timeLeft--;
      });
    });

    if (gyroEnabled) {
      startGyroscopeControl();
    }
  }

  void startGyroscopeControl() {
    gyroscopeSubscription?.cancel();

    gyroscopeSubscription = gyroscopeEventStream().listen((event) {
      if (!gyroEnabled || !running || paused || finished) return;

      final now = DateTime.now();

      if (now.difference(lastGyroMove).inMilliseconds < 220) return;

      final x = event.x;
      final y = event.y;

      const threshold = 1.2;

      if (x.abs() < threshold && y.abs() < threshold) return;

      if (x.abs() > y.abs()) {
        setDirection(0, x > 0 ? 1 : -1);
      } else {
        setDirection(y > 0 ? 1 : -1, 0);
      }

      lastGyroMove = now;
    });
  }

  void stopGyroscopeControl() {
    gyroscopeSubscription?.cancel();
    gyroscopeSubscription = null;
  }

  void tickGame() {
    if (!running || paused || finished) return;

    movePlayer();
    collectCell();
    moveEnemies();
    checkEnemyCollision();

    if (mounted && !finished) {
      setState(() {});
    }
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
      ];

      directions.shuffle(random);

      final possible = directions.where((direction) {
        final x = wrappedX(enemy.x + direction.x);
        final y = enemy.y + direction.y;
        return canMove(x, y);
      }).toList();

      if (possible.isEmpty) continue;

      possible.sort((a, b) {
        final ax = wrappedX(enemy.x + a.x);
        final ay = enemy.y + a.y;
        final bx = wrappedX(enemy.x + b.x);
        final by = enemy.y + b.y;

        final distA = (ax - playerX).abs() + (ay - playerY).abs();
        final distB = (bx - playerX).abs() + (by - playerY).abs();

        return distA.compareTo(distB);
      });

      final selected = random.nextInt(100) < 55
          ? possible.first
          : possible[random.nextInt(possible.length)];

      enemy.x = wrappedX(enemy.x + selected.x);
      enemy.y = enemy.y + selected.y;
    }
  }

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
        paused = true;
        Future.microtask(() {
          if (mounted && !finished) {
            showFoodDialog(currentFoods[index]);
          }
        });
      }
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Kena penjaga rempah! Nyawa berkurang.'),
                duration: Duration(milliseconds: 900),
              ),
            );
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

    Offset limited = delta;

    if (delta.distance > maxDistance) {
      limited = Offset.fromDirection(delta.direction, maxDistance);
    }

    setState(() {
      joystickOffset = limited;
    });

    if (limited.distance < 8) return;

    if (limited.dx.abs() > limited.dy.abs()) {
      setDirection(limited.dx > 0 ? 1 : -1, 0);
    } else {
      setDirection(0, limited.dy > 0 ? 1 : -1);
    }
  }

  void resetJoystick() {
    setState(() {
      joystickOffset = Offset.zero;
    });
  }

  Future<void> showFoodDialog(_FoodInfo food) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.paper,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(
              color: AppColors.line,
            ),
          ),
          title: Row(
            children: [
              Text(
                food.emoji,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  food.name,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            food.description,
            style: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w500,
              height: 1.5,
              fontSize: 14,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.greenEnd,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Lanjutkan',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted || finished) return;

    if (foundFood >= currentFoods.length) {
      finishGame(true);
      return;
    }

    setState(() {
      paused = false;
    });
  }

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

    setState(() {
      gyroEnabled = value;
    });

    if (value) {
      startGyroscopeControl();
    } else {
      stopGyroscopeControl();
    }
  }

  void showInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          margin: const EdgeInsets.all(14),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.line,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.spiceBrown,
                  size: 34,
                ),
                SizedBox(height: 12),
                Text(
                  'Cara Main',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 21,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Cari hadiah makanan khas di dalam labirin, hindari penjaga rempah, lalu kumpulkan semua hadiah agar misi selesai. Kamu bisa bermain dengan swipe, joystick, atau kontrol rotasi HP.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w500,
                    height: 1.55,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
            showBack: true,
          ),
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
                      border: Border.all(
                        color: AppColors.spiceBrown,
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x18000000),
                          blurRadius: 14,
                          offset: Offset(0, 7),
                        ),
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
                              color: AppColors.spiceBrown.withOpacity(0.28),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              '🟡',
                              style: TextStyle(fontSize: 38),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Pac-Man Nusantara',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.ink,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Pilih pulau, temukan makanan khas, dan hindari penjaga rempah.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.muted,
                            fontWeight: FontWeight.w500,
                            height: 1.45,
                            fontSize: 13.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Column(
                          children: islands.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _GlossyButton(
                                label: item,
                                onTap: () => startGame(item),
                              ),
                            );
                          }).toList(),
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
                showBack: false,
              ),
              const SizedBox(height: 10),
              buildStatsAndGyro(),
              const SizedBox(height: 10),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, area) {
                    const bottomControlHeight = 108.0;
                    const bottomGap = 4.0;

                    final boardAvailableHeight = max(
                      120.0,
                      area.maxHeight - bottomControlHeight - bottomGap,
                    );

                    final boardWidth = min(
                      area.maxWidth,
                      boardAvailableHeight * cols / rows,
                    );

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
                                color: AppColors.spiceBrown,
                                width: 2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x18000000),
                                  blurRadius: 12,
                                  offset: Offset(0, 7),
                                ),
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
                  },
                ),
              ),
            ],
          ),
        ),
        if (finished) buildFinishOverlay(),
      ],
    );
  }

  Widget buildTopBar({
    required String title,
    required String subtitle,
    required bool showBack,
  }) {
    return SizedBox(
      height: 52,
      child: Row(
        children: [
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
                border: Border.all(
                  color: AppColors.line,
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    '🍛',
                    style: TextStyle(fontSize: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontWeight: FontWeight.w500,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          _RoundIconButton(
            icon: Icons.info_outline_rounded,
            onTap: showInfo,
          ),
        ],
      ),
    );
  }

  Widget buildStatsAndGyro() {
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          Expanded(
            child: buildStats(),
          ),
          const SizedBox(width: 6),
          buildGyroTopChip(),
        ],
      ),
    );
  }

  Widget buildStats() {
    return Row(
      children: [
        Expanded(
          child: _StatBox(
            label: 'Skor',
            value: '$score',
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: _StatBox(
            label: 'Nyawa',
            value: '$lives',
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: _StatBox(
            label: 'Waktu',
            value: '${timeLeft}s',
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: _StatBox(
            label: 'Hadiah',
            value: '$foundFood/${currentFoods.length}',
          ),
        ),
      ],
    );
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
                : AppColors.line,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.screen_rotation_alt_rounded,
              color: gyroEnabled ? AppColors.spiceBrown : AppColors.muted,
              size: 15,
            ),
            const SizedBox(height: 1),
            Text(
              gyroEnabled ? 'ON' : 'OFF',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: gyroEnabled ? AppColors.spiceBrown : AppColors.muted,
                fontSize: 8.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBottomControlOnly() {
    return SizedBox(
      height: 108,
      width: double.infinity,
      child: Center(
        child: buildControllerCompact(),
      ),
    );
  }

  Widget buildControllerCompact() {
    return _JoystickController(
      offset: joystickOffset,
      onChanged: updateJoystick,
      onEnd: resetJoystick,
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
            border: Border.all(
              color: AppColors.line,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 20,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                win ? '🎉' : '💥',
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 12),
              Text(
                win ? 'Misi $island Selesai!' : 'Misi Gagal',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 21,
                ),
              ),
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
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 22),
              _GlossyButton(
                label: 'Kembali ke Menu',
                onTap: backToMenu,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

    final boardPaint = Paint()..color = const Color(0xFF050714);
    final wallFillPaint = Paint()..color = const Color(0xFF06183B);
    final wallStrokePaint = Paint()
      ..color = const Color(0xFF2E66FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = min(tileW, tileH) * 0.10;
    final dotPaint = Paint()..color = const Color(0xFFFFB28C);
    final playerPaint = Paint()..color = const Color(0xFFFFE438);
    final mouthPaint = Paint()..color = const Color(0xFF050714);

    canvas.drawRect(Offset.zero & size, boardPaint);

    for (var r = 0; r < maze.length; r++) {
      for (var c = 0; c < maze[r].length; c++) {
        final value = maze[r][c];
        final rect = Rect.fromLTWH(
          c * tileW,
          r * tileH,
          tileW,
          tileH,
        );

        if (value == 1) {
          final rounded = RRect.fromRectAndRadius(
            rect.deflate(0.8),
            Radius.circular(min(tileW, tileH) * 0.24),
          );
          canvas.drawRRect(rounded, wallFillPaint);
          canvas.drawRRect(rounded, wallStrokePaint);
        } else if (value == 0) {
          canvas.drawCircle(
            rect.center,
            min(tileW, tileH) * 0.09,
            dotPaint,
          );
        } else if (value == 2) {
          drawEmoji(
            canvas,
            '🎁',
            rect.center,
            min(tileW, tileH) * 0.74,
          );
        }
      }
    }

    for (final enemy in enemies) {
      final center = Offset(
        enemy.x * tileW + tileW / 2,
        enemy.y * tileH + tileH / 2,
      );

      drawEmoji(
        canvas,
        '🌶️',
        center,
        min(tileW, tileH) * 0.82,
      );
    }

    final playerCenter = Offset(
      playerX * tileW + tileW / 2,
      playerY * tileH + tileH / 2,
    );

    final radius = min(tileW, tileH) * 0.42;

    canvas.drawCircle(
      playerCenter + Offset(0, radius * 0.22),
      radius * 0.95,
      Paint()..color = const Color(0x55000000),
    );

    canvas.drawCircle(playerCenter, radius, playerPaint);

    canvas.drawCircle(
      playerCenter - Offset(radius * 0.20, radius * 0.22),
      radius * 0.15,
      Paint()..color = const Color(0xFFFFF59D),
    );

    final mouth = Path();

    final direction = Offset(
      dirX == 0 && dirY == 0 ? 1 : dirX.toDouble(),
      dirX == 0 && dirY == 0 ? 0 : dirY.toDouble(),
    );

    if (direction.dx > 0) {
      mouth.moveTo(playerCenter.dx, playerCenter.dy);
      mouth.lineTo(playerCenter.dx + radius, playerCenter.dy - radius * 0.45);
      mouth.lineTo(playerCenter.dx + radius, playerCenter.dy + radius * 0.45);
    } else if (direction.dx < 0) {
      mouth.moveTo(playerCenter.dx, playerCenter.dy);
      mouth.lineTo(playerCenter.dx - radius, playerCenter.dy - radius * 0.45);
      mouth.lineTo(playerCenter.dx - radius, playerCenter.dy + radius * 0.45);
    } else if (direction.dy > 0) {
      mouth.moveTo(playerCenter.dx, playerCenter.dy);
      mouth.lineTo(playerCenter.dx - radius * 0.45, playerCenter.dy + radius);
      mouth.lineTo(playerCenter.dx + radius * 0.45, playerCenter.dy + radius);
    } else {
      mouth.moveTo(playerCenter.dx, playerCenter.dy);
      mouth.lineTo(playerCenter.dx - radius * 0.45, playerCenter.dy - radius);
      mouth.lineTo(playerCenter.dx + radius * 0.45, playerCenter.dy - radius);
    }

    mouth.close();
    canvas.drawPath(mouth, mouthPaint);
  }

  void drawEmoji(Canvas canvas, String emoji, Offset center, double size) {
    final painter = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(fontSize: size),
      ),
      textDirection: TextDirection.ltr,
    );

    painter.layout();
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _MazePainter oldDelegate) {
    return true;
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatBox({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.line,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w500,
                fontSize: 8,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JoystickController extends StatelessWidget {
  final Offset offset;
  final void Function(Offset localPosition, Size size) onChanged;
  final VoidCallback onEnd;

  const _JoystickController({
    required this.offset,
    required this.onChanged,
    required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      height: 104,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(
            constraints.maxWidth,
            constraints.maxHeight,
          );

          return GestureDetector(
            onPanDown: (details) {
              onChanged(details.localPosition, size);
            },
            onPanUpdate: (details) {
              onChanged(details.localPosition, size);
            },
            onPanEnd: (_) {
              onEnd();
            },
            onPanCancel: onEnd,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.paper,
                    border: Border.all(
                      color: AppColors.line,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x18000000),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.cream,
                    border: Border.all(
                      color: AppColors.line,
                    ),
                  ),
                ),
                Transform.translate(
                  offset: offset * 0.72,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.greenEnd,
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
                    child: const Icon(
                      Icons.control_camera_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({
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
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _GlossyButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GlossyButton({
    required this.label,
    required this.onTap,
  });

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
            side: const BorderSide(
              color: AppColors.greenShadow,
              width: 1.3,
            ),
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14.5,
          ),
        ),
      ),
    );
  }
}

class _FoodInfo {
  final String name;
  final String emoji;
  final String description;

  const _FoodInfo(this.name, this.emoji, this.description);
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