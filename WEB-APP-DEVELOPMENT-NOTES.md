# Victoria Web App - Complete Development Notes

## Project Overview

Interactive coloring book web application for children (ages 5-12) featuring number-themed pages with rhyming words. Primary target devices are iPad/iPhone with desktop support.

**Branch**: `claude/web-app-only-011CV4nxBQnNmtK15assLMD7`

---

## Architecture

### File Structure
```
web-app/
├── index.html              ← ALL CODE IS HERE (self-contained)
├── images/                 ← Coloring page PNGs (15 images)
├── js/                     ← UNUSED (legacy files)
└── css/                    ← UNUSED (styles inline in index.html)
```

### Key Design Decisions
- **Single-file app**: All HTML, CSS, and JavaScript in `index.html`
- **Dual canvas system**: Background canvas (coloring page) + drawing canvas (user strokes)
- **Vanilla JavaScript**: No external dependencies
- **Touch-first design**: Optimized for iPad/iPhone with desktop fallback

---

## Content Pages

Based on "From 1 to 10 with Rhymes":
- **Page 1 (ONE)**: Sun, Fun, Run, Bun
- **Page 2 (TWO)**: Tattoo, Cockatoo, I Am Too, Fondue
- **Page 3 (THREE)**: Tree, Agree, Free, Debris
- **Page 4 (FOUR)**: Door, Snore, Roar, Core

---

## Feature History

### Phase 1: Spacing Optimizations (Session 2025-11-13)

**Problem**: Coloring pictures not utilizing available viewport space efficiently

**Solution**:
- Reduced padding: Desktop 5px (was 10px), Mobile 2px
- Reduced gaps: Desktop 10px (was 20px), Mobile 5px
- Tightened canvas constraints:
  - Desktop: `calc(100vh - 10px)` → **30px saved**
  - Mobile Portrait: `calc(100vh - 180px)` → **70px saved**
  - Tablet Landscape: `calc(100vh - 110px)` → **40px saved**
- Increased canvas width: 98vw (was 95vw) on mobile

**Result**: 50-100px more canvas space across devices

---

### Phase 2: Zoom/Pan Functionality (Session 2025-11-17)

**Problem**: Users cannot zoom for detailed coloring work

**Implementation**:
1. ✅ Zoom controls UI (top-left panel)
2. ✅ Zoom range: 1x to 3x (0.2x increments)
3. ✅ Mouse wheel zoom (desktop)
4. ✅ Pinch-to-zoom (touch devices)
5. ✅ Pan with Shift+Drag or Right-Click (desktop)
6. ✅ Pan with two-finger drag (touch)
7. ✅ Auto-reset zoom when loading new pictures
8. ✅ Auto-center when returning to 1x scale

**Bug Fixes**:
1. Canvas pixelation when zoomed → High-quality image rendering
2. Boundary sound inconsistency with zoom → Zoom-independent detection
3. Initial zoom scale issue → Proper reset to scale 1
4. Image off-center after pan → Auto-center at scale 1
5. Cursor staying crosshair → Only show 'grabbing' when actively panning

**Files Modified**: `index.html` (lines 281-352, 601-615, 1323-1513)

---

### Phase 3: Boundary Detection & Sound System (Ongoing)

#### Current Implementation

**Boundary Detection Logic** (`index.html:692-862`):

1. **`isInsideDrawingArea(x, y, brushRadius)`** (lines 692-751):
   - Checks 8-16 points around brush circumference
   - Detects if brush edge touches black lines (threshold < 128 RGB)
   - Measures line thickness and penetration depth
   - Allows 50% penetration into black lines before triggering sound
   - Returns `false` (triggers sound) if penetration > 50% of line thickness

2. **`measurePenetrationDepth(centerX, centerY, angle, brushRadius, lineThickness)`** (lines 753-801):
   - Calculates brush edge position
   - Casts ray backward from edge toward center
   - Measures distance traveled while still on black pixels
   - Returns penetration depth (capped at line thickness)

3. **`estimateLineThickness(x, y, angle)`** (lines 803-862):
   - Measures in radial direction (same as penetration)
   - Casts ray outward from edge point
   - Casts ray inward toward center
   - Returns total line thickness in penetration direction

