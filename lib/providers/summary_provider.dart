import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/expense_summary.dart';
import 'expense_provider.dart';

/// 汇总周期类型
enum SummaryPeriod {
  day,
  week,
  month,
}

/// 当前汇总周期提供者
final summaryPeriodProvider = StateProvider<SummaryPeriod>((ref) {
  return SummaryPeriod.month;
});

/// 获取指定周期的日期范围
(DateTime, DateTime) _getPeriodRange(SummaryPeriod period) {
  final now = DateTime.now();
  DateTime start;
  DateTime end;

  switch (period) {
    case SummaryPeriod.day:
      start = DateTime(now.year, now.month, now.day);
      end = start.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));
      break;
    case SummaryPeriod.week:
      // 本周一到下周一
      final weekday = now.weekday;
      start = DateTime(now.year, now.month, now.day - weekday + 1);
      end = start.add(const Duration(days: 7)).subtract(const Duration(seconds: 1));
      break;
    case SummaryPeriod.month:
      // 本月1日到下月1日
      start = DateTime(now.year, now.month, 1);
      end = DateTime(now.year, now.month + 1, 1).subtract(const Duration(seconds: 1));
      break;
  }

  return (start, end);
}

/// 汇总数据提供者
final summaryProvider = FutureProvider<ExpenseSummary>((ref) async {
  final repository = ref.watch(expenseRepositoryProvider);
  final period = ref.watch(summaryPeriodProvider);
  final (start, end) = _getPeriodRange(period);
  return repository.getSummary(start, end);
});

/// 今日支出汇总提供者
final todaySummaryProvider = FutureProvider<ExpenseSummary>((ref) async {
  final repository = ref.watch(expenseRepositoryProvider);
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  final end = start.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));
  return repository.getSummary(start, end);
});

/// 本周支出汇总提供者
final weekSummaryProvider = FutureProvider<ExpenseSummary>((ref) async {
  final repository = ref.watch(expenseRepositoryProvider);
  final now = DateTime.now();
  final weekday = now.weekday;
  final start = DateTime(now.year, now.month, now.day - weekday + 1);
  final end = start.add(const Duration(days: 7)).subtract(const Duration(seconds: 1));
  return repository.getSummary(start, end);
});

/// 本月支出汇总提供者
final monthSummaryProvider = FutureProvider<ExpenseSummary>((ref) async {
  final repository = ref.watch(expenseRepositoryProvider);
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, 1);
  final end = DateTime(now.year, now.month + 1, 1).subtract(const Duration(seconds: 1));
  return repository.getSummary(start, end);
});

/// 自定义日期范围汇总提供者
final customRangeSummaryProvider = FutureProvider.family<ExpenseSummary, (DateTime, DateTime)>((ref, range) async {
  final repository = ref.watch(expenseRepositoryProvider);
  final (start, end) = range;
  return repository.getSummary(start, end);
});

/// 汇总数据刷新触发器
final summaryRefreshProvider = StateProvider<int>((ref) => 0);

/// 自动刷新的汇总提供者（当 refreshTrigger 变化时重新获取）
final autoRefreshSummaryProvider = FutureProvider<ExpenseSummary>((ref) async {
  // 监听 refreshTrigger 的变化
  ref.watch(summaryRefreshProvider);
  // 监听支出列表的变化
  ref.watch(expenseListProvider);

  final repository = ref.watch(expenseRepositoryProvider);
  final period = ref.watch(summaryPeriodProvider);
  final (start, end) = _getPeriodRange(period);
  return repository.getSummary(start, end);
});
