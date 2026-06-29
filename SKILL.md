---
name: safari-web-agent
description: "Use when you need browser automation that works on ANY website — scraping, form-filling, monitoring, testing. Uses real Safari with your login sessions, bypasses anti-bot detection with native macOS events (isTrusted: true), and handles JS-heavy pages where Playwright and headless browsers fail. macOS only. Requires Safari MCP."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [macos]
metadata:
  hermes:
    tags: [browser-automation, web-scraping, safari, macos, anti-detection, playwright-alternative, mcp]
    related_skills: [macos-computer-use]
---

# Safari Web Agent

Universal web automation via real Safari. Not a headless browser — your actual Safari with your cookies, sessions, and macOS-native events.

## Overview

Most web automation tools (Playwright, Puppeteer, Selenium) launch a fresh headless browser. They fail on three common scenarios:

1. **Login-walled sites** — no cookies, no sessions, have to re-login (and often hit CAPTCHA)
2. **Anti-bot pages** — Cloudflare, G2, datadome flag headless browsers; you get stuck on "Just a moment..."
3. **Rich text editors** — ProseMirror, Draft.js, Slate editors maintain internal state separate from DOM; `fill()` changes the DOM but the framework state stays stale, so Submit sends old data

Safari Web Agent solves all three by using your **real Safari browser** through the Safari MCP bridge — 96 tools spanning JavaScript injection, AppleScript fallback, native CGEvent clicks, clipboard paste, accessibility tree snapshots, and WebKit-specific audits.

## When to Use

**Trigger classes:**
- "Scrape data from [site]" — especially login-required or JS-heavy pages
- "Automate this form on [site]" — especially sites with rich text editors
- "Monitor this page for changes"
- "Test this site on Safari/WebKit"
- "This site blocks Playwright/Puppeteer"

