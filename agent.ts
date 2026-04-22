import { query } from "@anthropic-ai/claude-agent-sdk";

/**
 * Expense Planner Agent
 *
 * Reads plan.md and executes each phase sequentially.
 * After each phase, runs verification commands.
 */

const PLAN_FILE = "plan.md";
const PHASES = [
  {
    name: "阶段 1: 项目初始化",
    tasks: [
      "添加依赖: flutter_riverpod, sqflite, path_provider, intl, equatable 到 pubspec.yaml",
      "创建目录结构: lib/core/constants, lib/core/theme, lib/core/utils, lib/data/database, lib/data/models, lib/data/repositories, lib/providers, lib/screens, lib/widgets",
      "创建 lib/core/constants/app_colors.dart 定义颜色常量",
      "创建 lib/core/constants/app_spacing.dart 定义间距常量",
      "创建 lib/core/theme/app_theme.dart 配置 MaterialTheme"
    ]
  },
  {
    name: "阶段 2: 数据层",
    tasks: [
      "创建 lib/data/models/expense.dart - Expense 模型",
      "创建 lib/data/models/category.dart - Category 模型",
      "创建 lib/data/models/expense_summary.dart - ExpenseSummary 模型",
      "创建 lib/data/database/database_helper.dart - SQLite 单例助手",
      "创建 lib/data/database/tables.dart - 表创建 SQL",
      "创建 lib/data/repositories/expense_repository.dart - Expense CRUD",
      "创建 lib/data/repositories/category_repository.dart - Category CRUD"
    ]
  },
  {
    name: "阶段 3: 状态管理",
    tasks: [
      "创建 lib/providers/database_provider.dart - 数据库实例提供者",
      "创建 lib/providers/expense_provider.dart - Expense StateNotifier",
      "创建 lib/providers/category_provider.dart - Category StateNotifier",
      "创建 lib/providers/summary_provider.dart - 汇总计算提供者",
      "更新 lib/main.dart 配置 Riverpod 和路由"
    ]
  },
  {
    name: "阶段 4: 核心 UI",
    tasks: [
      "创建 lib/widgets/expense_tile.dart - 支出列表项组件",
      "创建 lib/widgets/category_chip.dart - 分类标签组件",
      "创建 lib/widgets/summary_card.dart - 汇总卡片组件",
      "创建 lib/widgets/empty_state.dart - 空状态组件",
      "创建 lib/screens/home/home_screen.dart - 首页仪表盘",
      "实现 BottomNavigation 底部导航 (Home, Expenses, Summary, Categories)"
    ]
  },
  {
    name: "阶段 5: 支出功能",
    tasks: [
      "创建 lib/screens/expense/expense_list_screen.dart - 支出列表页",
      "创建 lib/screens/expense/add_expense_screen.dart - 添加/编辑支出表单",
      "创建 lib/screens/expense/expense_detail_screen.dart - 支出详情页",
      "实现日期和分类筛选功能"
    ]
  },
  {
    name: "阶段 6: 汇总功能",
    tasks: [
      "创建 lib/screens/summary/summary_screen.dart - 汇总页面",
      "实现日/周/月周期切换",
      "实现分类支出可视化"
    ]
  },
  {
    name: "阶段 7: 分类功能",
    tasks: [
      "创建 lib/screens/category/category_list_screen.dart - 分类列表页",
      "创建 lib/screens/category/add_category_screen.dart - 添加/编辑分类表单",
      "实现图标和颜色选择器"
    ]
  },
  {
    name: "阶段 8: 测试与完善",
    tasks: [
      "创建 test/unit/models/ 单元测试",
      "创建 test/widget/ 组件测试",
      "创建 test/integration/ 集成测试",
      "添加错误处理和加载状态",
      "运行 flutter analyze 检查代码"
    ]
  }
];

async function run() {
  console.log("🚀 Expense Planner Agent 启动\n");
  console.log(`📋 读取计划文件: ${PLAN_FILE}\n`);

  // Build prompt from plan phases
  const prompt = `你是 Expense Planner 项目的自主开发智能体。

项目计划定义在 ${PLAN_FILE} 文件中。请按照以下阶段顺序执行：

${PHASES.map((phase, i) => `
## ${phase.name}
${phase.tasks.map(task => `- ${task}`).join("\n")}
`).join("\n")}

## 执行要求

1. 按阶段顺序执行，每个阶段完成所有任务后再进入下一阶段
2. 每完成一个阶段，运行以下验证命令：
   - flutter analyze（检查代码错误）
   - flutter test（运行测试）
3. 验证通过后再继续下一阶段
4. 如果验证失败，修复问题后重新验证
5. 所有阶段完成后，运行 flutter run 验证应用可正常运行

## 工具使用

使用以下工具完成开发：
- Read, Edit, Write, Glob - 读写和编辑文件
- Bash - 运行 flutter analyze, flutter test, flutter run 等命令

## 权限模式

使用 permissionMode: "acceptEdits" 自动批准文件编辑。

现在开始执行第一阶段。`;

  console.log("开始自主开发...\n");
  console.log("=".repeat(50) + "\n");

  let phaseIndex = 0;
  for await (const message of query({
    prompt,
    options: {
      allowedTools: ["Read", "Edit", "Write", "Glob", "Bash", "WebSearch"],
      permissionMode: "acceptEdits"
    }
  })) {
    if (message.type === "assistant" && message.message?.content) {
      for (const block of message.message.content) {
        if ("text" in block) {
          const text = block.text as string;
          // Highlight phase changes
          if (text.includes("阶段") || text.includes("Phase")) {
            console.log(`\n📦 ${text}\n`);
          } else {
            console.log(text);
          }
        } else if ("name" in block) {
          console.log(`\n🔧 Tool: ${(block as any).name}\n`);
        }
      }
    } else if (message.type === "result") {
      const subtype = (message as any).subtype;
      console.log(`\n${"=".repeat(50)}`);
      console.log(`✅ 阶段完成: ${subtype}`);
      phaseIndex++;
      if (phaseIndex < PHASES.length) {
        console.log(`\n📋 准备执行: ${PHASES[phaseIndex].name}\n`);
      } else {
        console.log("\n🎉 所有阶段执行完成！\n");
      }
    }
  }
}

run().catch(console.error);
