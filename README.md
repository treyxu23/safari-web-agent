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

## ⚡ 快速 Demo

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

| 维度 | Safari Web Agent | Playwright | Puppeteer | Selenium |
|------|:---:|:---:|:---:|:---:|
| **登录态** | ✅ 真实 Safari，已登录 | ❌ 新浏览器，重登 | ❌ 新浏览器，重登 | ❌ 新浏览器，重登 |
| **Cloudflare 绕过** | ✅ `native_click` 原生事件 | ❌ 被拦 | ❌ 被拦 | ❌ 被拦 |
| **DataDome/Akamai** | ✅ 真人级别 CGEvent | ❌ 被识别为 bot | ❌ 被识别为 bot | ❌ 被识别为 bot |
| **富文本编辑器** | ✅ 剪贴板粘贴，状态同步 | ❌ DOM fill，状态不同步 | ❌ DOM fill，状态不同步 | ❌ DOM fill，状态不同步 |
| **安装体积** | 0（Safari 预装） | ~500MB | ~400MB | ~300MB |
| **启动速度** | 即开即用 | 3-5 秒 | 2-4 秒 | 3-8 秒 |
| **跨平台** | ❌ 仅 macOS | ✅ Win/Mac/Linux | ✅ Win/Mac/Linux | ✅ Win/Mac/Linux |
| **CI/CD** | ❌ 需 macOS GUI | ✅ 无头模式 | ✅ 无头模式 | ✅ 无头模式 |
| **WebKit 真机测试** | ✅ 真实 Safari | ❌ WebKit 模拟 | ❌ | ❌ |
| **CSP 阻断时** | ✅ AppleScript 降级 | ❌ 报错 | ❌ 报错 | ❌ 报错 |

> **结论**：Safari Web Agent 不做 Playwright 能做的事。它做 Playwright **做不到**的事。

## 📦 安装

```bash
# 一键安装
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

| Feature | Safari Web Agent | Playwright | Puppeteer | Selenium |
|---------|:---:|:---:|:---:|:---:|
| **Login sessions** | ✅ Real Safari, logged in | ❌ Fresh browser | ❌ Fresh browser | ❌ Fresh browser |
| **Cloudflare bypass** | ✅ `native_click` CGEvent | ❌ Blocked | ❌ Blocked | ❌ Blocked |
| **Anti-bot (DataDome)** | ✅ Human-level events | ❌ Flagged as bot | ❌ Flagged as bot | ❌ Flagged as bot |
| **Rich text editors** | ✅ Native paste, synced state | ❌ DOM fill, stale state | ❌ DOM fill, stale state | ❌ DOM fill, stale state |
| **Install size** | 0 (Safari built-in) | ~500MB | ~400MB | ~300MB |
| **Startup time** | Instant | 3-5s | 2-4s | 3-8s |
| **Cross-platform** | ❌ macOS only | ✅ All | ✅ All | ✅ All |
| **CI/CD** | ❌ Needs macOS GUI | ✅ Headless | ✅ Headless | ✅ Headless |
| **WebKit testing** | ✅ Real Safari | ❌ WebKit only | ❌ | ❌ |
| **CSP fallback** | ✅ AppleScript | ❌ Fails | ❌ Fails | ❌ Fails |

> **TL;DR**: Safari Web Agent doesn't do what Playwright can do. It does what Playwright **can't**.

---

## License

MIT

## Credits

Built on [Safari MCP](https://github.com/achiya-automation/safari-mcp) by Achiya Automation.  
Inspired by [playwright-skill](https://github.com/lackeyjb/playwright-skill) and the Claude Code Skills ecosystem.
