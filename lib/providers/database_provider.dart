import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../data/database/database_helper.dart';

/// 数据库实例提供者
final databaseProvider = FutureProvider<Database>((ref) async {
  final dbHelper = DatabaseHelper.instance;
  return dbHelper.database;
});

/// 数据库助手提供者
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});
