---
name: add
description: |
  添加新功能技能，用于 Flutter/Dart 项目。当用户要求添加新功能、新页面、新组件、新模型、新仓库或任何需要扩展项目功能时触发。遵循 Clean Architecture 架构，包含完整流程：查找代码插入位置 → 编写代码 → 编写测试用例 → 测试验证 → 记录功能历史 → 提交代码。当用户请求添加任何新功能时，始终使用此技能。
---

# 添加新功能工作流

## 工作流程步骤

### 1. 查找代码插入位置

根据新功能类型，确定需要修改/创建的文件：

**功能类型与对应位置：**
- **新页面 (Screen)**：创建在 `lib/screens/<feature>/` 目录
- **新组件 (Widget)**：创建在 `lib/widgets/` 目录
- **新模型 (Model)**：创建在 `lib/data/models/` 目录
- **新仓库 (Repository)**：创建在 `lib/data/repositories/` 目录
- **新提供者 (Provider)**：创建在 `lib/providers/` 目录
- **新工具函数**：创建在 `lib/core/utils/` 目录
- **新常量**：添加到 `lib/core/constants/` 目录

**查找插入位置的方法：**
1. 使用 Glob 查找相关目录和文件
2. 使用 Grep 查找类似的实现作为参考
3. 阅读相关文件的代码结构，了解项目的编码规范

### 2. 编写代码

根据 Clean Architecture 原则编写代码：

1. **遵循现有代码风格**：阅读项目中现有代码，保持一致的命名和格式
2. **使用 Riverpod 状态管理**：提供者使用 `StateNotifier` 或 `AsyncNotifier`
3. **遵循项目架构**：UI / 业务逻辑 / 数据层分离
4. **使用现有常量和工具**：`AppColors`、`AppSpacing`、`日期/货币格式化工具等`

### 3. 编写测试用例

为新功能编写单元测试或组件测试：

1. **创建测试文件**：`test/unit/<feature>_test.dart` 或 `test/widget/<feature>_test.dart`
2. **测试覆盖**：
   - 正常情况
   - 边界情况
   - 错误处理
   - 状态变化
3. **使用 mockito** 进行依赖模拟
4. **测试文件命名**：`xxx_test.dart`

### 4. 测试验证

运行测试验证功能正确性：

```bash
# 运行单元测试
flutter test test/unit/

# 运行所有测试
flutter test

# 运行单个测试文件
flutter test test/unit/<feature>_test.dart

# 静态分析
flutter analyze
```

**如果测试失败**：回到步骤 2 修改代码，最多循环 5 次。

### 5. 功能历史记录

**创建功能历史文件**：
- 位置：`./z_guides/feature/`
- 文件名格式：`YYYY-MMDD-HHMM-功能简要描述.md`
- 示例：`2026-04-22-1430-add_expense_export.md`

**功能历史文件内容**：
```markdown
# 新功能记录

## 日期
YYYY-MM-DD HH:MM

## 功能名称
[功能名称]

## 功能描述
[清晰描述功能]

## 实现方案
[如何实现]

## 修改的文件
- file1.dart（新增/修改）
- file2.dart（新增/修改）

## 测试验证
[测试结果]

## 注意事项
[任何特殊考虑或后续待办]
```

### 6. 提交代码

**提交前检查**：
1. 确保所有测试通过
2. 确保 `flutter analyze` 无错误
3. 保存所有未提交的文件

**提交信息格式**：
```
feat: 添加[功能名称]

- 新增功能描述
- 技术实现要点

```

## 注意事项

- 每个新功能对应一个历史文件
- 测试验证循环不超过 5 次
- 提交前确保功能历史已保存
- 保持代码风格与项目一致
- 遵循 Flutter 最佳实践
