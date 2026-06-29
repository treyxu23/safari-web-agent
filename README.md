<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/banner.svg">
  <source media="(prefers-color-scheme: light)" srcset="assets/banner.svg">
  <img alt="Safari Web Agent — Web automation using your real Safari browser" src="assets/banner.svg" width="100%">
</picture>

[![SKILL.md Valid](https://github.com/treyxu23/safari-web-agent/actions/workflows/validate.yml/badge.svg)](https://github.com/treyxu23/safari-web-agent/actions/workflows/validate.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform: macOS](https://img.shields.io/badge/platform-macOS-lightgrey)](https://github.com/achiya-automation/safari-mcp)
[![Hermes Skill](https://img.shields.io/badge/Hermes-Skill-blue)](https://github.com/nousresearch/hermes-agent)

---

**English** | [中文](#中文)

## 🤔 The Problem

You ask an AI agent to "scrape this site" or "fill this form". It uses Playwright/Puppeteer. Then:

```
❌ "Please log in"           → No cookies, fresh browser, CAPTCHA hell
❌ "Just a moment..."        → Cloudflare flags headless Chrome  
❌ Form looks filled but...  → Submit sends OLD data (ProseMirror state desync)
```

## 🦊 The Solution

**Safari Web Agent** — a Hermes Skill that drives your REAL Safari browser.

```bash
# Your Safari is already logged into Gmail, Notion, GitHub, everything.
# Safari's native events (CGEvent) are indistinguishable from human clicks.
# Clipboard-native paste (Cmd+V) syncs framework state where DOM fill breaks.

$ hermes
> scrape the top 10 AI tools from ProductHunt with votes and taglines

safari_navigate → Done
safari_snapshot  → 24 items found  
safari_evaluate  → [ {name: "Claude Code", votes: "▲2,847", ...}, ... ]
✅ 10 tools extracted in 8 seconds
```

## ⚡ Quick Demo

```javascript
// ProductHunt scraper — works through Cloudflare
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
// → [{ name: "...", votes: "▲2,847", tagline: "..." }, ...]

## Why Safari over Playwright?

| Scenario | Playwright | Safari Web Agent |
|----------|-----------|------------------|
| **Gmail, Notion, etc.** | Must re-login, CAPTCHA risk | Already logged in ✅ |
| **Cloudflare-protected** | Stuck on "Just a moment..." | Native events bypass it ✅ |
| **ProseMirror editor** | `fill()` changes DOM, Submit sends stale data ❌ | `native_type` → clipboard paste → framework sync ✅ |
| **Install size** | ~500MB (Node + browsers) | 0 (Safari pre-installed) |
| **Cross-platform** | Mac/Win/Linux | macOS only |

## Installation

### Prerequisites
- macOS (Safari is built-in)
- Node.js (for `npx`)

### One-Click Install

```bash
curl -fsSL https://raw.githubusercontent.com/treyxu23/safari-web-agent/main/scripts/install.sh | bash
```

Or manually:

```bash
# 1. Install Safari MCP (npm package + Safari extension)
npm install -g safari-mcp

# 2. Install Safari Extension
#    → Open Safari → Preferences → Extensions
#    → Enable "Safari MCP" extension
#    → In menu bar: Develop → Allow JavaScript from Apple Events

# 3. Grant macOS permissions
#    → System Settings → Privacy & Security → Automation
#    → Enable Safari for your terminal app
#    → System Settings → Privacy & Security → Accessibility
#    → Enable your terminal app

# 4. Verify
npx safari-mcp --doctor
```

### Add to Hermes

Add this to your `~/.hermes/profiles/<profile>/config.yaml`:

```yaml
mcp_servers:
  safari:
    command: npx
    args:
    - safari-mcp
    enabled: true
    timeout: 120
```

Then install the skill:

```bash
git clone https://github.com/treyxu23/safari-web-agent.git \
  ~/.hermes/profiles/<profile>/skills/safari-web-agent/
```

## Use Cases

### 1. Data Scraping (Login-Required)
Scrape your own data from sites you're already logged into — analytics dashboards, e-commerce seller centers, CRM systems.

### 2. Anti-Bot Bypass
Automate sites protected by Cloudflare, DataDome, Akamai, G2 — the native CGEvent path produces events indistinguishable from human interaction.

### 3. Rich Text Editor Automation
Fill ProseMirror (Notion, Linear), Draft.js (Medium), Slate editors correctly — clipboard-native paste goes through the real paste pipeline, syncing framework state.

### 4. Safari/WebKit Testing
Test PWA readiness, viewport behavior, CSS compatibility on real Safari — `safari_check_pwa()`, `safari_inspect_viewport()`, `safari_webkit_compat()`.

### 5. Page Monitoring
Monitor pages for changes, track Web Vitals (FCP, LCP, CLS), capture network requests.

## Documentation

| File | Content |
|------|---------|
| [SKILL.md](SKILL.md) | Core skill — triggers, workflow, pitfalls |
| [references/tools-reference.md](references/tools-reference.md) | Complete Safari MCP tool catalog |
| [references/anti-detection.md](references/anti-detection.md) | Anti-bot bypass techniques |
| [references/workflow-patterns.md](references/workflow-patterns.md) | Reusable automation patterns |
| [examples/](examples/) | Real-world examples |

## Architecture

```
User → Hermes Agent → Safari MCP Server (npx) → Safari Extension → Safari.app
                         ↕ (AppleScript fallback when JS blocked)
```

96 tools, two execution paths:
- **JavaScript path** (fast, most pages) — injects JS via Safari extension
- **Native path** (anti-bot, CSP-blocked) — CGEvent clicks, clipboard paste, AppleScript

## Comparison with Alternatives

| Feature | Safari Web Agent | playwright-skill | Puppeteer | Selenium |
|---------|-----------------|------------------|-----------|----------|
| Real browser sessions | ✅ Your Safari | ❌ Fresh browser | ❌ Fresh browser | ❌ Fresh browser |
| Anti-bot bypass | ✅ Native events | ❌ Flagged | ❌ Flagged | ❌ Flagged |
| Rich text editors | ✅ Native paste | ⚠️ DOM fill issues | ⚠️ DOM fill issues | ⚠️ DOM fill issues |
| Zero install size | ✅ Safari built-in | ❌ ~500MB | ❌ ~400MB | ❌ ~300MB |
| CI/CD ready | ❌ Needs macOS GUI | ✅ Headless | ✅ Headless | ✅ Headless |
| Cross-platform | ❌ macOS only | ✅ All | ✅ All | ✅ All |
| WebKit testing | ✅ Real Safari | ❌ WebKit only | ❌ | ❌ |

---

## 中文

### 这是什么？

一个 **Hermes Agent Skill**，让 AI Agent 能操控你真实的 Safari 浏览器——带着你的登录态、Cookie、和能绕过反爬检测的原生 macOS 事件。

市面上的浏览器自动化工具（Playwright、Puppeteer、Selenium）都是开一个全新的无头浏览器。平时能用，但遇到这三种场景就废了：
- 🔐 需要登录的网站（没 Cookie，得重登 → 验证码）
- 🛡️ 有反爬的页面（Cloudflare "验证你是人类" → 永远转圈）
- ✍️ 富文本编辑器（ProseMirror/Draft.js → DOM 填了但框架状态没变，提交发的是旧内容）

Safari Web Agent 三个全解决。

### 和 Playwright 的核心区别

| 场景 | Playwright | Safari Web Agent |
|------|-----------|------------------|
| 打开 Gmail/Notion | 要重新登录，可能触发验证码 | 你的 Safari 已经登着 ✅ |
| Cloudflare 防护的网站 | 卡在"Just a moment..." | `native_click` 原生事件直接过 ✅ |
| Notion/Linear 编辑器 | `fill()` 改了 DOM，但提交时内容消失 ❌ | `native_type` 走剪贴板粘贴，框架状态同步 ✅ |
| 安装体积 | ~500MB | 0（Safari 预装） |

### 安装

```bash
# 一键安装
curl -fsSL https://raw.githubusercontent.com/treyxu23/safari-web-agent/main/scripts/install.sh | bash

# 或手动
npm install -g safari-mcp     # MCP 服务器
# 然后去 Safari → 偏好设置 → 扩展 → 启用 "Safari MCP"
# 系统设置 → 隐私与安全性 → 自动化 → 允许终端控制 Safari
# 系统设置 → 隐私与安全性 → 辅助功能 → 允许终端
```

### 使用场景

1. **登录态抓取** — 从你已经登录的网站提取数据（后台、卖家中心、CRM）
2. **反爬绕过** — 原生事件过 Cloudflare/DataDome/Akamai
3. **富文本编辑器** — 正确填写 Notion/Medium/飞书文档
4. **Safari 兼容性测试** — PWA 审计、viewport 验证、WebKit CSS 检查
5. **页面监控** — 定时检查页面变化、Web Vitals

---

## License

MIT — use it, fork it, ship it.

## Credits

Built on [Safari MCP](https://github.com/achiya-automation/safari-mcp) by Achiya Automation.  
Inspired by [playwright-skill](https://github.com/lackeyjb/playwright-skill) and the Claude Code Skills ecosystem.
