import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../providers/category_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/summary_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/expense_tile.dart';
import 'add_expense_screen.dart';
import 'expense_detail_screen.dart';

/// 支出列表屏幕
///
/// 筛选区域可折叠显示，避免占用过多空间
/// 按日期分组显示，帮助用户按时间线回顾支出
class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  bool _showFilters = false;

  @override
  Widget build(BuildContext context) {
    final expenseState = ref.watch(expenseListProvider);
    final categoryState = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('支出列表'),
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
            ),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
        ],
      ),
      body: Column(
        children: [
          // 筛选区域
          if (_showFilters) _buildFilterSection(categoryState),

          // 支出列表
          Expanded(child: _buildExpenseList(expenseState)),
        ],
      ),
    );
  }

  Widget _buildFilterSection(CategoryListState categoryState) {
    final expenseState = ref.watch(expenseListProvider);
    final theme = Theme.of(context);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isLandscape ? _buildLandscapeLayout(categoryState, expenseState, theme)
          : _buildPortraitLayout(categoryState, expenseState, theme),
    );
  }

  Widget _buildPortraitLayout(
      CategoryListState categoryState, ExpenseListState expenseState, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 分类筛选
        Text('按分类筛选', style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        _buildCategoryChips(categoryState, expenseState),
        const SizedBox(height: AppSpacing.md),

        // 日期范围筛选
        Text('按日期筛选', style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        _buildDateFilterRow(expenseState),
      ],
    );
  }

  Widget _buildLandscapeLayout(
      CategoryListState categoryState, ExpenseListState expenseState, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左侧分类筛选
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('按分类筛选', style: theme.textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              _buildCategoryChips(categoryState, expenseState),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),

        // 右侧日期筛选
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('按日期筛选', style: theme.textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              _buildDateFilterRow(expenseState),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChips(
      CategoryListState categoryState, ExpenseListState expenseState) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        GestureDetector(
          onTap: () =>
              ref.read(expenseListProvider.notifier).filterByCategory(null),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: expenseState.selectedCategoryId == null
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                AppSpacing.buttonRadius,
              ),
              border: Border.all(color: AppColors.primary),
            ),
            child: Text(
              '全部',
              style: theme.textTheme.labelLarge?.copyWith(
                color: expenseState.selectedCategoryId == null
                    ? Colors.white
                    : AppColors.primary,
              ),
            ),
          ),
        ),
        ...categoryState.categories.map((category) {
          final isSelected = expenseState.selectedCategoryId == category.id;
          final color = Color(category.colorValue);

          return GestureDetector(
            onTap: () => ref
                .read(expenseListProvider.notifier)
                .filterByCategory(category.id),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  AppSpacing.buttonRadius,
                ),
                border: Border.all(color: color),
              ),
              child: Text(
                category.name,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDateFilterRow(ExpenseListState expenseState) {
    return Row(
      children: [
        Expanded(
          child: _buildDateFilterChip(
            label: '今天',
            isSelected: _isTodayFilter(),
            onTap: () => _applyDateFilter(DateRange.today),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildDateFilterChip(
            label: '本周',
            isSelected: _isThisWeekFilter(),
            onTap: () => _applyDateFilter(DateRange.thisWeek),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildDateFilterChip(
            label: '本月',
            isSelected: _isThisMonthFilter(),
            onTap: () => _applyDateFilter(DateRange.thisMonth),
          ),
        ),
      ],
    );
  }

  Widget _buildDateFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  bool _isTodayFilter() {
    final state = ref.read(expenseListProvider);
    if (state.startDate == null || state.endDate == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return state.startDate == today &&
        state.endDate == tomorrow.subtract(const Duration(seconds: 1));
  }

  bool _isThisWeekFilter() {
    final state = ref.read(expenseListProvider);
    if (state.startDate == null || state.endDate == null) return false;

    final now = DateTime.now();
    final weekday = now.weekday;
    final monday = DateTime(now.year, now.month, now.day - weekday + 1);
    final nextMonday = monday.add(const Duration(days: 7));

    return state.startDate == monday &&
        state.endDate == nextMonday.subtract(const Duration(seconds: 1));
  }

  bool _isThisMonthFilter() {
    final state = ref.read(expenseListProvider);
    if (state.startDate == null || state.endDate == null) return false;

    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);

    return state.startDate == firstDay &&
        state.endDate == nextMonth.subtract(const Duration(seconds: 1));
  }

  void _applyDateFilter(DateRange range) {
    final now = DateTime.now();
    DateTime start;
    DateTime end;

    switch (range) {
      case DateRange.today:
        start = DateTime(now.year, now.month, now.day);
        end = start
            .add(const Duration(days: 1))
            .subtract(const Duration(seconds: 1));
        break;
      case DateRange.thisWeek:
        final weekday = now.weekday;
        start = DateTime(now.year, now.month, now.day - weekday + 1);
        end = start
            .add(const Duration(days: 7))
            .subtract(const Duration(seconds: 1));
        break;
      case DateRange.thisMonth:
        start = DateTime(now.year, now.month, 1);
        end = DateTime(
          now.year,
          now.month + 1,
          1,
        ).subtract(const Duration(seconds: 1));
        break;
    }

    ref.read(expenseListProvider.notifier).filterByDateRange(start, end);
  }

  Widget _buildExpenseList(ExpenseListState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return ErrorState(
        message: state.error!,
        onRetry: () => ref.read(expenseListProvider.notifier).loadExpenses(),
      );
    }

    if (state.expenses.isEmpty) {
      if (state.hasFilters) {
        return EmptyState.search();
      }
      return EmptyState.expenses(onAdd: () => _showAddExpenseSheet(context));
    }

    // 按日期分组
    final groupedExpenses = _groupExpensesByDate(state.expenses);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(expenseListProvider.notifier).loadExpenses();
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(
          top: AppSpacing.sm,
          bottom: 80, // 为 FAB 留出空间
        ),
        itemCount: groupedExpenses.length,
        itemBuilder: (context, index) {
          final entry = groupedExpenses.entries.elementAt(index);
          return _buildDateSection(entry.key, entry.value);
        },
      ),
    );
  }

  Map<String, List<dynamic>> _groupExpensesByDate(List<dynamic> expenses) {
    final grouped = <String, List<dynamic>>{};
    final dateFormat = DateFormat('yyyy 年 MM 月 dd 日');

    for (final expense in expenses) {
      final dateKey = dateFormat.format(expense.date);
      grouped.putIfAbsent(dateKey, () => []).add(expense);
    }

    return grouped;
  }

  Widget _buildDateSection(String dateLabel, List<dynamic> expenses) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePadding,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            dateLabel,
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ...expenses.map(
          (expense) => ExpenseTile(
            expense: expense,
            onTap: () => _showExpenseDetail(expense.id!),
            onDelete: () => _deleteExpense(expense.id!),
          ),
        ),
      ],
    );
  }

  void _showAddExpenseSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddExpenseScreen(),
    );
  }

  void _showExpenseDetail(int expenseId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExpenseDetailScreen(expenseId: expenseId),
    );
  }

  void _deleteExpense(int id) {
    ref.read(expenseListProvider.notifier).deleteExpense(id);
    ref.invalidate(monthSummaryProvider);
    ref.invalidate(todaySummaryProvider);
    ref.invalidate(weekSummaryProvider);
  }
}

enum DateRange { today, thisWeek, thisMonth }
