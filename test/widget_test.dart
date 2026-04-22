import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coin/main.dart';
import 'test_config.dart';

void main() {
  setUpAll(() {
    // 初始化 sqflite_common_ffi
    initSqfliteFfi();
  });

  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: ExpensePlannerApp(),
      ),
    );

    // Verify that the app loads with the home screen
    expect(find.text('支出规划'), findsOneWidget);
  });
}
