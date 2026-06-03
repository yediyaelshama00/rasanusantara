import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/recipe_model.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();
  Database? _database;

  // Naikkan versi DB dari 1 → 2 karena ada kolom baru
  static const int _dbVersion = 2;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'rasanusantara.db');
    _database = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return _database!;
  }

  // Migrasi: dipanggil saat versi DB lama < versi baru
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Tambah kolom base_servings dengan default 4
      await db.execute(
        'ALTER TABLE recipes ADD COLUMN base_servings INTEGER NOT NULL DEFAULT 4',
      );
      // Update nilai base_servings per resep sesuai seed
      final servingsMap = {
        'Rendang': 4,
        'Gudeg': 4,
        'Papeda': 2,
        'Rawon': 4,
        'Ayam Betutu': 4,
        'Pempek': 6,
        'Coto Makassar': 4,
        'Soto Banjar': 4,
        'Seruit': 3,
        'Mie Aceh': 2,
        'Choi Pan': 6,
        'Ketupat Kandangan': 4,
        'Tinutuan': 4,
        'Sop Konro': 3,
        'Plecing Kangkung': 3,
        'Sei Sapi': 4,
        'Ikan Bakar Manokwari': 2,
        'Sagu Lempeng': 4,
      };
      for (final entry in servingsMap.entries) {
        await db.update(
          'recipes',
          {'base_servings': entry.value},
          where: 'name = ?',
          whereArgs: [entry.key],
        );
      }
    }
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
        image_path TEXT NOT NULL,
        base_servings INTEGER NOT NULL DEFAULT 4
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
        imagePath: 'assets/images/rendang.png',
        baseServings: 4,
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
        imagePath: 'assets/images/gudeg.png',
        baseServings: 4,
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
        imagePath: 'assets/images/papeda.png',
        baseServings: 2,
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
        imagePath: 'assets/images/rawon.png',
        baseServings: 4,
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
        imagePath: 'assets/images/ayam_betutu.png',
        baseServings: 4,
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
        imagePath: 'assets/images/pempek.png',
        baseServings: 6,
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
        imagePath: 'assets/images/coto_makassar.png',
        baseServings: 4,
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
        imagePath: 'assets/images/soto_banjar.png',
        baseServings: 4,
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
        imagePath: 'assets/images/seruit.png',
        baseServings: 3,
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
        imagePath: 'assets/images/mie_aceh.png',
        baseServings: 2,
      ),
      const Recipe(
        name: 'Choi Pan',
        province: 'Kalimantan Barat',
        island: 'Kalimantan',
        description: 'Makanan khas Singkawang berupa kue isi sayur.',
        ingredients: 'Tepung beras\nBengkuang\nBawang putih\nGaram',
        steps: 'Buat kulit\nIsi dengan sayur\nKukus hingga matang',
        cookTimeMinutes: 60,
        difficulty: 'Sedang',
        estimatedCost: 50000,
        imagePath: 'assets/images/choi_pan.png',
        baseServings: 6,
      ),
      const Recipe(
        name: 'Ketupat Kandangan',
        province: 'Kalimantan Selatan',
        island: 'Kalimantan',
        description: 'Ketupat dengan kuah santan ikan haruan.',
        ingredients: 'Ketupat\nIkan haruan\nSantan\nBumbu rempah',
        steps: 'Masak ikan\nBuat kuah santan\nSajikan dengan ketupat',
        cookTimeMinutes: 80,
        difficulty: 'Sedang',
        estimatedCost: 85000,
        imagePath: 'assets/images/ketupat_kandangan.png',
        baseServings: 4,
      ),
      const Recipe(
        name: 'Tinutuan',
        province: 'Sulawesi Utara',
        island: 'Sulawesi',
        description: 'Bubur Manado berisi sayuran sehat.',
        ingredients: 'Beras\nLabu\nBayam\nJagung',
        steps: 'Masak beras\nTambahkan sayur\nAduk hingga jadi bubur',
        cookTimeMinutes: 50,
        difficulty: 'Mudah',
        estimatedCost: 40000,
        imagePath: 'assets/images/tinutuan.png',
        baseServings: 4,
      ),
      const Recipe(
        name: 'Sop Konro',
        province: 'Sulawesi Selatan',
        island: 'Sulawesi',
        description: 'Sup iga dengan bumbu rempah khas Makassar.',
        ingredients: 'Iga sapi\nBumbu rempah\nAir',
        steps: 'Rebus iga\nTambahkan bumbu\nMasak hingga empuk',
        cookTimeMinutes: 120,
        difficulty: 'Sedang',
        estimatedCost: 120000,
        imagePath: 'assets/images/sop_konro.png',
        baseServings: 3,
      ),
      const Recipe(
        name: 'Plecing Kangkung',
        province: 'Nusa Tenggara Barat',
        island: 'Bali & Nusa Tenggara',
        description: 'Sayur kangkung dengan sambal khas Lombok.',
        ingredients: 'Kangkung\nCabai\nTerasi\nTomat',
        steps: 'Rebus kangkung\nBuat sambal\nCampur dan sajikan',
        cookTimeMinutes: 30,
        difficulty: 'Mudah',
        estimatedCost: 30000,
        imagePath: 'assets/images/plecing_kangkung.png',
        baseServings: 3,
      ),
      const Recipe(
        name: 'Sei Sapi',
        province: 'Nusa Tenggara Timur',
        island: 'Bali & Nusa Tenggara',
        description: 'Daging asap khas NTT.',
        ingredients: 'Daging sapi\nKayu bakar\nGaram',
        steps: 'Asapi daging\nMasak hingga matang\nSajikan',
        cookTimeMinutes: 90,
        difficulty: 'Sedang',
        estimatedCost: 100000,
        imagePath: 'assets/images/sei_sapi.png',
        baseServings: 4,
      ),
      const Recipe(
        name: 'Ikan Bakar Manokwari',
        province: 'Papua Barat',
        island: 'Papua',
        description: 'Ikan bakar dengan sambal khas Papua.',
        ingredients: 'Ikan\nCabai\nTomat\nJeruk nipis',
        steps: 'Bakar ikan\nBuat sambal\nSajikan bersama',
        cookTimeMinutes: 40,
        difficulty: 'Mudah',
        estimatedCost: 70000,
        imagePath: 'assets/images/ikan_bakar_manokwari.png',
        baseServings: 2,
      ),
      const Recipe(
        name: 'Sagu Lempeng',
        province: 'Papua',
        island: 'Papua',
        description: 'Olahan sagu kering khas Papua.',
        ingredients: 'Sagu\nAir',
        steps: 'Campur\nPanggang hingga kering',
        cookTimeMinutes: 35,
        difficulty: 'Mudah',
        estimatedCost: 25000,
        imagePath: 'assets/images/sagu_lempeng.png',
        baseServings: 4,
      ),
    ];

    for (final recipe in recipes) {
      await db.insert('recipes', recipe.toMap());
    }
  }
}