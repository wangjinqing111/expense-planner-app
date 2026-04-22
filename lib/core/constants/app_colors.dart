import 'package:flutter/material.dart';

/// 应用颜色常量
class AppColors {
  AppColors._();

  // 主色
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  // 次要色
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryLight = Color(0xFF34D399);
  static const Color secondaryDark = Color(0xFF059669);

  // 错误色
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);

  // 警告色
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);

  // 成功色
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);

  // 中性色
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);

  // 文本色
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // 边框色
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // 分类颜色预设
  static const List<Color> categoryColors = [
    Color(0xFFEF4444), // 红色
    Color(0xFFF97316), // 橙色
    Color(0xFFF59E0B), // 黄色
    Color(0xFF84CC16), // 青柠
    Color(0xFF22C55E), // 绿色
    Color(0xFF10B981), // 翠绿
    Color(0xFF14B8A6), // 青色
    Color(0xFF06B6D4), // 浅蓝
    Color(0xFF0EA5E9), // 蓝色
    Color(0xFF3B82F6), // 亮蓝
    Color(0xFF6366F1), // 靛蓝
    Color(0xFF8B5CF6), // 紫色
    Color(0xFFA855F7), // 紫罗兰
    Color(0xFFD946EF), // 品红
    Color(0xFFEC4899), // 粉红
    Color(0xFFF43F5E), // 玫红
  ];

  // 获取分类颜色（按索引）
  static Color getCategoryColor(int index) {
    return categoryColors[index % categoryColors.length];
  }
}
