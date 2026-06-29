# Publishing a Hermes Skill to GitHub

End-to-end workflow for turning a local skill into a polished public GitHub repo. Derived from publishing `safari-web-agent` (June 2026).

## 1. Repo Setup

```bash
cd ~/.hermes/profiles/<profile>/skills/<skill-name>
git init
git add .
git commit -m "🦊 Initial release"
gh repo create <skill-name> --public --source=. --push
```

## 2. GitHub Metadata

Set these immediately — they're what people see in search results:

```bash
gh repo edit <user>/<repo> \
  --description "中文优先的描述，突出差异化卖点" \
  --homepage "https://..." \
  --add-topic "hermes-skill" \
  --add-topic "..."  # repeat for each topic
gh repo edit <user>/<repo> --enable-wiki=false --enable-projects=false
```

**Guidelines**:
- Description: Chinese first if targeting Chinese users. Call out the unique moat in 1-2 sentences.
- Topics: 8-12 tags mixing category (`hermes-skill`), platform (`macos`), tech (`mcp`, `browser-automation`), and differentiators (`anti-detection`).
- Disable unused features (Wiki, Projects) — an empty wiki looks abandoned.

## 3. CI with GitHub Actions

Create `.github/workflows/validate.yml` to auto-validate SKILL.md format:

```yaml
name: Validate SKILL.md
on:
  push:
    paths: ['SKILL.md']
  pull_request:
    paths: ['SKILL.md']
  workflow_dispatch:
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: {python-version: '3.11'}
      - run: pip install pyyaml
      - run: python3 scripts/validate-skill.py
```

Add a badge to README: `[![SKILL.md Valid](...badge.svg)](.../actions)`

**Token pitfall**: Pushing `.github/workflows/` requires `workflow` scope on the token. If `git push` is rejected, use the GitHub Contents REST API as fallback (see `references/github-token-automation.md`).

## 4. README Structure

For a skill targeting Chinese users:

```markdown
<picture><img src="assets/banner.svg" width="100%"></picture>  ← Visual banner FIRST
[badges]

**中文** | [English](#english)

## 🤔 痛点               ← Hook: what sucks without this tool
## 🦊 解法               ← Solution: what this does, with terminal demo
## 🎯 适合谁             ← Target audience (5 user types + 3 anti-users)
## ⚡ 快速 Demo          ← One code block that proves it works
## 🆚 对比其他工具        ← Multi-tool × multi-dimension comparison table
## 📦 安装               ← 30-second quickstart FIRST, then detailed
## 🎯 使用场景           ← Bullet list of concrete scenarios
## 📚 文档               ← Link table to references/
---
## English               ← Same structure, abbreviated
```

**Anti-patterns**:
- "What is this?" headers → use "The Problem" / "The Solution" (emotional hook)
- 2-tool comparison → 6-tool × 10-dimension table (establishes authority)
- Installation first → Demo first (people need to see it works before they'll install)

## 5. Visual Banner

Create an SVG banner (`assets/banner.svg`) that works as both README header and social preview (OG image):

- Dark theme background (#0d1117 → #161b22 gradient)
- Left: visual iconography (product logo metaphors)
- Center-right: Title + subtitle + 3 killer feature pills
- Bottom bar: platform constraints + repo path
- Use `PingFang SC` / `Microsoft YaHei` for Chinese text

SVG is preferred over PNG — renders at any resolution, weighs ~5KB, and GitHub uses the first `<img>` in README as the social preview.

## 6. Token & Auth

When publishing requires new tokens or auth scope changes:

- **`gh auth login -w`** (browser OAuth) is more reliable than `gh auth login --with-token`. Use it whenever possible.
- **`gh auth refresh -s workflow`** will prompt browser-based re-auth to add scopes.
- **Never embed raw tokens in inline scripts.** Shell quoting and Python escaping reliably corrupt them.
- **The GitHub Contents REST API** can push files when `git push` is blocked by scope restrictions.

Full details in `references/github-token-automation.md`.

## 7. Examples: Real Code, Not Pseudocode

The user will call out hand-wavy examples immediately. Every example must be:

**❌ Pseudocode (gets rejected):**
```
safari_navigate("京东搜索")
safari_evaluate(extract_price) → ¥7999
✅ 三平台比价，15 秒
```

**✅ Real code (passes):**
```javascript
safari_navigate("https://search.jd.com/Search?keyword=iPhone+16+Pro+256G&enc=utf-8")
safari_wait_for(selector=".gl-item")
safari_evaluate(`document.querySelector('.gl-item .p-price i')?.textContent`)
// → "7999.00"
```

Rules:
- **Real URLs** — never "卖家中心" or "京东搜索", always the actual `https://` URL
- **Real selectors** — never `extract_price`, always `document.querySelector('.gl-item .p-price i')`
- **Real output** — never `→ ¥7999`, always `→ "7999.00"` (show actual return format)
- **Real numbers** — never "30 秒" without evidence; if you don't know, don't claim
- **Explain WHY** — after each example, one sentence on why it works where competitors fail
- **Show the error case** — for rich text editors, show the ❌ `fill()` approach first, then the ✅ `native_type()` fix

This is the #1 thing that separates a convincing README from a hand-wavy one. The user knows the difference instantly.

## Checklist

- [ ] `gh repo edit` — description, topics, homepage set
- [ ] Wiki and Projects disabled if empty
- [ ] CI workflow created and badge added to README
- [ ] README: Chinese-first, problem→solution→audience→demo→comparison→install
- [ ] Comparison table: ≥4 tools, ≥8 dimensions
- [ ] Banner SVG in `assets/` with Chinese text
- [ ] `scripts/install.sh` exists and is executable
- [ ] `scripts/validate-skill.py` works locally
- [ ] All code examples use real URLs, real selectors, real output (no pseudocode)
- [ ] Error-vs-fix contrast shown for at least one scenario (❤️❌→✅ pattern)
- [ ] Every example includes a one-line "why it works" explanation
