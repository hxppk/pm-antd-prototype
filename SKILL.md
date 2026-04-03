---
name: pm-antd-prototype
description: >
  Use when PM wants to generate frontend prototypes from requirements using Ant Design components.
  Triggers: /pm-prototype, "生成原型", "antd 原型", "前端原型", "需求转界面", "用 antd 做页面".
  Generates runnable React + antd prototypes with mock data from natural language descriptions.
---

# PM Antd 原型生成

从产品需求到可运行的 antd React 原型。严格使用 Ant Design 组件库，禁止自定义样式。

## 子命令

- `/pm-prototype version` — 读取 skill 目录下的 `VERSION` 文件，显示版本号。如果 template/ 已存在，同时读取 `template/node_modules/antd/package.json` 显示 antd 版本。
- `/pm-prototype update-template` — 在 `~/.claude/skills/pm-antd-prototype/template/` 目录执行 `npm update`，更新所有依赖到最新版，完成后显示更新后的 antd 版本。

如果用户输入包含以上子命令关键词（version、update-template），执行对应操作后直接结束，不进入原型生成流程。

## 启动引导 + 项目初始化

skill 启动后，**自动完成项目初始化，PM 无需任何手动操作**。每个需求都是一个独立的新项目文件夹。

### 模板机制

skill 目录下维护一个预装好依赖的 template/ 文件夹，新项目直接复制，无需重新下载 npm 包。

**首次运行（无 template/）：**

1. 在 skill 目录下创建模板：
   ```bash
   npm create vite@latest ~/.claude/skills/pm-antd-prototype/template -- --template react-ts
   cd ~/.claude/skills/pm-antd-prototype/template
   npm install antd react-router-dom
   ```
2. 清空 Vite 默认文件，写入脚手架模板（见 references/scaffold-templates.md）：
   - 删除 `src/App.css`、`src/index.css`、`src/assets/`
   - 写入 `src/layouts/BasicLayout.tsx`（antd Layout 骨架）
   - 写入 `src/App.tsx`（路由 + antd ConfigProvider）
   - 写入 `src/main.tsx`（入口）
   - 创建 `src/pages/` 和 `src/mock/` 空目录
3. 创建参考材料目录：`mkdir -p references/screenshots references/prd`
4. `npm run dev` 验证能启动，确认无编译错误后停止 dev server
5. 提示 PM：模板已创建完成，后续新建项目将秒级完成

**后续运行（已有 template/）：**

1. 询问 PM 项目名称（或从需求关键词自动生成，如"用户管理"→ `user-management`）
2. **必须用 Bash 工具执行以下命令，不可跳过：**
   ```bash
   cp -r ~/.claude/skills/pm-antd-prototype/template/ ./<项目名>
   ```
3. **必须用 Bash 工具切换到项目目录：**
   ```bash
   cd ./<项目名>
   ```
4. **必须用 Bash 工具验证文件夹结构已就绪：**
   ```bash
   ls -la src/ references/
   ```
   确认 `src/layouts/`、`src/pages/`、`src/mock/`、`references/screenshots/`、`references/prd/` 都存在后，才能继续。

**⚠️ 严禁跳过上述 Bash 命令。必须先执行复制、切换目录、验证文件夹结构，确认成功后才能展示引导。**

### 初始化完成后展示引导

上述命令全部执行成功后，向 PM 展示以下使用指南，等待 PM 回复：

~~~
项目 <项目名> 已创建完成！

我已为你创建了参考材料文件夹：

references/
├── screenshots/   ← 把老系统界面截图放这里（.png / .jpg）
└── prd/           ← 把 PRD 参考文档放这里（.md / .pdf）

如果是改造老系统模块：
  请把相关界面截图放到 references/screenshots/
  把相关 PRD 文档放到 references/prd/
  放好后告诉我，我会参考这些材料来理解现有设计

如果是全新项目：
  不需要放任何文件，直接描述你的需求即可

准备好了吗？请描述你想要的页面或功能。
~~~

PM 回复后，进入阶段二。

## 阶段二：需求整理

### 读取参考材料（强制）

**如果 `references/screenshots/` 或 `references/prd/` 下有文件，必须全部读取，不可跳过。**

