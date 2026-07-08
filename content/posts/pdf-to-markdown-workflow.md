---
title: "学术PDF的AI工作流：用MinerU打通文献阅读与AI处理"
date: 2026-07-08
description: "从下载文献到MinerU解析，再到AI翻译与上下文注入——一套完整的学术PDF处理流水线"
tags: ["MinerU", "PDF", "Markdown", "LaTeX", "LLM", "工作流"]
categories: ["工具"]
---

## 痛点：PDF ≠ AI友好

学术论文的最终载体几乎永远是 **PDF**。PDF 保证了排版一致性、跨平台可读性，但对 AI Agent 来说，PDF 是一个糟糕的输入格式：

- ✅ 人类读 PDF：翻页、看图表、扫公式
- ❌ AI 读 PDF：文本可能被分页打断、多栏排版错乱、公式变成图片或乱码

让 Claude、GPT、本地 LLM 等 AI 真正理解一篇论文，第一步永远是把 PDF 转换成 AI 能消化的结构文本。这时就需要 **MinerU**。

## MinerU 是什么

[MinerU](https://mineru.net) 是由上海人工智能实验室（InternLM 团队）开发的开源文档解析引擎。它专门解决 PDF → Markdown / LaTeX / JSON 的高质量转换问题，尤其擅长：

- **公式 → LaTeX**：无论是行内公式还是独立公式块
- **表格 → HTML / Markdown**：跨页合并、复杂表头
- **多栏布局**：自动按阅读顺序拼接
- **扫描件 / 手写体**：OCR 双引擎（VLM + OCR），支持 109 种语言
- **自动去页眉页脚**：输出连贯的纯正文

目前提供两种使用模式：

| 模式 | 是否需要GPU | 文件限制 | 费用 |
|------|-------------|----------|------|
| **Flash Mode**（闪电模式） | 不需要，云端 | 10MB / 20页 | 免费 |
| **Precision Mode**（精准模式） | 不需要，云端 | 200MB / 600页 | 免费（需注册 token） |
| **Local Deploy**（本地部署） | 需要 8GB+ VRAM | 无限制 | 自付 GPU 成本 |

## 工作流全景

```
┌──────────┐    ┌──────────┐    ┌──────────────┐    ┌───────────────┐
│ 下载 PDF  │ → │ MinerU   │ → │ Markdown /   │ → │ 下游任务       │
│ (Arxiv等) │    │ 解析     │    │ LaTeX / JSON │    │ 翻译 / RAG /   │
└──────────┘    └──────────┘    └──────────────┘    │ AI 问答        │
                                                     └───────────────┘
```

下面我把每一步拆开来讲。

---

## 第一步：下载论文 PDF

以 arXiv 为例，一篇论文一般有两个 URL：

- 摘要页：`https://arxiv.org/abs/2305.10601`
- PDF：`https://arxiv.org/pdf/2305.10601`

用 Python 下载很简单：

```python
import requests

def download_arxiv_pdf(arxiv_id: str, output_path: str):
    url = f"https://arxiv.org/pdf/{arxiv_id}"
    resp = requests.get(url, stream=True)
    resp.raise_for_status()
    with open(output_path, "wb") as f:
        for chunk in resp.iter_content(chunk_size=8192):
            f.write(chunk)
    print(f"PDF saved to {output_path}")

download_arxiv_pdf("2305.10601", "paper.pdf")
```

其他常见来源类似：OpenReview、PubMed Central、IEEE 等都提供 PDF 直链。

---

## 第二步：MinerU 解析

### 快速尝鲜——Flash Mode

最省事的方式，连 API Key 都不需要：

```bash
pip install mineru-open-sdk
```

```python
from mineru import MinerU

client = MinerU()
result = client.flash_extract("paper.pdf")
# 输出 Markdown 文本
print(result.markdown[:1000])
# 或保存到文件
with open("paper.md", "w", encoding="utf-8") as f:
    f.write(result.markdown)
```

Flash Mode 的转换结果示例：

```markdown
## 3 Method

### 3.1 Preliminary

Let **x** ∈ ℝ^d be the input vector and *y* ∈ ℝ the target.
We define the loss function as

$$ \mathcal{L}(\theta) = \frac{1}{n} \sum_{i=1}^n \ell(f_\theta(x_i), y_i) $$

| Parameter | Description | Default |
|-----------|-------------|---------|
| *lr* | Learning rate | 1e-4 |
| *batch_size* | Batch size | 32 |
| *dropout* | Dropout ratio | 0.1 |
```

可以看到：公式被正确转为 LaTeX，表格转为 Markdown 表格，多栏文本按正确阅读顺序排列。这就是 AI 能直接消化的格式。

### 正式使用——Precision Mode

如果需要处理超过 20 页的论文或有更高精度要求，去 [mineru.net/apiManage/token](https://mineru.net/apiManage/token) 免费申请一个 token：

```python
client = MinerU("your-api-token-here")
result = client.extract(
    "paper.pdf",
    model="vlm",      # VLM 模型精度更高
    pages="1-20",     # 可指定页码范围
)
result.save_all("./output/")
```

输出目录结构：

```
output/
├── paper.md           # Markdown 完整版
├── paper_full.md      # 含元信息的 Markdown
├── paper.docx         # Word 文档
├── paper.html         # HTML 版
├── paper.tex          # LaTeX 源码
├── paper.json         # 结构化 JSON
└── images/            # 提取的图片
```

对于 AI 下游任务，**Markdown** 和 **JSON** 是最实用的两个格式。

---

## 第三步：下游任务

有了高质量的 Markdown，下游可以做的就很多了。

### 任务一：翻译为中文

用 Claude 或 GPT 翻译整篇论文：

```python
from openai import OpenAI

client = OpenAI()  # 支持任意兼容 OpenAI 的 API

with open("paper.md", "r", encoding="utf-8") as f:
    markdown = f.read()

response = client.chat.completions.create(
    model="claude-sonnet-5",
    messages=[
        {
            "role": "system",
            "content": "你是一位专业的学术翻译。将用户提供的英文论文翻译为中文。"
                       "保持学术严谨性，公式不翻译，专业术语在括号内标注英文。"
                       "保留所有 LaTeX 公式和 Markdown 格式。"
        },
        {"role": "user", "content": markdown}
    ],
    temperature=0.1  # 翻译不需要创造性
)

with open("paper_zh.md", "w", encoding="utf-8") as f:
    f.write(response.choices[0].message.content)
```

翻译结果保留了所有公式、表格、代码块，AI 只替换了正文语言。这样你可以**用母语快速通读一篇论文的核心内容**。

### 任务二：作为 AI Agent 的上下文

这是更高级的用法——把转换后的 Markdown 注入 AI Agent 的上下文，让 AI 回答论文相关问题：

```python
context_md = open("paper.md").read()

response = client.chat.completions.create(
    model="claude-sonnet-5",
    messages=[
        {
            "role": "user",
            "content": f"""以下是一篇学术论文的内容。请阅读并回答我的问题。

---论文开始---
{context_md}
---论文结束---

我的问题：这篇论文的主要贡献是什么？实验用了什么数据集？"""
        }
    ]
)
```

更实用的方式是做成 RAG 系统，将多篇论文向量化后统一检索：

```python
from openai import OpenAI

client = OpenAI()

# 读取多篇转换后的论文
papers = {}
for fname in ["paper1.md", "paper2.md", "paper3.md"]:
    with open(fname) as f:
        content = f.read()
    # 分块（每块约 1000 tokens）
    chunks = [content[i:i+3000] for i in range(0, len(content), 3000)]
    for chunk in chunks:
        resp = client.embeddings.create(
            model="text-embedding-3-small",
            input=chunk
        )
        # 存入向量数据库（如 Chroma、Qdrant 等）
        # vector_db.add(embedding=resp.data[0].embedding, text=chunk, metadata={"source": fname})

# 检索 + 回答
query = "这篇论文用了什么损失函数？"
query_emb = client.embeddings.create(
    model="text-embedding-3-small",
    input=query
).data[0].embedding
# results = vector_db.search(query_emb, top_k=3)
# ... 将检索结果拼入 prompt 即可
```

这样你就有了一个 **个人论文知识库**，可以同时向几十上百篇论文提问。

---

## 完整流水线 Demo

把以上步骤拼成一个函数：

```python
import requests
from mineru import MinerU

def paper_pipeline(arxiv_id: str, api_token: str = None):
    """一篇论文从下载到 AI 可读的完整流水线"""
    # 1. 下载
    pdf_path = f"{arxiv_id}.pdf"
    url = f"https://arxiv.org/pdf/{arxiv_id}"
    with open(pdf_path, "wb") as f:
        f.write(requests.get(url).content)
    print(f"✅ 下载完成: {pdf_path}")

    # 2. MinerU 解析
    client = MinerU(api_token) if api_token else MinerU()
    if api_token:
        result = client.extract(pdf_path)
    else:
        result = client.flash_extract(pdf_path)
    result.save_all(f"./{arxiv_id}_output/")
    print(f"✅ MinerU 解析完成")

    # 3. 返回 Markdown 路径
    md_path = f"./{arxiv_id}_output/{arxiv_id}.md"
    return md_path

# 一条命令跑完
md = paper_pipeline("2305.10601", "your-token")
print(f"Markdown ready: {md}")
```

---

## 什么时候用哪种模式

| 场景 | 推荐模式 | 原因 |
|------|----------|------|
| 看一篇 10 页以内的短文 | Flash Mode | 零配置，一次调用 |
| 整篇博士论文（>50页） | Precision Mode | 精度更高，文件上限宽裕 |
| 批量处理几十篇 | Precision Mode | 200MB / 600页限制 |
| 敏感数据不出内网 | Local Deploy | 完全离线 |
| 日常快速翻译 | Flash Mode | 速度足够 |
| 构建论文 RAG 知识库 | Precision Mode | 解析质量影响检索效果 |

## 小结

这个工作流的核心理念是：**用最适合的工具做最擅长的事**。

- PDF 适合人类阅读和排版传输
- MinerU 擅长把 PDF 无损转换为 AI 可读的结构文本
- AI（Claude / GPT）擅长理解、翻译、检索这些文本

三者组合，就形成了一条高效的学术文献处理流水线：

> **下载 → MinerU 解析 → Markdown → AI 翻译 / RAG 问答**

对于每天需要追踪大量论文的研究者来说，这能节省大量时间。你不再需要一篇篇从头读到尾，而是可以先让 AI 帮你筛选和理解，再决定深入精读哪些。

## 参考资源

- [MinerU 官网](https://mineru.net)
- [MinerU GitHub](https://github.com/opendatalab/MinerU)
- [MinerU Python SDK](https://pypi.org/project/mineru-open-sdk/)
- [免费 API Token](https://mineru.net/apiManage/token)
- [MinerU MCP Server](https://pypi.org/project/mineru-open-mcp/)（可与 Claude Desktop 集成）
