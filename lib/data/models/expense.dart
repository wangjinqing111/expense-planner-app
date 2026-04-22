import 'package:equatable/equatable.dart';

/// 支出模型
class Expense extends Equatable {
  /// 支出 ID
  final int? id;

  /// 支出标题
  final String title;

  /// 支出金额
  final double amount;

  /// 分类 ID
  final int categoryId;

  /// 支出日期
  final DateTime date;

  /// 备注
  final String? note;

  /// 创建时间
  final DateTime? createdAt;

  /// 更新时间
  final DateTime? updatedAt;

  const Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  /// 从数据库 Map 创建 Expense
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      categoryId: map['category_id'] as int,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  /// 转换为数据库 Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'amount': amount,
      'category_id': categoryId,
      'date': date.toIso8601String().split('T').first,
      'note': note,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// 复制并修改字段
  Expense copyWith({
    int? id,
    String? title,
    double? amount,
    int? categoryId,
    DateTime? date,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        amount,
        categoryId,
        date,
        note,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'Expense(id: $id, title: $title, amount: $amount, categoryId: $categoryId, date: $date)';
  }
}
