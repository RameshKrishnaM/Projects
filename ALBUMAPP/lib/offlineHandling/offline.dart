// lib/services/database_service.dart

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'app.db'),
      onCreate: (db, version) {
        db
          ..execute('''
          CREATE TABLE albums (
            id INTEGER PRIMARY KEY,
            userId INTEGER,
            title TEXT
          )
        ''')
          ..execute('''
          CREATE TABLE photos (
            id INTEGER PRIMARY KEY,
            albumId INTEGER,
            title TEXT,
            url TEXT,
            thumbnailUrl TEXT
          )
        ''')
          ..execute('''
          CREATE TABLE posts (
            id INTEGER PRIMARY KEY,
            userId INTEGER,
            title TEXT,
            body TEXT
          )
        ''')
          ..execute('''
          CREATE TABLE comments (
            id INTEGER PRIMARY KEY,
            postId INTEGER,
            name TEXT,
            email TEXT,
            body TEXT
          )
        ''')
          ..execute('''
          CREATE TABLE profile (
            id INTEGER PRIMARY KEY,
            name TEXT,
            username TEXT,
            email TEXT,
            phone TEXT,
            website TEXT
          )
        ''');
      },
      version: 1,
    );
  }
}
