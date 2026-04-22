import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../data/database/database_helper.dart';

/// 数据库实例提供者
///
/// 使用 FutureProvider 而非 Provider，因为数据库初始化是异步的
/// DatabaseHelper.instance 本身已是单例，但通过 Provider 封装便于测试时替换
final databaseProvider = FutureProvider<Database>((ref) async {
  final dbHelper = DatabaseHelper.instance;
  return dbHelper.database;
});

/// 数据库助手提供者
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});
