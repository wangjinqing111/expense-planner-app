import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../data/models/expense_summary.dart';
import '../../data/models/category.dart';
import '../../providers/category_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/summary_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/expense_tile.dart';
import '../../widgets/summary_card.dart';
import '../expense/add_expense_screen.dart';
import '../expense/expense_list_screen.dart';
import '../expense/expense_detail_screen.dart';
import '../category/category_list_screen.dart';
import '../summary/summary_screen.dart';

/// 首页屏幕
///
/// IndexedStack 保持各 tab 状态，避免每次切换重新构建
/// addPostFrameCallback 确保数据加载在界面首次绘制后执行，避免阻塞
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // 初始化数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryListProvider.notifier).loadCategories();
      ref.read(expenseListProvider.notifier).loadExpenses();
    });
  }

  List<Widget> get _screens => [
    _DashboardScreen(onNavigateToExpenseList: () {
      setState(() => _currentIndex = 1);
    }),
    const ExpenseListScreen(),
    const SummaryScreen(),
    const CategoryListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: '支出',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_outline),
            activeIcon: Icon(Icons.pie_chart),
            label: '汇总',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
            label: '分类',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseSheet(context),
        child: const Icon(Icons.add),
      ),
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
}

/// 仪表盘屏幕
class _DashboardScreen extends ConsumerWidget {
  final VoidCallback? onNavigateToExpenseList;

  const _DashboardScreen({this.onNavigateToExpenseList});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // 监听汇总数据
    final monthSummaryAsync = ref.watch(monthSummaryProvider);
    final todaySummaryAsync = ref.watch(todaySummaryProvider);
    final weekSummaryAsync = ref.watch(weekSummaryProvider);
    final expenseState = ref.watch(expenseListProvider);
    final categoryMap = ref.watch(categoryMapProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('支出规划'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(monthSummaryProvider);
              ref.invalidate(todaySummaryProvider);
              ref.invalidate(weekSummaryProvider);
              ref.read(expenseListProvider.notifier).loadExpenses();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(monthSummaryProvider);
          ref.invalidate(todaySummaryProvider);
          ref.invalidate(weekSummaryProvider);
          await ref.read(expenseListProvider.notifier).loadExpenses();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 本月总支出卡片
              monthSummaryAsync.when(
                data: (summary) => _buildMonthTotalCard(
                  context,
                  summary.totalAmount,
                  summary.expenseCount,
                ),
                loading: () =>
                    _buildMonthTotalCard(context, 0, 0, isLoading: true),
                error: (_, __) =>
                    _buildMonthTotalCard(context, 0, 0, hasError: true),
              ),

              const SizedBox(height: AppSpacing.md),

              // 今日/本周支出
              Row(
                children: [
                  Expanded(
                    child: todaySummaryAsync.when(
                      data: (summary) => AmountCard(
                        label: '今日支出',
                        amount: summary.totalAmount,
                        color: AppColors.secondary,
                      ),
                      loading: () => const AmountCard(
                        label: '今日支出',
                        amount: 0,
                        color: AppColors.secondary,
                      ),
                      error: (_, __) => const AmountCard(
                        label: '今日支出',
                        amount: 0,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.cardSpacing),
                  Expanded(
                    child: weekSummaryAsync.when(
                      data: (summary) => AmountCard(
                        label: '本周支出',
                        amount: summary.totalAmount,
                        color: AppColors.warning,
                      ),
                      loading: () => const AmountCard(
                        label: '本周支出',
                        amount: 0,
                        color: AppColors.warning,
                      ),
                      error: (_, __) => const AmountCard(
                        label: '本周支出',
                        amount: 0,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // 分类支出排行
              Text('分类支出', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              monthSummaryAsync.when(
                data: (summary) =>
                    _buildCategorySummary(context, summary, categoryMap),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(child: Text('加载失败')),
              ),

              const SizedBox(height: AppSpacing.lg),

              // 最近支出
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('最近支出', style: theme.textTheme.titleMedium),
                  TextButton(
                    onPressed: onNavigateToExpenseList,
                    child: const Text('查看全部'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              if (expenseState.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (expenseState.expenses.isEmpty)
                const EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: '暂无支出记录',
                  message: '点击下方按钮添加您的第一笔支出',
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: expenseState.expenses.length > 5
                      ? 5
                      : expenseState.expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenseState.expenses[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: ExpenseTile(
                        expense: expense,
                        onTap: () => _showExpenseDetail(context, expense.id!),
                        onDelete: () => _deleteExpense(ref, expense.id!),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthTotalCard(
    BuildContext context,
    double amount,
    int count, {
    bool isLoading = false,
    bool hasError = false,
  }) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '¥');

    return Card(
      color: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '本月支出',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  if (isLoading)
                    const SizedBox(
                      height: 36,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  else if (hasError)
                    Text(
                      '加载失败',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                      ),
                    )
                  else
                    Text(
                      currencyFormat.format(amount),
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              '$count 笔支出',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySummary(
    BuildContext context,
    ExpenseSummary summary,
    Map<int, Category> categoryMap,
  ) {
    if (summary.byCategory.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Text('暂无分类支出数据'),
        ),
      );
    }

    // 按金额排序
    final sortedEntries = summary.byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalAmount = summary.totalAmount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: sortedEntries.take(5).map((entry) {
            final category = categoryMap[entry.key];
            if (category == null) return const SizedBox.shrink();

            final percentage = totalAmount > 0
                ? (entry.value / totalAmount) * 100
                : 0.0;

            return CategorySummaryItem(
              categoryName: category.name,
              amount: entry.value,
              percentage: percentage,
              color: Color(category.colorValue),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showExpenseDetail(BuildContext context, int expenseId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExpenseDetailScreen(expenseId: expenseId),
    );
  }

  void _deleteExpense(WidgetRef ref, int id) {
    ref.read(expenseListProvider.notifier).deleteExpense(id);
    ref.invalidate(monthSummaryProvider);
    ref.invalidate(todaySummaryProvider);
    ref.invalidate(weekSummaryProvider);
  }
}
