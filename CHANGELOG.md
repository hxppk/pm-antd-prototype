# Changelog

## [1.2.0] - 2026-04-07

### Added

- **GitHub Pages 在线预览发布** — PM 满意后可一键发布到 GitHub Pages，生成 `https://<用户名>.github.io/<仓库名>/` 预览链接，支持后续更新发布
- **GitHub 登录前置检查** — 发布前自动检测 `gh auth status`，未登录时引导 PM 完成 GitHub 注册 + CLI 安装 + 登录

## [1.1.0] - 2026-04-07

### Fixed

- **[Critical] 项目复制后无法启动** — `cp -r` 改为 `cp -a`，保留 `node_modules/.bin/` 符号链接，修复生成项目 `npm run dev`/`lint`/`tsc` 全部失败的问题
- **[High] 路径注入风险** — 用户指定的项目路径现在必须用双引号包裹，防止空格或 shell 特殊字符导致命令出错或执行意外操作
- **[Medium] 脚手架默认菜单指向死链** — 模板 `BasicLayout.tsx` 的菜单改为空数组，代码生成阶段再根据需求填充，避免点击菜单项跳转到不存在的路由
- **项目创建到错误位置** — 项目默认创建在 `~/projects/<项目名>`（而非当前工作目录），创建前向 PM 确认路径，创建后展示完整路径并支持迁移
- **模板创建步骤缺少强制标注** — 首次运行的 bash 命令块添加 `必须` 强制执行语
- **需求文档示例与 section 检测冲突** — 代码块内的示例标题从 `##` 改为 `###`，避免干扰 SKILL.md 结构解析

### Added

- `scripts/lint-skill.sh` — SKILL.md 流程缺陷检查脚本，用于 autoresearch 自动化验证
- 路径确认门控 — 创建项目前向 PM 展示预设路径，支持自定义和迁移
- Windows 安装说明（PowerShell / Git Bash）

## [1.0.0] - 2026-04-06

### Added

- 初始版本发布
- 五阶段工作流：项目初始化 → 需求整理 → 组件选型+代码生成 → 代码校验 → 迭代调整
- Template 机制：预装依赖的模板目录，新项目秒级复制
- 六条硬规则：禁止自定义样式、禁止裸 HTML 布局、禁止重造轮子、反馈组件强制、Props 必须真实、非 antd 必须标注
- antd 组件不覆盖时的降级策略
- 截图导航结构提取
- PDF 读取失败的跨平台提示
- `/pm-prototype version` 和 `/pm-prototype update-template` 子命令
