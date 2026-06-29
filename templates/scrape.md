# Template: Data Scraping

Copy this template and customize for your scraping task.

## Setup

```javascript
// 1. Define target
const TARGET_URL = "https://example.com/list"
const ITEMS_PER_PAGE = 20
const MAX_PAGES = 5

// 2. Define extraction function (JavaScript, runs in Safari)
const EXTRACT_SCRIPT = `
  Array.from(document.querySelectorAll('.item-card')).map(card => ({
    title: card.querySelector('.title')?.textContent?.trim(),
    price: card.querySelector('.price')?.textContent?.trim(),
    link: card.querySelector('a')?.href,
    image: card.querySelector('img')?.src
  }))
`
```

## Execution

### Step 1: Navigate
```
safari_navigate(url="TARGET_URL")
safari_wait_for(selector=".item-card")  // wait for initial load
```

### Step 2: Verify page state
```
safari_snapshot()
→ Confirm items are visible, pagination exists
```

### Step 3: Scrape loop
```
let allData = []
let page = 1

while (page <= MAX_PAGES):
    // Extract current page
    data = safari_evaluate(EXTRACT_SCRIPT)
    allData.push(...data)

    // Check for next page
    hasNext = safari_evaluate(
      "!!document.querySelector('.pagination .next:not([disabled])')"
    )

    if (!hasNext): break

    // Go to next page
    safari_click(text="Next")  // or safari_native_click if anti-bot
    safari_wait_for(selector=".item-card")  // wait for new page
    safari_wait(500)  // small delay to avoid rate limiting
    page++
```

### Step 4: Handle anti-bot (if needed)
```
// If clicking "Next" produces no change:
safari_native_click(text="Next")
safari_wait_for(selector=".item-card")
```

### Step 5: Return results
```
allData.length  // total items scraped
allData.slice(0, 3)  // preview first 3
→ Save to file
```

## Alternative: Infinite Scroll

```
let prevCount = 0
let attempts = 0

while (attempts < 20):
    safari_scroll(direction="down", amount=800)
    safari_wait(1500)

    count = safari_evaluate("document.querySelectorAll('.item').length")
    if (count == prevCount): break

    prevCount = count
    attempts++

// Extract all
safari_evaluate(EXTRACT_SCRIPT)
```

## Pitfalls

- **Dynamic selectors**: If `.item-card` doesn't work, use `safari_snapshot` to find the right selector
- **Rate limiting**: Add `safari_wait(1000-3000)` between pages for aggressive sites
- **Lazy images**: Images may not load until scrolled into view — use `safari_scroll_to_element` first
