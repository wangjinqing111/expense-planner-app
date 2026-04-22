import 'package:equatable/equatable.dart';

/// 支出汇总模型
///
/// byCategory 使用 Map<int, double> 而非列表，便于快速查找特定分类的金额
/// 空汇总使用 factory 构造，简化初始状态处理
class ExpenseSummary extends Equatable {
  /// 周期开始日期
  final DateTime periodStart;

  /// 周期结束日期
  final DateTime periodEnd;

  /// 周期内总支出金额
  final double totalAmount;

  /// 按分类分组的支出
  final Map<int, double> byCategory;

  /// 支出记录数量
  final int expenseCount;

  const ExpenseSummary({
    required this.periodStart,
    required this.periodEnd,
    required this.totalAmount,
    required this.byCategory,
    required this.expenseCount,
  });

  /// 创建空汇总
  factory ExpenseSummary.empty({
    required DateTime periodStart,
    required DateTime periodEnd,
  }) {
    return ExpenseSummary(
      periodStart: periodStart,
      periodEnd: periodEnd,
      totalAmount: 0,
      byCategory: const {},
      expenseCount: 0,
    );
  }

  /// 复制并修改字段
  ExpenseSummary copyWith({
    DateTime? periodStart,
    DateTime? periodEnd,
    double? totalAmount,
    Map<int, double>? byCategory,
    int? expenseCount,
  }) {
    return ExpenseSummary(
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      totalAmount: totalAmount ?? this.totalAmount,
      byCategory: byCategory ?? this.byCategory,
      expenseCount: expenseCount ?? this.expenseCount,
    );
  }

  @override
  List<Object?> get props => [
        periodStart,
        periodEnd,
        totalAmount,
        byCategory,
        expenseCount,
      ];

  @override
  String toString() {
    return 'ExpenseSummary(periodStart: $periodStart, periodEnd: $periodEnd, totalAmount: $totalAmount, expenseCount: $expenseCount)';
  }
}
