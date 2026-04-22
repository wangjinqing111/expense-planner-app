import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../database/tables.dart';
import '../models/category.dart';

/// 分类仓库类
///
/// 删除前检查是否有关联支出，防止数据孤岛
/// 提供强制删除方法 deleteWithExpenses，满足级联删除需求
class CategoryRepository {
  final DatabaseHelper _databaseHelper;

  CategoryRepository({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  /// 获取数据库实例
  Future<Database> get _db => _databaseHelper.database;

  /// 插入分类
  Future<int> insert(Category category) async {
    final db = await _db;
    final data = category.toMap();
    data['created_at'] = DateTime.now().toIso8601String();
    return db.insert(Tables.categories, data);
  }

  /// 更新分类
  Future<int> update(Category category) async {
    final db = await _db;
    return db.update(
      Tables.categories,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// 删除分类
  Future<int> delete(int id) async {
    final db = await _db;
    // 检查是否有关联的支出
    final countResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM ${Tables.expenses} WHERE category_id = ?
    ''', [id]);
    final count = (countResult.first['count'] as int?) ?? 0;
    if (count > 0) {
      throw Exception('无法删除有支出关联的分类');
    }
    return db.delete(
      Tables.categories,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 强制删除分类（同时删除关联的支出）
  Future<int> deleteWithExpenses(int id) async {
    final db = await _db;
    // 先删除关联的支出
    await db.delete(
      Tables.expenses,
      where: 'category_id = ?',
      whereArgs: [id],
    );
    // 再删除分类
    return db.delete(
      Tables.categories,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 根据 ID 获取分类
  Future<Category?> getById(int id) async {
    final db = await _db;
    final maps = await db.query(
      Tables.categories,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Category.fromMap(maps.first);
  }

  /// 获取所有分类（按创建时间升序）
  Future<List<Category>> getAll() async {
    final db = await _db;
    final maps = await db.query(
      Tables.categories,
      orderBy: 'created_at ASC',
    );
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  /// 根据名称搜索分类
  Future<List<Category>> searchByName(String name) async {
    final db = await _db;
    final maps = await db.query(
      Tables.categories,
      where: 'name LIKE ?',
      whereArgs: ['%$name%'],
      orderBy: 'created_at ASC',
    );
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  /// 获取分类总数
  Future<int> getCount() async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${Tables.categories}',
    );
    return (result.first['count'] as int?) ?? 0;
  }

  /// 检查分类名称是否已存在
  Future<bool> nameExists(String name, {int? excludeId}) async {
    final db = await _db;
    String query = 'SELECT COUNT(*) as count FROM ${Tables.categories} WHERE name = ?';
    List<dynamic> args = [name];

    if (excludeId != null) {
      query += ' AND id != ?';
      args.add(excludeId);
    }

    final result = await db.rawQuery(query, args);
    return ((result.first['count'] as int?) ?? 0) > 0;
  }

  /// 检查分类是否有关联支出
  Future<bool> hasExpenses(int id) async {
    final db = await _db;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM ${Tables.expenses} WHERE category_id = ?
    ''', [id]);
    return ((result.first['count'] as int?) ?? 0) > 0;
  }
}
