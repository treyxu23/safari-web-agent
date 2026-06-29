# Claude Code Compatibility

How to make a Hermes Skill also work as a Claude Code Plugin.

## The Pattern

Add a single file: `.claude-plugin/plugin.json`

```json
{
  "name": "skill-name",
  "version": "1.0.0",
  "description": "What it does (Claude Code sees this in /plugin list)",
  "author": { "name": "Your Name" },
  "license": "MIT",
  "repository": "https://github.com/user/repo",
  "keywords": ["claude-skill", "claude-code", "..."],
  "category": "automation|research|development|..."
}
```

## What Changes

**Nothing in SKILL.md needs to change.** Hermes SKILL.md frontmatter has extra fields (`version`, `author`, `license`, `metadata.hermes.*`) that Claude Code simply ignores. Both systems parse the same `name` and `description` fields.

## Installation from Claude Code

```
/plugin marketplace add user/repo
/plugin install skill-name@skill-name
```

## MCP Server Config

Claude Code needs Safari MCP configured separately in `~/.claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "safari": {
      "command": "npx",
      "args": ["safari-mcp"]
    }
  }
}
```

## README Updates

For dual-platform skills, the install section should show Claude Code first (larger audience), then Hermes:

```markdown
## 📦 Install

> Supports **Claude Code** and **Hermes**.

### Claude Code
/plugin marketplace add user/repo
/plugin install skill-name@skill-name

### Hermes
git clone https://github.com/user/repo.git \
  ~/.hermes/profiles/<profile>/skills/skill-name/
```

## Badge

```markdown
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Skill-8A2BE2)](repo-url)
```

## Why This Matters

Hermes has a niche user base. Claude Code has millions. By adding one 15-line JSON file, the same skill reaches a 100x larger audience with zero code changes.
