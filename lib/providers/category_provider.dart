import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/category.dart';
import '../data/repositories/category_repository.dart';

/// 分类仓库提供者
///
/// CategoryMapProvider 使用 map 结构实现 O(1) 查找，避免列表遍历
/// categoryByIdProvider.family 支持按 ID 快速获取单个分类
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

/// 分类列表状态
class CategoryListState {
  final List<Category> categories;
  final bool isLoading;
  final String? error;

  const CategoryListState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });

  CategoryListState copyWith({
    List<Category>? categories,
    bool? isLoading,
    String? error,
  }) {
    return CategoryListState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 分类列表状态管理器
class CategoryListNotifier extends StateNotifier<CategoryListState> {
  final CategoryRepository _repository;

  CategoryListNotifier(this._repository) : super(const CategoryListState());

  /// 加载所有分类
  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final categories = await _repository.getAll();
      state = state.copyWith(categories: categories, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 添加分类
  Future<bool> addCategory(Category category) async {
    try {
      await _repository.insert(category);
      await loadCategories();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// 更新分类
  Future<bool> updateCategory(Category category) async {
    try {
      await _repository.update(category);
      await loadCategories();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// 删除分类
  Future<bool> deleteCategory(int id) async {
    try {
      await _repository.delete(id);
      await loadCategories();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 分类列表提供者
final categoryListProvider =
    StateNotifierProvider<CategoryListNotifier, CategoryListState>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return CategoryListNotifier(repository);
});

/// 分类地图提供者（用于快速查找）
final categoryMapProvider = Provider<Map<int, Category>>((ref) {
  final state = ref.watch(categoryListProvider);
  return {for (var c in state.categories) c.id!: c};
});

/// 根据 ID 获取分类提供者
final categoryByIdProvider = Provider.family<Category?, int>((ref, id) {
  final categoryMap = ref.watch(categoryMapProvider);
  return categoryMap[id];
});
