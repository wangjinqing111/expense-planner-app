# Bug 修复记录

## 日期
2026-04-22

## 问题描述
首页-最近支出，使用滑动删除数据时，删除成功后页面会出现闪烁。

## 根本原因
`ExpenseListNotifier.deleteExpense()` 在删除成功后调用 `loadExpenses()` 重新加载数据，而 `loadExpenses()` 会先将 `isLoading` 设为 `true`，导致 UI 短暂显示加载状态，造成闪烁。

## 解决方案
采用乐观更新（Optimistic Update）策略：先立即从 UI 移除项目，再执行数据库操作。如果数据库操作失败，则恢复原始列表。这样可以避免设置 `isLoading = true` 导致的页面闪烁。

## 修改的文件
- `lib/providers/expense_provider.dart`

## 验证方式
1. 运行 `flutter analyze lib/` 无错误
2. 手动测试：滑动删除最近支出记录，验证页面不再闪烁
