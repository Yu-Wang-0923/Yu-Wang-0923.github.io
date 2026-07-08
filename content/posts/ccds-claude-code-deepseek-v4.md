---
title: "CCDS: Claude Code + DeepSeek v4 经验"
date: 2026-07-08T19:00:00+08:00
description: "Claude Code 搭配 DeepSeek v4 的使用经验"
tags: ["Claude Code", "DeepSeek", "CCDS", "AI", "工具"]
categories: ["工具"]
---

[Claude Code](https://claude.ai/code) 是 Anthropic 官方的 CLI Agent，默认使用 Claude 模型。但你可以在 Settings 里把它换成 DeepSeek v4（或其他兼容 OpenAI API 的模型）。

## 安装

安装主要分两步：装 Claude Code + 配 DeepSeek 模型。

参考官方文档：[Claude Code 集成 DeepSeek](https://api-docs.deepseek.com/zh-cn/quick_start/agent_integrations/claude_code)

## /model 切换

装好后在 Claude Code 对话中键入 `/model`，会列出可用模型列表，用方向键选择和回车确认即可。每次切换只对当前会话生效（除非选了 Set default）。

搭配 DeepSeek v4 的优势：

- **价格更低**：token 成本大约 Claude 的 1/10
- **上下文窗口大**：适合处理大型代码库
- **速度尚可**：日常编码够用

## Shift+Tab 模式切换

Claude Code 底部状态栏显示当前工作模式，按 **Shift+Tab** 循环切换：

| 模式 | 状态栏 | 说明 |
|------|--------|------|
| **Auto Mode** | `⏵⏵ auto mode on` | Claude 自主执行，不逐一询问 |
| **Manual Mode** | `⏸ manual mode on` | 每次操作前询问确认 |
| **Accept Edits** | `⏵⏵ accept edits on` | 自动接受文件修改 |
| **Plan Mode** | `⏸ plan mode on` | 只规划不执行，适合先讨论方案 |

用 Shift+Tab 在这些模式间循环，根据当前任务灵活切换。比如需要快速批量操作时用 Auto Mode，涉及重要修改时切 Manual Mode 逐条确认。

### Shift+Tab 选择文件

除了切换模式，Shift+Tab 还有一个功能：在对话中按 Shift+Tab 会弹出文件选择器，可以用方向键和空格键勾选要包含的文件，回车确认后 Claude Code 就只基于这些文件工作。

对于 monorepo 或大项目特别有用——不用把全部代码塞进上下文，节省 token 也提升回答精度。

---

后面想到什么再更新。
