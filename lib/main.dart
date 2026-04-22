import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'screens/home/home_screen.dart';

void main() {
  // 确保 Flutter 引擎完全初始化后再运行应用
  // 原因：某些插件（如 sqflite）在 runApp 前就需要访问 native 平台通道
  // 如果 binding 未就绪，插件调用可能失败或导致崩溃
  WidgetsFlutterBinding.ensureInitialized();

  // ProviderScope 是 Riverpod 的根容器，管理所有状态提供者的生命周期
  // 原因：Riverpod 使用提供者模式替代传统的 inheritedWidget/Context 获取状态
  // 放在根节点确保所有子 widget 都能通过 ref.watch/read 访问状态
  runApp(
    const ProviderScope(
      child: ExpensePlannerApp(),
    ),
  );
}

/// 支出规划应用
class ExpensePlannerApp extends StatelessWidget {
  const ExpensePlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '支出规划',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
