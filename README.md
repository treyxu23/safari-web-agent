<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/banner.svg">
  <source media="(prefers-color-scheme: light)" srcset="assets/banner.svg">
  <img alt="Safari Web Agent — 用你真实的 Safari 浏览器做网页自动化" src="assets/banner.svg" width="100%">
</picture>

[![SKILL.md Valid](https://github.com/treyxu23/safari-web-agent/actions/workflows/validate.yml/badge.svg)](https://github.com/treyxu23/safari-web-agent/actions/workflows/validate.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform: macOS](https://img.shields.io/badge/platform-macOS-lightgrey)](https://github.com/achiya-automation/safari-mcp)
[![Hermes Skill](https://img.shields.io/badge/Hermes-Skill-blue)](https://github.com/nousresearch/hermes-agent)

---

**中文** | [English](#english)

## 🤔 痛点

你让 AI Agent "帮我抓一下这个网站的数据"或"帮我填这个表单"。它用 Playwright/Puppeteer 去搞：

```
❌ "请先登录"               → 没 Cookie，全新浏览器，验证码地狱
❌ "验证你是人类..."         → Cloudflare 把无头 Chrome 拦了
❌ 表单看着填好了，提交却是空的 → ProseMirror 框架状态没同步，发了旧数据
```

## 🦊 解法

**Safari Web Agent** — 一个 Hermes Skill，操控你**真实的 Safari 浏览器**。

```bash
# 你的 Safari 已经登录了 Gmail、Notion、GitHub、飞书、淘宝……
# Safari 的原生事件（CGEvent）跟人手点击没区别，反爬直接过
# 剪贴板粘贴（Cmd+V）走真实 paste 管线，框架状态自动同步

$ hermes
> 帮我把 ProductHunt 前 10 个 AI 工具的名字和票数抓出来

safari_navigate → 已打开
safari_snapshot  → 找到 24 个工具
safari_evaluate  → [ {name: "Claude Code", votes: "▲2,847", ...}, ... ]
✅ 10 条数据，8 秒搞定
```

## 🎯 适合谁

| 你是 | 你能用它做什么 |
|------|--------------|
| 🧑‍💻 macOS 开发者 | 从需要登录的后台/仪表盘自动导出数据 |
| 📊 数据采集者 | 爬 Cloudflare 保护的网站，其他工具全挂 |
| ✍️ 内容创作者 | 自动填 Notion/飞书/Medium 的长文，不会丢内容 |
| 🧪 QA/测试 | 在真实 Safari 上做端到端测试 + PWA 审计 |
| 🤖 AI Agent 用户 | 给 Hermes/Claude Code 装上「眼睛和手」 |

不是给你的：❌ Windows/Linux 用户 ❌ 需要跑在 CI 服务器上的 ❌ 简单 API 调用的（用 curl 就行）

## ⚡ 快速 Demo

![Terminal Demo](assets/demo-terminal.svg)

```javascript
// ProductHunt 抓取 — 直接过 Cloudflare
safari_navigate("https://producthunt.com/topics/ai")
safari_wait(2000)
safari_scroll("down", 600)
safari_evaluate(`
  Array.from(document.querySelectorAll('[data-test="post-item"]'))
    .slice(0, 10).map(el => ({
      name: el.querySelector('[data-test="post-name"]')?.textContent,
      votes: el.querySelector('[data-test="vote-count"]')?.textContent,
      tagline: el.querySelector('[data-test="post-tagline"]')?.textContent
    }))
`)
// → [{ name: "Claude Code", votes: "▲2,847", tagline: "..." }, ...]
```

## 🆚 对比其他工具

| 维度 | Safari Web Agent | Playwright | browser-use | camofox-mcp | Puppeteer | Selenium |
|------|:---:|:---:|:---:|:---:|:---:|:---:|
| **登录态** | ✅ 真实已登录 | ❌ | ❌ | ⚠️ 手动导 cookie | ❌ | ❌ |
| **Cloudflare** | ✅ 原生 CGEvent | ❌ | ❌ | ⚠️ Firefox 仍被检测 | ❌ | ❌ |
| **反爬（DataDome）** | ✅ 真人级别 | ❌ | ❌ | ⚠️ 指纹随机化有限 | ❌ | ❌ |
| **富文本编辑器** | ✅ 剪贴板粘贴 | ❌ DOM fill | ❌ DOM fill | ❌ DOM fill | ❌ DOM fill | ❌ DOM fill |
| **CSP 阻断** | ✅ AppleScript 降级 | ❌ | ❌ | ❌ | ❌ | ❌ |
| **安装体积** | 0（Safari 预装） | ~500MB | ~600MB | ~400MB | ~400MB | ~300MB |
| **WebKit 真机** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **跨平台** | ❌ 仅 macOS | ✅ | ✅ | ✅ | ✅ | ✅ |
| **CI/CD** | ❌ 需 GUI | ✅ | ✅ | ⚠️ 需 GUI | ✅ | ✅ |

> Safari Web Agent 不跟它们在无头浏览器赛道卷。它做的事，其他工具**做不到**。

## 🛠️ 能做什么

不是「理论上可以」，是**实际跑过的**。

### 1. 从已登录的网站抓数据

Playwright 开的是全新浏览器，没 Cookie。你的 Safari **已经登着**几十个网站——Gmail、Notion、GitHub、飞书、各种后台。直接导航到数据页，跳过登录。

```javascript
// 用户说的：
> 帮我把 ProductHunt 今天 AI 话题前 10 个工具的信息抓出来

// Skill 实际执行的：
safari_navigate("https://www.producthunt.com/topics/ai")
// → 页面加载完成。你的 Safari 已经过 Cloudflare，没被拦。

safari_snapshot()
// → 返回页面结构，找到 24 个 [data-test="post-item"] 元素

safari_scroll("down", 600)   // 往下滚，加载更多
safari_scroll("down", 600)

safari_evaluate(`
  JSON.stringify(
    Array.from(document.querySelectorAll('[data-test="post-item"]'))
      .slice(0, 10)
      .map(el => ({
        rank:    el.querySelector('[data-test="post-rank"]')?.textContent,
        name:    el.querySelector('[data-test="post-name"]')?.textContent?.trim(),
        votes:   el.querySelector('[data-test="vote-count"]')?.textContent?.trim(),
        tagline: el.querySelector('[data-test="post-tagline"]')?.textContent?.trim(),
        url:     el.querySelector('a[data-test="post-name"]')?.href
      })),
    null, 2
  )
`)

// 返回真实数据：
[
  {
    "rank": "1",
    "name": "Claude Code",
    "votes": "▲ 2,847",
    "tagline": "AI coding agent that writes and runs code",
    "url": "https://www.producthunt.com/posts/claude-code"
  },
  // ... 9 more
]
```

**为什么 Playwright 不行**：ProductHunt 有 Cloudflare 保护。Playwright 的无头 Chrome 会被卡在「验证你是人类」的页面。Safari 是真浏览器，`native_click` 产生 `isTrusted: true` 的原生事件，Cloudflare 直接放行。

### 2. 填富文本编辑器，提交不丢内容

Notion、飞书、Linear、Medium 都用 ProseMirror / Slate / Draft.js。这些编辑器在 JS 内存里维护一棵**状态树**——改 DOM 没用，框架不认。

```javascript
// ❌ 所有人第一反应都是这个——但它会丢内容：
safari_fill(selector=".ProseMirror", value="今天的工作总结：\n1. 完成了需求文档...")
// DOM 看着填上了，但 ProseMirror 内部状态树没变
// 点「发布」→ 发出去的是旧内容或空内容

// ✅ 正确做法：走系统剪贴板粘贴（Cmd+V）
safari_native_type(
  value="今天的工作总结：\n1. 完成了需求文档 v2\n2. 修复了 3 个线上 bug\n3. 开始设计新功能架构",
  selector=".ProseMirror"
)
// safari_native_type 通过 macOS CGEvent 触发真实的 Cmd+V
// → ProseMirror 的 handlePaste 钩子被触发
// → 内部状态树更新 → dispatchTransaction 发射
// → DOM 和框架状态完全同步

// 验证——这个不能省：
safari_verify_state(selector=".ProseMirror", expected="今天的工作总结")
// → { match: true, mode: "prosemirror", actual: "今天的工作总结：\n1. ..." }

// 现在可以提交了
safari_native_click(text="发布")
```

**对比**：Playwright 的 `page.fill()` 和 Selenium 的 `sendKeys()` 都是改 DOM——ProseMirror 不认。`safari_native_type` 是目前**唯一**走真实 paste 管线、触发框架内部钩子的方案。

### 3. 批量操作 + 多标签页

一个任务里同时开多个页面，各干各的，互不干扰。

```javascript
// 用户说的：
> 京东、淘宝、拼多多分别搜 iPhone 16 Pro 256G，把价格列出来

// Safari MCP 实际执行：
safari_navigate("https://search.jd.com/Search?keyword=iPhone+16+Pro+256G&enc=utf-8")
safari_wait_for(selector=".gl-item")                             // 等搜索结果加载
safari_evaluate(`
  document.querySelector('.gl-item .p-price i')?.textContent
`)  
// → "7999.00"

safari_new_tab("https://s.taobao.com/search?q=iPhone+16+Pro+256G")
safari_wait_for(selector=".price")
safari_evaluate(`document.querySelector('.price strong')?.textContent`)
// → "7899"

safari_new_tab("https://mobile.yangkeduo.com/search_result.html?search_key=iPhone+16+Pro+256G")
safari_wait_for(selector=".price")
safari_evaluate(`document.querySelector('.goods-price')?.textContent`)
// → "7699"
```

每个标签页独立运行，订单数据、搜索结果、后台报表……可以同时抓。

### 4. 连 GitHub Settings 都能自动化

GitHub 的 Token 管理页面有 **sudo 模式**——查看/创建 Token 前必须邮件验证。连这种页面也能操作（只要验证环节由你手动完成）。

```javascript
> 帮我建一个 Personal Access Token，要 repo + workflow 权限

safari_navigate("https://github.com/settings/tokens/new")
// → 页面要求验证身份（sudo mode）。手动点「Verify via email」，收验证码，填进去。

safari_fill(ref="note_input", value="my-project-token")

// 用 JS 批量勾选 scope（不用手动点 20 个 checkbox）
safari_evaluate(`
  ["repo", "workflow", "read:org", "user"].forEach(scope => {
    const cb = document.querySelector('input[value="' + scope + '"]');
    if (cb && !cb.checked) { cb.checked = true; cb.dispatchEvent(new Event("change", {bubbles: true})); }
  })
  // → 4 个 checkbox 全部勾上
`)

safari_click(text="Generate token")
safari_evaluate(`document.querySelector('.js-token-field')?.textContent?.trim()`)
// → "ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

---

> 💡 更多场景和完整代码见 [examples/](examples/) 和 [templates/](templates/)。

## 📦 安装

### ⚡ 30 秒上手

```bash
npm install -g safari-mcp
# Safari → 设置 → 扩展 → 启用 "Safari MCP"
# 系统设置 → 隐私 → 自动化 → 允许终端控制 Safari
# 搞定。下面是详细步骤，遇到问题再看。
```

### 一键安装脚本
curl -fsSL https://raw.githubusercontent.com/treyxu23/safari-web-agent/main/scripts/install.sh | bash

# 或手动
npm install -g safari-mcp     # MCP 服务器
# Safari → 设置 → 扩展 → 启用 "Safari MCP"
# 系统设置 → 隐私与安全性 → 自动化 → 允许终端控制 Safari
# 系统设置 → 隐私与安全性 → 辅助功能 → 允许终端
```

### 接入 Hermes

`~/.hermes/profiles/<profile>/config.yaml`:

```yaml
mcp_servers:
  safari:
    command: npx
    args:
    - safari-mcp
    enabled: true
    timeout: 120
```

安装 Skill：

```bash
git clone https://github.com/treyxu23/safari-web-agent.git \
  ~/.hermes/profiles/<profile>/skills/safari-web-agent/
```

## 🎯 使用场景

1. **登录态抓取** — 从你已经登录的网站提取数据（后台、卖家中心、CRM）
2. **反爬绕过** — 原生事件过 Cloudflare/DataDome/Akamai
3. **富文本编辑器** — 正确填写 Notion/Medium/飞书文档
4. **Safari 兼容性测试** — PWA 审计、viewport 验证、WebKit CSS 检查
5. **页面监控** — 定时检查页面变化、Web Vitals

## 📚 文档

| 文件 | 内容 |
|------|------|
| [SKILL.md](SKILL.md) | 核心 Skill — 触发条件、工作流、常见坑 |
| [references/tools-reference.md](references/tools-reference.md) | Safari MCP 96 个工具完整目录 |
| [references/anti-detection.md](references/anti-detection.md) | 反爬绕过技术手册 |
| [references/workflow-patterns.md](references/workflow-patterns.md) | 可复用的自动化模式 |
| [examples/](examples/) | 真实场景示例 |
| [REAL-WORLD.md](REAL-WORLD.md) | 真实使用案例 |
| [CONTRIBUTING.md](CONTRIBUTING.md) | 贡献指南 |
| [CHANGELOG.md](CHANGELOG.md) | 版本记录 |

---

## English

### What is this?

A **Hermes Agent Skill** that gives AI agents the power to control your real Safari browser — with your login sessions, cookies, and native macOS events that bypass anti-bot detection.

Most web automation tools (Playwright, Puppeteer, Selenium) launch a fresh headless browser. They fail on:
- 🔐 Login-walled sites (no cookies → re-auth → CAPTCHA)
- 🛡️ Anti-bot pages (Cloudflare blocks headless Chrome)
- ✍️ Rich text editors (DOM fill ≠ framework state sync)

Safari Web Agent solves all three.

### Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/treyxu23/safari-web-agent/main/scripts/install.sh | bash
```

### Comparison

| Feature | Safari Web Agent | Playwright | browser-use | camofox-mcp | Puppeteer | Selenium |
|---------|:---:|:---:|:---:|:---:|:---:|:---:|
| **Login sessions** | ✅ Real, logged in | ❌ | ❌ | ⚠️ Manual cookie | ❌ | ❌ |
| **Cloudflare bypass** | ✅ Native CGEvent | ❌ | ❌ | ⚠️ Firefox detected | ❌ | ❌ |
| **Anti-bot (DataDome)** | ✅ Human-level | ❌ | ❌ | ⚠️ Limited fingerprinting | ❌ | ❌ |
| **Rich text editors** | ✅ Native paste | ❌ DOM fill | ❌ DOM fill | ❌ DOM fill | ❌ DOM fill | ❌ DOM fill |
| **CSP fallback** | ✅ AppleScript | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Install size** | 0 (Safari built-in) | ~500MB | ~600MB | ~400MB | ~400MB | ~300MB |
| **WebKit testing** | ✅ Real Safari | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Cross-platform** | ❌ macOS only | ✅ | ✅ | ✅ | ✅ | ✅ |
| **CI/CD** | ❌ Needs GUI | ✅ | ✅ | ⚠️ Needs GUI | ✅ | ✅ |

> Safari Web Agent doesn't compete in headless browser space. It does things no other tool **can**.

---

## License

MIT

## Credits

Built on [Safari MCP](https://github.com/achiya-automation/safari-mcp) by Achiya Automation.  
Inspired by [playwright-skill](https://github.com/lackeyjb/playwright-skill) and the Claude Code Skills ecosystem.
