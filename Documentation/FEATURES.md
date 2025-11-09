# Feature Specifications

## Phase 1: MVP Features

### F1: PDF Page Loading & Display

**User Story**: As a user, I want to see my coloring book pages on the iPad so I can choose which page to color.

**Requirements**:
- Import PDF from app bundle
- Display page thumbnails in a grid
- Select a page to open coloring view
- Pages display at full iPad resolution

**Acceptance Criteria**:
- [ ] PDF loads within 1 second
- [ ] All pages visible in gallery
- [ ] Tapping page opens coloring view
- [ ] Image quality is crisp on Retina display

**Technical Details**:
- Use PDFKit to load document
- Render pages at 2x resolution for Retina
- Cache rendered thumbnails

---

### F2: Finger-Based Digital Coloring

**User Story**: As a child, I want to color with my finger so I can fill in the pictures.

**Requirements**:
- Touch and drag to color
- Smooth, lag-free drawing
- Fill regions with selected color
- Visual feedback showing where finger is touching

**Acceptance Criteria**:
- [ ] Touch response < 16ms (60 FPS)
- [ ] Coloring appears under finger in real-time
- [ ] No lag or jitter during drawing
- [ ] Works across entire canvas

**Technical Details**:
- Use SwiftUI Canvas + DragGesture
- Implement flood fill algorithm
- Update bitmap on background thread
- Optimize touch sampling

**UI/UX**:
- Cursor circle follows finger
- Current color shown in cursor
- Touch area: entire canvas except toolbar

---

### F3: Boundary Detection & Feedback

**User Story**: As a child, I want to know when I color outside the lines so I can improve my coloring.

**Requirements**:
- Detect when coloring goes outside boundary lines
- Play sound effect when boundary crossed
- Show visual feedback (gentle animation)
- Provide haptic feedback (iPad vibration)

**Acceptance Criteria**:
- [ ] Boundary detected within 5ms
- [ ] Sound plays immediately (<50ms latency)
- [ ] Haptic triggers simultaneously
- [ ] Visual indicator appears (border flash or gentle shake)
- [ ] Feedback doesn't startle or frustrate child
- [ ] Repeated violations don't spam feedback (debounced)

**Technical Details**:
- Pre-process PDF to extract black lines as boundaries
- Create binary mask (boundary = 1, colorable = 0)
- Check mask on each touch point
- Debounce feedback to max 1 per 500ms per stroke

**Sound Design**:
- Gentle "oops" or "boop" sound (~200ms)
- Friendly tone, not alarming
- Volume: 60-70% of max

**Visual Feedback Options**:
1. Border briefly turns red at violation point
2. Canvas gently shakes (3px, 100ms)
3. Small "X" icon appears briefly

**Haptic**:
- UIImpactFeedbackGenerator with light impact

---

### F4: Page Completion Detection & Celebration

**User Story**: As a child, I want to see a celebration when I finish coloring a page so I feel accomplished.

**Requirements**:
- Automatically detect when page is completed well
- Show congratulatory animation
- Play success sound effect
- Haptic success pattern

**Completion Criteria**:
- At least 70% of colorable area filled
- Less than 10% of colored area outside boundaries
- At least 3 different colors used

**Acceptance Criteria**:
- [ ] Completion detected within 100ms of final stroke
- [ ] Animation is exciting and rewarding
- [ ] Sound is celebratory and age-appropriate
- [ ] Child clearly understands they succeeded
- [ ] Can dismiss celebration and continue coloring

**Technical Details**:
- Run completion check after each stroke
- Analyze bitmap: count colored vs total pixels
- Track boundary violations per page
- Trigger celebration when thresholds met

**Celebration Animation**:
- Confetti falling from top (200+ particles)
- "Great Job!" or "Amazing!" text with bounce
- Stars bursting from corners
- Duration: 3-5 seconds
- Auto-dismiss or tap to dismiss

**Sound**:
- Applause + success chime
- Duration: 3-5 seconds
- Uplifting, encouraging tone

---

### F5: Color Palette

**User Story**: As a child, I want to choose from many colors so I can make my picture colorful.

