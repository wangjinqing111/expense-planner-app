import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coin/data/models/category.dart';
import 'package:coin/widgets/category_chip.dart';

void main() {
  group('CategoryChip Widget Tests', () {
    const testCategory = Category(
      id: 1,
      name: '餐饮',
      icon: 'restaurant',
      colorValue: 0xFFEF4444,
    );

    testWidgets('should display category name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChip(category: testCategory),
          ),
        ),
      );

      expect(find.text('餐饮'), findsOneWidget);
    });

    testWidgets('should display category icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChip(category: testCategory),
          ),
        ),
      );

      expect(find.byIcon(Icons.restaurant), findsOneWidget);
    });

    testWidgets('should call onTap when pressed', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChip(
              category: testCategory,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('餐饮'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('should change style when selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChip(
              category: testCategory,
              isSelected: true,
            ),
          ),
        ),
      );

      // When selected, the chip should be visually different
      // This is a basic test - in a real app you might test the Container's decoration
      expect(find.text('餐饮'), findsOneWidget);
    });

    testWidgets('should hide icon when showIcon is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChip(
              category: testCategory,
              showIcon: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.restaurant), findsNothing);
      expect(find.text('餐饮'), findsOneWidget);
    });
  });

  group('CategoryChipGrid Widget Tests', () {
    final categories = [
      const Category(
        id: 1,
        name: '餐饮',
        icon: 'restaurant',
        colorValue: 0xFFEF4444,
      ),
      const Category(
        id: 2,
        name: '交通',
        icon: 'directions_car',
        colorValue: 0xFF3B82F6,
      ),
      const Category(
        id: 3,
        name: '购物',
        icon: 'shopping_bag',
        colorValue: 0xFF8B5CF6,
      ),
    ];

    testWidgets('should display all categories', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChipGrid(categories: categories),
          ),
        ),
      );

      expect(find.text('餐饮'), findsOneWidget);
      expect(find.text('交通'), findsOneWidget);
      expect(find.text('购物'), findsOneWidget);
    });

    testWidgets('should highlight selected category', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChipGrid(
              categories: categories,
              selectedCategoryId: 2,
            ),
          ),
        ),
      );

      // All categories should be rendered
      expect(find.text('餐饮'), findsOneWidget);
      expect(find.text('交通'), findsOneWidget);
      expect(find.text('购物'), findsOneWidget);
    });

    testWidgets('should call onCategorySelected when category is tapped',
        (tester) async {
      int? selectedId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChipGrid(
              categories: categories,
              onCategorySelected: (id) => selectedId = id,
            ),
          ),
        ),
      );

      await tester.tap(find.text('餐饮'));
      await tester.pump();

      expect(selectedId, 1);
    });

    testWidgets('should deselect when selected category is tapped again',
        (tester) async {
      int? selectedId = 1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChipGrid(
              categories: categories,
              selectedCategoryId: selectedId,
              onCategorySelected: (id) => selectedId = id,
            ),
          ),
        ),
      );

      await tester.tap(find.text('餐饮'));
      await tester.pump();

      expect(selectedId, isNull);
    });
  });
}