**Don't use for:**
- Cross-platform needs (macOS only)
- CI/CD pipelines without a macOS GUI machine
- Simple API calls (use `curl` or `web_extract` instead)
- Pages that work fine with headless Playwright (it's faster)

## Architecture

```
User → Hermes (Claude) → Safari MCP Server (npx safari-mcp) → Safari Extension → Safari.app
                                ↕ (AppleScript fallback when JS blocked)
```

**Two execution paths**, auto-selected:

| Path | Trigger | Mechanism | isTrusted |
|------|---------|-----------|-----------|
| **JavaScript** (default) | Most pages | `safari_evaluate` injects JS into page | `false` |
| **AppleScript/CGEvent** (fallback) | CSP blocks JS, anti-bot detection | `safari_native_click`, `safari_native_type`, `safari_native_keyboard` | `true` |

The skill picks the right path automatically based on the page's behavior.

## Core Workflow

Every web automation task follows this 5-step pattern:

### Step 1: Navigate

```
safari_navigate(url="https://target-site.com")
```

Completion: page title and URL returned. If page requires login and you're already logged into Safari, you're in.

### Step 2: Snapshot

```
safari_snapshot()
```

Returns accessibility tree with ref IDs for every interactive element (like `@0_5`, `@0_12`). **Always snapshot before interacting** — refs expire after each new snapshot.

Completion: you have a list of clickable/fillable elements with ref IDs.

### Step 3: Interact

Pick the right tool for the job:

| Action | Best tool | When |
|--------|-----------|------|
| Click a button/link | `safari_click(ref="0_5")` | Standard interactions |
| Click through anti-bot | `safari_native_click(ref="0_5")` | Cloudflare, G2, WAF-protected sites |
| Fill a text input | `safari_fill(ref="0_8", value="text")` | Standard `<input>`, `<textarea>` |
| Type in rich text editor | `safari_native_type(value="text", ref="0_8")` | ProseMirror, Draft.js, Slate, Medium, Notion |
| Press Enter/Tab/Esc | `safari_press_key(key="enter")` | Form submission, navigation |
| Press key (native) | `safari_native_keyboard(key="enter")` | When JS keyboard events don't reach the framework |
| Select dropdown option | `safari_select_option(selector="...", value="Option")` | Native `<select>` |
| Set React select | `safari_react_select_set(ref="0_5", value="Option")` | react-select v5 components |

Completion: the page state changes (new content loads, form fills, etc.). Verify with a fresh snapshot.

### Step 4: Extract

```
safari_read_page(selector=".results", maxLength=10000)
safari_evaluate(script="document.querySelectorAll('.item').length")
safari_get_element(selector=".price")
```

For structured data, use `safari_evaluate` with JavaScript:

```javascript
// Extract product list as JSON
Array.from(document.querySelectorAll('.product-card')).map(card => ({
  title: card.querySelector('.title')?.textContent?.trim(),
  price: card.querySelector('.price')?.textContent?.trim(),
  link: card.querySelector('a')?.href
}))
```

Completion: you have the extracted data. If using `safari_evaluate`, verify with a DOM check — multi-line scripts sometimes return `(no return value)` even though they executed.

### Step 5: Visual Verify (optional)

```
safari_screenshot(fullPage=false)
```

Use only when you need to verify visual layout, colors, or images. `safari_snapshot` is cheaper and preferred for most verification.

## Advanced Techniques

These are loaded on-demand from references. Quick pointers:

### Anti-Detection (`references/anti-detection.md`)

- **Rule 1**: When regular `safari_click` produces no visible change → switch to `safari_native_click`. It generates macOS CGEvent-based clicks with `isTrusted: true`.
- **Rule 2**: When CSP blocks `safari_evaluate` → Safari MCP auto-falls-back to AppleScript. No action needed.
- **Rule 3**: For Discord, Slack, and similar apps → use `safari_native_type` for message input, `safari_native_keyboard(key="enter")` to send.

### Rich Text Editors (`references/workflow-patterns.md`)

- **ProseMirror** (Notion, linear.app): `safari_fill` changes DOM but framework state stays old → Submit sends stale data. Use `safari_native_type` instead.
- **Verification**: After filling, call `safari_verify_state(selector="...", expected="text")` to confirm framework state matches.
- **Monaco/CodeMirror/Ace** (code editors): Use `safari_replace_editor(text="...")`.

### Scraping Patterns (`templates/scrape.md`)

- **Infinite scroll**: `safari_scroll(direction="down", amount=800)` in a loop, snapshot after each scroll, stop when no new items appear.
- **Pagination**: Click "Next" → snapshot → extract → repeat until "Next" is disabled.
- **Lazy-loaded content**: `safari_scroll_to_element(text="target text")` scrolls until the element appears in DOM.

### Form Automation (`templates/form.md`)

- Auto-detect forms: `safari_detect_forms()` → returns all fields with selectors
- Batch fill: `safari_fill_form(fields=[{selector, value}, ...])`
- Submit detection: `safari_fill_and_submit(fields=[...])` auto-finds submit button

### Page Monitoring (`templates/monitor.md`)

- Extract key elements on schedule, diff against previous snapshot
- `safari_performance_metrics()` for Web Vitals (FCP, LCP, CLS)
- `safari_start_network_capture()` + `safari_network_details()` for API monitoring

## Common Pitfalls

1. **Ref expiry** — Refs from `safari_snapshot` expire after ANY new snapshot or page change. Always snapshot fresh before interacting. A ref like `0_5` becomes `1_5` after the second snapshot.

2. **`safari_evaluate` silent failure** — Multi-line scripts often return `(no return value)`. This does NOT mean the code didn't run. Verify with a DOM check: `safari_evaluate(script="document.querySelector('.result')?.textContent")`.

3. **Safari MCP times out during video playback** — Video decoding saturates resources. Pause video before any MCP operation.

4. **Tab desync after `safari_switch_tab`** — First command after switching may fail with `no tabs opened yet`. Fix: `safari_navigate` to current URL to re-anchor.

5. **React portal dropdowns invisible to snapshot** — Chakra UI, MUI, Radix options render outside the dialog. Use `safari_evaluate` with JS to find and click portal-rendered options. See `safari-mcp-portal-interaction` skill for detailed technique.

6. **`safari_fill` vs framework state** — Modern editors (ProseMirror, Lexical, Closure) maintain internal state separate from DOM. After `safari_fill`, always call `safari_verify_state(selector, expected)` before submitting. Use `safari_native_type` when fill fails verification.

7. **Don't `pkill -9 Safari`** — Kills user's login sessions. Always use graceful quit: `osascript -e 'tell app "Safari" to quit'`.

8. **`safari_navigate_and_read` is faster than `navigate` + `read_page`** — Saves one round-trip. Use it when you only need page text.

9. **Screenshots need Screen Recording permission** — If `safari_screenshot` fails, check System Settings → Privacy & Security → Screen Recording.

10. **Long strings get truncated** — `safari_fill(value=...)` with 1400+ char values may truncate to ~50-260 chars. Use clipboard pipeline for long content: write to clipboard → `safari_native_type`.

11. **GitHub sudo mode blocks automation** — GitHub's sensitive pages (token creation, settings) trigger a "Verify your identity" challenge that Safari MCP cannot bypass. When you hit this: tell the user to manually authenticate, wait for confirmation, then continue. For `gh` CLI auth, prefer `gh auth login -w` (browser-based OAuth) over `gh auth login --with-token` — the browser flow is more reliable. Never embed raw tokens in inline scripts (they get corrupted). See `references/github-token-automation.md` for the token workflow and `references/skill-publishing-to-github.md` for the full publishing pipeline.

## Verification Checklist

After any web automation task:

- [ ] Target page loaded successfully (title/URL matches expectation)
- [ ] All interactions produced visible changes (verify with fresh snapshot)
- [ ] Extracted data is complete and structured correctly
- [ ] If using `safari_fill` on rich text editors, `safari_verify_state` passed
- [ ] No stale refs used (always snapshot before click/fill)
- [ ] Safari still running and responsive (MCP connection intact)

## Files

| Path | Purpose |
|------|---------|
| `references/tools-reference.md` | Complete Safari MCP tool catalog (96 tools) |
| `references/anti-detection.md` | Techniques for bypassing anti-bot detection |
| `references/workflow-patterns.md` | Reusable patterns for common automation tasks |
| `references/github-token-automation.md` | Creating GitHub PATs via Safari MCP |
| `references/skill-publishing-to-github.md` | End-to-end workflow for publishing a Hermes Skill to GitHub |
| `scripts/install.sh` | One-click Safari MCP installer |
| `templates/scrape.md` | Data scraping workflow template |
| `templates/form.md` | Form automation workflow template |
| `templates/monitor.md` | Page monitoring workflow template |
| `examples/` | Real-world examples (ProductHunt, login-walled, editor) |