**Requirements**:
- Display 12-16 kid-friendly colors
- Large, easy-to-tap color swatches
- Show which color is currently selected
- Colors visible while coloring (non-intrusive)

**Acceptance Criteria**:
- [ ] All colors clearly visible
- [ ] Tap target ≥ 44x44 pts (Apple HIG)
- [ ] Selected color has clear indicator
- [ ] Color palette doesn't cover canvas
- [ ] One tap to select color

**Color Palette**:
1. Red (#FF0000)
2. Orange (#FF8C00)
3. Yellow (#FFD700)
4. Green (#00FF00)
5. Blue (#0000FF)
6. Purple (#9370DB)
7. Pink (#FF69B4)
8. Brown (#8B4513)
9. Black (#000000)
10. White (#FFFFFF)
11. Cyan (#00FFFF)
12. Magenta (#FF00FF)

**UI Design**:
- Horizontal scrolling row at bottom, OR
- Vertical column on left/right side
- Selected color: thicker border + scale up
- Color swatches: circles or rounded squares

---

### F6: Eraser Tool

**User Story**: As a child, I want to erase mistakes so I can try again.

**Requirements**:
- Dedicated eraser button
- Eraser removes coloring (makes pixels transparent)
- Visual eraser cursor
- Easy to switch between eraser and color

**Acceptance Criteria**:
- [ ] Eraser button clearly labeled/icon-based
- [ ] One tap activates eraser
- [ ] Eraser removes color smoothly
- [ ] Cursor shows eraser is active
- [ ] Switching back to color is easy

**Technical Details**:
- Set pixels to transparent (alpha = 0)
- Use same touch handling as coloring
- Eraser size: medium (20-30 pt diameter)

**UI**:
- Eraser icon: standard eraser symbol
- Active state: highlighted button
- Eraser cursor: circle with eraser icon inside

**Sound**:
- Soft erasing sound (like pencil on paper)
- Subtle, not distracting

---

### F7: Undo/Redo

**User Story**: As a child, I want to undo mistakes so I can keep my picture nice.

**Requirements**:
- Undo button reverses last action
- Redo button re-applies undone action
- Support at least 10 undo levels
- Visual indication when undo/redo unavailable

**Acceptance Criteria**:
- [ ] Undo reverses last stroke/fill
- [ ] Redo reapplies undone action
- [ ] Buttons disabled when stack empty
- [ ] Undo/redo happens instantly (<100ms)
- [ ] New action clears redo stack

**Technical Details**:
- Command pattern for undo/redo
- Store pixel diffs, not full bitmaps
- Max stack size: 50 commands
- Commands: ColorCommand, EraseCommand, FillCommand

**UI**:
- Standard undo/redo icons (curved arrows)
- Grayed out when unavailable
- Positioned in top toolbar
- Large enough for kids (≥44x44 pts)

**Sounds**:
- Undo: Whoosh backward
- Redo: Whoosh forward

---

## Phase 2: Future Features

### F8: Zoom & Pan (Future)

**User Story**: As a child, I want to zoom in for detailed coloring.

**Requirements**:
- Pinch to zoom in/out
- Two-finger pan to move around
- Zoom range: 1x to 4x
- Drawing accuracy maintained at all zoom levels

**Acceptance Criteria**:
- [ ] Smooth zoom animation
- [ ] Pan responds immediately
- [ ] Boundaries still detected correctly when zoomed
- [ ] Easy to reset to original zoom

---

### F9: Save & Share (Future)

**User Story**: As a user, I want to save completed pages so I can show them later.

**Requirements**:
- Save button exports colored page
- Save to Photos app
- Share via AirDrop, Messages, etc.
- Gallery of completed pages within app

---

### F10: Apple Pencil Support (Future)

**User Story**: As a user with Apple Pencil, I want to use it for more precise coloring.

**Requirements**:
- Detect Apple Pencil vs finger
- Optional: Pressure sensitivity
- Palm rejection
- Hover preview (iPad Pro)

---

### F11: Progress Tracking (Future)

**User Story**: As a child, I want to see which pages I've completed.

**Requirements**:
- Check mark on completed pages
- Progress percentage
- Unlockable achievements
- Special colors/stamps for completion

---

### F12: Custom Brushes (Future)

**User Story**: As a child, I want different brush sizes and patterns.

**Requirements**:
- Small, medium, large brush sizes
- Pattern brushes (stars, hearts, etc.)
- Texture brushes (crayon, marker, watercolor)

---

## UI/UX Guidelines

### Kid-Friendly Design Principles

1. **Large Touch Targets**: Minimum 44x44 pts (Apple HIG)
2. **High Contrast**: Easy to see colors and buttons
3. **Clear Feedback**: Always show what happened
4. **Simple Navigation**: Minimal steps between actions
5. **Forgiving**: Easy undo, hard to lose progress
6. **Encouraging**: Positive feedback, celebrate success
7. **No Text-Heavy Instructions**: Visual cues and icons
8. **Consistent Layout**: Tools always in same place

### Color Scheme

- **Primary Background**: White or light gray (canvas area)
- **UI Background**: Soft pastel (toolbar/palette areas)
- **Accent Color**: Bright, friendly (buttons and highlights)
- **Text**: Large, bold, kid-friendly font

### Iconography

- Use iOS SF Symbols where appropriate
- Custom icons for color palette
- Large, clear icons (24-32 pts)
- Labels optional (icons should be self-explanatory)

### Sounds

- All sounds optional (mute button in settings)
- Volume: Moderate (60-70%)
- Positive tone: Never harsh or scary
- Short duration: <500ms for feedback, <5s for celebrations

### Haptics

- Use sparingly: Only for important feedback
- Light to medium intensity
- Never vibrate continuously

---

## Accessibility

### Support for All Kids

1. **VoiceOver**: All buttons labeled for screen readers
2. **Large Text**: UI scales with system text size
3. **Colorblind Mode**: Patterns/textures in addition to colors
4. **Motor Challenges**: Adjustable tool sizes, slower timeouts
5. **Hearing Impaired**: Visual feedback for all audio cues

---

## Performance Requirements

| Metric | Target | Critical |
|--------|--------|----------|
| Drawing FPS | 60 | 45 |
| Touch Latency | <16ms | <50ms |
| Boundary Detection | <5ms | <10ms |
| Page Load | <1s | <2s |
| Memory Usage | <150MB | <250MB |
| Completion Check | <100ms | <200ms |

---

## Testing Checklist

### Functional Testing

- [ ] All pages load correctly
- [ ] Coloring works on all devices (iPad mini, iPad, iPad Pro)
- [ ] Boundary detection works on all pages
- [ ] Completion triggers correctly
- [ ] Undo/redo works for all actions
- [ ] Eraser removes color completely
- [ ] Audio plays on all devices
- [ ] Haptics work on supported devices

### Kid Testing

**Age 5-7**:
- [ ] Can select a color without help
- [ ] Understands boundary feedback
- [ ] Completes at least one page
- [ ] Finds undo button when needed
- [ ] Enjoys completion celebration

**Age 8-12**:
- [ ] Uses all tools effectively
- [ ] Completes multiple pages
- [ ] Understands completion criteria
- [ ] Engaged for 15+ minutes
- [ ] Provides feedback on features

### Edge Cases

- [ ] What happens if child scribbles everywhere?
- [ ] Can child color the same region multiple times?
- [ ] What if all colors used are the same?
- [ ] Can child erase everything and start over?
- [ ] What if iPad rotated during coloring?
- [ ] What if app backgrounded mid-coloring?

---

## Success Metrics

### Engagement
- Average session time: >10 minutes
- Pages completed per session: ≥1
- Return rate: >50% within 7 days

### Usability
- Time to first colored stroke: <10 seconds
- Boundary violations per page: <20
- Undo uses per page: <5

### Satisfaction
- Completion celebration triggered: ≥70% of pages
- App rating: ≥4.5 stars
- Kid requests to use again: >80%

---

## Out of Scope (V1)

- Multiplayer/sharing in real-time
- Social features
- In-app purchases
- User accounts/login
- Cloud sync
- Custom page creation
- AR features
- Animation of completed pages
- Stickers/stamps
- Text labels on images
