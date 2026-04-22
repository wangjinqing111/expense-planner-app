import 'package:flutter_test/flutter_test.dart';
import 'package:coin/data/models/expense_summary.dart';

void main() {
  group('ExpenseSummary Model Tests', () {
    test('should create ExpenseSummary with all fields', () {
      final periodStart = DateTime(2024, 1, 1);
      final periodEnd = DateTime(2024, 1, 31);
      final byCategory = {1: 100.0, 2: 200.0};

      final summary = ExpenseSummary(
        periodStart: periodStart,
        periodEnd: periodEnd,
        totalAmount: 300.0,
        byCategory: byCategory,
        expenseCount: 5,
      );

      expect(summary.periodStart, periodStart);
      expect(summary.periodEnd, periodEnd);
      expect(summary.totalAmount, 300.0);
      expect(summary.byCategory, byCategory);
      expect(summary.expenseCount, 5);
    });

    test('should create empty ExpenseSummary', () {
      final periodStart = DateTime(2024, 1, 1);
      final periodEnd = DateTime(2024, 1, 31);

      final summary = ExpenseSummary.empty(
        periodStart: periodStart,
        periodEnd: periodEnd,
      );

      expect(summary.periodStart, periodStart);
      expect(summary.periodEnd, periodEnd);
      expect(summary.totalAmount, 0);
      expect(summary.byCategory, isEmpty);
      expect(summary.expenseCount, 0);
    });

    test('should copy ExpenseSummary with modifications', () {
      final summary = ExpenseSummary(
        periodStart: DateTime(2024, 1, 1),
        periodEnd: DateTime(2024, 1, 31),
        totalAmount: 300.0,
        byCategory: {1: 100.0},
        expenseCount: 5,
      );

      final modified = summary.copyWith(
        totalAmount: 500.0,
        expenseCount: 10,
      );

      expect(modified.periodStart, summary.periodStart); // 保持不变
      expect(modified.periodEnd, summary.periodEnd); // 保持不变
      expect(modified.totalAmount, 500.0); // 修改了
      expect(modified.expenseCount, 10); // 修改了
      expect(modified.byCategory, summary.byCategory); // 保持不变
    });

    test('should support equality comparison', () {
      final summary1 = ExpenseSummary(
        periodStart: DateTime(2024, 1, 1),
        periodEnd: DateTime(2024, 1, 31),
        totalAmount: 300.0,
        byCategory: {1: 100.0},
        expenseCount: 5,
      );

      final summary2 = ExpenseSummary(
        periodStart: DateTime(2024, 1, 1),
        periodEnd: DateTime(2024, 1, 31),
        totalAmount: 300.0,
        byCategory: {1: 100.0},
        expenseCount: 5,
      );

      expect(summary1, equals(summary2));
    });
  });
}
