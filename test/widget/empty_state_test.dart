import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coin/widgets/empty_state.dart';

void main() {
  group('EmptyState Widget Tests', () {
    testWidgets('should display icon, title and message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.receipt_long,
              title: '测试标题',
              message: '测试消息',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.receipt_long), findsOneWidget);
      expect(find.text('测试标题'), findsOneWidget);
      expect(find.text('测试消息'), findsOneWidget);
    });

    testWidgets('should display action button when provided', (tester) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.receipt_long,
              title: '测试标题',
              message: '测试消息',
              actionLabel: '添加',
              onAction: () => buttonPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('添加'), findsOneWidget);

      await tester.tap(find.text('添加'));
      await tester.pump();

      expect(buttonPressed, isTrue);
    });

    testWidgets('expenses factory should create correct empty state',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState.expenses(),
          ),
        ),
      );

      expect(find.text('暂无支出记录'), findsOneWidget);
      expect(find.text('点击下方按钮添加您的第一笔支出'), findsOneWidget);
      expect(find.text('添加支出'), findsOneWidget);
    });

    testWidgets('categories factory should create correct empty state',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState.categories(),
          ),
        ),
      );

      expect(find.text('暂无分类'), findsOneWidget);
      expect(find.text('点击下方按钮创建您的第一个分类'), findsOneWidget);
      expect(find.text('添加分类'), findsOneWidget);
    });

    testWidgets('summary factory should create correct empty state',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState.summary(),
          ),
        ),
      );

      expect(find.text('暂无汇总数据'), findsOneWidget);
      expect(find.text('添加一些支出记录后查看汇总'), findsOneWidget);
    });

    testWidgets('search factory should create correct empty state',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState.search(),
          ),
        ),
      );

      expect(find.text('未找到结果'), findsOneWidget);
      expect(find.text('尝试调整筛选条件'), findsOneWidget);
    });
  });

  group('LoadingState Widget Tests', () {
    testWidgets('should display loading indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingState(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display message when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingState(message: '加载中...'),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('加载中...'), findsOneWidget);
    });
  });

  group('ErrorState Widget Tests', () {
    testWidgets('should display error message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorState(message: '发生了错误'),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('出错了'), findsOneWidget);
      expect(find.text('发生了错误'), findsOneWidget);
    });

    testWidgets('should display retry button when provided', (tester) async {
      bool retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(
              message: '发生了错误',
              onRetry: () => retryPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('重试'), findsOneWidget);

      await tester.tap(find.text('重试'));
      await tester.pump();

      expect(retryPressed, isTrue);
    });
  });
}