**Sound System** (`index.html:649-690`):
- Web Audio API oscillator (200Hz square wave)
- Throttled to max once per 200ms
- Auto-resume on user interaction if suspended
- Plays when coloring crosses 50% of line thickness

---

## Current Session: Penetration Detection Issue (2025-12-01)

### Problem Report

**User Observation**: Sound triggers much sooner than 50% penetration, especially when zoomed in

### Design Requirements (User Clarification)

**Allowed coloring zones**:
```
[White drawable area - 100% ALLOWED] | [Black line edge] → [0-50% into black: ALLOWED] → [50-100%: SOUND]
```

**Key principles**:
1. White area = completely free to color (no restrictions)
2. Black lines = tolerance/buffer zone
3. Can color ON TOP of black lines up to 50% of their thickness
4. Sound triggers only when crossing MORE than 50% through a black line

### Analysis Task

Need to analyze why sound triggers earlier than 50% penetration:

**Potential issues to investigate**:
1. **Coordinate scaling**: Zoom affects brush radius but not boundary canvas coordinates?
2. **Line thickness measurement**: Measuring in wrong direction (perpendicular vs radial)?
3. **Penetration calculation**: Starting point incorrect (edge vs center)?
4. **Brush radius**: Detection zone doesn't match actual brush size when zoomed?
5. **Pixel rounding**: Math.round() causing measurement errors at different zoom levels?
6. **Canvas resolution**: Boundary canvas vs drawing canvas resolution mismatch?

**Debug logs present** (line 734):
- Shows penetration depth, brush radius, line thickness, allowed penetration
- Should help identify where calculation goes wrong

**Next steps**:
1. Analyze the three functions in detail
2. Check coordinate transformations with zoom
3. Verify line thickness measurement direction
4. Test with debug logs at various zoom levels
5. Report findings and propose fix

---

## Technical Details

### App State Object

```javascript
app = {
    currentView: 'gallery',
    currentPage: null,
    currentPictureIndex: null,
    selectedColor: '#FF0000',
    currentTool: 'brush',
    isDrawing: false,
    undoStack: [],
    ctx: null,                    // Background canvas context
    drawingCtx: null,             // Drawing canvas context
    boundaryCanvas: null,         // Hidden canvas for detection
    boundaryCtx: null,
    lastX: 0,
    lastY: 0,
    audioContext: null,
    lastOutOfBoundsSound: 0,
    canvasListenersAdded: false,
    canvasReadyForDrawing: false,
    imageBounds: null,
    resolutionScale: null,        // devicePixelRatio (capped at 2x)
    zoom: {
        scale: 1,                 // Current zoom (1-3x)
        translateX: 0,
        translateY: 0,
        minScale: 1,
        maxScale: 3,
        step: 0.2,
        isPanning: false,
        lastPanX: 0,
        lastPanY: 0,
        pinchStartDistance: 0,
        pinchStartScale: 1
    }
}
```

### Canvas Setup

**Resolution scaling** (`index.html:1028-1029`):
```javascript
const resolutionScale = Math.min(window.devicePixelRatio || 1, 2);
const canvasSize = displaySize * resolutionScale;
```

**Purpose**: High-DPI display support without performance penalty

### Drawing System

**Brush size** (`index.html:1201-1210`):
```javascript
const baseBrushDiameter = 8;  // Constant visual size
const brushDiameter = (baseBrushDiameter / app.zoom.scale) * (app.resolutionScale || 1);
const actualBrushRadius = brushDiameter / 2;
```

**Coordinate transformation** (`index.html:1252-1282`):
- `getBoundingClientRect()` includes CSS transforms (zoom/pan)
- Maps screen coordinates to canvas internal coordinates
- Accounts for resolution scaling

---

## Colors Available

```javascript
['#FF0000', '#FF8C00', '#FFD700', '#00FF00', '#0000FF',
 '#9370DB', '#FF69B4', '#8B4513', '#000000', '#FFFFFF']
```

---

## Event Listeners

