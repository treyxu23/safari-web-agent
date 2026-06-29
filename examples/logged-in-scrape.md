# Example: Scrape Data from a Login-Required Site

Real-world example showing how to extract data from sites that require authentication — using your Safari's existing login session.

## Goal

Extract data from a SaaS dashboard, e-commerce seller center, or analytics platform that you're already logged into in Safari.

## Why Safari over Playwright?

Playwright starts a fresh browser — no cookies, no sessions. You'd have to:
1. Navigate to login page
2. Fill email/password
3. Handle 2FA/CAPTCHA
4. Wait for redirect

Safari Web Agent: you're already logged in. Navigate directly to the data page.

## Step-by-Step

### 1. Navigate to the dashboard (not the login page!)

```
safari_navigate(url="https://app.example.com/dashboard")
safari_wait(3000)
```

### 2. Verify logged-in state

```
safari_snapshot()
// → Look for your username, "Dashboard" heading, or data tables
// If you see "Sign In" instead → session expired, need to re-authenticate

// Quick check with JS:
safari_evaluate(`
  document.querySelector('.user-menu, .avatar, [data-test="user-name"]')
    ? 'LOGGED_IN'
    : 'NOT_LOGGED_IN'
`)
```

### 3. Navigate to the data/reports page

```
// Option A: Click navigation
safari_click(text="Reports")
safari_wait_for(text="Export")

// Option B: Direct URL
safari_navigate(url="https://app.example.com/reports/sales")
safari_wait(3000)
```

### 4. Interact with filters/date pickers

```
// Set date range
safari_fill(selector="input[name='start_date']", value="2026-01-01")
safari_fill(selector="input[name='end_date']", value="2026-06-30")

// Click "Apply" or "Filter"
safari_click(text="Apply")
safari_wait(2000)
```

### 5. Extract data from table

```
safari_evaluate(`
  (() => {
    const rows = document.querySelectorAll('table tbody tr');
    return Array.from(rows).map(row => {
      const cells = row.querySelectorAll('td');
      return {
        date: cells[0]?.textContent?.trim(),
        orders: cells[1]?.textContent?.trim(),
        revenue: cells[2]?.textContent?.trim(),
        status: cells[3]?.textContent?.trim()
      };
    });
  })()
`)
// → Returns structured table data
```

### 6. Handle pagination

```
let allData = []
let page = 1

while (page <= 10):  // max 10 pages
    // Extract current page
    data = safari_evaluate("<extraction_script>")
    allData.push(...data)

    // Check for next page
    hasNext = safari_evaluate(`
      !!document.querySelector('.pagination .next:not([disabled])')
    `)
    if (!hasNext): break

    // Go to next page
    safari_click(text="Next")
    safari_wait(2000)
    page++
```

### 7. Export to CSV (if available)

```
// Some dashboards have an "Export CSV" button
safari_click(text="Export")
safari_click(text="CSV")
// File downloads to ~/Downloads/
```

## Key Takeaways

- **Skip login entirely**: The biggest advantage — your Safari session is already authenticated.
- **Session expiry**: If your session expired, you'll be redirected to login. Handle this gracefully (alert user to re-login).
- **Rate limiting**: Some dashboards rate-limit API calls. Add `safari_wait(1000-2000)` between page navigations.
- **CSV export beats scraping**: If the site has an export button, use it instead of scraping tables — cleaner data, faster.