1. 检查 `references/screenshots/` 是否有图片文件，**有则必须逐一读取**（Claude Code 支持读取图片）
2. 检查 `references/prd/` 是否有 `.md` 或 `.pdf` 文件，**有则必须逐一读取**
   - `.md` 文件直接读取
   - `.pdf` 文件使用 Read 工具读取（Claude Code 原生支持 PDF）
   - **如果 PDF 读取失败**（常见于 Windows，报错 `pdftoppm` 或 `poppler` 缺失），向 PM 提示以下解决方案：
     ```
     PDF 读取失败，可能缺少 poppler 工具。请安装后重试：

     Windows (推荐 scoop):
       scoop install poppler

     Windows (手动):
       1. 从 https://github.com/oschwartz10612/poppler-windows/releases 下载
       2. 解压后将 bin 目录添加到系统 PATH
       3. 重启终端

     macOS:
       brew install poppler

     Linux:
       sudo apt install poppler-utils

     安装后重新运行 /pm-prototype 即可。
     或者，你也可以将 PDF 转为 .md 文件放到 references/prd/ 下。
     ```
3. 结合参考材料和 PM 的自然语言描述，理解需求全貌

### 从截图中提取导航结构

截图中包含的菜单信息（顶部导航、左侧菜单、面包屑等）通常不会出现在 PM 的口头描述中，但对原型至关重要。读取截图后，必须：

1. **识别顶部导航栏** — 提取菜单项名称和层级
2. **识别左侧菜单** — 提取菜单项名称、层级和父子关系
3. **识别面包屑** — 推断页面在导航中的位置
4. **将提取的导航结构写入需求文档** — 作为单独的「导航结构」章节
5. **更新 BasicLayout.tsx 的菜单配置** — 在代码生成时，将提取的菜单结构写入 Header Menu 和 Sider Menu

### 输出结构化需求文档

将需求整理为以下格式，输出到 `src/pages/<PageName>/README.md`：

~~~markdown
# <页面名称>

## 导航结构（从截图提取）
- 顶部导航：首页 | 画布管理 | 系统设置
- 左侧菜单：
  - 画布列表
  - 画布分类
  - 回收站

## 功能点
- 功能 1：一句话描述
- 功能 2：一句话描述
- ...

## 数据字段
| 字段名 | 类型 | 说明 |
|--------|------|------|
| name   | string | 用户姓名 |
| ...    | ...  | ...  |

## 交互说明
- 点击「新增」按钮 → 弹出新增表单弹窗
- 填写表单后点击「确定」→ 关闭弹窗，表格新增一行
- ...
~~~

### 确认门控

将需求文档内容展示给 PM，询问：
- 是否有遗漏的功能点？
- 字段清单是否完整？
- 交互流程是否正确？

PM 确认后，进入阶段三。

## 阶段三：组件选型 + 代码生成

### 组件选型

1. 读取 `src/pages/<PageName>/README.md` 中的需求文档
2. 读取 `node_modules/antd/es/` 下相关组件的 `.d.ts` 类型定义，确认可用组件和 props
3. 为每个功能点选定 antd 组件，输出选型清单给 PM 确认：

~~~
组件选型方案：

用户列表 → Table
  columns: name(Input), email(Input), role(Select)
  features: pagination, sorter

搜索区域 → Form + Row + Col
  字段: keyword(Input.Search), role(Select), status(Select)
  操作: 查询(Button primary), 重置(Button default)

新增用户 → Modal + Form
  字段: name(Input), email(Input), role(Select)
  操作: 确定(提交), 取消(关闭)

是否同意这个方案？
~~~

PM 确认后开始生成代码。

### 代码生成

按以下结构生成文件：

1. **页面组件** — `src/pages/<PageName>/index.tsx`
   - 所有 UI 严格使用 antd 组件（见硬规则）
   - 生成代码前，必须先读取对应 antd 组件的 `.d.ts` 确认 props 真实存在
   - 使用 TypeScript，定义清晰的接口类型

2. **Mock 数据** — `src/mock/<pageName>.ts`
   - 根据需求文档的字段清单生成合理的假数据
   - 导出为数组，页面组件直接 import 使用
   - **注意 import 路径**：页面组件在 `src/pages/<PageName>/index.tsx`，import mock 数据时路径为 `../../mock/<pageName>`（两层上级），不是 `../mock/<pageName>`

3. **路由注册** — 更新 `src/App.tsx`
   - 在 routes 数组中追加新页面的路由配置
   - 使用 React.lazy 懒加载页面组件

4. **菜单更新** — 更新 `src/layouts/BasicLayout.tsx`
   - 在 Menu items 中追加新页面的菜单项

