import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:reelify/core/constants/app_constants.dart';
import 'package:reelify/features/ai_recommendation/domain/models/user_interaction.dart';

class SqliteService {
  SqliteService._();
  static final SqliteService instance = SqliteService._();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE interactions (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        videoId TEXT NOT NULL,
        category TEXT,
        watchRatio REAL DEFAULT 0,
        liked INTEGER DEFAULT 0,
        commented INTEGER DEFAULT 0,
        skipped INTEGER DEFAULT 0,
        timestamp INTEGER,
        synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE cached_videos (
        id TEXT PRIMARY KEY,
        videoUrl TEXT,
        thumbnail TEXT,
        creatorId TEXT,
        creatorName TEXT,
        creatorAvatar TEXT,
        category TEXT,
        caption TEXT,
        likes INTEGER DEFAULT 0,
        commentsCount INTEGER DEFAULT 0,
        views INTEGER DEFAULT 0,
        uploadTime INTEGER,
        cachedAt INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE user_profile (
        id TEXT PRIMARY KEY,
        email TEXT,
        username TEXT,
        displayName TEXT,
        profileImage TEXT,
        bio TEXT,
        followersCount INTEGER DEFAULT 0,
        followingCount INTEGER DEFAULT 0,
        updatedAt INTEGER
      )
    ''');
  }

  // --- Interactions ---

  Future<void> saveInteraction(UserInteraction interaction) async {
    final db = await database;
    await db.insert(
      'interactions',
      interaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<UserInteraction>> getInteractions(String userId) async {
    final db = await database;
    final maps = await db.query(
      'interactions',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
      limit: 100,
    );
    return maps.map((m) => UserInteraction.fromMap(m)).toList();
  }

  Future<List<UserInteraction>> getUnsyncedInteractions() async {
    final db = await database;
    final maps = await db.query(
      'interactions',
      where: 'synced = 0',
    );
    return maps.map((m) => UserInteraction.fromMap(m)).toList();
  }

  Future<void> markSynced(String interactionId) async {
    final db = await database;
    await db.update(
      'interactions',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [interactionId],
    );
  }

  // --- Cached Videos ---

  Future<void> cacheVideo(Map<String, dynamic> videoMap) async {
    final db = await database;
    videoMap['cachedAt'] = DateTime.now().millisecondsSinceEpoch;
    await db.insert(
      'cached_videos',
      videoMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getCachedVideos() async {
    final db = await database;
    return await db.query(
      'cached_videos',
      orderBy: 'cachedAt DESC',
      limit: 20,
    );
  }

  // --- User Profile ---

  Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    final db = await database;
    profile['updatedAt'] = DateTime.now().millisecondsSinceEpoch;
    await db.insert(
      'user_profile',
      profile,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final db = await database;
    final maps = await db.query(
      'user_profile',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    return maps.isEmpty ? null : maps.first;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
