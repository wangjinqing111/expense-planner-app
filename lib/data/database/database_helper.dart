import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'tables.dart';

/// 数据库助手单例类
class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._();

  /// 获取单例实例
  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._();
    return _instance!;
  }

  /// 数据库名称
  static const String _databaseName = 'expense_planner.db';
  static const int _databaseVersion = 1;

  /// 获取数据库实例
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    if (_database != null) return _database!;

    String path;
    if (kIsWeb) {
      // Web 平台使用内存数据库（实际生产环境应使用 IndexedDB）
      _database = await openDatabase(
        inMemoryDatabasePath,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
      return _database!;
    } else {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      path = join(documentsDirectory.path, _databaseName);
    }

    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return _database!;
  }

  /// 创建数据库表
  Future<void> _onCreate(Database db, int version) async {
    // 创建分类表
    await db.execute(Tables.createCategoriesTable);

    // 创建支出表
    await db.execute(Tables.createExpensesTable);

    // 创建索引
    await db.execute(Tables.createExpenseDateIndex);
    await db.execute(Tables.createExpenseCategoryIndex);

    // 插入默认分类
    await _insertDefaultCategories(db);
  }

  /// 数据库升级处理
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 预留未来数据库迁移使用
  }

  /// 插入默认分类
  Future<void> _insertDefaultCategories(Database db) async {
    final defaultCategories = [
      {
        'name': '餐饮',
        'icon': 'restaurant',
        'color_value': 0xFFEF4444,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'name': '交通',
        'icon': 'directions_car',
        'color_value': 0xFF3B82F6,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'name': '购物',
        'icon': 'shopping_bag',
        'color_value': 0xFF8B5CF6,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'name': '娱乐',
        'icon': 'movie',
        'color_value': 0xFFEC4899,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'name': '医疗',
        'icon': 'medical_services',
        'color_value': 0xFF10B981,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'name': '住房',
        'icon': 'home',
        'color_value': 0xFFF59E0B,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'name': '教育',
        'icon': 'school',
        'color_value': 0xFF06B6D4,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'name': '其他',
        'icon': 'more_horiz',
        'color_value': 0xFF6B7280,
        'created_at': DateTime.now().toIso8601String(),
      },
    ];

    for (final category in defaultCategories) {
      await db.insert(Tables.categories, category);
    }
  }

  /// 关闭数据库
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// 删除数据库（用于测试）
  Future<void> deleteDatabase() async {
    if (kIsWeb) {
      _database = null;
      return;
    }
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
