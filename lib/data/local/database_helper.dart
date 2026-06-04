import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/recipe_model.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();
  Database? _database;

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

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE recipes ADD COLUMN base_servings INTEGER NOT NULL DEFAULT 4',
      );
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
        ingredients: '700g|daging sapi\n500ml|santan kental\n200ml|santan encer\n15 buah|cabai merah keriting\n8 siung|bawang merah\n5 siung|bawang putih\n3cm|lengkuas\n2 batang|serai\n5 lembar|daun jeruk\n2 lembar|daun kunyit\n1 sdt|garam\n1 sdt|gula merah',
        steps: 'Haluskan cabai merah, bawang merah, bawang putih, dan jahe menggunakan blender atau ulekan hingga benar-benar halus\nPanaskan wajan besar tanpa minyak, masukkan bumbu halus, serai, lengkuas, daun jeruk, dan daun kunyit lalu tumis hingga harum dan matang sekitar 5 menit\nMasukkan potongan daging sapi, aduk rata hingga daging berubah warna dan terbalut bumbu\nTuang santan encer terlebih dahulu, masak dengan api sedang sambil sesekali diaduk agar santan tidak pecah\nSetelah santan menyusut setengah, tuang santan kental, tambahkan garam dan gula merah, aduk rata\nKecilkan api ke level paling kecil, masak sambil sesekali diaduk selama 2 hingga 3 jam hingga kuah mengering dan bumbu berwarna cokelat gelap\nRendang siap disajikan saat daging empuk dan bumbu sudah benar-benar kering melapisi daging',
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
        ingredients: '1kg|nangka muda\n500ml|santan kental\n150g|gula merah\n8 siung|bawang merah\n5 siung|bawang putih\n1 sdt|ketumbar\n3 lembar|daun salam\n3cm|lengkuas\n4 butir|telur rebus\n1 sdt|garam',
        steps: 'Rebus potongan nangka muda dalam air mendidih selama 20 menit hingga sedikit lunak, tiriskan\nSusun daun salam dan lengkuas di dasar panci sebagai alas agar tidak gosong\nMasukkan nangka, bawang merah, bawang putih, ketumbar, gula merah, dan garam ke dalam panci\nTuang santan hingga semua bahan terendam, aduk perlahan\nMasak dengan api sedang sambil sesekali diaduk hingga santan mendidih\nKecilkan api, masukkan telur rebus, lanjutkan memasak selama 3 hingga 4 jam hingga kuah mengering dan warna gudeg menjadi cokelat kemerahan\nSajikan gudeg bersama nasi, sambal krecek, dan ayam opor',
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
        ingredients: '200g|tepung sagu\n700ml|air\n300g|ikan tongkol\n2cm|kunyit\n1 batang|serai\n3 lembar|daun jeruk\n1 buah|jeruk nipis\n1 sdt|garam',
        steps: 'Larutkan tepung sagu dengan 200ml air dingin hingga tidak ada gumpalan, sisihkan\nDidihkan 500ml air dalam panci terpisah\nTuang larutan sagu ke dalam air mendidih sambil diaduk cepat menggunakan dua sumpit panjang secara memutar hingga mengental dan bening\nAngkat papeda dari api, biarkan sebentar hingga teksturnya kenyal dan elastis\nUntuk kuah ikan: tumis kunyit dan serai hingga harum, masukkan ikan tongkol\nTuang air secukupnya, masukkan daun jeruk, garam, dan air jeruk nipis\nMasak ikan hingga matang sekitar 15 menit dengan api sedang\nSajikan papeda dalam mangkuk bersama kuah ikan kuning di sisinya',
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
        ingredients: '600g|daging sapi\n3 buah|kluwek\n8 siung|bawang merah\n5 siung|bawang putih\n2cm|kunyit\n3cm|lengkuas\n2 batang|serai\n4 lembar|daun jeruk\n100g|tauge\n2 sdm|minyak goreng\n1 sdt|garam',
        steps: 'Rebus daging sapi dalam 1500ml air hingga empuk sekitar 45 menit, angkat dan potong kotak, simpan kaldu\nHaluskan isi kluwek bersama bawang merah, bawang putih, dan kunyit\nPanaskan minyak, tumis bumbu halus bersama lengkuas dan serai hingga matang dan harum sekitar 7 menit\nMasukkan bumbu tumis ke dalam kaldu daging, aduk rata\nMasukkan kembali potongan daging, tambahkan daun jeruk dan garam\nMasak dengan api kecil selama 20 menit hingga kuah berwarna hitam pekat dan bumbu meresap\nSajikan rawon dalam mangkuk panas, tambahkan tauge, telur asin, dan sambal terasi di sisinya',
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
        ingredients: '1 ekor|ayam\n10 siung|bawang merah\n6 siung|bawang putih\n8 buah|cabai merah\n3cm|kunyit\n2cm|jahe\n2cm|kencur\n2 batang|serai\n1 sdt|terasi\n3 lembar|daun salam\n2 lembar|daun pisang\n1 sdt|garam\n1 sdm|minyak kelapa',
        steps: 'Haluskan bawang merah, bawang putih, cabai, kunyit, jahe, kencur, dan terasi menggunakan ulekan hingga menjadi pasta bumbu yang halus\nTambahkan garam dan minyak kelapa ke dalam bumbu, aduk rata\nBersihkan ayam, tusuk-tusuk permukaan ayam dengan garpu agar bumbu meresap lebih dalam\nBalurkan bumbu genep ke seluruh permukaan ayam, termasuk bagian dalam rongga\nSisipkan daun salam dan batang serai ke dalam rongga ayam\nBungkus ayam rapat-rapat menggunakan daun pisang, ikat dengan tali\nKukus ayam yang sudah dibungkus selama 60 menit dengan api sedang\nSetelah dikukus, panggang dalam oven 180 derajat selama 30 menit hingga daun pisang kecokelatan dan aroma rempah keluar\nSajikan ayam betutu panas dengan nasi putih dan sambal matah',
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
        description: 'Pempek adalah olahan ikan dan sagu khas Palembang yang disajikan bersama kuah cuko asam pedas.',
        ingredients: '500g|ikan tenggiri\n250g|tepung sagu\n3 siung|bawang putih\n2 butir|telur\n1 sdt|garam\n100ml|air es\n150g|gula merah\n3 sdm|asam jawa\n10 buah|cabai rawit',
        steps: 'Campur ikan tenggiri halus dengan bawang putih, garam, dan air es, aduk rata\nMasukkan telur satu per satu sambil terus diaduk hingga tercampur\nTambahkan tepung sagu sedikit demi sedikit sambil diuleni hingga adonan kalis dan tidak lengket di tangan\nBentuk adonan sesuai selera, bisa bulat panjang untuk pempek lenjer atau bentuk kapal selam dengan isian telur\nRebus pempek dalam air mendidih hingga mengapung ke permukaan tanda sudah matang, angkat dan tiriskan\nGoreng pempek yang sudah direbus dalam minyak panas hingga permukaan kecokelatan dan renyah\nUntuk cuko: rebus gula merah, asam jawa, cabai rawit, dan air hingga mendidih dan mengental, saring\nSajikan pempek dengan siraman cuko dan irisan timun serta ebi',
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
        description: 'Coto Makassar adalah sup daging sapi berbumbu kacang dan rempah khas Sulawesi Selatan.',
        ingredients: '500g|daging sapi\n100g|kacang tanah\n8 siung|bawang merah\n5 siung|bawang putih\n1 sdt|ketumbar\n1 sdt|jinten\n2 batang|serai\n3cm|lengkuas\n2 sdm|minyak goreng\n1 sdt|garam',
        steps: 'Rebus daging sapi dalam air hingga empuk sekitar 60 menit, angkat dan potong kotak kecil, simpan kaldu\nSangrai kacang tanah hingga kecokelatan, haluskan menggunakan blender atau ulekan\nHaluskan bawang merah, bawang putih, ketumbar, dan jinten\nPanaskan minyak, tumis bumbu halus bersama serai dan lengkuas hingga harum dan matang sekitar 5 menit\nMasukkan kacang tanah halus ke dalam tumisan, aduk rata\nTuang kaldu daging ke dalam campuran bumbu dan kacang, aduk hingga larut\nMasukkan potongan daging, tambahkan garam, masak dengan api kecil selama 20 menit\nKoreksi rasa, sajikan coto panas dalam mangkuk dengan ketupat, irisan daun bawang, dan perasan jeruk nipis',
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
        ingredients: '1 ekor|ayam\n6 siung|bawang merah\n4 siung|bawang putih\n1 batang|kayu manis\n3 butir|cengkeh\n3 butir|kapulaga\n4 butir|telur\n2 buah|perkedel\n2 sdm|minyak goreng\n1 sdt|garam',
        steps: 'Rebus ayam dalam 1500ml air bersama sedikit garam hingga matang sekitar 30 menit, angkat dan suwir-suwir dagingnya, simpan kaldu\nHaluskan bawang merah dan bawang putih\nPanaskan minyak, tumis bumbu halus bersama kayu manis, cengkeh, dan kapulaga hingga harum sekitar 4 menit\nMasukkan tumisan bumbu ke dalam kaldu ayam, aduk rata\nMasak kaldu dengan api kecil selama 15 menit hingga aroma rempah keluar sempurna\nTambahkan garam, koreksi rasa\nSiapkan mangkuk, isi dengan suwiran ayam, potongan telur rebus, dan perkedel\nSiram dengan kuah panas, sajikan dengan bawang goreng dan perasan jeruk nipis',
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
        description: 'Seruit adalah hidangan ikan bakar khas Lampung yang dimakan bersama sambal terasi dan tempoyak.',
        ingredients: '3 ekor|ikan sungai\n5 buah|cabai merah\n3 buah|cabai rawit\n1 sdt|terasi\n2 buah|tomat\n3 sdm|tempoyak\n2 buah|jeruk limau\n1 sdt|garam',
        steps: 'Bersihkan ikan, buang sisik dan isi perut, beri sayatan di bagian badan agar matang merata\nLumuri ikan dengan garam dan air jeruk limau, diamkan 15 menit agar bumbu meresap dan menghilangkan bau amis\nBakar ikan di atas bara arang, balik setiap 5 menit hingga kedua sisi matang kecokelatan sekitar 20 menit\nUntuk sambal: ulek cabai merah, cabai rawit, terasi, tomat, dan garam hingga kasar\nMasukkan tempoyak ke dalam sambal, aduk rata, tambahkan perasan jeruk limau\nSajikan ikan bakar di atas daun pisang bersama sambal tempoyak dan lalapan segar',
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
        description: 'Mie Aceh adalah mie tebal berbumbu kari pekat khas Aceh dengan pilihan daging sapi atau seafood.',
        ingredients: '400g|mie kuning\n200g|daging sapi\n8 siung|bawang merah\n5 siung|bawang putih\n5 buah|cabai merah\n2 sdt|bubuk kari\n150g|kol\n2 buah|tomat\n2 sdm|minyak goreng\n1 sdt|garam',
        steps: 'Haluskan bawang merah, bawang putih, dan cabai merah menggunakan blender\nPanaskan minyak dalam wajan besar, tumis bumbu halus hingga matang dan harum sekitar 5 menit\nTambahkan bubuk kari, aduk rata dan masak 2 menit hingga kari matang\nMasukkan daging sapi, masak hingga berubah warna\nTuang air secukupnya, masukkan tomat dan kol, masak hingga sayur sedikit layu\nMasukkan mie kuning, aduk rata hingga semua bumbu menempel pada mie\nTambahkan garam, koreksi rasa, masak hingga air sedikit menyusut\nSajikan mie aceh panas dengan acar timun, emping, dan perasan jeruk nipis',
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
        description: 'Choi Pan adalah kue kukus khas Singkawang berkulit tipis kenyal dengan isian sayur bengkuang yang gurih.',
        ingredients: '200g|tepung beras\n50g|tepung tapioka\n300ml|air hangat\n300g|bengkuang\n4 siung|bawang putih\n3 batang|daun bawang\n1 sdt|minyak wijen\n1 sdt|garam\n1 sdt|gula pasir\n2 sdm|minyak goreng',
        steps: 'Campurkan tepung beras dan tepung tapioka dalam wadah, tambahkan sedikit garam\nTuang air hangat sedikit demi sedikit sambil diuleni hingga adonan kulit kalis dan bisa dibentuk\nBungkus adonan dengan plastik, istirahatkan 15 menit\nPanaskan minyak, tumis bawang putih hingga harum, masukkan bengkuang parut\nTambahkan garam, gula, dan minyak wijen, masak hingga bengkuang layu dan matang sekitar 8 menit, angkat dan dinginkan\nAmbil sejumput adonan kulit, pipihkan tipis di telapak tangan, isi dengan tumisan bengkuang\nLipat dan rapatkan tepi adonan hingga berbentuk setengah lingkaran\nKukus choi pan dalam kukusan panas selama 15 menit hingga kulit bening dan matang\nSajikan dengan saus cabai atau kecap asin',
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
        description: 'Ketupat Kandangan adalah hidangan ketupat berkuah santan gurih dengan ikan haruan khas Kalimantan Selatan.',
        ingredients: '4 buah|ketupat\n400g|ikan haruan\n400ml|santan kental\n200ml|santan encer\n6 siung|bawang merah\n4 siung|bawang putih\n2cm|kunyit\n2cm|jahe\n2 batang|serai\n3 lembar|daun salam\n1 sdt|garam',
        steps: 'Haluskan bawang merah, bawang putih, kunyit, dan jahe\nPanaskan sedikit minyak, tumis bumbu halus bersama serai dan daun salam hingga harum sekitar 5 menit\nMasukkan potongan ikan haruan, masak sebentar hingga berubah warna\nTuang santan encer, masak dengan api sedang hingga mendidih\nSetelah mendidih, tuang santan kental, tambahkan garam\nKecilkan api, masak sambil sesekali diaduk agar santan tidak pecah selama 20 menit\nKoreksi rasa, kuah harus gurih dan sedikit kental\nSajikan ketupat yang sudah diiris dengan siraman kuah santan ikan panas',
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
        description: 'Tinutuan atau Bubur Manado adalah bubur beras bercampur berbagai sayuran segar yang menyehatkan.',
        ingredients: '150g|beras\n100g|labu kuning\n100g|bayam\n1 buah|jagung manis\n2 batang|daun bawang\n2 lembar|daun pandan\n1 sdt|garam\n1 sdt|minyak goreng',
        steps: 'Cuci beras hingga bersih, masak bersama 1200ml air dan daun pandan dengan api sedang\nAduk sesekali agar beras tidak menempel di dasar panci\nSetelah beras mulai pecah sekitar 20 menit, masukkan labu kuning dan jagung manis pipil\nMasak terus sambil diaduk hingga labu lunak dan bubur mengental sekitar 15 menit\nMasukkan bayam segar dan daun bawang, aduk rata\nTambahkan garam dan minyak goreng, masak 3 menit hingga sayur layu\nKoreksi rasa, bubur harus lembut dan gurih\nSajikan tinutuan panas dengan ikan asin, sambal roa, dan perkedel jagung di sisinya',
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
        description: 'Sop Konro adalah sup iga sapi berkuah hitam pekat dengan bumbu rempah khas Makassar.',
        ingredients: '800g|iga sapi\n4 buah|kluwek\n8 siung|bawang merah\n5 siung|bawang putih\n2 sdt|ketumbar\n1 sdt|jinten\n3cm|lengkuas\n2 batang|serai\n4 lembar|daun jeruk\n2 sdm|minyak goreng\n1 sdt|garam',
        steps: 'Rebus iga sapi dalam 2000ml air, buang buih yang muncul di permukaan hingga kaldu bersih\nRebus iga selama 60 menit hingga daging mulai empuk, angkat iga dan sisihkan kaldu\nHaluskan isi kluwek bersama bawang merah, bawang putih, ketumbar, dan jinten\nPanaskan minyak, tumis bumbu halus bersama lengkuas dan serai hingga matang dan harum sekitar 7 menit\nMasukkan iga sapi ke dalam tumisan bumbu, aduk rata hingga iga terbalut bumbu\nTuang kaldu sapi, masukkan daun jeruk dan garam\nMasak dengan api kecil selama 30 menit hingga kuah berwarna hitam pekat dan iga benar-benar empuk\nSajikan sop konro panas dengan ketupat atau nasi, taburan bawang goreng dan perasan jeruk nipis',
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
        description: 'Plecing Kangkung adalah hidangan sayur kangkung rebus dengan sambal tomat pedas segar khas Lombok.',
        ingredients: '400g|kangkung\n8 buah|cabai merah\n5 buah|cabai rawit\n1 sdt|terasi\n3 buah|tomat\n4 siung|bawang merah\n1 buah|jeruk limau\n1 sdt|garam\n1 sdt|gula pasir',
        steps: 'Cuci kangkung hingga bersih, pisahkan daun dari batang yang keras\nRebus air hingga mendidih, masukkan kangkung dan rebus selama 2 menit saja agar tetap hijau dan tidak terlalu layu\nAngkat dan tiriskan kangkung, siram dengan air dingin agar warna tetap hijau segar, tata di piring\nUntuk sambal: bakar tomat dan terasi di atas api langsung hingga sedikit gosong untuk menambah aroma\nUlek cabai merah, cabai rawit, bawang merah, dan terasi hingga kasar\nMasukkan tomat, ulek sebentar, tambahkan garam dan gula\nPeras jeruk limau ke dalam sambal, aduk rata\nSiramkan sambal plecing di atas kangkung rebus, sajikan segera',
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
        description: 'Sei Sapi adalah daging sapi asap khas NTT yang dimasak perlahan di atas bara dengan daun kesambi.',
        ingredients: '700g|daging sapi\n1 sdt|garam\n1 sdt|merica hitam\n3 siung|bawang putih\n1 sdm|air jeruk nipis\n3 lembar|daun kesambi',
        steps: 'Campurkan garam, merica, bawang putih halus, dan air jeruk nipis hingga menjadi bumbu olesan\nLumuri seluruh permukaan daging sapi dengan bumbu, pastikan merata, diamkan minimal 30 menit agar bumbu meresap\nSiapkan bara arang yang sudah membara, tidak boleh ada api langsung agar daging tidak gosong\nLetakkan daun kesambi di atas bara untuk menghasilkan asap beraroma khas\nLetakkan daging di atas panggangan, asapi dan panggang dengan api kecil sambil sesekali dibalik setiap 10 menit\nMasak perlahan selama 40 hingga 50 menit hingga daging matang merata, berwarna kecokelatan, dan beraroma asap\nIris daging sesuai selera, sajikan dengan nasi putih, lalapan segar, dan sambal khas NTT',
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
        description: 'Ikan Bakar Manokwari adalah ikan bakar khas Papua Barat dengan sambal dabu-dabu yang segar dan pedas.',
        ingredients: '2 ekor|ikan kerapu\n5 buah|cabai merah\n5 buah|cabai rawit\n3 buah|tomat\n4 siung|bawang merah\n2 buah|jeruk nipis\n1 sdt|garam\n1 sdm|minyak goreng\n1 sdt|kecap manis',
        steps: 'Bersihkan ikan, buang sisik dan isi perut, beri tiga sayatan diagonal di badan ikan agar bumbu meresap\nLumuri ikan dengan perasan jeruk nipis dan garam, diamkan 20 menit\nOleskan sedikit minyak goreng dan kecap manis pada ikan\nBakar ikan di atas bara arang dengan api sedang, balik setiap 8 menit hingga kedua sisi matang sekitar 25 menit\nUntuk sambal dabu-dabu: campurkan cabai merah, cabai rawit, tomat, dan bawang merah dalam wadah\nTambahkan perasan jeruk nipis, garam, dan sedikit minyak goreng, aduk rata\nSajikan ikan bakar panas dengan sambal dabu-dabu di sisinya dan nasi putih hangat',
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
        description: 'Sagu Lempeng adalah kue sagu panggang kering khas Papua yang renyah di luar dan padat di dalam.',
        ingredients: '400g|tepung sagu\n100ml|air\n1 sdt|garam\n50g|kelapa parut',
        steps: 'Campurkan tepung sagu dan garam dalam wadah besar, aduk rata\nMasukkan kelapa parut dan aduk hingga tercampur merata\nTuang air sedikit demi sedikit sambil diuleni hingga adonan bisa dipadatkan dan tidak terlalu kering\nBagi adonan menjadi beberapa bagian, padatkan masing-masing langsung dibentuk manual setebal 1cm\nPanaskan wajan datar atau teflon tanpa minyak di atas api kecil\nLetakkan lempeng sagu di atas wajan, panggang selama 15 menit sambil ditekan perlahan agar matang merata\nBalik lempeng, panggang sisi lainnya selama 15 menit lagi hingga kedua sisi kering dan sedikit kecokelatan\nAngkat dan dinginkan sebelum disajikan, sagu lempeng siap dimakan dengan teh atau sebagai teman lauk',
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