# Anti-Bot Detection Techniques

How to navigate and interact with sites that use anti-bot detection (Cloudflare, DataDome, Akamai, G2, PerimeterX).

## The Core Principle

Anti-bot systems distinguish bots from humans by checking `isTrusted` on UI events. JavaScript-dispatched events (`new MouseEvent('click')`) have `isTrusted: false`. Native macOS CGEvent clicks have `isTrusted: true` — indistinguishable from human interaction.

Safari MCP has **two execution paths**:
- **JavaScript path**: `safari_click`, `safari_fill` → `isTrusted: false`
- **Native path**: `safari_native_click`, `safari_native_type` → `isTrusted: true`

## Decision Tree

```
Page loads normally?
├─ YES → Use JS path (faster, doesn't move cursor)
│   └─ Click/fill produces visible change?
│       └─ NO → Switch to native path
└─ NO (stuck on "Just a moment..." / blank page / 403)
    └─ Switch to native path immediately
```

## Pattern 1: Cloudflare "Just a moment..."

**Symptom**: After `safari_navigate`, you don't see the actual page — just Cloudflare's challenge.

**Fix**: Use native path for all interactions on this domain.

```javascript
// Navigate
safari_navigate("https://protected-site.com")
safari_wait(3000)  // Let Cloudflare challenge resolve

// Take snapshot to find interactive elements
safari_snapshot()

// Use native_click instead of click for ALL interactions
safari_native_click(text="Sign In")     // Find by visible text
safari_native_click(ref="0_5")          // Or by ref from snapshot
```

## Pattern 2: Form Submission Gets Blocked

**Symptom**: Form fills correctly but submit returns 405/403.

**Fix**: Fill with JS path, submit with native path.

```javascript
// Fill form fields (JS path is fine for text inputs)
safari_fill_form([
  {selector: "#email", value: "user@example.com"},
  {selector: "#password", value: "password123"}
])

// Submit button — use native click
safari_native_click(text="Submit")
// OR native keyboard
safari_native_keyboard(key="enter")
```

## Pattern 3: G2 / Review Sites with WAF

**Symptom**: Page loads but interactions (clicking tabs, scrolling grids) produce no change.

**Fix**: All interactions on G2 and similar WAF-protected sites should use native path.

```javascript
safari_navigate("https://www.g2.com/categories/ai")
safari_snapshot()

// Click "Reviews" tab
safari_native_click(text="Reviews")

// Wait for content to load
safari_wait_for(text="Most Helpful")

// Extract data
safari_read_page(selector=".reviews-container")
```

## Pattern 4: CSP Blocks JavaScript Injection

**Symptom**: `safari_evaluate` returns empty/error. This happens on Google Search Console, LinkedIn, and other sites with strict Content-Security-Policy.

**Auto-fix**: Safari MCP automatically falls back to AppleScript when CSP blocks JS injection. You don't need to do anything — it's transparent. But if you need to debug:

```javascript
// Try evaluate
safari_evaluate("document.title")
// If CSP blocks → Safari MCP auto-uses AppleScript
// If you see "(no return value)" → code executed but no return value captured
// Verify with:
safari_evaluate("document.querySelector('.result')?.textContent || 'NOT_FOUND'")
```

## Pattern 5: Browser Fingerprinting

Some sites check navigator properties (webdriver, plugins, etc.). Safari MCP uses *your real Safari* — so `navigator.webdriver` is `false`, plugins array is real, fonts are real. No special handling needed.

**Exception**: If a site blocks Safari specifically (rare), emulate a different device:

```javascript
safari_emulate(device="iphone-14")
// ... interact ...
safari_reset_emulation()
```

## Pattern 6: Rate Limiting

**Symptom**: Too many requests in short time → 429 / temporary block.

**Fix**: Add human-like delays between interactions.

```javascript
safari_navigate("https://site.com")
safari_wait(1000 + Math.random() * 2000)  // 1-3s random delay
safari_native_click(ref="0_5")
safari_wait(500 + Math.random() * 1000)   // 0.5-1.5s random delay
```

## Quick Reference

| Site Type | Navigation | Click | Fill | Submit |
|-----------|-----------|-------|------|--------|
| Normal sites | `safari_navigate` | `safari_click` | `safari_fill` | `safari_press_key` |
| Cloudflare | `safari_navigate` + `safari_wait(3000)` | `safari_native_click` | `safari_fill` | `safari_native_click` |
| G2/WAF | `safari_navigate` | `safari_native_click` | `safari_fill` | `safari_native_click` |
| CSP strict | `safari_navigate` | `safari_click` | `safari_fill` | Auto-fallback |
| Rate-limited | `safari_navigate` + delays | `safari_click` + delays | `safari_fill` + delays | `safari_press_key` + delays |

## Verification

After switching to native path, verify:
1. Fresh snapshot shows expected content
2. Click produced visible change (new page, dropdown opened, etc.)
3. No error in console (`safari_get_console` → filter for errors)
