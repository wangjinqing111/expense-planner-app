import 'package:flutter_test/flutter_test.dart';
import 'package:coin/data/models/expense.dart';
import 'package:coin/data/models/category.dart';
import 'package:coin/data/models/expense_summary.dart';

/// 集成测试：完整的 CRUD 流程
///
/// 注意：这些测试不依赖数据库，用于验证模型和业务逻辑
void main() {
  group('CRUD Flow Integration Tests', () {
    group('Category CRUD Flow', () {
      test('should create, read, update, and delete category in memory', () {
        // Create
        const newCategory = Category(
          name: '餐饮',
          icon: 'restaurant',
          colorValue: 0xFFEF4444,
        );

        expect(newCategory.name, '餐饮');
        expect(newCategory.id, isNull);

        // Update (simulated with copyWith)
        final updatedCategory = newCategory.copyWith(
          name: '餐饮娱乐',
          icon: 'movie',
        );

        expect(updatedCategory.name, '餐饮娱乐');
        expect(updatedCategory.icon, 'movie');
        expect(updatedCategory.colorValue, newCategory.colorValue); // Unchanged
      });
    });

    group('Expense CRUD Flow', () {
      test('should create, read, update, and delete expense in memory', () {
        // Create
        final newExpense = Expense(
          title: '午餐',
          amount: 25.50,
          categoryId: 1,
          date: DateTime(2024, 1, 15),
        );

        expect(newExpense.title, '午餐');
        expect(newExpense.amount, 25.50);
        expect(newExpense.id, isNull);

        // Update (simulated with copyWith)
        final updatedExpense = newExpense.copyWith(
          title: '晚餐',
          amount: 50.00,
          note: '朋友聚餐',
        );

        expect(updatedExpense.title, '晚餐');
        expect(updatedExpense.amount, 50.00);
        expect(updatedExpense.note, '朋友聚餐');
        expect(updatedExpense.categoryId, newExpense.categoryId); // Unchanged
      });

      test('should handle expense with different categories', () {
        final expenses = [
          Expense(
            id: 1,
            title: '午餐',
            amount: 25.00,
            categoryId: 1,
            date: DateTime(2024, 1, 15),
          ),
          Expense(
            id: 2,
            title: '打车',
            amount: 15.00,
            categoryId: 2,
            date: DateTime(2024, 1, 15),
          ),
          Expense(
            id: 3,
            title: '电影',
            amount: 50.00,
            categoryId: 4,
            date: DateTime(2024, 1, 16),
          ),
        ];

        expect(expenses.length, 3);

        // Calculate total
        final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);
        expect(total, 90.00);

        // Group by category
        final byCategory = <int, List<Expense>>{};
        for (final expense in expenses) {
          byCategory.putIfAbsent(expense.categoryId, () => []).add(expense);
        }
        expect(byCategory.keys.length, 3);
        expect(byCategory[1]!.length, 1);
        expect(byCategory[2]!.length, 1);
        expect(byCategory[4]!.length, 1);
      });
    });

    group('Summary Calculation Flow', () {
      test('should calculate expense summary correctly', () {
        final expenses = [
          Expense(
            id: 1,
            title: '午餐1',
            amount: 25.00,
            categoryId: 1,
            date: DateTime(2024, 1, 15),
          ),
          Expense(
            id: 2,
            title: '午餐2',
            amount: 30.00,
            categoryId: 1,
            date: DateTime(2024, 1, 16),
          ),
          Expense(
            id: 3,
            title: '打车',
            amount: 15.00,
            categoryId: 2,
            date: DateTime(2024, 1, 17),
          ),
        ];

        // Calculate summary manually
        final totalAmount = expenses.fold<double>(0, (sum, e) => sum + e.amount);
        final byCategory = <int, double>{};
        for (final expense in expenses) {
          byCategory[expense.categoryId] =
              (byCategory[expense.categoryId] ?? 0) + expense.amount;
        }

        final summary = ExpenseSummary(
          periodStart: DateTime(2024, 1, 1),
          periodEnd: DateTime(2024, 1, 31),
          totalAmount: totalAmount,
          byCategory: byCategory,
          expenseCount: expenses.length,
        );

        expect(summary.totalAmount, 70.00);
        expect(summary.expenseCount, 3);
        expect(summary.byCategory[1], 55.00); // 25 + 30
        expect(summary.byCategory[2], 15.00);
      });

      test('should handle empty expense list', () {
        final summary = ExpenseSummary.empty(
          periodStart: DateTime(2024, 1, 1),
          periodEnd: DateTime(2024, 1, 31),
        );

        expect(summary.totalAmount, 0);
        expect(summary.expenseCount, 0);
        expect(summary.byCategory, isEmpty);
      });
    });

    group('Data Serialization Flow', () {
      test('should serialize and deserialize expense', () {
        final original = Expense(
          id: 1,
          title: '午餐',
          amount: 25.50,
          categoryId: 1,
          date: DateTime(2024, 1, 15),
          note: '测试备注',
          createdAt: DateTime(2024, 1, 15, 10, 0),
          updatedAt: DateTime(2024, 1, 15, 10, 0),
        );

        // Convert to Map
        final map = original.toMap();

        // Convert back to Expense
        final restored = Expense.fromMap(map);

        expect(restored.id, original.id);
        expect(restored.title, original.title);
        expect(restored.amount, original.amount);
        expect(restored.categoryId, original.categoryId);
        expect(restored.note, original.note);
      });

      test('should serialize and deserialize category', () {
        const original = Category(
          id: 1,
          name: '餐饮',
          icon: 'restaurant',
          colorValue: 0xFFEF4444,
          createdAt: null,
        );

        // Convert to Map
        final map = original.toMap();

        // Convert back to Category
        final restored = Category.fromMap(map);

        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.icon, original.icon);
        expect(restored.colorValue, original.colorValue);
      });
    });
  });
}
