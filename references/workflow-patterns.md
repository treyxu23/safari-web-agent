# Workflow Patterns

Reusable patterns for common web automation tasks. Each pattern is a named scenario with a concrete sequence of Safari MCP calls.

## Pattern: Data Scraping (Paginated)

Use when scraping a list that spans multiple pages.

```
1. safari_navigate(url="https://site.com/list?page=1")
2. Loop:
   a. safari_snapshot() → find elements
   b. safari_evaluate(extraction_script) → get data
   c. Check if "Next" button exists:
      - safari_evaluate("document.querySelector('.pagination .next:not([disabled])")
      - If exists → safari_click(text="Next") or safari_native_click(text="Next")
      - If not → break
   d. safari_wait_for(text="expected content") → ensure page loaded
   e. safari_wait(500) → small delay to avoid rate limiting
3. Return merged data
```

## Pattern: Data Scraping (Infinite Scroll)

Use when new items load as you scroll down.

```
1. safari_navigate(url="https://site.com/feed")
2. safari_wait_for(selector=".item") → wait for initial load
3. let prevCount = 0
4. Loop (max 20 iterations):
   a. safari_scroll(direction="down", amount=800)
   b. safari_wait(1500 + random(1000)) → wait for lazy load
   c. safari_evaluate("document.querySelectorAll('.item').length")
   d. If count == prevCount → break (no new items loaded)
   e. prevCount = count
5. safari_evaluate(extraction_script) → extract all items
```

## Pattern: Form Fill with Verification

Use when filling forms with rich text editors or framework-managed state.

```
1. safari_navigate(url="https://site.com/form")
2. safari_detect_forms() → find all form fields
3. For each field:
   a. If <input> or <textarea>:
      safari_fill(selector="...", value="text")
   b. If contenteditable / rich text:
      safari_native_type(value="text", selector="...")
4. Verify critical fields:
   safari_verify_state(selector="...", expected="text")
   → If mismatch: retry with safari_native_type
5. Submit:
   safari_native_click(text="Submit")
   OR safari_native_keyboard(key="enter")
6. safari_wait_for(text="Success") or safari_wait(2000)
   safari_snapshot() → verify submission succeeded
```

## Pattern: Login-Required Data Export

Use when you need data from a site you're already logged into.

```
1. safari_navigate(url="https://site.com/dashboard")
2. safari_snapshot() → verify you're logged in (look for username, dashboard elements)
3. If NOT logged in:
   → safari_fill(selector="#email", value="...")
   → safari_fill(selector="#password", value="...")
   → safari_native_click(text="Sign In")
   → safari_wait_for(text="Dashboard")
4. Navigate to data page:
   safari_click(text="Reports") or safari_navigate(url=".../reports")
5. Click export:
   safari_click(text="Export") or safari_native_click(text="Download CSV")
6. Handle download (Safari auto-downloads to ~/Downloads/)
```

## Pattern: Multi-Tab Comparison

Use when comparing data across multiple pages simultaneously.

```
1. safari_navigate(url="https://site-a.com/item/1")
   safari_read_page(selector=".price") → extract price A
2. safari_new_tab(url="https://site-b.com/item/1")
   safari_read_page(selector=".price") → extract price B
3. safari_new_tab(url="https://site-c.com/item/1")
   safari_read_page(selector=".price") → extract price C
4. Compare results
```

## Pattern: Page Change Monitor

Use when monitoring a page for content changes on a schedule.

```
// Run periodically (as a cron or manual check)
1. safari_navigate(url="https://site.com/page")
2. safari_read_page(selector=".content", maxLength=5000)
3. Calculate hash of extracted content
4. Compare with previous hash from storage
5. If changed:
   → Record new hash
   → Record timestamp
   → Extract diff (what changed)
6. Optional: safari_screenshot(fullPage=true) for visual record
```

## Pattern: Rich Text Editor (ProseMirror/Draft.js/Slate)

Use for Notion, Linear, Medium, and other modern editors.

```
1. safari_navigate(url="https://site.com/editor")
2. safari_click(text="New document") or safari_click(ref="editor_ref")
3. safari_wait(500)
4. DO NOT use safari_fill → it changes DOM but not framework state
5. USE safari_native_type:
   safari_native_type(
     value="Your full text content here...",
     selector=".ProseMirror"  // or ref from snapshot
   )
6. safari_verify_state(selector=".ProseMirror", expected="Your full text")
   → If false: retry with safari_native_type
7. safari_native_click(text="Publish") or safari_native_keyboard(key="enter", modifiers=["cmd"])
```

**Why `safari_native_type` works**: It goes through the real clipboard paste pipeline (Cmd+V via CGEvent). ProseMirror/Draft.js process the paste event natively and update their internal model. `safari_fill` manipulates DOM directly — the framework doesn't detect the change.

## Pattern: React Select Dropdown

Use for react-select v5 components (common in Cloudflare, Stripe, modern dashboards).

```
1. safari_snapshot() → find the react-select ref
2. safari_react_select_set(ref="0_5", value="Option Label")
   → This directly sets the value via React fiber, bypassing the menu UI
3. If option not found → safari_react_select_list_options(ref="0_5")
   → Returns exact labels to use
```

## Pattern: File Upload (No Dialog)

Use when you need to upload a file to a web form.

```
1. safari_navigate(url="https://site.com/upload")
2. DO NOT click the file input
3. safari_upload_file(selector="input[type='file']", filePath="/path/to/file.pdf")
4. safari_wait(2000)
5. safari_native_click(text="Upload") or safari_native_click(text="Submit")
```

## Pattern: Debugging "Nothing Happens"

When an interaction produces no visible change:

```
1. safari_start_console() → capture JS errors
2. safari_start_network_capture() → capture API calls
3. Retry the interaction
4. safari_console_filter(level="error") → check for JS errors
5. safari_network_details(filter="/api/") → check for failed API calls
6. safari_screenshot() → visual check
7. Based on findings:
   - JS error → the site has a bug, work around it
   - API 403 → switch to native path (anti-bot detection)
   - No error, no visible change → portal-rendered element, use safari_evaluate to find it
```
