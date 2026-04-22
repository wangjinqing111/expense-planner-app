/// 应用间距常量
///
/// 采用 4px 基础单位的倍数系统，确保间距比例协调一致
/// 集中管理避免多处硬编码，便于统一调整
class AppSpacing {
  AppSpacing._();

  // 基础间距
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // 页面内边距
  static const double pagePadding = 16.0;
  static const double cardPadding = 16.0;

  // 卡片间距
  static const double cardSpacing = 12.0;
  static const double cardRadius = 12.0;

  // 列表项间距
  static const double listItemSpacing = 8.0;
  static const double listItemPadding = 12.0;

  // 按钮间距
  static const double buttonHeight = 48.0;
  static const double buttonRadius = 8.0;
  static const double buttonSpacing = 12.0;

  // 输入框间距
  static const double inputHeight = 56.0;
  static const double inputRadius = 8.0;

  // 图标大小
  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // 底部导航栏高度
  static const double bottomNavHeight = 60.0;

  // AppBar 高度
  static const double appBarHeight = 56.0;
}
