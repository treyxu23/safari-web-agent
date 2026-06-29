# Template: Page Monitoring

Copy this template to set up periodic page monitoring.

## Setup

```javascript
const MONITOR_URL = "https://example.com/page-to-watch"
const CHECK_INTERVAL = "daily"  // or "hourly", "weekly"
const SELECTOR = ".content"     // CSS selector for the content to monitor
```

## One-Time Check

```
// 1. Navigate
safari_navigate(url="MONITOR_URL")

// 2. Extract content
content = safari_read_page(selector=".content")

// 3. Compute hash for change detection
// (store this hash for future comparison)
hash = safari_evaluate(`
  (() => {
    const el = document.querySelector('.content');
    if (!el) return 'NO_ELEMENT';
    const text = el.textContent.trim();
    // Simple hash function
    let hash = 0;
    for (let i = 0; i < text.length; i++) {
      const char = text.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash |= 0; // Convert to 32bit integer
    }
    return hash.toString();
  })()
`)

// 4. Store: { url, timestamp, hash, content_snippet }
```

## Periodic Check (Cron Pattern)

```
// Load previous hash from storage
prev_hash = "<stored_hash>"

// Navigate
safari_navigate(url="MONITOR_URL")
safari_wait_for(selector=".content")

// Extract
content = safari_read_page(selector=".content")
new_hash = safari_evaluate("<hash_script>")

// Compare
if (new_hash !== prev_hash):
    // CHANGE DETECTED
    screenshot = safari_screenshot(fullPage=true)
    // Store: { url, timestamp, old_hash, new_hash, screenshot }
    // NOTIFY user
else:
    // No change — log timestamp only
```

## Enhanced: Visual + Performance Monitoring

```
safari_navigate(url="MONITOR_URL")

// Visual
safari_screenshot(fullPage=true)  // → base64 JPEG

// Performance
safari_performance_metrics()  // → FCP, LCP, CLS, navigation timing

// Console errors
safari_start_console()
safari_wait(3000)
errors = safari_console_filter(level="error")

// Network
safari_start_network_capture()
safari_reload()
api_calls = safari_network_details(filter="/api/")

// Save: { screenshot, performance, errors, api_calls }
```

## Enhanced: Multi-Element Watch

Monitor specific elements (price changes, availability, etc.):

```
safari_navigate(url="MONITOR_URL")

elements = safari_evaluate(`
  (() => {
    const results = {};
    // Watch price
    const price = document.querySelector('.price');
    if (price) results.price = price.textContent.trim();
    // Watch stock
    const stock = document.querySelector('.stock-status');
    if (stock) results.stock = stock.textContent.trim();
    // Watch any element
    const title = document.querySelector('h1');
    if (title) results.title = title.textContent.trim();
    return JSON.stringify(results);
  })()
`)

// Compare each field against previous values
```

## Pitfalls

- **Dynamic content**: Pages with timestamps will always produce different hashes. Exclude timestamp elements from the selector.
- **Login-required**: If the page requires login, ensure Safari is already logged in. The monitoring will use your real session.
- **Anti-bot**: If the page blocks regular navigation, use native path for extraction: `safari_read_page` still works on Cloudflare-protected pages.
- **Hash collisions**: The simple hash function is fast but can collide. For critical monitoring, store the full content or use SHA-256.
