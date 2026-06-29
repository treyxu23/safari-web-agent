# Safari MCP Tool Reference

Complete catalog of Safari MCP tools, organized by category. Generated from the `safari-mcp` npm package by Achiya Automation.

## Navigation

| Tool | Signature | Returns |
|------|-----------|---------|
| `safari_navigate` | `url: string` | Page title + URL |
| `safari_navigate_and_read` | `url: string, maxLength?: number` | Page text (saves 1 round-trip) |
| `safari_reload` | `hard?: boolean` | Reloaded page |
| `safari_go_back` | — | Previous page |
| `safari_go_forward` | — | Next page |
| `safari_new_tab` | `url?: string` | New tab |
| `safari_close_tab` | — | Closed tab |
| `safari_list_tabs` | — | Tab list with indices |
| `safari_switch_tab` | `index: number` | Switched tab |

**Speed tip**: Use `safari_navigate_and_read` instead of `navigate` + `read_page` — saves one full round-trip.

## Page Reading

| Tool | Signature | Best for |
|------|-----------|----------|
| `safari_snapshot` | `selector?: string` | **PREFERRED** — accessibility tree with ref IDs for every interactive element |
| `safari_read_page` | `selector?: string, maxLength?: number` | Raw text content |
| `safari_get_source` | `maxLength?: number` | Full HTML source |
| `safari_analyze_page` | — | Title, URL, meta tags, headings, links, images, forms, text preview |
| `safari_extract_meta` | — | All meta tags, OG, Twitter cards, JSON-LD |
| `safari_extract_links` | `limit?: number, filter?: string` | All links with href, text, rel |
| `safari_extract_images` | `limit?: number` | All images with src, alt, dimensions |
| `safari_extract_tables` | `selector?: string, limit?: number` | HTML tables → structured JSON |

**Key rule**: Always use `safari_snapshot` before any interaction — it gives ref IDs for click/fill. Use `safari_read_page` only when you need raw text.

## Interaction (JavaScript path)

| Tool | Signature | Notes |
|------|-----------|-------|
| `safari_click` | `ref?, selector?, text?, x?, y?` | Pure JS PointerEvent — doesn't touch real mouse |
| `safari_double_click` | `selector?, x?, y?` | Double-click |
| `safari_right_click` | `selector?, x?, y?` | Context menu |
| `safari_hover` | `ref?, selector?, x?, y?` | Hover |
| `safari_drag` | `sourceSelector?, targetSelector?, ...` | Drag and drop |
| `safari_fill` | `ref?, selector?, value` | Fill input/textarea/select/contenteditable |
| `safari_type_text` | `text, ref?, selector?` | Character-by-character typing (for autocomplete) |
| `safari_press_key` | `key, modifiers?` | Keyboard event (enter, tab, escape, arrows) |
| `safari_select_option` | `selector?, ref?, value` | Native `<select>` |
| `safari_react_select_set` | `selector?, ref?, value` | react-select v5 dropdown |
| `safari_scroll` | `direction, amount?` | Scroll up/down |
| `safari_scroll_to` | `x?, y?` | Scroll to position |
| `safari_scroll_to_element` | `selector?, text?, block?` | Scroll to element |
| `safari_upload_file` | `selector, filePath` | Upload file (no file dialog) |
| `safari_replace_editor` | `text` | Replace ALL content in Monaco/CodeMirror/Ace |

## Interaction (Native/CGEvent path)

These produce `isTrusted: true` events — use when anti-bot detection blocks JS events.

| Tool | Signature | Notes |
|------|-----------|-------|
| `safari_native_click` | `ref?, selector?, text?, x?, y?, doubleClick?` | OS-level CGEvent click |
| `safari_native_hover` | `ref?, selector?, text?, x?, y?, dwellMs?` | Real mouse hover |
| `safari_native_type` | `value, selector?, ref?` | Clipboard paste (Cmd+V) — for ProseMirror/Draft.js |
| `safari_native_keyboard` | `key, modifiers?` | OS-level keypress (no focus steal) |

**When to use native path over JS path:**
- Click produces no visible change → try `safari_native_click`
- `safari_fill` works visually but Submit sends stale data → use `safari_native_type`
- Keyboard events don't reach the framework (Discord, Slack) → use `safari_native_keyboard`

## JavaScript Execution

| Tool | Signature | Notes |
|------|-----------|-------|
| `safari_evaluate` | `script: string` | Execute JS in page; auto-falls-back to AppleScript when CSP blocks |
| `safari_verify_state` | `selector, expected` | Check framework state matches expected value |

**Warning**: `safari_evaluate` with multi-line scripts often returns `(no return value)`. This doesn't mean the code didn't run. Verify with a separate DOM check.

## Network

