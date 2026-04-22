import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/expense.dart';
import '../data/repositories/expense_repository.dart';

/// 支出仓库提供者
final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository();
});

/// 支出列表状态
class ExpenseListState {
  final List<Expense> expenses;
  final bool isLoading;
  final String? error;
  final int? selectedCategoryId;
  final DateTime? startDate;
  final DateTime? endDate;

  const ExpenseListState({
    this.expenses = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategoryId,
    this.startDate,
    this.endDate,
  });

  ExpenseListState copyWith({
    List<Expense>? expenses,
    bool? isLoading,
    String? error,
    int? selectedCategoryId,
    DateTime? startDate,
    DateTime? endDate,
    bool clearCategoryId = false,
    bool clearDateRange = false,
  }) {
    return ExpenseListState(
      expenses: expenses ?? this.expenses,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCategoryId:
          clearCategoryId ? null : (selectedCategoryId ?? this.selectedCategoryId),
      startDate: clearDateRange ? null : (startDate ?? this.startDate),
      endDate: clearDateRange ? null : (endDate ?? this.endDate),
    );
  }

  /// 是否应用了筛选
  bool get hasFilters => selectedCategoryId != null || startDate != null;
}

/// 支出列表状态管理器
///
/// 操作成功后根据当前筛选条件决定重新加载哪个列表，保持筛选状态一致
/// dismissible 滑动删除提供直观操作方式，符合移动端用户习惯
class ExpenseListNotifier extends StateNotifier<ExpenseListState> {
  final ExpenseRepository _repository;

  ExpenseListNotifier(this._repository) : super(const ExpenseListState());

  /// 加载所有支出
  Future<void> loadExpenses() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final expenses = await _repository.getAll();
      state = state.copyWith(expenses: expenses, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 按筛选条件加载支出
  Future<void> loadFilteredExpenses() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      List<Expense> expenses;

      if (state.selectedCategoryId != null &&
          state.startDate != null &&
          state.endDate != null) {
        expenses = await _repository.getByCategoryAndDateRange(
          state.selectedCategoryId!,
          state.startDate!,
          state.endDate!,
        );
      } else if (state.selectedCategoryId != null) {
        expenses = await _repository.getByCategory(state.selectedCategoryId!);
      } else if (state.startDate != null && state.endDate != null) {
        expenses =
            await _repository.getByDateRange(state.startDate!, state.endDate!);
      } else {
        expenses = await _repository.getAll();
      }

      state = state.copyWith(expenses: expenses, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 添加支出
  Future<bool> addExpense(Expense expense) async {
    try {
      await _repository.insert(expense);
      if (state.hasFilters) {
        await loadFilteredExpenses();
      } else {
        await loadExpenses();
      }
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// 更新支出
  Future<bool> updateExpense(Expense expense) async {
    try {
      await _repository.update(expense);
      if (state.hasFilters) {
        await loadFilteredExpenses();
      } else {
        await loadExpenses();
      }
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// 删除支出
  ///
  /// 采用乐观更新策略：先立即从 UI 移除项目，再执行数据库操作
  /// 避免 setLoading(true) 导致的页面闪烁问题
  Future<bool> deleteExpense(int id) async {
    final originalExpenses = state.expenses;

    // 乐观更新：立即从列表中移除
    state = state.copyWith(
      expenses: state.expenses.where((e) => e.id != id).toList(),
    );

    try {
      await _repository.delete(id);
      return true;
    } catch (e) {
      // 失败时恢复原始列表
      state = state.copyWith(
        error: e.toString(),
        expenses: originalExpenses,
      );
      return false;
    }
  }

  /// 按分类筛选
  void filterByCategory(int? categoryId) {
    if (categoryId == null) {
      state = state.copyWith(clearCategoryId: true);
    } else {
      state = state.copyWith(selectedCategoryId: categoryId);
    }
    loadFilteredExpenses();
  }

  /// 按日期范围筛选
  void filterByDateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) {
      state = state.copyWith(clearDateRange: true);
    } else {
      state = state.copyWith(startDate: start, endDate: end);
    }
    loadFilteredExpenses();
  }

  /// 清除筛选
  void clearFilters() {
    state = state.copyWith(clearCategoryId: true, clearDateRange: true);
    loadExpenses();
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 支出列表提供者
final expenseListProvider =
    StateNotifierProvider<ExpenseListNotifier, ExpenseListState>((ref) {
  final repository = ref.watch(expenseRepositoryProvider);
  return ExpenseListNotifier(repository);
});

/// 支出总数提供者
final expenseCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(expenseRepositoryProvider);
  return repository.getCount();
});

/// 支出总金额提供者
final expenseTotalAmountProvider = FutureProvider<double>((ref) async {
  final repository = ref.watch(expenseRepositoryProvider);
  return repository.getTotalAmount();
});
