/// 数据库表定义
///
/// 外键约束 ON DELETE CASCADE 确保删除分类时自动清理关联支出
/// 为 date 和 category_id 创建索引，加速常用查询
class Tables {
  Tables._();

  /// 支出表名称
  static const String expenses = 'expenses';

  /// 分类表名称
  static const String categories = 'categories';

  /// 创建支出表 SQL
  static const String createExpensesTable = '''
    CREATE TABLE $expenses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      amount REAL NOT NULL,
      category_id INTEGER NOT NULL,
      date TEXT NOT NULL,
      note TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT,
      FOREIGN KEY (category_id) REFERENCES $categories (id) ON DELETE CASCADE
    )
  ''';

  /// 创建分类表 SQL
  static const String createCategoriesTable = '''
    CREATE TABLE $categories (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      icon TEXT NOT NULL,
      color_value INTEGER NOT NULL,
      created_at TEXT NOT NULL
    )
  ''';

  /// 创建索引 SQL
  static const String createExpenseDateIndex = '''
    CREATE INDEX idx_expense_date ON $expenses (date)
  ''';

  static const String createExpenseCategoryIndex = '''
    CREATE INDEX idx_expense_category ON $expenses (category_id)
  ''';
}
