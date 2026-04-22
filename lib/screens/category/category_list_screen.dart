import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../data/models/category.dart';
import '../../providers/category_provider.dart';
import '../../widgets/empty_state.dart';
import 'add_category_screen.dart';

/// 分类列表屏幕
class CategoryListScreen extends ConsumerWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryState = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('分类管理'),
      ),
      body: _buildCategoryList(context, ref, categoryState),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategorySheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryList(
    BuildContext context,
    WidgetRef ref,
    CategoryListState state,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return ErrorState(
        message: state.error!,
        onRetry: () => ref.read(categoryListProvider.notifier).loadCategories(),
      );
    }

    if (state.categories.isEmpty) {
      return EmptyState.categories(
        onAdd: () => _showAddCategorySheet(context),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(categoryListProvider.notifier).loadCategories();
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(
          top: AppSpacing.sm,
          bottom: 80,
        ),
        itemCount: state.categories.length,
        itemBuilder: (context, index) {
          final category = state.categories[index];
          return _buildCategoryTile(context, ref, category);
        },
      ),
    );
  }

  Widget _buildCategoryTile(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) {
    final theme = Theme.of(context);
    final color = Color(category.colorValue);

    return Dismissible(
      key: Key('category_${category.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        color: AppColors.error,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) => _confirmDelete(context, category),
      onDismissed: (direction) => _deleteCategory(ref, category),
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePadding,
          vertical: AppSpacing.xs,
        ),
        child: InkWell(
          onTap: () => _showEditCategorySheet(context, category),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Row(
              children: [
                // 图标
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                  ),
                  child: Icon(
                    _getIconData(category.icon),
                    color: color,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // 名称
                Expanded(
                  child: Text(
                    category.name,
                    style: theme.textTheme.titleMedium,
                  ),
                ),

                // 编辑按钮
                IconButton(
                  icon: const Icon(Icons.edit),
                  color: AppColors.textSecondary,
                  onPressed: () => _showEditCategorySheet(context, category),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, Category category) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除分类 "${category.name}" 吗？\n\n如果有支出关联到此分类，将无法删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(WidgetRef ref, Category category) async {
    try {
      final success =
          await ref.read(categoryListProvider.notifier).deleteCategory(category.id!);
      if (!success) {
        // 重新加载以显示最新状态
        await ref.read(categoryListProvider.notifier).loadCategories();
      }
    } catch (e) {
      // 显示错误
    }
  }

  void _showAddCategorySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddCategoryScreen(),
    );
  }

  void _showEditCategorySheet(BuildContext context, Category category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCategoryScreen(category: category),
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
