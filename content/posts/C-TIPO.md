---
title: "C-TIPO: 一种使用 AI Agent 的提示词模板"
date: 2026-07-08T17:00:00+08:00
draft: false
tags:
  - AI
  - prompt-engineering
  - 方法论
  - ECG
  - 科研
categories:
  - 技术分享
---

## 什么是 C-TIPO？

C-TIPO 是一种结构化的提示词模板，全称是 **Context → Task → Input → Process → Output**。它借鉴了计算机科学的输入-处理-输出模型，专为 AI Agent 设计，能够清晰传达任务的完整上下文和执行路径。

## 模板结构

```markdown
## Context（背景）
描述当前状态、为什么需要做这件事、相关的约束条件。

## Task（任务）
一句话说明要完成的目标。

## Input（输入）
提供给 AI 的原材料、数据、参考资料。

## Process（过程）
明确的执行步骤或思考链。

## Output（输出）
期望的输出格式、结构、交付物。
```

## 为什么有效？

### 1. 消除歧义

很多模糊的指令源于缺少上下文。C-TIPO 强制在 `Context` 中说明背景，让 AI Agent 能做出更符合预期的判断。

### 2. 过程可控

`Process` 是关键——它不是告诉 AI "做什么"，而是告诉 AI "怎么做"。这对于需要多步推理的复杂任务尤其重要。

### 3. 输出结构化

`Output` 定义了最终交付物的格式，无论是 Markdown、JSON、CSV 还是图像，AI Agent 都能精准产出。

## 真实案例：心电信号（ECG）研究项目

以下展示 C-TIPO 在一个真实的科研项目中的应用——从数据获取、特征工程到建模的完整流程。

### 案例 1：获取数据集

```markdown
## Context
- 需要获取 MIMIC 数据库的汉化项目

## Task
- 获取 MIMIC 汉化项目库

## Input
- https://github.com/liuxinyuan123/MIMIC_database_translation_project

## Process
- 克隆项目库到本地

## Output
- D:\Yu\idopECG\information\mimic_database_translation_project
```

### 案例 2：数据调查

```markdown
## Context
- 需要了解 MDS-ED 数据集的字段含义
- 参考 MIMIC 汉化项目中的翻译信息

## Task
- 将数据集各字段分组并翻译为中文

## Input
- E:\Data\ECG\MDS-ED-HierMultiClass\src\data\memmap\mds_ed.csv
- D:\Yu\idopECG\information\mimic_database_translation_project

## Process
1. 用 Pandas 读取 CSV
2. 按前缀分组（general_、demographics_、biometrics_ 等）
3. 对照汉化项目逐一翻译

## Output
- D:\Yu\idopECG\output\MDS-ED数据集调查\general.csv
- D:\Yu\idopECG\output\MDS-ED数据集调查\demographics.csv
- D:\Yu\idopECG\output\MDS-ED数据集调查\biometrics.csv
- ...
```

### 案例 3：信号处理（平稳小波变换去噪）

```markdown
## Context
- ECG 信号含有噪声，需要平滑处理
- 参考梳理.tex 中的方法

## Task
- 对指定 study_id 的 ECG 数据进行平稳小波变换去噪

## Input
- subject_id = "12298456"
- study_id = "49574353"
- D:\Yu\idopECG\data\{subject_id}\{subject_id}.csv

## Process
1. 从 CSV 提取 study_id 对应的 ECG 路径
2. 采用 SWT（平稳小波变换）去噪
   - 小波基：rbio3.9
   - 分解层数 L = 2
   - 阈值方式：soft（软阈值）
   - 噪声估计：MAD / 0.6745
   - 阈值公式：α·σ·√(2logN)，α = 0.5
3. 可视化 II 导联前 2.5 秒的结果

## Output
- D:\Yu\idopECG\output\res_idopECG\拟合\lead_II.png
  （离散观测值用黑色空心圆点，拟合曲线用红色实线）
```

### 案例 4：变量选择（Group Lasso）

