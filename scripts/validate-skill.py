#!/usr/bin/env python3
"""Validate SKILL.md against Hermes Skill spec."""

import sys, re, yaml
from pathlib import Path

SKILL_PATH = Path("SKILL.md")
MAX_NAME_LEN = 64
MAX_DESC_LEN = 1024
MAX_CONTENT_LEN = 100_000

errors = []

# ── 1. File exists ──
if not SKILL_PATH.exists():
    errors.append("SKILL.md not found")
    for e in errors:
        print(f"❌ {e}")
    sys.exit(1)

content = SKILL_PATH.read_text()

# ── 2. Starts with --- ──
if not content.startswith("---"):
    errors.append("SKILL.md must start with '---' (no leading whitespace/BOM)")

# ── 3. Has closing --- ──
m = re.search(r"\n---\s*\n", content[3:]) if content.startswith("---") else None
if not m:
    errors.append("Missing closing '---' for YAML frontmatter")
    for e in errors:
        print(f"❌ {e}")
    sys.exit(1)

fm_end = 3 + m.start() + 3  # position after closing ---
fm_text = content[3 : m.start() + 3]

# ── 4. Parse YAML ──
try:
    fm = yaml.safe_load(fm_text)
except yaml.YAMLError as e:
    errors.append(f"Invalid YAML frontmatter: {e}")
    for e in errors:
        print(f"❌ {e}")
    sys.exit(1)

if not isinstance(fm, dict):
    errors.append("Frontmatter must be a YAML mapping")

# ── 5. Required fields ──
for field in ["name", "description", "version", "author", "license"]:
    if field not in fm:
        errors.append(f"Missing required field: '{field}'")

# ── 6. Name constraints ──
name = fm.get("name", "")
if name:
    if len(name) > MAX_NAME_LEN:
        errors.append(f"'name' too long: {len(name)} chars (max {MAX_NAME_LEN})")
    if not re.match(r"^[a-z0-9][a-z0-9-]*$", name):
        errors.append(f"'name' must be lowercase letters, digits, hyphens: '{name}'")

# ── 7. Description constraints ──
desc = fm.get("description", "")
if desc:
    if len(desc) > MAX_DESC_LEN:
        errors.append(f"'description' too long: {len(desc)} chars (max {MAX_DESC_LEN})")

# ── 8. Metadata block ──
metadata = fm.get("metadata", {})
if not isinstance(metadata, dict):
    errors.append("'metadata' must be a mapping")
else:
    hermes = metadata.get("hermes", {})
    if not isinstance(hermes, dict):
        errors.append("'metadata.hermes' must be a mapping")
    elif "tags" not in hermes:
        errors.append("Missing 'metadata.hermes.tags'")

# ── 9. Non-empty body ──
body = content[fm_end:].strip()
if not body:
    errors.append("Body after frontmatter is empty")

# ── 10. Total size ──
if len(content) > MAX_CONTENT_LEN:
    errors.append(f"SKILL.md too large: {len(content)} chars (max {MAX_CONTENT_LEN})")

# ── Report ──
if errors:
    for e in errors:
        print(f"❌ {e}")
    sys.exit(1)
else:
    print(f"✅ SKILL.md valid: name='{name}', desc={len(desc)} chars, body={len(body)} chars")
