import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../data/models/expense.dart';
import '../../providers/category_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/summary_provider.dart';
import '../../widgets/category_chip.dart';

/// 添加/编辑支出屏幕
///
/// 同一屏幕支持添加和编辑，通过 expense 参数区分模式
/// 输入格式过滤确保金额只接受合理数值，防止输入异常
class AddExpenseScreen extends ConsumerStatefulWidget {
  final Expense? expense; // 如果提供则是编辑模式

  const AddExpenseScreen({super.key, this.expense});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>(); // 表单状态管理，用于验证和提交
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  int? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  bool get isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _titleController.text = widget.expense!.title;
      _amountController.text = widget.expense!.amount.toString();
      _noteController.text = widget.expense!.note ?? '';
      _selectedCategoryId = widget.expense!.categoryId;
      _selectedDate = widget.expense!.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryState = ref.watch(categoryListProvider);

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
                      isEditing ? '编辑支出' : '添加支出',
                      style: theme.textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // 标题输入
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: '支出标题',
                    hintText: '例如：午餐、打车费',
                    prefixIcon: Icon(Icons.title),
                  ),
                  maxLength: 50,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入支出标题';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // 金额输入
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: '金额',
                    hintText: '0.00',
                    prefixIcon: Icon(Icons.currency_yen),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入金额';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return '请输入有效金额';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // 分类选择
                Text('选择分类', style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                if (categoryState.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (categoryState.categories.isEmpty)
                  const Text('暂无分类，请先添加分类')
                else
                  CategoryChipGrid(
                    categories: categoryState.categories,
                    selectedCategoryId: _selectedCategoryId,
                    onCategorySelected: (id) {
                      setState(() => _selectedCategoryId = id);
                    },
                  ),
                if (_selectedCategoryId == null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      '请选择一个分类',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),

                // 日期选择
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('日期'),
                  subtitle: Text(
                    DateFormat('yyyy 年 MM 月 dd 日').format(_selectedDate),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _selectDate(context),
                ),
                const Divider(),

                // 备注输入
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: '备注（可选）',
                    hintText: '添加备注...',
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
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

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedCategoryId == null) {
      return;
    }

    setState(() => _isLoading = true);

    final expense = Expense(
      id: widget.expense?.id,
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text),
      categoryId: _selectedCategoryId!,
      date: _selectedDate,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      createdAt: widget.expense?.createdAt,
    );

    bool success;
    if (isEditing) {
      success = await ref
          .read(expenseListProvider.notifier)
          .updateExpense(expense);
    } else {
      success = await ref
          .read(expenseListProvider.notifier)
          .addExpense(expense);
    }

    if (success) {
      // 刷新汇总数据
      ref.invalidate(monthSummaryProvider);
      ref.invalidate(todaySummaryProvider);
      ref.invalidate(weekSummaryProvider);
      ref.invalidate(summaryProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? '支出已更新' : '支出已添加'),
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
