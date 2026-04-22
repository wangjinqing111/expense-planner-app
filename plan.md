# Expense Planner - 实现计划

## 背景

将一个极简的 Flutter 计数器应用转变为一个功能完整的支出规划器，利用自主智能体驱动的方式进行开发和验证。项目已配置 Claude Agent SDK，将用于自主开发。

## 架构

### 项目结构
```
lib/
├── main.dart                    # 入口点，配置 Riverpod
├── core/
│   ├── constants/               # 颜色、间距、字符串常量
│   ├── theme/                   # AppTheme 配置
│   └── utils/                   # 日期/货币工具
├── data/
│   ├── database/               # SQLite 助手，表定义
│   ├── models/                  # Expense, Category, ExpenseSummary
│   └── repositories/           # 增删改查操作
├── providers/                   # Riverpod 状态管理
├── screens/                    # Home, Expense, Summary, Category 页面
└── widgets/                    # 可复用组件

test/
├── unit/                       # 模型、仓库、提供者 单元测试
├── widget/                     # 组件测试
└── integration/               # 完整增删改查流程
```

### 技术栈
- **状态管理**: Riverpod (flutter_riverpod)
- **数据库**: sqflite + SQLite
- **架构**: 清洁架构 (UI / 业务逻辑 / 数据)

## 实现阶段

### 阶段 1: 项目初始化
- 添加依赖: flutter_riverpod, sqflite, path_provider, intl, equatable
- 创建目录结构
- 配置应用主题

### 阶段 2: 数据层
- 创建模型 (Expense, Category, ExpenseSummary)
- 实现 DatabaseHelper 单例
- 创建增删改查仓库
- 编写仓库单元测试

### 阶段 3: 状态管理
- DatabaseProvider → RepositoryProviders → StateNotifiers
- SummaryProvider 计算汇总数据
- 提供者单元测试

### 阶段 4: 核心 UI
- 可复用组件: ExpenseTile, CategoryChip, SummaryCard
- HomeScreen 首页仪表盘
- BottomNavigation 底部导航 (4个标签页)

### 阶段 5: 支出功能
- ExpenseListScreen 带筛选条件的列表
- AddExpenseScreen 带验证的表单
- ExpenseDetailScreen 支出详情页

### 阶段 6: 汇总功能
- SummaryScreen 日/周/月周期视图
- 分类支出可视化

### 阶段 7: 分类功能
- CategoryListScreen 分类管理页
- AddCategoryScreen 图标/颜色选择器

### 阶段 8: 测试与完善
- 增删改查流程集成测试
- 错误处理、加载状态
- 最终验证

## Claude Agent 工作流程

每个阶段后运行验证:
```bash
flutter analyze   # 检查错误
flutter test      # 运行测试
flutter run       # 验证应用运行
```

## 需要添加的依赖

```yaml
dependencies:
  flutter_riverpod: ^2.4.9
  sqflite: ^2.3.0
  path_provider: ^2.1.1
  intl: ^0.18.1
  equatable: ^2.0.5

dev_dependencies:
  mockito: ^5.4.4
  build_runner: ^2.4.7
  sqflite_common_ffi: ^2.3.0
```

## 验收标准

- [ ] 支出和分类的增删改查功能正常
- [ ] 汇总计算准确
- [ ] 数据在应用重启后持久化
- [ ] 单元测试覆盖率 >80%
- [ ] 主要页面有组件测试
- [ ] 关键流程有集成测试
- [ ] 可构建 Android/iOS/Web 应用
