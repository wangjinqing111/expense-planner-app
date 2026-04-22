import 'package:flutter_test/flutter_test.dart';
import 'package:coin/data/models/category.dart';

void main() {
  group('Category Model Tests', () {
    test('should create Category with required fields', () {
      const category = Category(
        name: '餐饮',
        icon: 'restaurant',
        colorValue: 0xFFEF4444,
      );

      expect(category.name, '餐饮');
      expect(category.icon, 'restaurant');
      expect(category.colorValue, 0xFFEF4444);
      expect(category.id, isNull);
      expect(category.createdAt, isNull);
    });

    test('should create Category with all fields', () {
      final now = DateTime.now();
      final category = Category(
        id: 1,
        name: '交通',
        icon: 'directions_car',
        colorValue: 0xFF3B82F6,
        createdAt: now,
      );

      expect(category.id, 1);
      expect(category.name, '交通');
      expect(category.icon, 'directions_car');
      expect(category.colorValue, 0xFF3B82F6);
      expect(category.createdAt, now);
    });

    test('should convert Category to Map', () {
      const category = Category(
        id: 1,
        name: '餐饮',
        icon: 'restaurant',
        colorValue: 0xFFEF4444,
      );

      final map = category.toMap();

      expect(map['id'], 1);
      expect(map['name'], '餐饮');
      expect(map['icon'], 'restaurant');
      expect(map['color_value'], 0xFFEF4444);
    });

    test('should create Category from Map', () {
      final map = {
        'id': 1,
        'name': '餐饮',
        'icon': 'restaurant',
        'color_value': 0xFFEF4444,
        'created_at': '2024-01-15T10:00:00.000',
      };

      final category = Category.fromMap(map);

      expect(category.id, 1);
      expect(category.name, '餐饮');
      expect(category.icon, 'restaurant');
      expect(category.colorValue, 0xFFEF4444);
    });

    test('should copy Category with modifications', () {
      const category = Category(
        id: 1,
        name: '餐饮',
        icon: 'restaurant',
        colorValue: 0xFFEF4444,
      );

      final modified = category.copyWith(
        name: '餐饮娱乐',
        icon: 'movie',
      );

      expect(modified.id, 1); // 保持不变
      expect(modified.name, '餐饮娱乐'); // 修改了
      expect(modified.icon, 'movie'); // 修改了
      expect(modified.colorValue, 0xFFEF4444); // 保持不变
    });

    test('should support equality comparison', () {
      const category1 = Category(
        id: 1,
        name: '餐饮',
        icon: 'restaurant',
        colorValue: 0xFFEF4444,
      );

      const category2 = Category(
        id: 1,
        name: '餐饮',
        icon: 'restaurant',
        colorValue: 0xFFEF4444,
      );

      expect(category1, equals(category2));
    });
  });
}
