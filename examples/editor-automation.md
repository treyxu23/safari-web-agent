# Example: Automate a Rich Text Editor (ProseMirror)

Real-world example showing how to correctly fill a ProseMirror-based editor — Notion, Linear, or any modern rich text editor.

## The Problem

`DOMNodeInserted`? ProseMirror doesn't use it. `innerHTML` = `"text"`? ProseMirror's internal state model (a tree of nodes) doesn't know about it. Submit the form? ProseMirror serializes from its internal model — and sends the OLD content.

This is the #1 reason Playwright/Selenium "fills" an editor but the submission still has old data.

## The Solution

`CMD+V` via OS-level CGEvent.
The OS pasteboard pipeline triggers ProseMirror's native `handlePaste` hook → internal state updates → `dispatchTransaction` fires → UI re-renders. DOM text, internal model, and visual display are all in sync.

## Step-by-Step (Notion example)

### 1. Navigate to the editor

```
safari_navigate(url="https://notion.so/your-workspace/your-page")
safari_wait(3000)
```

### 2. Click into the editor to focus

```
safari_click(ref="0_15")  // ref for the ProseMirror editor div
safari_wait(500)
```

### 3. Fill with native_type (NOT safari_fill)

```
// CORRECT: Use safari_native_type
safari_native_type(
  value="This is the content I want to write. It will be properly synced with ProseMirror's internal state.",
  selector=".ProseMirror"
)
```

### 4. Verify the content is actually there

```
safari_verify_state(
  selector=".ProseMirror",
  expected="This is the content I want to write"
)
// → Returns { match: true/false, mode: "prosemirror", actual: "..." }
```

### 5. If verification fails, retry

```
// Sometimes the first paste doesn't register. Retry:
safari_native_type(
  value="This is the content I want to write. It will be properly synced with ProseMirror's internal state.",
  selector=".ProseMirror"
)
safari_verify_state(selector=".ProseMirror", expected="This is the content")

// If STILL failing, try clicking the editor first, then native_type:
safari_click(ref="0_15")
safari_wait(300)
safari_native_type(value="content", selector=".ProseMirror")
```

### 6. Submit/Save

```
// Notion auto-saves, but for other editors:
safari_native_click(text="Save")
// or
safari_native_keyboard(key="enter", modifiers=["cmd"])
```

## Common Pitfall: safari_fill "looks right" but isn't

```
// WRONG — this is the most common mistake:
safari_fill(selector=".ProseMirror", value="My content")
safari_native_click(text="Save")
// → The editor SHOWS "My content", but ProseMirror's internal model
//   still has the old content. The save sends OLD data.

// CORRECT:
safari_native_type(value="My content", selector=".ProseMirror")
safari_verify_state(selector=".ProseMirror", expected="My content")
safari_native_click(text="Save")
```

## Why This Works Across Frameworks

| Framework | Used by | How native_type works |
|-----------|---------|----------------------|
| **ProseMirror** | Notion, Linear, Atlassian | `handlePaste` hook → `tr.replaceWith()` → `dispatch()` |
| **Draft.js** | Medium, old Facebook | `handlePaste()` → `EditorState.push()` |
| **Slate** | GitBook, Outline | `insertData` → `Transforms.insertFragment()` |
| **Lexical** | New Facebook, Discord | `$insertNodes()` via paste command |
| **Quill** | Many SaaS apps | `clipboard.matchers` → `updateContents()` |
| **Tiptap** | Modern SaaS | ProseMirror under the hood — same as above |

All of them handle native paste events. None of them handle `innerHTML` changes.

## Key Takeaways

- **ALWAYS verify**: After `safari_native_type`, call `safari_verify_state`. It's the only way to know if the content is really there.
- **Never use `safari_fill` on rich text editors**: It's always `safari_native_type` for contenteditable/ProseMirror/Draft.js fields.
- **Code editors are different**: Monaco/CodeMirror/Ace → use `safari_replace_editor`, not `safari_native_type`.
