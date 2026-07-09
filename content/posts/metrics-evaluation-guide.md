---
title: "Metrics：传闻中的评估指标"
date: 2026-07-08T21:00:00+08:00
description: "分类、回归、聚类常用评估指标速查手册"
tags: ["Metrics", "机器学习", "评估指标", "sklearn", "AUC", "ROC"]
categories: ["技术分享"]
---

模型训完了，怎么评价它好不好？这篇文章梳理了分类、回归、聚类中常见的评估指标，附带公式、sklearn 调用方式和优缺点对比，方便随时查阅。

---

## 基础单元：混淆矩阵四兄弟

一切分类指标的起点——TP、TN、FP、FN。

| 名称 | 含义 | 公式 / 备注 |
|------|------|-------------|
| **TP** (True Positive) | 真阳性 — 实际正类且预测正类 | 混淆矩阵原始单元，透明度最高 |
| **TN** (True Negative) | 真阴性 — 实际负类且预测负类 | 同上 |
| **FP** (False Positive) | 假阳性 — 实际负类但预测正类 | 同上（I 类错误） |
| **FN** (False Negative) | 假阴性 — 实际正类但预测负类 | 同上（II 类错误） |

```python
from sklearn.metrics import confusion_matrix
```

---

## 分类指标

### MCC — 马修斯相关系数

$$
\text{MCC} = \frac{TP \times TN - FP \times FN}{\sqrt{(TP+FP)(TP+FN)(TN+FP)(TN+FN)}}
$$

- 范围 $[-1, 1]$，$1$ 为完美预测，$0$ 为随机，$-1$ 为完全不一致
- **优势**：样本比例悬殊时仍能提供客观评估，是二分类最全面的单一指标
- **缺陷**：计算逻辑相对复杂

```python
from sklearn.metrics import matthews_corrcoef
```

### ACC — 准确率

$$
\text{ACC} = \frac{TP+TN}{TP+FP+FN+TN}
$$

- **优势**：简单直观
- **缺陷**：样本不均衡时失效（99% 负类，全猜负就有 0.99）

```python
from sklearn.metrics import accuracy_score
```

### Precision — 精确率（查准率）

$$
\text{Precision} = \frac{TP}{TP+FP}
$$

- 预测为正的样本中，有多少真的是正类
- **优势**：预测结果可信度高；**缺陷**：与 Recall 博弈，忽略漏诊风险

```python
from sklearn.metrics import precision_score
```

### Recall — 召回率（查全率）

$$
\text{Recall} = \frac{TP}{TP+FN}
$$

- 真正的正类中，有多少被模型找出来了
- **优势**：捕捉能力强；**缺陷**：误报多时 Precision 偏低

```python
from sklearn.metrics import recall_score
```

### F1-score — F1 值

$$
F_1 = 2 \times \frac{\text{Precision} \times \text{Recall}}{\text{Precision} + \text{Recall}} = \frac{2 \cdot TP}{2 \cdot TP + FP + FN}
$$

- 范围 $[0,1]$，Precision 和 Recall 的调和平均
- **优势**：数据不均衡时比 ACC 更合理；**缺陷**：忽略 TN

```python
from sklearn.metrics import f1_score
```

### ROC 曲线

ROC 由点 $(FPR, TPR)$ 构成：

$$
FPR = \frac{FP}{FP+TN}, \quad TPR = \frac{TP}{TP+FN}
$$

- 曲线越接近左上角，区分能力越强
- **优势**：Precision-Recall 平衡，评价全面；**缺陷**：极度不均衡时需结合 PR 曲线

```python
from sklearn.metrics import roc_curve
```

### AUC — ROC 曲线下面积

$$
\text{AUC} = \int_0^1 ROC(x)\,dx \quad \text{（常用梯形法近似）}
$$

- 范围 $[0.5, 1]$，$0.5$ 为随机猜测
- **优势**：对类别不平衡有一定鲁棒性，评估整体排序能力
- **缺陷**：不反映概率校准程度；不同形状的 ROC 曲线 AUC 可能相同

```python
from sklearn.metrics import roc_auc_score
```

### Micro AUC — 微观平均 AUC

将多分类拆为多个二分类，所有样本合并为整体计算全局 AUC。

- **优势**：少数类别影响被保留；**缺陷**：多数类别主导结果

```python
micro_auc = roc_auc_score(y_true, y_score, multi_class='ovr', average='micro')
```

### Macro AUC — 宏观平均 AUC

$$
\text{Macro AUC} = \frac{1}{n}\sum_{i=1}^{n} AUC_i
$$

- **优势**：关注整体系统性能；**缺陷**：噪声类别影响被放大

```python
macro_auc = roc_auc_score(y_true, y_score, multi_class='ovr', average='macro')
```

### DeLong Test — DeLong 检验

检验同一测试集上两个模型的 AUC 差异是否具有统计显著性。

$$
Z = \frac{AUC_1 - AUC_2}{\sqrt{Var(AUC_1) + Var(AUC_2) - 2Cov(AUC_1, AUC_2)}}
$$

