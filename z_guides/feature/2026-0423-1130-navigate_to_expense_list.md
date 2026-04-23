# 新功能记录

## 日期
2026-04-23 11:30

## 功能名称
导航到支出列表

## 功能描述
在首页仪表盘的"最近支出"模块，点击"查看全部"按钮可导航到支出列表页面。

## 实现方案
- 将 `_screens` 从字段改为 getter，避免在初始化时访问 `setState`
- 为 `_DashboardScreen` 添加 `onNavigateToExpenseList` 回调参数
- 点击"查看全部"按钮时触发回调，切换到底部导航的支出列表 tab（索引 1）

## 修改的文件
- `lib/screens/home/home_screen.dart`（修改）

## 测试验证
- `flutter analyze` 无错误，只有 info 级别警告
