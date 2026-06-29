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

### 🛒 从已登录后台导出数据

你的 Safari 已经登着拼多多/淘宝卖家中心、飞书后台、Google Analytics。不用重登，直接抓。

```
> 帮我把拼多多后台近 30 天订单导出为 CSV

safari_navigate("卖家中心 → 订单管理")
safari_fill("input[name=start]", "2026-06-01")    # 你的登录态，不用重登
safari_click("查询")
safari_scroll × 5                                  # 自动翻页
safari_evaluate(extract_orders)                    # 提取 500 条 → CSV
✅ 原来 2 小时的手工活，30 秒
```

### 🛡️ 爬 Cloudflare 保护的网站

ProductHunt、G2、很多 SaaS 官网都有 Cloudflare。Playwright 卡在 "Just a moment..."，Safari 的 `native_click` 直接过。

```
> 把 ProductHunt AI 话题前 20 个工具抓出来

safari_navigate("producthunt.com/topics/ai")
safari_scroll(× 5)          # Cloudflare 没拦，直接加载
safari_evaluate → 20 条结构化数据
✅ 姓名、票数、简介、链接，8 秒
```

### ✍️ 填富文本编辑器不丢内容

Notion、飞书文档、Medium 用 ProseMirror/Slate，`fill()` 改了 DOM 但框架状态没变，提交时内容是空的。`native_type` 走剪贴板，框架自动同步。

```
> 帮我把这篇 3000 字草稿填进 Notion

safari_native_type(value=全文, selector=".ProseMirror")
safari_verify_state → ✅ 3000 字全部同步
```

### 📊 批量多站点比价

同时开 3 个 Safari 标签页，分别搜同一商品，一次提取所有价格。

```
> 同时查京东、淘宝、拼多多的 iPhone 16 Pro 价格

safari_navigate("京东搜索")
safari_evaluate → ¥7999
safari_new_tab("淘宝搜索")
safari_evaluate → ¥7899
safari_new_tab("拼多多搜索")
safari_evaluate → ¥7699
✅ 三平台价格对比，15 秒
```

### 🔐 自动化 GitHub 操作

连 GitHub Settings 这种有 sudo 模式保护的页面也能操作。

```
> 帮我建一个带 repo + workflow scope 的 GitHub Token

safari_navigate("github.com/settings/tokens/new")
safari_fill(note="my-token")
safari_evaluate(check_scope_boxes)
safari_click("Generate token")
✅ 全自动，不用手动点 20 个 checkbox
```

### 📋 更多

| 场景 | 说明 | 示例文件 |
|------|------|---------|
| 定时监控页面变化 | 价格变动、库存更新自动通知 | `templates/monitor.md` |
| PWA 审计 | 检查网站在 iOS Safari 上的表现 | `references/tools-reference.md#webkit` |
| 表单批量提交 | 自动填 100 条数据进后台 | `templates/form.md` |

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