| Tool | Signature | Notes |
|------|-----------|-------|
| `safari_network` | `limit?: number` | Quick overview via Performance API (no setup needed) |
| `safari_start_network_capture` | — | Start capturing detailed requests (fetch + XHR) |
| `safari_network_details` | `limit?: number, filter?: string` | Captured requests with headers, status, timing |
| `safari_mock_route` | `urlPattern, response` | Intercept and mock network requests |
| `safari_clear_mocks` | — | Remove all mock routes |
| `safari_clear_network` | — | Clear captured requests |
| `safari_throttle_network` | `profile?, latency?, downloadKbps?` | Simulate slow network |

## Console

| Tool | Signature | Notes |
|------|-----------|-------|
| `safari_start_console` | — | Start capturing console messages |
| `safari_get_console` | — | Get captured messages |
| `safari_console_filter` | `level` | Filter by level (log/warn/error/info) |
| `safari_clear_console` | — | Clear captured messages |

## Visual

| Tool | Signature | Notes |
|------|-----------|-------|
| `safari_screenshot` | `fullPage?: boolean` | Full page or viewport screenshot (base64 JPEG) |
| `safari_screenshot_element` | `selector` | Screenshot of specific element |
| `safari_save_pdf` | `path` | Save page as PDF |
| `safari_paste_image` | `filePath` | Paste image from file into focused element |

**Expensive**: Screenshots are costly — prefer `safari_snapshot` for structure, use screenshots only for visual verification.

## Forms

| Tool | Signature | Notes |
|------|-----------|-------|
| `safari_detect_forms` | — | Auto-detect all forms with fields, types, selectors |
| `safari_fill_form` | `fields: [{selector, value}]` | Fill multiple fields at once |
| `safari_fill_and_submit` | `fields: [{selector, value}], submitSelector?` | Fill AND submit in one call |
| `safari_clear_field` | `selector` | Clear an input field |

## Storage

| Tool | Signature | Notes |
|------|-----------|-------|
| `safari_get_cookies` | — | Get cookies for current page |
| `safari_set_cookie` | `name, value, domain?, path?, ...` | Set a cookie |
| `safari_delete_cookies` | `name?, all?` | Delete cookies |
| `safari_local_storage` | `key?` | Get localStorage |
| `safari_set_local_storage` | `key, value` | Set localStorage |
| `safari_delete_local_storage` | `key?` | Delete/clear localStorage |
| `safari_session_storage` | `key?` | Get sessionStorage |
| `safari_set_session_storage` | `key, value` | Set sessionStorage |
| `safari_delete_session_storage` | `key?` | Delete/clear sessionStorage |
| `safari_export_storage` | — | Export all storage as JSON |
| `safari_import_storage` | `state` | Import storage from JSON |
| `safari_get_indexed_db` | `dbName, storeName, limit?` | Read IndexedDB |
| `safari_list_indexed_dbs` | — | List IndexedDB databases |

## WebKit/Safari Specific

| Tool | Signature | Notes |
|------|-----------|-------|
| `safari_check_pwa` | — | PWA readiness audit (icons, manifest, splash screens) |
| `safari_inspect_viewport` | — | Validate `<meta name=viewport>` against iOS Safari best practices |
| `safari_webkit_compat` | — | Check CSS properties against live Safari engine |
| `safari_safe_area_insets` | — | Read safe-area-inset values for notch/Dynamic Island |
| `safari_css_coverage` | — | Find unused CSS rules across stylesheets |

## Device Emulation

| Tool | Signature | Notes |
|------|-----------|-------|
| `safari_emulate` | `device?, width?, height?, userAgent?` | Emulate mobile device |
| `safari_reset_emulation` | — | Back to desktop mode |
| `safari_resize` | `width, height` | Resize Safari window |

## Permissions & Diagnostics

| Tool | Signature | Notes |
|------|-----------|-------|
| `safari_doctor` | — | Diagnose macOS permission chain (run FIRST when things don't work) |
| `safari_override_geolocation` | `latitude, longitude, accuracy?` | Mock geolocation |

## Utilities

| Tool | Signature | Notes |
|------|-----------|-------|
| `safari_clipboard_read` | — | Read clipboard text |
| `safari_clipboard_write` | `text` | Write to clipboard |
| `safari_wait` | `ms` | Fixed wait |
| `safari_wait_for` | `selector?, text?, timeout?` | Wait for element/text to appear |
| `safari_wait_for_new_tab` | `timeout?, urlContains?` | Wait for new tab (e.g. OAuth popup) |
| `safari_handle_dialog` | `action, text?` | Handle alert/confirm/prompt |
| `safari_run_script` | `steps: [{action, args}]` | Batch multiple actions in one call |
| `safari_reload_extension` | — | Hot-reload Safari MCP extension |
| `safari_get_computed_style` | `selector, properties?` | Get computed CSS for element |
| `safari_accessibility_snapshot` | `selector?, maxDepth?` | Full accessibility tree |
| `safari_performance_metrics` | — | Web Vitals (FCP, LCP, CLS), navigation timing, memory |