```markdown
## Context
- 需要从 12 导联 ECG 中识别导联间的相互作用
- 参考梳理.tex 中的变量选择方法

## Task
- 获取指定 study_id 的全部 12 导联支撑集

## Input
- subject_id = "12298456"
- study_id = "49574353"
- D:\Yu\idopECG\data\{subject_id}\{subject_id}.csv

## Process
1. 通过 Legendre 基函数展开获取平滑 ECG（R = 3）
2. 候选源导联：除目标导联外 11 个导联
3. 设计矩阵 1000 × (11 × (R + 1))
4. 响应 dxⱼ(t)/dt 由中心差分法计算
5. 组大小校正权重 w_g = √(2logN)
6. 正则化参数 α = 0.05 × max(α)
7. 求解器：FISTA

## Output
- D:\Yu\idopECG\output\res_idopECG\变量选择\support_set.csv
  （lead, r2, alpha, w_g, support_set）
```

### 案例 5：ODE 求解与效应分解

```markdown
## Context
- 需要将 ECG 信号分解为自身效应和交互效应
- 参考梳理.tex 中的 ODE 优化求解方法

## Task
- 获取指定 study_id 的 ODE 求解结果

## Input
- subject_id = "12298456"
- study_id = "49574353"
- D:\Yu\idopECG\data\{subject_id}\{subject_id}.csv

## Process
1. 通过 SWT 获取平滑 ECG
2. 通过 Group Lasso 获取变量选择结果
3. 傅里叶基函数截断阶数 N = 30
4. Legendre 基函数截断阶数 R = 3
5. 求解 ODE，分解自身效应和交互效应

## Output
- lead_II_ode.png（观测值 vs 预测曲线，效应分解图）
- effect.csv（time, self_I, II_to_I, ...）
- network_from_to.csv（from, to, effect_mean, effect_type）
- network_from_to.png（有向图网络，按出度力学布局）
```

### 案例 6：GLMy 拓扑特征提取

```markdown
## Context
- 参考 GLMy 论文中的方法提取拓扑特征
- H_p 正确计算需 p+2 维路径；dim=4 可计算 H₀, H₁, H₂
- β₀：底层网络连通分支数
- β₁：特定方向闭环数
- β₂：更高阶有向空腔数

## Task
- 从 idopECG 网络特征中提取 GLMy 特征

## Input
- subject_id = "12298456"
- study_id = "49574353"
- D:\Yu\idopECG\output\idopECG_all\feature_network_integral.npy

## Process
1. 从 feature_network_integral.npy 获取网络特征
2. 按正负权重分开处理
3. 计算持续同调条形码

## Output
- glmy_barcodes.csv（study_id, sign, dimension, birth, death, persistence）
- glmy_features.csv（各维度的有限/无限条形码计数）
- glmy_idop.png（3×3 条形码图，together/positive/negative）
```

### 案例 7：机器学习消融实验

```markdown
## Context
- 需要评估不同特征组合对分类性能的贡献
- 参考 MDS-ED 文章中的实验设计
- 心内/心外疾病组 + 人群亚组

## Task
- 完成机器学习消融实验

## Input
- mds_ed.csv, memmap.npy
- glmy_features.npy, feature_network_integral.npy
- 心内/心外疾病标签，人群亚组划分

## Process
- 对比 7 种特征组合：
  - ECG features only
  - idopNet only / integral only
  - GLMy (together/positive/negative) only
  - 两两组合
- 指标：AUROC

## Output
- 消融实验.csv（所有组合的 AUROC 对比）
- 两两散点对比图
```

## 模板使用要点

| 要素 | 说明 | 常见误区 |
|------|------|---------|
| **Context** | 说明背景、约束、参考材料 | 缺少领域知识，AI 产出偏离预期 |
| **Task** | 一句话明确目标 | 目标模糊，AI 不确定要做什么 |
| **Input** | 提供完整输入数据和参考 | 遗漏关键依赖文件或路径 |
| **Process** | 方法、参数、步骤 | 只告诉"做什么"不告诉"怎么做" |
| **Output** | 格式、路径、内容示例 | 输出不规范导致后续流程断裂 |

## 总结

C-TIPO 的核心理念是 **好输入 = 好输出**。在我的研究项目中，每个任务（从数据获取、信号处理、变量选择、ODE 求解到 GLMy 特征提取和消融实验）都用 C-TIPO 模板描述，AI Agent 能准确理解需求、使用正确的参数和方法、输出标准化格式，大幅减少了沟通成本和返工时间。

下次使用 AI Agent 时，不妨试试 C-TIPO 模板。
