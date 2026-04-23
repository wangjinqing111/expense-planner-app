import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../data/models/category.dart';
import '../../providers/category_provider.dart';

/// 添加/编辑分类屏幕
///
/// 实时预览让用户在添加前看到效果，提升体验
/// 颜色和图标组合可选，提供个性化分类能力
class AddCategoryScreen extends ConsumerStatefulWidget {
  final Category? category; // 如果提供则是编辑模式

  const AddCategoryScreen({super.key, this.category});

  @override
  ConsumerState<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends ConsumerState<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String _selectedIcon = 'more_horiz';
  int _selectedColorIndex = 0;
  bool _isLoading = false;

  bool get isEditing => widget.category != null;

  // 可选图标列表
  static const List<String> availableIcons = [
    'restaurant',
    'directions_car',
    'shopping_bag',
    'movie',
    'medical_services',
    'home',
    'school',
    'flight',
    'fitness_center',
    'pets',
    'local_cafe',
    'local_grocery_store',
    'phone_android',
    'attach_money',
    'more_horiz',
  ];

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.category!.name;
      _selectedIcon = widget.category!.icon;
      _selectedColorIndex = AppColors.categoryColors.indexWhere(
        (color) => color.value == widget.category!.colorValue,
      );
      if (_selectedColorIndex < 0) _selectedColorIndex = 0;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Form(
            key: _formKey,
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

                // 标题
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? '编辑分类' : '添加分类',
                      style: theme.textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // 预览
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.categoryColors[_selectedColorIndex]
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      _getIconData(_selectedIcon),
                      size: 40,
                      color: AppColors.categoryColors[_selectedColorIndex],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 名称输入
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '分类名称',
                    hintText: '例如：餐饮、交通',
                    prefixIcon: Icon(Icons.label),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入分类名称';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // 图标选择
                Text('选择图标', style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: availableIcons.map((iconName) {
                    final isSelected = _selectedIcon == iconName;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = iconName),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.categoryColors[_selectedColorIndex]
                                    .withOpacity(0.2)
                              : AppColors.border.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.categoryColors[_selectedColorIndex]
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          _getIconData(iconName),
                          color: isSelected
                              ? AppColors.categoryColors[_selectedColorIndex]
                              : AppColors.textSecondary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 颜色选择
                Text('选择颜色', style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: AppColors.categoryColors.asMap().entries.map((
                    entry,
                  ) {
                    final index = entry.key;
                    final color = entry.value;
                    final isSelected = _selectedColorIndex == index;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedColorIndex = index),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Colors.white
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 提交按钮
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(isEditing ? '保存' : '添加'),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final category = Category(
      id: widget.category?.id,
      name: _nameController.text.trim(),
      icon: _selectedIcon,
      colorValue: AppColors.categoryColors[_selectedColorIndex].value,
      createdAt: widget.category?.createdAt,
    );

    bool success;
    if (isEditing) {
      success = await ref
          .read(categoryListProvider.notifier)
          .updateCategory(category);
    } else {
      success = await ref
          .read(categoryListProvider.notifier)
          .addCategory(category);
    }

    if (success) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? '分类已更新' : '分类已添加'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('操作失败，请重试'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
