import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';

/// 汇总卡片组件
///
/// 卡片式布局便于用户快速扫视关键数据
/// CategorySummaryItem 包含进度条，直观展示占比关系
class SummaryCard extends StatelessWidget {
  final String title;
  final double totalAmount;
  final int expenseCount;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const SummaryCard({
    super.key,
    required this.title,
    required this.totalAmount,
    required this.expenseCount,
    this.icon,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '¥');

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: AppSpacing.iconMd,
                      color: iconColor ?? AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                currencyFormat.format(totalAmount),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '$expenseCount 笔支出',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 分类汇总项组件
class CategorySummaryItem extends StatelessWidget {
  final String categoryName;
  final double amount;
  final double percentage;
  final Color color;
  final VoidCallback? onTap;

  const CategorySummaryItem({
    super.key,
    required this.categoryName,
    required this.amount,
    required this.percentage,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '¥');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.xs,
        ),
        child: Row(
          children: [
            // 颜色指示器
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // 分类信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryName,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs / 2),
                  // 进度条
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // 金额
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(amount),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 简洁的金额展示卡片
class AmountCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color? color;
  final bool isLarge;

  const AmountCard({
    super.key,
    required this.label,
    required this.amount,
    this.color,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '¥');

    return Card(
      color: color?.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(isLarge ? AppSpacing.lg : AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color ?? AppColors.textSecondary,
              ),
            ),
            SizedBox(height: isLarge ? AppSpacing.sm : AppSpacing.xs),
            Text(
              currencyFormat.format(amount),
              style: (isLarge
                      ? theme.textTheme.headlineMedium
                      : theme.textTheme.titleLarge)
                  ?.copyWith(
                fontWeight: FontWeight.bold,
                color: color ?? AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
