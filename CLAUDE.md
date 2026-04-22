# CLAUDE.md

本文件为 Claude Code (claude.ai/code) 在此代码仓库中工作时提供指导。

## 项目概述

这是一个 **Flutter** 支出规划应用，支持 iOS、Android、Linux、macOS、Windows 和 Web 平台。

## 常用命令

```bash
# 运行应用
flutter run

# 在指定设备运行
flutter run -d <device_id>

# 构建 Android release 版本
flutter build apk --release

# 构建 iOS 模拟器版本
flutter build ios --simulator --no-codesign

# 运行所有测试
flutter test

# 运行指定目录的测试
flutter test test/unit/

# 运行单个测试文件
flutter test test/widget_test.dart

# 分析代码错误
flutter analyze

# 获取依赖
flutter pub get

# 列出可用设备
flutter devices
```

## 架构

本项目采用 **Clean Architecture** 清洁架构，使用 Riverpod 进行状态管理。

### 项目结构
```
lib/
├── main.dart                    # 应用入口
├── core/
│   ├── constants/              # 颜色、间距、字符串常量
│   ├── theme/                   # AppTheme 主题配置
│   └── utils/                   # 日期/货币工具函数
├── data/
│   ├── database/               # SQLite 数据库助手、表定义
│   ├── models/                  # Expense, Category, ExpenseSummary
│   └── repositories/           # 增删改查操作
├── providers/                   # Riverpod 状态管理
├── screens/                    # Home, Expense, Summary, Category 页面
└── widgets/                    # 可复用组件

test/
├── unit/                       # 模型、仓库、提供者 单元测试
├── widget/                     # 页面和组件测试
└── integration/               # 完整增删改查流程集成测试
```

### 技术栈
- **状态管理**: Riverpod (flutter_riverpod)
- **数据库**: sqflite + SQLite 本地持久化
- **架构**: 清洁架构 (UI / 业务逻辑 / 数据层分离)

### 核心模型
- `Expense`: id, title, amount, categoryId, date, note, timestamps
- `Category`: id, name, icon, colorValue, createdAt
- `ExpenseSummary`: periodStart, periodEnd, totalAmount, byCategory, expenseCount

## 依赖

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

## 配置文件

- `pubspec.yaml` — 依赖和 Flutter SDK 版本约束
- `analysis_options.yaml` — 代码规范检查规则
- `agent.ts` — Claude Agent SDK，用于自主开发
