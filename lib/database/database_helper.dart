import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:my_class_schedule/models/schedule.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'schedule_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE schedules(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        startTimeHour INTEGER,
        startTimeMinute INTEGER,
        endTimeHour INTEGER,
        endTimeMinute INTEGER,
        dayOfWeek INTEGER,
        room TEXT,
        teacher TEXT,
        colorValue INTEGER,
        notes TEXT
      )
    ''');
  }

  Future<int> insertSchedule(Schedule schedule) async {
    Database db = await database;
    return await db.insert('schedules', schedule.toMap());
  }

  Future<List<Schedule>> getSchedules() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('schedules');
    return List.generate(maps.length, (i) {
      return Schedule.fromMap(maps[i]);
    });
  }

  Future<int> updateSchedule(Schedule schedule) async {
    Database db = await database;
    return await db.update(
      'schedules',
      schedule.toMap(),
      where: 'id = ?',
      whereArgs: [schedule.id],
    );
  }

  Future<int> deleteSchedule(int id) async {
    Database db = await database;
    return await db.delete(
      'schedules',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}