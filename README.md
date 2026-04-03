# PM Antd Prototype Skill

让产品经理通过 Claude Code 自然语言描述需求，严格使用 Ant Design 组件库，快速生成可运行的 React 前端原型。

## 安装

```bash
git clone https://github.com/hxppk/pm-antd-prototype.git ~/.claude/skills/pm-antd-prototype
```

安装后重启 Claude Code 即可使用。

## 使用

在项目目录下输入 `/pm-prototype`，或直接说"生成原型"、"前端原型"等触发。

## 工作流程

1. **启动引导** — 引导 PM 准备参考材料（老系统截图、PRD 文档）
2. **项目初始化** — 自动创建 Vite + React + TypeScript + antd 项目
3. **需求整理** — 自然语言描述 → 结构化需求文档 → PM 确认
4. **组件选型 + 代码生成** — 从 antd 组件库选型 → PM 确认 → 生成代码 + mock 数据
5. **代码校验** — 自动检查是否严格符合 antd 规范，输出校验报告
6. **迭代调整** — PM 继续对话调整，每次重新校验

## 核心规则

- 禁止自定义 CSS / styled-components / inline style
- 禁止用 div/span 做布局，必须用 antd 的 Layout/Row/Col/Flex/Space
- 禁止自己实现 antd 已有的功能
- 所有交互反馈必须用 antd 的 message/notification/Modal.confirm
- 生成代码前必须读 `.d.ts` 确认 props 真实存在
- 超出 antd 能力范围的实现必须标注，提示需 UI 介入确认

## 更新

```bash
cd ~/.claude/skills/pm-antd-prototype && git pull
```

## 许可

MIT
