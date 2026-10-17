import 'package:path/path.dart';
import 'package:restaurant_app/data/models/restaurant.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const String _databaseName = 'restaurant.db';
  static const String _tableName = 'favorites';

  Future<Database>? _databaseFuture;

  Future<Database> get _database => _databaseFuture ??= _open();

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), _databaseName);

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT NOT NULL,
            pictureId TEXT NOT NULL,
            city TEXT NOT NULL,
            rating REAL NOT NULL
          )
        ''');
      },
    );
  }

  Future<List<Restaurant>> getFavorites() async {
    final db = await _database;
    final rows = await db.query(_tableName);
    return rows.map(Restaurant.fromJson).toList();
  }

  Future<void> insertFavorite(Restaurant restaurant) async {
    final db = await _database;
    await db.insert(
      _tableName,
      restaurant.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFavorite(String id) async {
    final db = await _database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }
}