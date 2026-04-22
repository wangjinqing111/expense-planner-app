import 'package:flutter/material.dart';

import '../core/constants/app_spacing.dart';
import '../data/models/category.dart';

/// 分类标签组件
///
/// isSelected 控制选中态样式，区分选中和未选中状态
/// iconMap 硬编码而非动态获取，是为了减少运行时开销
class CategoryChip extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool showIcon;

  const CategoryChip({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(category.colorValue);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          border: Border.all(
            color: color,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(
                _getIconData(category.icon),
                size: AppSpacing.iconSm,
                color: isSelected ? Colors.white : color,
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              category.name,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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

/// 分类选择器网格
class CategoryChipGrid extends StatelessWidget {
  final List<Category> categories;
  final int? selectedCategoryId;
  final ValueChanged<int?>? onCategorySelected;
  final bool allowDeselect;

  const CategoryChipGrid({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    this.onCategorySelected,
    this.allowDeselect = true,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: categories.map((category) {
        return CategoryChip(
          category: category,
          isSelected: category.id == selectedCategoryId,
          onTap: () {
            if (allowDeselect && category.id == selectedCategoryId) {
              onCategorySelected?.call(null);
            } else {
              onCategorySelected?.call(category.id);
            }
          },
        );
      }).toList(),
    );
  }
}
