# Demo Techniques for GitHub Repos

How to create convincing demos for tools that can't be screenshotted (permission issues) or don't have a GUI.

## Animated Terminal SVG

CSS-animated SVG simulating a terminal session. Pure SVG, no external hosting, works on GitHub, renders inline.

### Why SVG over GIF/video

| Format | GitHub renders inline | No external hosting | Animates | Editable |
|--------|:--:|:--:|:--:|:--:|
| GIF | ✅ | ✅ | ✅ | ❌ |
| Video (mp4) | ❌ requires click | ❌ needs hosting | ✅ | ❌ |
| Animated SVG | ✅ | ✅ | ✅ | ✅ |

### Structure

```xml
<svg viewBox="0 0 780 500">
  <!-- Window chrome: dark bg, traffic light dots, title bar -->
  <rect width="780" height="500" rx="10" fill="#1a1b26"/>
  <circle cx="18" cy="16" r="6" fill="#f7768e"/>  <!-- red -->

  <!-- Content with staggered reveal using opacity animations -->
  <text y="60" fill="#9ece6a" opacity="0">
    $ <animate attributeName="opacity" values="0;1" dur="0.5s" fill="freeze"/>
  </text>
  <text y="60" fill="#7aa2f7">
    > scrape ProductHunt
    <animate attributeName="opacity" values="0;0;1" dur="2s" fill="freeze"/>
  </text>
</svg>
```

### Key Techniques

**Staggered reveal**: Each line appears after the previous one by offsetting `values` timing:
```
values="0;0;0;1"  → appears at t=1.5s  (3 zeros × 0.5s each)
values="0;0;0;0;1" → appears at t=2s
```

**Opacity pulse**: Use `fill="freeze"` to keep final state after animation ends.

**Terminal color palette**:
| Element | Color |
|---------|-------|
| Prompt `$` | `#9ece6a` (green) |
| User command `>` | `#7aa2f7` (blue) |
| Output text | `#c0caf5` (light) |
| Comments/logs | `#565f89` (dim) |
| Success `✅` | `#9ece6a` (green) |
| Warning `⚠️` | `#e0af68` (yellow) |
| Error `❌` | `#f7768e` (red) |

### When to Use

- Screen recording permission not available
- Tool has no visual output (CLI/API)
- Want inline demo that works without clicking
- Need to show a multi-step process with timing

### When NOT to Use

- Tool has a visual GUI that's the main selling point → record real video
- Demo requires showing dynamic web content → real GIF
- One-step operation → static screenshot is enough
