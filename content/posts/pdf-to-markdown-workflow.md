---
title: "MinerU: 让AI爽看PDF"
date: 2026-07-08T18:00:00+08:00
description: "PDF→Markdown/LaTeX，让AI看懂论文"
tags: ["MinerU", "PDF", "Markdown", "LaTeX", "LLM", "工作流"]
categories: ["工具"]
---

学术论文是 PDF 格式的——对 AI 来说这很糟糕。分页打断、多栏错乱、公式变图片，Claude/GPT 用 PDF 效果大打折扣。

[MinerU](https://mineru.net) 是上海 AI 实验室开源的文档解析引擎，能把 PDF 转为 AI 友好的 Markdown / LaTeX / JSON：

```
下载 PDF → MinerU 解析 → Markdown → AI 翻译 / RAG / 问答
```

## 快速上手

打开 [mineru.net](https://mineru.net)，上传 PDF，一键导出 Markdown 或 LaTeX。

公式自动转 LaTeX、表格变 Markdown、多栏按阅读顺序排列。AI 直接能读。

> 也支持 API / Python SDK / CLI / MCP Server，进阶用法按需选。

## 下游任务举例

**翻译**：把 Markdown 丢给 Claude → 保留公式和格式的中文版。

**RAG 上下文**：多篇论文转 Markdown 后向量化，统一检索问答。

---

等我有空了再往深写。参考：[MinerU 官网](https://mineru.net) · [GitHub](https://github.com/opendatalab/MinerU) · [Python SDK](https://pypi.org/project/mineru-open-sdk/)
