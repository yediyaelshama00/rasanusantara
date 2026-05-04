import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/recipe_model.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'rasanusantara.db');
    _database = await openDatabase(path, version: 1, onCreate: _onCreate);
    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        salt TEXT NOT NULL,
        photo_path TEXT,
        biometric_enabled INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE recipes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        province TEXT NOT NULL,
        island TEXT NOT NULL,
        description TEXT NOT NULL,
        ingredients TEXT NOT NULL,
        steps TEXT NOT NULL,
        cook_time_minutes INTEGER NOT NULL,
        difficulty TEXT NOT NULL,
        estimated_cost INTEGER NOT NULL,
        emoji TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE favorites(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        recipe_id INTEGER NOT NULL,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(user_id, recipe_id),
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY(recipe_id) REFERENCES recipes(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE cooking_schedules(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        recipe_id INTEGER NOT NULL,
        cooking_time TEXT NOT NULL,
        reminder_time TEXT,
        note TEXT,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY(recipe_id) REFERENCES recipes(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE feedbacks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        impression TEXT NOT NULL,
        suggestion TEXT NOT NULL,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE search_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        keyword TEXT NOT NULL,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await _seedRecipes(db);
  }

  Future<void> _seedRecipes(Database db) async {
    final recipes = [
      const Recipe(
        name: 'Rendang',
        province: 'Sumatera Barat',
        island: 'Sumatera',
        description: 'Rendang adalah masakan Minangkabau berbumbu pekat yang dimasak perlahan hingga bumbu meresap dan kuah mengering.',
        ingredients: 'Daging sapi\nSantan\nCabai merah\nBawang merah\nBawang putih\nLengkuas\nSerai\nDaun jeruk\nDaun kunyit\nGaram',
        steps: 'Haluskan bumbu\nTumis bumbu hingga wangi\nMasukkan daging dan santan\nMasak perlahan sambil diaduk\nKecilkan api hingga bumbu mengental\nSajikan saat daging empuk',
        cookTimeMinutes: 180,
        difficulty: 'Sulit',
        estimatedCost: 145000,
        emoji: '🍛',
      ),
      const Recipe(
        name: 'Gudeg',
        province: 'DI Yogyakarta',
        island: 'Jawa',
        description: 'Gudeg adalah olahan nangka muda bercita rasa manis gurih yang menjadi ikon kuliner Yogyakarta.',
        ingredients: 'Nangka muda\nSantan\nGula merah\nBawang merah\nBawang putih\nKetumbar\nDaun salam\nLengkuas\nTelur rebus',
        steps: 'Rebus nangka muda\nSusun bumbu dan daun salam\nTambahkan santan dan gula merah\nMasak lama hingga cokelat\nSajikan dengan telur dan sambal krecek',
        cookTimeMinutes: 120,
        difficulty: 'Sedang',
        estimatedCost: 85000,
        emoji: '🥘',
      ),
      const Recipe(
        name: 'Papeda',
        province: 'Papua',
        island: 'Papua',
        description: 'Papeda adalah makanan pokok berbahan sagu yang biasa disantap bersama ikan kuah kuning.',
        ingredients: 'Tepung sagu\nAir panas\nIkan tongkol\nKunyit\nSerai\nDaun jeruk\nJeruk nipis\nGaram',
        steps: 'Larutkan sagu dengan air\nTuang air panas sambil diaduk\nMasak ikan kuah kuning\nSajikan papeda dengan kuah ikan',
        cookTimeMinutes: 45,
        difficulty: 'Mudah',
        estimatedCost: 65000,
        emoji: '🐟',
      ),
      const Recipe(
        name: 'Rawon',
        province: 'Jawa Timur',
        island: 'Jawa',
        description: 'Rawon adalah sup daging berkuah hitam khas Jawa Timur yang memakai kluwek sebagai bumbu utama.',
        ingredients: 'Daging sapi\nKluwek\nBawang merah\nBawang putih\nKunyit\nLengkuas\nSerai\nDaun jeruk\nTauge pendek',
        steps: 'Rebus daging hingga empuk\nHaluskan bumbu dan kluwek\nTumis bumbu\nMasukkan ke kuah daging\nSajikan dengan tauge dan sambal',
        cookTimeMinutes: 90,
        difficulty: 'Sedang',
        estimatedCost: 105000,
        emoji: '🍲',
      ),
      const Recipe(
        name: 'Ayam Betutu',
        province: 'Bali',
        island: 'Bali & Nusa Tenggara',
        description: 'Ayam Betutu adalah hidangan ayam berbumbu genep khas Bali dengan aroma rempah kuat.',
        ingredients: 'Ayam utuh\nBawang merah\nBawang putih\nCabai\nKunyit\nJahe\nKencur\nSerai\nDaun pisang',
        steps: 'Haluskan bumbu genep\nBalur ayam dengan bumbu\nBungkus daun pisang\nKukus atau panggang hingga matang\nSajikan hangat',
        cookTimeMinutes: 110,
        difficulty: 'Sedang',
        estimatedCost: 115000,
        emoji: '🍗',
      ),
      const Recipe(
        name: 'Pempek',
        province: 'Sumatera Selatan',
        island: 'Sumatera',
        description: 'Pempek adalah olahan ikan dan sagu khas Palembang yang disajikan bersama kuah cuko.',
        ingredients: 'Ikan tenggiri\nTepung sagu\nBawang putih\nTelur\nGaram\nGula merah\nAsam jawa\nCabai',
        steps: 'Campur ikan dan sagu\nBentuk adonan\nRebus hingga mengapung\nGoreng sebentar\nSajikan dengan cuko',
        cookTimeMinutes: 75,
        difficulty: 'Sedang',
        estimatedCost: 90000,
        emoji: '🥟',
      ),
      const Recipe(
        name: 'Coto Makassar',
        province: 'Sulawesi Selatan',
        island: 'Sulawesi',
        description: 'Coto Makassar adalah sup daging berbumbu kacang dan rempah khas Sulawesi Selatan.',
        ingredients: 'Daging sapi\nKacang tanah\nBawang merah\nBawang putih\nKetumbar\nJinten\nSerai\nLengkuas',
        steps: 'Rebus daging\nSangrai kacang dan haluskan\nTumis bumbu\nMasukkan bumbu ke kaldu\nSajikan dengan ketupat',
        cookTimeMinutes: 100,
        difficulty: 'Sedang',
        estimatedCost: 100000,
        emoji: '🍜',
      ),
      const Recipe(
        name: 'Soto Banjar',
        province: 'Kalimantan Selatan',
        island: 'Kalimantan',
        description: 'Soto Banjar adalah soto ayam khas Banjar dengan rempah harum dan kuah bening gurih.',
        ingredients: 'Ayam\nBawang merah\nBawang putih\nKayu manis\nCengkeh\nKapulaga\nTelur\nPerkedel',
        steps: 'Rebus ayam\nTumis bumbu rempah\nCampurkan ke kaldu\nSuwir ayam\nSajikan dengan telur dan perkedel',
        cookTimeMinutes: 70,
        difficulty: 'Mudah',
        estimatedCost: 75000,
        emoji: '🍵',
      ),
      const Recipe(
        name: 'Seruit',
        province: 'Lampung',
        island: 'Sumatera',
        description: 'Seruit adalah hidangan ikan bakar atau goreng yang dimakan bersama sambal terasi dan tempoyak.',
        ingredients: 'Ikan sungai\nCabai\nTerasi\nTomat\nTempoyak\nJeruk limau\nGaram',
        steps: 'Bersihkan ikan\nBakar atau goreng ikan\nUlek sambal\nCampurkan tempoyak\nSajikan bersama lalapan',
        cookTimeMinutes: 55,
        difficulty: 'Mudah',
        estimatedCost: 70000,
        emoji: '🌶️',
      ),
      const Recipe(
        name: 'Mie Aceh',
        province: 'Aceh',
        island: 'Sumatera',
        description: 'Mie Aceh adalah mie berbumbu kari pekat dengan pilihan daging, seafood, atau ayam.',
        ingredients: 'Mie kuning\nDaging atau udang\nBawang merah\nBawang putih\nCabai\nKari\nKol\nTomat',
        steps: 'Tumis bumbu\nMasukkan daging atau udang\nTambahkan mie dan sayur\nAduk dengan kuah kari\nSajikan dengan acar',
        cookTimeMinutes: 45,
        difficulty: 'Mudah',
        estimatedCost: 60000,
        emoji: '🍝',
      ),
    ];

    for (final recipe in recipes) {
      await db.insert('recipes', recipe.toMap());
    }
  }
}
