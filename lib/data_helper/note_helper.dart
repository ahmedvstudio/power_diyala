import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class NoteHelper {
  static final NoteHelper _instance = NoteHelper._internal();
  final StreamController<List<Map<String, dynamic>>> _notesController =
      StreamController.broadcast();

  factory NoteHelper() {
    _instance._init();
    return _instance;
  }

  NoteHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'notes.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            region TEXT,
            sites TEXT,
            date TEXT,
            p_eng TEXT,
            t_eng TEXT,
            t_tech TEXT,
            g_tech TEXT,
            e_tech TEXT,
            comments TEXT
          )
        ''');
      },
    );
  }

  void _init() async {
    _fetchNotes();
  }

  void _fetchNotes() async {
    List<Map<String, dynamic>> notes = await getNotes();
    _notesController.add(notes);
  }

  Stream<List<Map<String, dynamic>>> getNotesStream() {
    return _notesController.stream;
  }

  Future<int> insertNote(Map<String, dynamic> note) async {
    final db = await database;
    final result = await db.insert('notes', note);
    _fetchNotes();
    return result;
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    final result = await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
    _fetchNotes();
    return result;
  }

  Future<List<Map<String, dynamic>>> getNotes() async {
    final db = await database;
    return await db.query('notes');
  }

  void dispose() {
    _notesController.close();
  }
}
