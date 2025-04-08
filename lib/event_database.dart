import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'event_item.dart';

/// Manages all database operations for the Event table.
class EventDatabase {
  static final EventDatabase instance = EventDatabase._init();
  static Database? _database;

  EventDatabase._init();

  /// Returns the database, or initializes it if not yet created.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('events.db');
    return _database!;
  }

  /// Initializes the database with the given name.
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  /// Creates the database schema.
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        location TEXT NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL
      )
    ''');
  }

  /// Fetches all events from the database.
  Future<List<Event>> getAllEvents() async {
    final db = await instance.database;
    final result = await db.query('events');
    return result.map((json) => Event.fromMap(json)).toList();
  }

  /// Inserts a new event into the database.
  Future<int> insertEvent(Event event) async {
    final db = await instance.database;
    return await db.insert('events', event.toMap());
  }

  /// Updates an existing event in the database.
  Future<int> updateEvent(Event event) async {
    final db = await instance.database;
    return await db.update(
      'events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  /// Deletes an event by ID.
  Future<int> deleteEvent(int id) async {
    final db = await instance.database;
    return await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }

  /// Closes the database connection.
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
