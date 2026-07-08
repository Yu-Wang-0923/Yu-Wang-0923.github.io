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

```bash
pip install mineru-open-sdk
```

```python
from mineru import MinerU

# Flash Mode — 零配置，免费，单文件 ≤20 页
client = MinerU()
result = client.flash_extract("paper.pdf")
with open("paper.md", "w", encoding="utf-8") as f:
    f.write(result.markdown)
```

公式变 LaTeX、表格变 Markdown、多栏按阅读顺序排列。AI 直接能读。

> 篇幅更长或精度要求更高 → 申请免费 token 用 Precision Mode（200MB/600页），输出 MD/DOCX/HTML/LaTeX/JSON。

## 下游任务举例

**翻译**：把 Markdown 丢给 Claude → 保留公式和格式的中文版。

**RAG 上下文**：多篇论文转 Markdown 后向量化，统一检索问答。

---

等我有空了再往深写。参考：[MinerU 官网](https://mineru.net) · [GitHub](https://github.com/opendatalab/MinerU) · [Python SDK](https://pypi.org/project/mineru-open-sdk/)
