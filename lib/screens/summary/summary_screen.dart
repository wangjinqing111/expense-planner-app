import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../data/models/category.dart';
import '../../data/models/expense_summary.dart';
import '../../providers/category_provider.dart';
import '../../providers/summary_provider.dart';
import '../../widgets/empty_state.dart';

/// 汇总屏幕
class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPeriod = ref.watch(summaryPeriodProvider);
    final summaryAsync = ref.watch(summaryProvider);
    final categoryMap = ref.watch(categoryMapProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('支出汇总'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(summaryProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // 周期选择器
          _buildPeriodSelector(context, ref, currentPeriod),

          // 汇总内容
          Expanded(
            child: summaryAsync.when(
              data: (summary) => _buildSummaryContent(context, summary, categoryMap),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ErrorState(
                message: error.toString(),
                onRetry: () => ref.invalidate(summaryProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(
    BuildContext context,
    WidgetRef ref,
    SummaryPeriod currentPeriod,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Row(
        children: [
          _buildPeriodChip(
            context,
            label: '今日',
            isSelected: currentPeriod == SummaryPeriod.day,
            onTap: () =>
                ref.read(summaryPeriodProvider.notifier).state = SummaryPeriod.day,
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildPeriodChip(
            context,
            label: '本周',
            isSelected: currentPeriod == SummaryPeriod.week,
            onTap: () =>
                ref.read(summaryPeriodProvider.notifier).state = SummaryPeriod.week,
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildPeriodChip(
            context,
            label: '本月',
            isSelected: currentPeriod == SummaryPeriod.month,
            onTap: () =>
                ref.read(summaryPeriodProvider.notifier).state = SummaryPeriod.month,
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
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
      ),
    );
  }

  Widget _buildSummaryContent(
    BuildContext context,
    ExpenseSummary summary,
    Map<int, Category> categoryMap,
  ) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '¥');

    if (summary.expenseCount == 0) {
      return EmptyState.summary();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 总支出卡片
          Card(
            color: AppColors.primary,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '总支出',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    currencyFormat.format(summary.totalAmount),
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${summary.expenseCount} 笔支出',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // 周期日期范围
          Row(
            children: [
              Icon(Icons.date_range, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${DateFormat('MM/dd').format(summary.periodStart)} - ${DateFormat('MM/dd').format(summary.periodEnd)}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // 分类支出明细
          Text(
            '分类支出明细',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),

          if (summary.byCategory.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Text('暂无分类支出数据'),
              ),
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    // 表头
                    Row(
                      children: [
                        const SizedBox(width: 28),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '分类',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '金额',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        SizedBox(
                          width: 50,
                          child: Text(
                            '占比',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),

                    // 分类列表
                    ...summary.byCategory.entries.map<Widget>((entry) {
                      final category = categoryMap[entry.key];
                      if (category == null) return const SizedBox.shrink();

                      final percentage = summary.totalAmount > 0
                          ? (entry.value / summary.totalAmount) * 100
                          : 0.0;
                      final color = Color(category.colorValue);

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            // 颜色指示器
                            Container(
                              width: 4,
                              height: 36,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),

                            // 分类名称和图标
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      _getIconData(category.icon),
                                      size: 16,
                                      color: color,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    category.name,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),

                            // 金额
                            Expanded(
                              child: Text(
                                currencyFormat.format(entry.value),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),

                            // 百分比
                            SizedBox(
                              width: 50,
                              child: Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: theme.textTheme.bodySmall,
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

          const SizedBox(height: AppSpacing.lg),

          // 可视化柱状图
          if (summary.byCategory.isNotEmpty) ...[
            Text(
              '支出分布',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildBarChart(context, summary, categoryMap),
          ],
        ],
      ),
    );
  }

  Widget _buildBarChart(
    BuildContext context,
    ExpenseSummary summary,
    Map<int, Category> categoryMap,
  ) {
    final theme = Theme.of(context);
    final maxAmount = summary.byCategory.values.isEmpty
        ? 0.0
        : summary.byCategory.values.reduce((a, b) => a > b ? a : b);

    if (maxAmount == 0) return const SizedBox.shrink();

    // 按金额排序
    final sortedEntries = summary.byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: sortedEntries.take(6).map((entry) {
            final category = categoryMap[entry.key];
            if (category == null) return const SizedBox.shrink();

            final percentage = entry.value / maxAmount;
            final color = Color(category.colorValue);

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      category.name,
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: percentage,
                          child: Container(
                            height: 24,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    const iconMap = {
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'shopping_bag': Icons.shopping_bag,
      'movie': Icons.movie,
      'medical_services': Icons.medical_services,
      'home': Icons.home,
      'school': Icons.school,
      'more_horiz': Icons.more_horiz,
      'flight': Icons.flight,
      'fitness_center': Icons.fitness_center,
      'pets': Icons.pets,
      'local_cafe': Icons.local_cafe,
      'local_grocery_store': Icons.local_grocery_store,
      'phone_android': Icons.phone_android,
      'attach_money': Icons.attach_money,
    };
    return iconMap[iconName] ?? Icons.more_horiz;
  }
}
