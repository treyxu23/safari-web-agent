# Creating GitHub Tokens via Safari MCP

Pattern for automating GitHub personal access token (classic) creation through Safari MCP. Useful when setting up a new machine or regenerating tokens with specific scopes.

## Prerequisites

- Safari MCP connected and running
- User already logged into GitHub in Safari
- Target scopes identified beforehand

## Workflow

### Step 1: Navigate to token creation page

```
safari_navigate("https://github.com/settings/tokens")
```

If GitHub shows a sudo-mode challenge (blue box with "Verify via email"):
- **This cannot be automated** — Safari MCP cannot complete sudo mode
- Tell the user: "GitHub needs you to verify identity. Go to Safari → click 'Verify via email' → enter the code from your email → then tell me to continue."
- After they complete it, re-navigate to the token page

### Step 2: Open the new token form

```
safari_evaluate("window.location.href = 'https://github.com/settings/tokens/new'")
```

Using `safari_evaluate` for navigation is more reliable than `safari_click` on the "Generate new token" dropdown, which often fails to expand the `<details>` element.

### Step 3: Fill the form with JavaScript

GitHub's token creation form has checkbox-heavy markup that's hard to interact with via individual clicks. Batch-fill with `safari_evaluate`:

```javascript
// Set note (name)
const note = document.querySelector('#oauth_access_description, input[name="oauth_access[description]"]');
note.value = 'hermes-agent-ci';
note.dispatchEvent(new Event('input', {bubbles: true}));

// Set expiration to "No expiration"
const exp = document.querySelector('#expiration, select[name="oauth_access[expiration]"]');
if (exp) { exp.value = ''; exp.dispatchEvent(new Event('change', {bubbles: true})); }

// Check required scopes
['repo', 'workflow', 'read:org', 'user'].forEach(scope => {
  const cb = document.querySelector(`input[type="checkbox"][value="${scope}"]`);
  if (cb && !cb.checked) {
    cb.checked = true;
    cb.dispatchEvent(new Event('change', {bubbles: true}));
  }
});
```

### Step 4: Click Generate

```
safari_click(text="Generate token")
safari_wait(2000)
```

### Step 5: Extract the token

```javascript
// The token appears in plain text on the confirmation page
const match = document.body.innerText.match(/ghp_[a-zA-Z0-9]{35,}/);
return match ? match[0] : 'NOT_FOUND';
```

## Pitfalls

### "Note has already been taken"

GitHub enforces unique token names. If the name already exists (even from a previously deleted token), you'll see this error. Use a unique suffix: `hermes-agent-ci`, `hermes-agent-v2`, etc.

The error persists even after deleting the old token — GitHub keeps a namespace registry. The simplest fix: append a timestamp or random string.

### Expiry dropdown won't open via click

GitHub's expiry dropdown is a custom `<details>` element. `safari_click` often fails to expand it. Use `safari_evaluate` to set the select value directly.

### Token not immediately active

Newly created tokens can take 5-10 seconds to propagate. If `gh auth login --with-token` or API calls fail immediately after creation, wait and retry.

### Sudo mode blocks all automation

GitHub requires periodic re-authentication (sudo mode) for sensitive pages. When Safari MCP hits this, the only option is to tell the user to manually authenticate, then continue.

## Token Scope Quick Reference

| Scope | Needed for |
|-------|-----------|
| `repo` | Push/pull code, create repos, manage PRs |
| `workflow` | Push `.github/workflows/` files, trigger Actions |
| `read:org` | Read org membership (needed for `gh auth status`) |
| `user` | Update user profile, read user data |

**Minimum set for a full-featured Hermes agent**: `repo`, `workflow`, `read:org`, `user`.
