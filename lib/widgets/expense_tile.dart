import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/constants/app_spacing.dart';
import '../data/models/expense.dart';
import '../providers/category_provider.dart';

/// 支出列表项组件
///
/// 使用 ConsumerWidget 而非 StatelessWidget，因为需要访问分类信息
/// Dismissible 支持滑动删除，提供直观操作方式
class ExpenseTile extends ConsumerWidget {
  final Expense expense;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ExpenseTile({
    super.key,
    required this.expense,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(categoryByIdProvider(expense.categoryId));
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '¥');

    return Dismissible(
      key: Key('expense_${expense.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.md),
        color: theme.colorScheme.error,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('确认删除'),
            content: const Text('确定要删除这条支出记录吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('删除'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) => onDelete?.call(),
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePadding,
          vertical: AppSpacing.xs,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Row(
              children: [
                // 分类图标
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: category != null
                        ? Color(category.colorValue).withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                  ),
                  child: Icon(
                    _getIconData(category?.icon ?? 'more_horiz'),
                    color: category != null
                        ? Color(category.colorValue)
                        : Colors.grey,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // 支出信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.title,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        category?.name ?? '未知分类',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),

                // 金额和日期
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '-${currencyFormat.format(expense.amount)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      DateFormat('MM/dd').format(expense.date),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 将图标名称转换为 IconData
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