生成完毕后，进入阶段四。

## 阶段四：代码校验

代码生成完毕后，自查所有新生成或修改的 `.tsx` 文件，逐项检查：

### 校验项

1. **自定义样式检查** — 扫描是否存在：
   - `import` 了任何 `.css` / `.less` / `.scss` 文件
   - 使用了 `styled-components` / `@emotion`
   - 使用了 `style={{...}}` inline style（antd 的 `style` prop 如 Content style={{ padding: 24 }} 除外，仅限 antd 组件自身的布局 style）
2. **裸 HTML 布局检查** — 扫描是否使用了 `<div>` `<span>` `<section>` 等做布局容器（作为 antd 组件子元素的文本包裹除外）
3. **组件来源检查** — 所有 UI 组件的 import 是否来自 `antd`（非 antd 的如 `react-router-dom` 的 `Link` 等工具性组件除外）
4. **Props 校验** — 对照 `node_modules/antd/es/` 下对应组件的 `.d.ts`，检查使用的 props 是否真实存在
5. **交互反馈检查** — 确认所有用户反馈（成功/失败/确认）使用了 antd 的 `message` / `notification` / `Modal.confirm`

### 输出校验报告

~~~
antd 规范校验报告：

✅ 自定义样式：未发现自定义 CSS / inline style
❌ 裸 HTML 布局：UserList.tsx:45 — <div className="search-bar"> 应改为 <Space> 或 <Flex>
✅ 组件来源：所有 UI 组件均来自 antd
✅ Props 校验：所有 props 与类型定义一致
✅ 交互反馈：全部使用 antd Message/Modal

发现 1 处违规，是否修复？
~~~

### 违规处理

- 有违规项 → 询问 PM 是否修复
  - PM 同意修复 → 修正代码，重新校验，再出报告
  - PM 跳过 → 保留当前代码，继续
- 全部通过 → 运行 `npm run dev`，提示 PM 在浏览器查看

校验通过后，进入阶段五。

## 阶段五：迭代调整

校验通过并运行 `npm run dev` 后，向 PM 展示以下引导：

~~~
原型已生成，你可以在浏览器中查看效果。

如果需要调整，直接告诉我，比如：
  - "表格加一列操作按钮，里面放编辑和删除"
  - "搜索区多加一个日期范围筛选"
  - "把新增弹窗改成抽屉（Drawer）"
  - "列表默认每页 20 条，不要 10 条"

每次调整后我会重新校验 antd 规范并给你报告。
~~~

### 迭代流程

1. PM 描述调整需求
2. 修改代码（仍遵守硬规则）
3. 重新执行阶段四（代码校验）
4. 输出校验报告 → PM 确认
5. 循环，直到 PM 满意

---

## antd 组件不覆盖时的降级策略

当 PM 的需求确实超出 antd 组件能力范围时（如复杂拖拽排序、自定义图表、特殊动画等），可以自由发挥实现，但必须：

1. **代码中明确标注**：在非 antd 代码块上方加注释
   ```tsx
   // ⚠️ 非 antd 组件：需 UI 确认
   ```
2. **校验报告中单独列出**：
   ~~~
   ⚠️ 非 antd 组件（需 UI 介入确认）：
     - DragSortList.tsx — 拖拽排序列表，antd 无对应组件，使用了 @dnd-kit
     - CustomChart.tsx — 漏斗图，antd 无图表组件，使用了 inline SVG
   ~~~
3. **询问 PM**：是否接受当前实现，还是先用 antd 近似方案替代，等 UI 介入后再调整

---

## 硬规则（贯穿全流程）

以下规则在所有阶段强制执行，无例外：

1. **禁止自定义样式** — 不允许写自定义 CSS、styled-components、inline style（antd 组件自身的布局 style prop 除外）
2. **禁止裸 HTML 布局** — 不允许用 `<div>` `<span>` 做布局容器，必须用 antd 的 Layout / Row / Col / Flex / Space
3. **禁止重造轮子** — 不允许自己实现 antd 已有的功能（弹窗、表格、表单、下拉选择等）
4. **反馈组件强制** — 所有交互反馈必须用 antd 的 message / notification / Modal.confirm
5. **Props 必须真实** — 生成代码前必须先读对应组件的 `node_modules/antd/es/<Component>/index.d.ts` 确认 props 存在
6. **非 antd 必须标注** — 任何超出 antd 能力范围的实现，必须在代码和校验报告中明确标注（见降级策略）
