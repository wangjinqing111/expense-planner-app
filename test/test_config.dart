import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// 初始化 sqflite_common_ffi 用于测试
void initSqfliteFfi() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}
