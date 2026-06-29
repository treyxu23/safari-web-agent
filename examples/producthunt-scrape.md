# Example: Scrape ProductHunt's AI Tools

Real-world example showing how to scrape ProductHunt's AI topic page — extracting tool names, votes, and taglines.

## Goal

Extract the top 20 AI tools from ProductHunt with: name, votes, tagline, link.

## Why Safari over Playwright?

ProductHunt uses Cloudflare protection. Playwright's headless Chromium often gets stuck on "Just a moment..." Safari Web Agent uses your real Safari — already through Cloudflare, no challenge.

## Step-by-Step

### 1. Navigate to ProductHunt AI topic

```
safari_navigate(url="https://www.producthunt.com/topics/ai")
safari_wait(3000)  // Let Cloudflare page load fully
```

### 2. Snapshot to verify page loaded

```
safari_snapshot()
// → Should see "AI" heading, product cards with names and vote counts
// If you see "Just a moment..." → wait longer, Cloudflare is still challenging
```

### 3. Scroll to load more tools

```
safari_scroll(direction="down", amount=600)
safari_wait(1500)
safari_scroll(direction="down", amount=600)
safari_wait(1500)
```

### 4. Extract structured data with JavaScript

```
safari_evaluate(`
  (() => {
    const posts = document.querySelectorAll('[data-test="post-item"]');
    return Array.from(posts).slice(0, 20).map((post, i) => {
      const nameEl = post.querySelector('a[data-test="post-name"]');
      const votesEl = post.querySelector('[data-test="vote-count"]');
      const taglineEl = post.querySelector('[data-test="post-tagline"]');
      return {
        rank: i + 1,
        name: nameEl?.textContent?.trim() || '',
        votes: votesEl?.textContent?.trim() || '0',
        tagline: taglineEl?.textContent?.trim() || '',
        url: nameEl?.href || ''
      };
    });
  })()
`)
// → Returns JSON array of 20 tools
```

### 5. Verify extraction quality

```
// Check we got real data
safari_evaluate(`
  (() => {
    const posts = document.querySelectorAll('[data-test="post-item"]');
    return {
      total: posts.length,
      first_name: posts[0]?.querySelector('[data-test="post-name"]')?.textContent,
      first_votes: posts[0]?.querySelector('[data-test="vote-count"]')?.textContent
    };
  })()
`)
// → Should show real tool name and vote count
```

## Key Takeaways

- **Cloudflare bypass**: Your real Safari is already through Cloudflare — no special handling needed for ProductHunt.
- **`data-test` attributes**: ProductHunt uses `data-test` attributes which are stable. Prefer these over CSS classes for scraping.
- **Scroll before extract**: ProductHunt lazy-loads items. Scroll to load more before extracting.
- **Verify with sample**: Always verify extraction with one sample element before extracting all.
