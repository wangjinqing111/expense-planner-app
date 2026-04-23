# Bug 修复记录

## 日期
2026-04-23 09:45

## 问题描述
横屏模式下，支出列表选择分类和今天筛选条件时，显示 "BOTTOM OVERFLOWED BY 15 PIXELS" 错误。

## 根本原因
`_buildFilterSection` 方法返回的 `Container` 中直接包含一个 `Column`，Column 内容在横屏模式下空间不足时无法滚动，导致溢出。

## 解决方案
将 `Column` 包装在 `SingleChildScrollView` 中，使筛选区域在空间不足时可以独立滚动。

## 修改的文件
- lib/screens/expense/expense_list_screen.dart

## 验证方式
- flutter analyze 无错误
- 横屏模式下测试筛选功能正常显示