- **优势**：提供了统计显著性校验；**缺陷**：只适用于 AUC 对比，计算繁琐

```python
from mlxtend.evaluate import delong_roc_test
```

---

## 回归指标

### MSE — 均方误差

$$
MSE = \frac{1}{n}\sum (y_{\text{true}} - y_{\text{pred}})^2
$$

- **优势**：处处可导，深度学习最优损失函数
- **缺陷**：对异常值惩罚极重，偏离数据容易带偏模型

```python
from sklearn.metrics import mean_squared_error
```

### RMSE — 均方根误差

$$
RMSE = \sqrt{MSE}
$$

- **优势**：解决了 MSE 单位与原始目标不一致的问题
- **缺陷**：同样受异常值影响

```python
rmse = np.sqrt(mean_squared_error(y_true, y_pred))
```

### MAE — 平均绝对误差

$$
MAE = \frac{1}{n}\sum |y_{\text{true}} - y_{\text{pred}}|
$$

- **优势**：对异常值不敏感，比 MSE/RMSE 更稳健
- **缺陷**：零点处不可导，优化难度略高

```python
from sklearn.metrics import mean_absolute_error
```

### MAD — 中位数绝对偏差

$$
MAD = \text{median}( |y_{\text{true}} - y_{\text{pred}}| )
$$

- 常与 MAE 混用
- **优势**：对异常值敏感度强于 MSE；**缺陷**：无法反映全局误差分布

### MAPE — 平均绝对百分误差

$$
MAPE = \frac{100\%}{n} \sum \left| \frac{y_i - \hat{y}_i}{y_i} \right|
$$

- **优势**：无量纲百分比，支持跨量纲比较
- **缺陷**：真值为 $0$ 时失效，天然倾向压低预测值

```python
from sklearn.metrics import mean_absolute_percentage_error
```

### R² — 决定系数

$$
R^2 = 1 - \frac{\sum (y_{\text{true}} - y_{\text{pred}})^2}{\sum (y_{\text{true}} - \bar{y})^2}
$$

- 衡量模型对数据波动的解释能力
- **优势**：关心数据走势而非绝对误差大小；**缺陷**：无法判定过拟合

```python
from sklearn.metrics import r2_score
```

### Adjusted R² — 调整后 R²

$$
R^2_{\text{adj}} = 1 - \frac{(1 - R^2)(n - 1)}{n - p - 1}
$$

- 引入样本量 $n$ 和特征数 $p$ 作为惩罚项
- **优势**：只有新特征显著提升效果时指标才增加，防止冗余特征浑水摸鱼

### SSE — 误差平方和

$$
SSE = \sum_i \sum_{x \in C_i} ||x - \mu_i||^2
$$

- 聚类中衡量簇内紧密度，也用于回归分析的方差计算
- **优势**：统计分析基础项；**缺陷**：随样本量线性累加，不可跨数据集比较

```python
from sklearn.metrics import mean_squared_error  # 回归中使用
```

### AIC / BIC — 赤池 / 贝叶斯信息准则

$$
AIC = 2k - 2\ln L
$$

$$
BIC = k\ln n - 2\ln L
$$

| | AIC | BIC |
|------|-----|-----|
| **目标** | 预测未知数据能力最强的模型 | 寻找生成数据的"真实模型" |
| **惩罚力度** | 较弱，大样本下易选复杂模型 | 较强，可能导致欠拟合 |

```python
import statsmodels.api as sm
```

---

## 聚类指标

### Si — 轮廓系数

$$
Si = \frac{1}{n}\sum s(i), \quad s(i) = \frac{b(i) - a(i)}{\max\{a(i), b(i)\}}
$$

- $a(i)$：样本 $i$ 到同簇其他样本的平均距离（紧密度）
- $b(i)$：样本 $i$ 到最近其他簇的平均距离（分离度）
- 范围 $[-1, 1]$，越接近 $1$ 聚类效果越好

```python
from sklearn.metrics import silhouette_score
```

---

## 模型选择

### K-Fold CV — K 折交叉验证

$$
\text{CV Score} = \frac{1}{K}\sum_{i=1}^{K} \text{Score}_i
$$

- **优势**：评估泛化能力，避免单次划分带来的偶然性
- **缺陷**：计算量是单次训练 ×K

```python
from sklearn.model_selection import KFold
```

---

## 速查表

| 场景 | 首选指标 | 搭配指标 |
|------|---------|---------|
| 二分类（均衡） | ACC | F1 + AUC |
| 二分类（不均衡） | MCC | AUC + F1 |
| 多分类 | Macro F1 | Micro F1 |
| 回归（含异常值） | MAE | R² |
| 回归（无异常值） | RMSE | R² |
| 聚类 | Si (轮廓系数) | SSE |
| 模型选择 | K-Fold CV | AIC / BIC |
| AUC 对比 | DeLong Test | — |

---

写到最后还是那句老话：**没有最好的指标，只有最适合当前场景的指标。** 实际项目中，通常需要多个指标联合判断——单一数字永远无法讲完整故事。
