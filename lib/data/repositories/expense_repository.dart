import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../database/tables.dart';
import '../models/expense.dart';
import '../models/expense_summary.dart';

/// 支出仓库类
class ExpenseRepository {
  final DatabaseHelper _databaseHelper;

  ExpenseRepository({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  /// 获取数据库实例
  Future<Database> get _db => _databaseHelper.database;

  /// 插入支出
  Future<int> insert(Expense expense) async {
    final db = await _db;
    final data = expense.toMap();
    data['created_at'] = DateTime.now().toIso8601String();
    return db.insert(Tables.expenses, data);
  }

  /// 更新支出
  Future<int> update(Expense expense) async {
    final db = await _db;
    final data = expense.toMap();
    data['updated_at'] = DateTime.now().toIso8601String();
    return db.update(
      Tables.expenses,
      data,
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  /// 删除支出
  Future<int> delete(int id) async {
    final db = await _db;
    return db.delete(
      Tables.expenses,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 根据 ID 获取支出
  Future<Expense?> getById(int id) async {
    final db = await _db;
    final maps = await db.query(
      Tables.expenses,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Expense.fromMap(maps.first);
  }

  /// 获取所有支出（按日期降序）
  Future<List<Expense>> getAll() async {
    final db = await _db;
    final maps = await db.query(
      Tables.expenses,
      orderBy: 'date DESC, created_at DESC',
    );
    return maps.map((map) => Expense.fromMap(map)).toList();
  }

  /// 根据日期范围获取支出
  Future<List<Expense>> getByDateRange(DateTime start, DateTime end) async {
    final db = await _db;
    final maps = await db.query(
      Tables.expenses,
      where: 'date >= ? AND date <= ?',
      whereArgs: [
        start.toIso8601String().split('T').first,
        end.toIso8601String().split('T').first,
      ],
      orderBy: 'date DESC, created_at DESC',
    );
    return maps.map((map) => Expense.fromMap(map)).toList();
  }

  /// 根据分类 ID 获取支出
  Future<List<Expense>> getByCategory(int categoryId) async {
    final db = await _db;
    final maps = await db.query(
      Tables.expenses,
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'date DESC, created_at DESC',
    );
    return maps.map((map) => Expense.fromMap(map)).toList();
  }

  /// 根据分类和日期范围获取支出
  Future<List<Expense>> getByCategoryAndDateRange(
    int categoryId,
    DateTime start,
    DateTime end,
  ) async {
    final db = await _db;
    final maps = await db.query(
      Tables.expenses,
      where: 'category_id = ? AND date >= ? AND date <= ?',
      whereArgs: [
        categoryId,
        start.toIso8601String().split('T').first,
        end.toIso8601String().split('T').first,
      ],
      orderBy: 'date DESC, created_at DESC',
    );
    return maps.map((map) => Expense.fromMap(map)).toList();
  }

  /// 计算指定日期范围的支出汇总
  Future<ExpenseSummary> getSummary(DateTime start, DateTime end) async {
    final db = await _db;
    final startStr = start.toIso8601String().split('T').first;
    final endStr = end.toIso8601String().split('T').first;

    // 获取总金额和数量
    final result = await db.rawQuery('''
      SELECT
        COALESCE(SUM(amount), 0) as total,
        COUNT(*) as count
      FROM ${Tables.expenses}
      WHERE date >= ? AND date <= ?
    ''', [startStr, endStr]);

    final total = (result.first['total'] as num?)?.toDouble() ?? 0.0;
    final count = (result.first['count'] as int?) ?? 0;

    // 按分类汇总
    final categoryResult = await db.rawQuery('''
      SELECT
        category_id,
        SUM(amount) as total
      FROM ${Tables.expenses}
      WHERE date >= ? AND date <= ?
      GROUP BY category_id
    ''', [startStr, endStr]);

    final byCategory = <int, double>{};
    for (final row in categoryResult) {
      final categoryId = row['category_id'] as int;
      final categoryTotal = (row['total'] as num?)?.toDouble() ?? 0.0;
      byCategory[categoryId] = categoryTotal;
    }

    return ExpenseSummary(
      periodStart: start,
      periodEnd: end,
      totalAmount: total,
      byCategory: byCategory,
      expenseCount: count,
    );
  }

  /// 获取支出总数
  Future<int> getCount() async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${Tables.expenses}',
    );
    return (result.first['count'] as int?) ?? 0;
  }

  /// 获取总支出金额
  Future<double> getTotalAmount() async {
    final db = await _db;
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total FROM ${Tables.expenses}
    ''');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}