### Drawing Canvas
- `mousedown` → `startDraw()`
- `mousemove` → `draw()`
- `mouseup` → `stopDraw()`
- `mouseout` → `stopDraw()`
- `touchstart` → `handleTouch()` (converts to mouse events)
- `touchmove` → `handleTouch()`
- `touchend` → `stopDraw()`
- `contextmenu` → Prevent (allows right-click pan)

### Zoom Controls
- `wheel` → `handleWheel()` (zoom with mouse wheel)
- Two-finger touch → `handlePinchStart/Move/End()`
- Zoom buttons → `zoomIn()`, `zoomOut()`, `resetZoom()`

---

## Known Working Features

✅ Gallery view with page selection
✅ Type 1 page layout (4 pictures + center circle)
✅ Coloring canvas with brush/eraser
✅ Color palette (10 colors)
✅ Undo functionality (20 state stack)
✅ Clear canvas
✅ Zoom/pan (1x to 3x)
✅ Touch gestures (pinch, pan)
✅ High-DPI rendering
✅ Boundary detection (basic)
✅ Out-of-bounds sound
✅ Responsive design (desktop, mobile, tablet)

---

## Known Issues

⚠️ **Penetration detection triggers sound too early** (especially when zoomed)
- Sound plays before reaching 50% line thickness penetration
- Investigation in progress

---

## Device Testing

### Desktop (Chrome/Firefox/Safari)
- ✅ Mouse drawing
- ✅ Mouse wheel zoom
- ✅ Shift+Drag / Right-Click pan
- ✅ Keyboard shortcuts (if any)

### iPad (Safari)
- ✅ Single finger drawing
- ✅ Pinch-to-zoom
- ✅ Two-finger pan
- ✅ Touch-friendly UI

### iPhone (Safari)
- ✅ Portrait mode layout
- ✅ Touch gestures
- ✅ Responsive controls

---

## Performance Optimizations

1. **Canvas resolution capped at 2x** (line 1028): Prevents excessive memory on 3x devices
2. **Sound throttled to 200ms** (line 653): Avoids audio spam
3. **CSS transforms for zoom** (line 1377): GPU-accelerated
4. **Undo stack limited to 20** (line 1362): Prevents memory bloat
5. **willReadFrequently hint** (line 1065): Optimizes getImageData calls

---

## Deployment

**Current hosting**: Local/testing only

**Future deployment options**:
1. GitHub Pages (static hosting)
2. Netlify (CDN + HTTPS)
3. Vercel (edge functions if needed)
4. AWS S3 + CloudFront

**Requirements**:
- Static file hosting only
- HTTPS for Web Audio API
- CORS headers for cross-origin images (if using external CDN)

---

## Future Enhancements (Potential)

1. Save/export drawing as image
2. Share drawings via URL
3. Progress tracking (% completion)
4. Multiple brush sizes
5. Color mixing/custom colors
6. Animation on completion
7. Sound effects for coloring (not just boundary)
8. Parental dashboard
9. Offline support (PWA)
10. Multilingual support

---

## Git Workflow

**Main branch**: (Not specified - iOS app branch)
**Web-app branch**: `claude/web-app-only-011CV4nxBQnNmtK15assLMD7`

**Commit conventions**:
- Feature: "Add zoom/pan functionality"
- Fix: "Fix boundary sound inconsistency with zoom"
- Docs: "Update development notes"

**Push command**:
```bash
git push -u origin claude/web-app-only-011CV4nxBQnNmtK15assLMD7
```

---

## Important Notes

1. **index.html is self-contained**: All code inline, no external JS/CSS
2. **Legacy files exist but unused**: `js/app.js`, `js/type1-page.js`, `css/styles.css`
3. **Boundary canvas is hidden**: Only used for pixel detection, never displayed
4. **Audio requires user interaction**: Web Audio API policy compliance
5. **Zoom state resets per picture**: Intentional UX decision

---

## Session History

- **2025-11-13**: Spacing optimizations
- **2025-11-17**: Zoom/pan implementation + 5 bug fixes
- **2025-12-01**: Penetration detection analysis (in progress)

---

**Last Updated**: 2025-12-01
**Status**: Active development - investigating penetration detection issue
