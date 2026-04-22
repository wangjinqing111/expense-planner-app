import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../data/models/expense.dart';
import '../../providers/category_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/summary_provider.dart';
import 'add_expense_screen.dart';

/// 支出详情屏幕
///
/// 底部弹窗形式展示，保留上下文便于用户快速返回
/// 详情页直接提供编辑和删除入口，减少操作步骤
class ExpenseDetailScreen extends ConsumerWidget {
  final int expenseId;

  const ExpenseDetailScreen({super.key, required this.expenseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '¥');
    final expenseState = ref.watch(expenseListProvider);
    final categoryMap = ref.watch(categoryMapProvider);

    // 查找支出
    final expense = expenseState.expenses.where((e) => e.id == expenseId).firstOrNull;

    if (expense == null) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const Center(
          child: Text('支出记录不存在'),
        ),
      );
    }

    final category = categoryMap[expense.categoryId];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部拖动条
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // 标题栏
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '支出详情',
                    style: theme.textTheme.titleLarge,
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editExpense(context, expense),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: AppColors.error,
                        onPressed: () => _confirmDelete(context, ref, expense),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // 金额
              Center(
                child: Text(
                  '-${currencyFormat.format(expense.amount)}',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 详情卡片
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        context,
                        icon: Icons.title,
                        label: '标题',
                        value: expense.title,
                      ),
                      const Divider(),
                      _buildDetailRow(
                        context,
                        icon: Icons.category,
                        label: '分类',
                        value: category?.name ?? '未知分类',
                        valueColor: category != null
                            ? Color(category.colorValue)
                            : null,
                      ),
                      const Divider(),
                      _buildDetailRow(
                        context,
                        icon: Icons.calendar_today,
                        label: '日期',
                        value: DateFormat('yyyy 年 MM 月 dd 日').format(expense.date),
                      ),
                      if (expense.note != null && expense.note!.isNotEmpty) ...[
                        const Divider(),
                        _buildDetailRow(
                          context,
                          icon: Icons.note,
                          label: '备注',
                          value: expense.note!,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // 关闭按钮
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('关闭'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: AppSpacing.iconMd, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs / 2),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editExpense(BuildContext context, Expense expense) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddExpenseScreen(expense: expense),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条支出记录吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 关闭对话框
              Navigator.pop(context); // 关闭详情页
              _deleteExpense(context, ref, expense);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _deleteExpense(BuildContext context, WidgetRef ref, Expense expense) {
    ref.read(expenseListProvider.notifier).deleteExpense(expense.id!);
    ref.invalidate(monthSummaryProvider);
    ref.invalidate(todaySummaryProvider);
    ref.invalidate(weekSummaryProvider);
    ref.invalidate(summaryProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('支出已删除'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
