# Bug 修复记录

## 日期
2026-04-23 12:00

## 问题描述
分类管理 - 编辑分类保存时报错：`DatabaseException(Not Null constraint failed: categories.created_at)`

## 根本原因
编辑分类时，在 `AddCategoryScreen._submit()` 中创建 `Category` 对象时丢失了 `createdAt` 字段。当 `createdAt` 为 null 时，数据库更新 SQL 会设置 `created_at = NULL`，违反 `NOT NULL` 约束。

这与之前 `expense` 编辑问题的根因相同。

## 解决方案
在 `_submit()` 创建 `Category` 对象时，保留原始的 `createdAt`：
```dart
createdAt: widget.category?.createdAt,
```

## 修改的文件
- `lib/screens/category/add_category_screen.dart`（修改）

## 验证方式
- `flutter analyze` 无错误，只有 info 级别警告
