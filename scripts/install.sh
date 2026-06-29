#!/bin/bash
# Safari Web Agent — One-Click Installer
# Installs Safari MCP (npm package + Safari extension prerequisites)
# and verifies the setup.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/treyxu23/safari-web-agent/main/scripts/install.sh | bash
#   OR
#   chmod +x install.sh && ./install.sh

set -euo pipefail

# ─── Colors ───────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ─── Banner ───────────────────────────────────────────────
echo ""
echo -e "${BOLD}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║     🧭 Safari Web Agent Installer       ║${NC}"
echo -e "${BOLD}║     Browser automation with real Safari  ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════╝${NC}"
echo ""

# ─── Step 1: Check macOS ─────────────────────────────────
echo -e "${BLUE}[1/6]${NC} Checking macOS..."
if [[ "$(uname)" != "Darwin" ]]; then
    echo -e "${RED}✗ This installer only supports macOS.${NC}"
    echo "  Safari Web Agent requires Safari, which is macOS-only."
    exit 1
fi
echo -e "${GREEN}✓ macOS detected ($(sw_vers -productVersion))${NC}"

# ─── Step 2: Check Safari ─────────────────────────────────
echo -e "${BLUE}[2/6]${NC} Checking Safari..."
if [ -d "/Applications/Safari.app" ] || [ -d "$HOME/Applications/Safari.app" ]; then
    SAFARI_VERSION=$(defaults read /Applications/Safari.app/Contents/Info.plist CFBundleShortVersionString 2>/dev/null || echo "unknown")
    echo -e "${GREEN}✓ Safari found (v${SAFARI_VERSION})${NC}"
else
    echo -e "${RED}✗ Safari not found.${NC}"
    echo "  Safari Web Agent requires Safari. Please install it from the App Store."
    exit 1
fi

# ─── Step 3: Check Node.js/npm ────────────────────────────
echo -e "${BLUE}[3/6]${NC} Checking Node.js..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✓ Node.js found (${NODE_VERSION})${NC}"
else
    echo -e "${YELLOW}⚠ Node.js not found.${NC}"
    echo "  Safari MCP requires Node.js for the npx command."
    echo ""
    echo "  Install options:"
    echo "    1. Download from https://nodejs.org (LTS recommended)"
    echo "    2. brew install node"
    echo "    3. nvm install --lts"
    echo ""
    read -p "  Press Enter after installing Node.js, or Ctrl+C to cancel... "
fi

# Verify npm/npx
if ! command -v npx &> /dev/null; then
    echo -e "${RED}✗ npx not found (should come with Node.js).${NC}"
    exit 1
fi
echo -e "${GREEN}✓ npx available${NC}"

# ─── Step 4: Install Safari MCP npm package ───────────────
echo -e "${BLUE}[4/6]${NC} Installing Safari MCP..."
if npm list -g safari-mcp &> /dev/null 2>&1; then
    echo -e "${GREEN}✓ safari-mcp already installed globally${NC}"
    npm list -g safari-mcp 2>/dev/null | grep safari-mcp
else
    echo "  Running: npm install -g safari-mcp"
    if npm install -g safari-mcp 2>&1; then
        echo -e "${GREEN}✓ safari-mcp installed successfully${NC}"
    else
        echo -e "${RED}✗ Failed to install safari-mcp.${NC}"
        echo "  Try: npm install -g safari-mcp --registry https://registry.npmjs.org"
        exit 1
    fi
fi

# ─── Step 5: Safari Extension Setup Guide ─────────────────
echo ""
echo -e "${BLUE}[5/6]${NC} Safari Extension Setup"
echo ""
echo -e "  ${YELLOW}Manual steps required:${NC}"
echo ""
echo -e "  ${BOLD}a) Enable Safari Extension:${NC}"
echo "     1. Open Safari"
echo "     2. Safari → Settings → Extensions"
echo "     3. Find 'Safari MCP' and enable it"
echo ""
echo -e "  ${BOLD}b) Allow JavaScript from Apple Events:${NC}"
echo "     1. In Safari menu bar: Develop → Allow JavaScript from Apple Events"
echo "     (If you don't see 'Develop' menu: Safari → Settings → Advanced →"
echo "      check 'Show Develop menu in menu bar')"
echo ""
echo -e "  ${BOLD}c) Grant macOS Automation Permission:${NC}"
echo "     1. System Settings → Privacy & Security → Automation"
echo "     2. Find your terminal app (Terminal/iTerm/Warp)"
echo "     3. Enable 'Safari' toggle"
echo ""
echo -e "  ${BOLD}d) Grant Accessibility Permission:${NC}"
echo "     1. System Settings → Privacy & Security → Accessibility"
echo "     2. Add/enable your terminal app"
echo "     (Required for native_click, native_type, native_keyboard)"
echo ""
echo -e "  ${BOLD}e) Grant Screen Recording Permission (optional):${NC}"
echo "     1. System Settings → Privacy & Security → Screen Recording"
echo "     2. Enable Safari"
echo "     (Required for safari_screenshot, safari_save_pdf)"
echo ""

read -p "  Have you completed the manual steps above? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}⚠ Please complete the manual steps and re-run this installer.${NC}"
    echo "  You can skip to verification with: npx safari-mcp --doctor"
    exit 1
fi

# ─── Step 6: Verify Setup ─────────────────────────────────
echo -e "${BLUE}[6/6]${NC} Verifying Safari MCP setup..."

# Check if Safari is running
if ! pgrep -x "Safari" > /dev/null; then
    echo -e "${YELLOW}⚠ Safari is not running. Opening Safari...${NC}"
    open -a Safari
    sleep 3
fi

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║     ✅ Installation Complete!            ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Safari Web Agent is ready.${NC}"
echo ""
echo "  Next steps:"
echo "  1. Add this to your Hermes config.yaml:"
echo ""
echo -e "     ${BOLD}mcp_servers:${NC}"
echo -e "     ${BOLD}  safari:${NC}"
echo -e "     ${BOLD}    command: npx${NC}"
echo -e "     ${BOLD}    args:${NC}"
echo -e "     ${BOLD}    - safari-mcp${NC}"
echo -e "     ${BOLD}    enabled: true${NC}"
echo -e "     ${BOLD}    timeout: 120${NC}"
echo ""
echo "  2. Install this skill:"
echo "     git clone https://github.com/treyxu23/safari-web-agent.git \\"
echo "       ~/.hermes/profiles/<profile>/skills/safari-web-agent/"
echo ""
echo "  3. Run safari_doctor to diagnose any permission issues:"
echo "     (Available as an MCP tool within Hermes)"
echo ""
echo "  For troubleshooting: https://github.com/achiya-automation/safari-mcp"
echo ""
