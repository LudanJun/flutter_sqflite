import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal(); // 私有构造函数
  static Database? _database; // 数据库实例

  // 表名
  final String tableNotes = 'notes';
  
  // 列名
  final String columnId = 'id';
  final String columnTitle = 'title';
  final String columnContent = 'content';
  final String columnCreatedAt = 'createdAt';

  // 单例模式
  factory DatabaseHelper() { // 工厂构造函数
    return _instance;
  }

  DatabaseHelper._internal(); // 私有构造函数

  // 获取数据库实例
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // 初始化数据库
  Future<Database> _initDatabase() async {
    // 获取数据库路径
    String path = join(await getDatabasesPath(), 'notes_database.db');
    
    // 打开/创建数据库
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // 创建表
  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      '''
      CREATE TABLE $tableNotes (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTitle TEXT NOT NULL,
        $columnContent TEXT NOT NULL,
        $columnCreatedAt TEXT NOT NULL
      )
      ''',
    );
  }

  // 插入笔记
  Future<int> insertNote(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert(tableNotes, row);
  }

  // 获取所有笔记
  Future<List<Map<String, dynamic>>> getNotes() async {
    Database db = await database;
    return await db.query(tableNotes, orderBy: '$columnCreatedAt DESC');// 按创建时间降序排列
  }

  // 获取单个笔记
  Future<Map<String, dynamic>?> getNote(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      tableNotes,
      where: '$columnId = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  // 更新笔记
  Future<int> updateNote(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row[columnId];
    return await db.update(
      tableNotes,
      row,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // 删除笔记
  Future<int> deleteNote(int id) async {
    Database db = await database;
    return await db.delete(
      tableNotes,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // 删除所有笔记
  Future<int> deleteAllNotes() async {
    Database db = await database;
    return await db.delete(tableNotes);
  }
}