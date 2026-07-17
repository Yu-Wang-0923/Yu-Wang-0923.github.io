---
title: "CC Switch：让 Codex 拥有多个大脑"
date: 2026-07-17T12:00:00+08:00
description: "从 Clash Verge、Codex Plus 登录到 DeepSeek V4 Flash 与 Kimi K3 本地路由的完整配置。"
tags: ["CC Switch", "Codex", "AI", "LLM", "工具"]
categories: ["工具"]
draft: false
---

Codex 很强，但它不必永远只用同一个“大脑”。这篇文章记录我的实际配置：先通过 Clash Verge 完成官方 Codex Plus 登录，再用 CC Switch 接入 `deepseek-v4-flash` 和 `kimi-k3`。

写业务代码时，我可能更看重稳定和工具调用；读长文档时，希望上下文更大；做简单修改时，又想用一个便宜、响应快的模型。问题在于：每换一次供应商，就手改一次 `~/.codex/config.toml`，既麻烦，也很容易把 API 地址、模型名或密钥写错。

[CC Switch](https://github.com/farion1231/cc-switch) 就是解决这个问题的。它是一款免费、开源、跨平台的桌面工具，可以集中管理 Codex、Claude Code、Gemini CLI、OpenCode 等 AI 编程工具的供应商配置。

对我来说，它最直观的价值是：**Codex 还是那个 Codex，但背后的模型可以按任务切换。**

## “多个大脑”是什么意思？

Codex 可以通过不同的模型供应商运行。每个供应商配置通常包含：

- API 地址（Base URL）
- API Key 或官方登录信息
- 模型名称
- API 协议及其他参数

不用 CC Switch 时，这些内容散落在配置文件里；用了 CC Switch 后，可以把它们保存成多个独立方案：

| 使用场景 | 可以选择的“大脑” |
|---|---|
| 复杂重构、Agent 长任务 | 推理和工具调用能力更强的模型 |
| 阅读论文、大型代码库 | 长上下文模型 |
| 改文案、补注释、小修复 | 速度快、成本低的模型 |
| 某个接口临时不可用 | 备用供应商 |

CC Switch 做的并不是同时调用一群模型，而是把“换供应商、换模型、换账号”变成一次可回退的切换。

## 准备工作

项目唯一官方渠道是：

- 官网：[ccswitch.io](https://ccswitch.io)
- 源码：[farion1231/cc-switch](https://github.com/farion1231/cc-switch)
- 下载：[GitHub Releases](https://github.com/farion1231/cc-switch/releases)

macOS 可以用 Homebrew：

```bash
brew install --cask cc-switch
```

Windows、Linux 用户可以直接在 Releases 页面选择对应的安装包。安装前最好确认下载地址来自官方仓库，不要把 API Key 或账号密码交给来历不明的网站。

除此之外，还需要准备：

- 已安装的 Codex App 或 Codex CLI
- 可以正常使用 Codex 的 ChatGPT Plus 账号
- DeepSeek 与 Kimi 对应的 API Key
- Clash Verge，以及一条可用的美国节点

## 第一部分：配置 Clash Verge，登录官方 Codex

### 1. 选择节点

打开 Clash Verge，选择一条可用的**美国节点**。

节点不一定延迟越低越好，关键是出口稳定，并且能够正常访问 ChatGPT 和 Codex。切换节点后可以先在浏览器中打开 ChatGPT，确认登录页和对话功能正常。

![选择美国节点，开启系统代理并将代理模式设为规则](/images/cc-switch-guide/clash-system-proxy-rule.png)

### 2. 修改 Clash Verge 设置

按下面的配置开启代理：

- **代理模式**：`Rule`
- **系统代理**：启用
- **DNS 覆写**：打开
- **IPv6**：禁用
- **DNS Listen**：改为 `:1053`
- **TUN 模式**：启用

先进入设置，打开 DNS 覆写并关闭 IPv6：

![打开 DNS 覆写并关闭 IPv6](/images/cc-switch-guide/clash-dns-ipv6.png)

点击“虚拟网卡模式”右侧的齿轮，进入 TUN 详细设置：

![进入虚拟网卡模式设置](/images/cc-switch-guide/clash-tun-settings-entry.png)

将 DNS 劫持的监听地址设为 `any:1053`，保存配置：

![将 DNS 劫持监听地址改为 any:1053](/images/cc-switch-guide/clash-dns-listen-1053.png)

回到首页，打开“虚拟网卡模式”：

![启用 Clash Verge 虚拟网卡模式](/images/cc-switch-guide/clash-enable-tun.png)

完整状态可以记成：

```text
美国节点
  → Rule 模式
  → 系统代理
  → DNS 覆写（:1053）
  → 关闭 IPv6
  → TUN 模式
```

TUN 模式首次开启时，系统可能要求安装或授权网络扩展。修改 DNS 监听端口后，如果出现域名无法解析，可以先确认 `1053` 没有被其他程序占用，再重启 Clash Verge。

### 3. 用 default 完成 Plus 登录

打开 CC Switch，进入顶部的 **Codex** 页面，选择 **default**，也就是官方 Codex 配置，然后点击“启用”。

![在 CC Switch 中选择 Codex 的 default 配置](/images/cc-switch-guide/cc-switch-codex-providers.png)

此时不要开启 CC Switch 的 Codex 本地路由。关闭并重新启动 Codex，选择 **Sign in with ChatGPT**，在浏览器中使用 ChatGPT Plus 账号登录，并完成授权回跳。

登录成功后，Codex 会把官方认证信息保存在：

```text
~/.codex/auth.json
```

不要把这个文件上传到 GitHub，也不要把内容复制给别人。现在先用官方模型发起一次简单对话，确认 Codex 能正常回复，再继续配置第三方模型。

> `default` 的作用不仅是登录，也是回退入口。第三方模型配置出错时，先关闭本地路由，再切回 `default`，就能重新使用官方 Codex。

## 第二部分：配置 DeepSeek V4 Flash 与 Kimi K3 路由

Codex 原生使用 OpenAI Responses API，而 DeepSeek、Kimi 等上游通常提供 Chat Completions API。两者协议不同，直接把第三方地址写进 Codex，容易出现 `/responses` 404、模型列表不显示或流式响应异常。

CC Switch 的本地路由负责双向转换：

```text
Codex Responses 请求
        ↓
CC Switch 本地路由
        ↓
DeepSeek / Kimi Chat Completions
        ↓
转换回 Codex Responses 响应
```

### 1. 添加 DeepSeek V4 Flash

在 CC Switch 中进入 **Codex → 添加供应商**，优先选择内置的 DeepSeek 预设，然后填写：

![从 CC Switch 预设中选择 DeepSeek 或 Kimi](/images/cc-switch-guide/cc-switch-add-provider.png)

- **名称**：`DeepSeek V4 Flash`
- **API Key**：填入自己的 DeepSeek Key
- **模型**：`deepseek-v4-flash`
- **上游格式**：`Chat Completions（需开启路由）`
- **需要本地路由映射**：启用

Base URL 优先保留 CC Switch 预设值。如果使用的是第三方平台，则按该平台的控制台填写，不要把 `/chat/completions` 整段路径写进 Base URL。

保存后先不要急着启动 Codex。

### 2. 添加 Kimi K3

再次进入 **Codex → 添加供应商**，选择 Kimi 预设或自定义供应商，然后填写：

- **名称**：`Kimi K3`
- **API Key**：填入自己的 Kimi Key
- **模型**：`kimi-k3`
- **上游格式**：`Chat Completions（需开启路由）`
- **需要本地路由映射**：启用

Kimi 开放平台 Key 与 Kimi For Coding Key 的 API 地址不同，不能混用。使用内置预设时，选与 Key 来源相匹配的配置；使用自定义供应商时，以对应控制台给出的 Base URL 为准。

> `deepseek-v4-flash` 和 `kimi-k3` 是本文使用的模型标识。模型名可能随供应商、套餐或发布时间变化，最终应以控制台或 `/v1/models` 返回的真实 ID 为准。

### 3. 开启 CC Switch 本地路由

进入：

```text
设置 → 路由 → 本地路由
```

也可以先在首页打开“显示本地路由开关”，然后使用顶部的快捷开关：

![在 CC Switch 首页启用本地路由快捷开关](/images/cc-switch-guide/cc-switch-enable-local-route.png)

依次完成：

1. 打开**路由总开关**。
2. 保持监听地址为默认的 `127.0.0.1:15721`，除非该端口冲突。
3. 在“路由启用”中打开 **Codex**，让 CC Switch 接管 Codex 请求。
4. 回到 Codex 供应商列表，启用 `DeepSeek V4 Flash` 或 `Kimi K3`。
5. 完全退出并重新启动 Codex。

![打开路由总开关并启用 Codex 路由](/images/cc-switch-guide/cc-switch-route-codex.png)

这里有两个不同的端口，不要混淆：

| 端口 | 所属工具 | 用途 |
|---|---|---|
| `:1053` | Clash Verge | DNS 覆写监听 |
| `127.0.0.1:15721` | CC Switch | Codex 本地路由与协议转换 |

### 4. 验证路由

重启 Codex 后输入 `/model`，确认能看到当前供应商的模型。然后发送一个简单任务，并同时观察：

- CC Switch 路由面板的请求数是否增加；
- 当前供应商是否为刚才启用的 DeepSeek 或 Kimi；
- 对应平台的用量记录是否出现新请求；
- Codex 是否仍能正常流式输出和调用工具。

切换 DeepSeek 与 Kimi 时，先在 CC Switch 中点击目标供应商的“启用”，再重启 Codex，以便重新加载 `config.toml` 和模型目录。

## 可选：第三方模型下保留官方登录态

如果还希望在使用第三方 API 时保留 Codex 官方插件、远程操作或账号识别，可以进入：

```text
设置 → 通用 → Codex 应用增强
```

开启**切换第三方时保留官方登录**。这样官方 Plus 登录信息继续留在 `auth.json`，第三方供应商信息写进 `config.toml`，模型流量则经过 CC Switch 本地路由。

Codex 界面此时仍可能显示官方账号，这是预期行为；真正的模型和计费方要看 CC Switch 当前供应商、路由日志以及第三方平台的用量记录。

## 需要注意的地方

**第一，CC Switch 是配置管理器，不会凭空提供模型额度。** 你仍然需要对应供应商的账号、订阅或 API Key。

**第二，第三方中转服务需要谨慎选择。** 代码、提示词和上下文可能经过对方服务器，不要把公司私有代码、密钥或敏感数据发送给不可信的服务。

**第三，切换后通常要重启 Codex。** 如果仍然显示旧模型，先关闭当前 Codex 会话并重新启动，再检查激活的供应商、路由开关和模型名。

**第四，先保留官方配置。** 折腾第三方接口前，给现有配置留一条明确的回退路径。

## 结语

CC Switch 没有改变 Codex 的交互方式，却把模型选择从“改配置文件”变成了“按任务选工具”。

现在我的 Codex 有三条清晰的路径：`default` 负责官方 Plus，`DeepSeek V4 Flash` 负责快速任务，`Kimi K3` 作为另一个可切换的大脑。

以前我会问：今天要不要用 Codex？现在我更常问：**这个任务，应该让 Codex 用哪个大脑？**

当模型、价格、速度和可用性不断变化时，这种可切换、可备份、可回退的工作流，比绑定在单一配置上更从容。

---

参考资料：[CC Switch 官方仓库](https://github.com/farion1231/cc-switch) · [官方用户手册](https://github.com/farion1231/cc-switch/tree/main/docs/user-manual/zh) · [Codex DeepSeek 路由攻略](https://github.com/farion1231/cc-switch/blob/main/docs/guides/codex-deepseek-routing-guide-zh.md) · [Codex Kimi 路由攻略](https://github.com/farion1231/cc-switch/blob/main/docs/guides/codex-kimi-routing-guide-zh.md)
