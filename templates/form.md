# Template: Form Automation

Copy this template and customize for your form-filling task.

## Setup

```javascript
// 1. Target form URL
const FORM_URL = "https://example.com/form"

// 2. Define field mappings
const FIELDS = [
  { selector: "#name", value: "John Doe", type: "input" },
  { selector: "#email", value: "john@example.com", type: "input" },
  { selector: "#bio", value: "Full bio text...", type: "richtext" },  // rich text!
  { selector: "#category", value: "Technology", type: "select" },
  { selector: "#file", value: "/path/to/file.pdf", type: "file" },
]
```

## Execution

### Step 1: Navigate & detect
```
safari_navigate(url="FORM_URL")
safari_detect_forms()  // → discover all form fields automatically
```

### Step 2: Fill fields by type

**For standard inputs:**
```
safari_fill(selector="#name", value="John Doe")
safari_fill(selector="#email", value="john@example.com")
```

**For rich text editors (ProseMirror/Draft.js/Slate):**
```
// DO NOT use safari_fill — it changes DOM but not framework state
// USE safari_native_type instead (clipboard paste pipeline)
safari_native_type(value="Full bio text...", selector="#bio")
// VERIFY
safari_verify_state(selector="#bio", expected="Full bio text...")
```

**For native <select> dropdowns:**
```
safari_select_option(selector="#category", value="Technology")
```

**For react-select v5 (Cloudflare, Stripe, dashboards):**
```
safari_react_select_set(ref="0_5", value="Technology")
```

**For file uploads:**
```
// Do NOT click the file input first
safari_upload_file(selector="#file", filePath="/path/to/file.pdf")
```

### Step 3: Batch fill (for simple forms)
```
// If all fields are standard inputs, batch them:
safari_fill_form([
  { selector: "#name", value: "John Doe" },
  { selector: "#email", value: "john@example.com" },
  { selector: "#phone", value: "555-0123" },
])
```

### Step 4: Verify critical fields
```
safari_verify_state(selector="#name", expected="John Doe")
safari_verify_state(selector="#email", expected="john@example.com")
// If any fail, re-fill with safari_native_type
```

### Step 5: Submit
```
// Option A: Click submit button (anti-bot safe)
safari_native_click(text="Submit")

// Option B: Press Enter (if form submits on Enter)
safari_native_keyboard(key="enter")

// Option C: Auto-detect submit + fill in one call
safari_fill_and_submit([
  { selector: "#name", value: "John Doe" },
  { selector: "#email", value: "john@example.com" },
])
```

### Step 6: Verify submission
```
safari_wait(2000)
safari_snapshot()  // → check for success message, redirect, etc.
safari_read_page(selector=".success-message")
```

## Pitfalls

- **Rich text editors**: Most common failure point. Always use `safari_native_type` for contenteditable/ProseMirror/Draft.js fields
- **react-select**: Must use `safari_react_select_set`, regular `safari_click` won't work
- **File inputs**: Never click file inputs before `safari_upload_file` — it auto-closes any open file dialog
- **Hidden fields**: `safari_detect_forms` only finds visible fields; check HTML source for hidden fields
- **CAPTCHA**: If the form has CAPTCHA, Safari Web Agent can't solve it — the user must intervene
