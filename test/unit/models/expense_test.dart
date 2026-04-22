import 'package:flutter_test/flutter_test.dart';
import 'package:coin/data/models/expense.dart';

void main() {
  group('Expense Model Tests', () {
    test('should create Expense with required fields', () {
      final expense = Expense(
        title: '午餐',
        amount: 25.50,
        categoryId: 1,
        date: DateTime(2024, 1, 15),
      );

      expect(expense.title, '午餐');
      expect(expense.amount, 25.50);
      expect(expense.categoryId, 1);
      expect(expense.date, DateTime(2024, 1, 15));
      expect(expense.id, isNull);
      expect(expense.note, isNull);
    });

    test('should create Expense with all fields', () {
      final now = DateTime.now();
      final expense = Expense(
        id: 1,
        title: '晚餐',
        amount: 100.00,
        categoryId: 2,
        date: DateTime(2024, 1, 16),
        note: '朋友聚餐',
        createdAt: now,
        updatedAt: now,
      );

      expect(expense.id, 1);
      expect(expense.title, '晚餐');
      expect(expense.amount, 100.00);
      expect(expense.categoryId, 2);
      expect(expense.note, '朋友聚餐');
      expect(expense.createdAt, now);
      expect(expense.updatedAt, now);
    });

    test('should convert Expense to Map', () {
      final expense = Expense(
        id: 1,
        title: '午餐',
        amount: 25.50,
        categoryId: 1,
        date: DateTime(2024, 1, 15),
        note: '测试备注',
      );

      final map = expense.toMap();

      expect(map['id'], 1);
      expect(map['title'], '午餐');
      expect(map['amount'], 25.50);
      expect(map['category_id'], 1);
      expect(map['date'], '2024-01-15');
      expect(map['note'], '测试备注');
    });

    test('should create Expense from Map', () {
      final map = {
        'id': 1,
        'title': '午餐',
        'amount': 25.50,
        'category_id': 1,
        'date': '2024-01-15',
        'note': '测试备注',
        'created_at': '2024-01-15T10:00:00.000',
        'updated_at': '2024-01-15T10:00:00.000',
      };

      final expense = Expense.fromMap(map);

      expect(expense.id, 1);
      expect(expense.title, '午餐');
      expect(expense.amount, 25.50);
      expect(expense.categoryId, 1);
      expect(expense.date.year, 2024);
      expect(expense.date.month, 1);
      expect(expense.date.day, 15);
      expect(expense.note, '测试备注');
    });

    test('should copy Expense with modifications', () {
      final expense = Expense(
        id: 1,
        title: '午餐',
        amount: 25.50,
        categoryId: 1,
        date: DateTime(2024, 1, 15),
      );

      final modified = expense.copyWith(
        title: '晚餐',
        amount: 50.00,
      );

      expect(modified.id, 1); // 保持不变
      expect(modified.title, '晚餐'); // 修改了
      expect(modified.amount, 50.00); // 修改了
      expect(modified.categoryId, 1); // 保持不变
      expect(modified.date, DateTime(2024, 1, 15)); // 保持不变
    });

    test('should support equality comparison', () {
      final expense1 = Expense(
        id: 1,
        title: '午餐',
        amount: 25.50,
        categoryId: 1,
        date: DateTime(2024, 1, 15),
      );

      final expense2 = Expense(
        id: 1,
        title: '午餐',
        amount: 25.50,
        categoryId: 1,
        date: DateTime(2024, 1, 15),
      );

      expect(expense1, equals(expense2));
    });
  });
}
