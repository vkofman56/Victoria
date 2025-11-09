# Technical Architecture

## System Overview

Victoria is an iOS iPad application that converts static PDF coloring pages into an interactive digital coloring experience with real-time boundary detection and feedback.

## Architecture Pattern

**MVVM (Model-View-ViewModel)** with SwiftUI
- Separation of concerns
- Testable business logic
- Reactive UI updates via Combine framework

## Core Components

### 1. PDF Processing Layer

#### PDFPageLoader
**Purpose**: Load and render PDF pages from the coloring book

**Responsibilities**:
- Import PDF document from Assets
- Extract individual pages
- Render pages at optimal resolution for iPad
- Cache rendered pages for performance

**Technologies**:
- PDFKit (iOS native framework)
- CGContext for rendering

**Key Methods**:
```swift
func loadPDF(from url: URL) -> PDFDocument?
func extractPage(at index: Int) -> PDFPage?
func renderPage(_ page: PDFPage, size: CGSize) -> UIImage
```

#### BoundaryExtractor
**Purpose**: Pre-process coloring pages to identify colorable regions and boundaries

**Responsibilities**:
- Convert PDF pages to high-resolution bitmap
- Detect black lines (boundaries) using color thresholding
- Create binary mask images (white = colorable, black = boundary)
- Generate flood-fill starting points for each region

**Algorithm**:
1. Render PDF page to bitmap
2. Apply color threshold (identify black pixels as boundaries)
3. Create inverted mask (boundaries = impassable)
4. Identify connected components (individual colorable regions)
5. Store boundary data for real-time checking

**Technologies**:
- Core Image for image processing
- vImage for high-performance pixel manipulation
- Core Graphics for bitmap operations

---

### 2. Drawing Engine

#### ColoringCanvas (SwiftUI View)
**Purpose**: Main interactive canvas where children draw

**Responsibilities**:
- Handle touch events (finger drawing)
- Render current coloring in real-time
- Display boundary lines overlay
- Update UI on color/tool changes

**Implementation**:
```swift
struct ColoringCanvas: View {
    @StateObject var viewModel: ColoringViewModel

    var body: some View {
        Canvas { context, size in
            // Draw base image
            // Draw user's coloring layer
            // Draw current stroke
        }
        .gesture(DragGesture(minimumDistance: 0)
            .onChanged { value in
                // Handle drawing
            }
        )
    }
}
```

#### DrawingEngine
**Purpose**: Core drawing logic and bitmap manipulation

**Responsibilities**:
- Maintain drawing bitmap (RGBA)
- Implement flood-fill algorithm for coloring
- Apply brush strokes with anti-aliasing
- Manage drawing layers

**Flood Fill Algorithm**:
```
Input: Touch point (x, y), selected color
1. Check if point is within bounds
2. Get starting pixel color
3. If starting pixel is boundary color -> trigger boundary feedback
4. Use queue-based flood fill:
   - Add starting point to queue
   - While queue not empty:
     - Get point from queue
     - If point color matches start color:
       - Set to selected color
       - Add adjacent points to queue
       - Check boundaries during fill
5. Return success/failure status
```

**Technologies**:
- Core Graphics (CGContext, CGImage)
- Accelerate framework for optimized pixel operations

---

### 3. Boundary Detection System

#### BoundaryDetector
**Purpose**: Real-time detection when coloring goes outside lines

**Responsibilities**:
- Monitor drawing strokes against boundary mask
- Detect when finger/drawing crosses boundary
- Trigger immediate feedback
- Track boundary violations per stroke

**Detection Algorithm**:
```
On each touch point:
1. Get pixel coordinate
2. Sample boundary mask at coordinate
3. If mask pixel is black (boundary):
   - Increment violation counter
   - If first violation in stroke:
     - Trigger feedback
   - Return violation=true
4. Else:
   - Allow coloring
   - Return violation=false
```

**Performance Optimization**:
- Sample every N pixels for long strokes
- Use lookup table for mask checking (O(1))
- Run detection on background thread
- Debounce feedback to avoid spam

#### FeedbackManager
**Purpose**: Provide multi-sensory feedback for boundary violations

**Responsibilities**:
- Play sound effects
- Trigger haptic feedback
- Show visual indicators (gentle shake, color flash)
- Manage feedback timing (avoid overwhelming user)

**Feedback Types**:
- **Boundary Violation**: Gentle "oops" sound + light haptic
- **Eraser Use**: Soft erasing sound
- **Color Selection**: Click sound
- **Undo/Redo**: Whoosh sound
- **Page Complete**: Celebration sound + confetti animation

---

### 4. Tool System

#### ColorPalette
**Purpose**: Color selection interface

**UI Design**:
- Grid of color swatches
- Large, kid-friendly touch targets (44x44 pts minimum)
- Visual indication of selected color
- Pre-defined kid-safe color palette (bright, appealing colors)

**Color Set**:
```swift
let kidFriendlyColors: [Color] = [
    .red, .blue, .green, .yellow, .orange, .purple,
    .pink, .brown, .black, .cyan, .mint, .indigo
]
```

#### Tool Types
```swift
enum ColoringTool {
    case brush(color: Color)
    case eraser
    case fillBucket(color: Color) // Flood fill
}
```

#### EraserTool
**Purpose**: Remove coloring

**Implementation**:
- Set pixels to transparent
- Visual eraser cursor following finger
- Adjustable size (small, medium, large)

---

### 5. Undo/Redo System

#### CommandPattern Implementation

**Purpose**: Enable undo/redo of all drawing operations

**Architecture**:
```swift
protocol DrawingCommand {
    func execute()
    func undo()
}

class ColorCommand: DrawingCommand {
    let affectedPixels: [(x: Int, y: Int, previousColor: Color)]
    let newColor: Color

    func execute() {
        // Apply coloring
    }

    func undo() {
        // Restore previous pixels
    }
}

class CommandManager {
    private var undoStack: [DrawingCommand] = []
    private var redoStack: [DrawingCommand] = []

    func execute(_ command: DrawingCommand)
    func undo()
    func redo()
}
```

**Stack Management**:
- Max stack size: 50 commands (memory optimization)
- Clear redo stack on new command
- Store only pixel differences (not full images)

---

### 6. Completion Detection

#### CompletionAnalyzer
**Purpose**: Detect when a coloring page is "completed well"

**Completion Criteria**:
1. **Coverage**: At least 70% of colorable regions have color
2. **Accuracy**: Less than 10% boundary violations
3. **Variety**: Multiple colors used (not all one color)

**Algorithm**:
```
func analyzeCompletion() -> CompletionStatus {
    1. Count total colorable pixels (from mask)
    2. Count colored pixels (non-white, non-boundary)
    3. Calculate coverage = colored / total

    4. Count pixels outside boundaries
    5. Calculate accuracy = 1 - (outside / colored)

    6. Count unique colors used

    7. If coverage >= 70% AND accuracy >= 90% AND colors > 2:
        return .complete(score: calculate())
    8. Else:
        return .incomplete(progress: coverage)
}
```

#### CelebrationView
**Purpose**: Show exciting celebration when page completed

**Animation**:
- Confetti particle system (200+ particles)
- "Great Job!" text with scale animation
- Star bursts from corners
- Sound effect: Applause + success chime
- Haptic: Success pattern

**Technologies**:
- SwiftUI animations
- SpriteKit for particle effects (optional)

---

### 7. Audio System

#### AudioManager
**Purpose**: Centralized audio playback

**Responsibilities**:
- Preload sound effects
- Play sounds on demand
- Manage volume and mixing
- Prevent audio overlap (e.g., multiple violation sounds)

**Sound Files** (needed in `Sounds/` folder):
- `boundary_violation.mp3` - Gentle "oops" (200ms)
- `eraser.mp3` - Soft erasing sound
- `color_select.mp3` - Click (100ms)
- `undo.mp3` - Whoosh backward
- `redo.mp3` - Whoosh forward
- `celebration.mp3` - Applause + chime (3-5s)

**Implementation**:
```swift
class AudioManager: ObservableObject {
    private var players: [String: AVAudioPlayer] = [:]

    func preloadSound(named: String)
    func play(sound: String, volume: Float = 1.0)
    func stopAll()
}
```

---

## Data Flow

### Drawing Flow
```
User Touch → ColoringCanvas → DrawingEngine → BoundaryDetector
                                   ↓                    ↓
                            Update Bitmap      Check Violation
                                   ↓                    ↓
                            Command Stack      FeedbackManager
                                   ↓                    ↓
                            Canvas Refresh    Audio + Haptic
```

### Completion Check Flow
```
User Completes Stroke → CompletionAnalyzer.checkProgress()
                                   ↓
                    Analyze Coverage + Accuracy
                                   ↓
                    If Complete → CelebrationView
                                   ↓
                         Update Progress Data
```

---

## Memory Management

### Optimization Strategies

1. **Bitmap Size**:
   - Target: 2048x2048 pixels max (iPad Pro resolution)
   - Use appropriate scale factor for device
   - RGBA 32-bit format

2. **Lazy Loading**:
   - Load only current and adjacent PDF pages
   - Unload pages not in view
   - Cache processed boundary masks

3. **Command Stack**:
   - Limit to 50 undo steps
   - Store pixel diffs, not full images
   - Compress old commands if needed

4. **Audio**:
   - Preload short sounds (<1MB each)
   - Use compressed formats (AAC, MP3)
   - Unload unused sounds

---

## Performance Targets

- **Drawing Latency**: <16ms (60 FPS)
- **Boundary Detection**: <5ms per touch point
- **Page Load Time**: <1 second
- **Memory Usage**: <150MB for app + active page
- **Completion Analysis**: <100ms

---

## Security & Privacy

- **No Network**: App works 100% offline
- **No Data Collection**: No analytics or tracking
- **Local Storage Only**: All data stays on device
- **Kid-Safe**: No ads, no in-app purchases (optional)

---

## Testing Strategy

### Unit Tests
- DrawingEngine algorithms
- BoundaryDetector accuracy
- CompletionAnalyzer logic
- CommandManager undo/redo

### UI Tests
- Touch handling
- Tool switching
- Page navigation
- Color selection

### Kid Testing
- 5-8 year olds: Basic coloring, feedback clarity
- 9-12 year olds: Advanced features, engagement
- Observe: Confusion points, enjoyment, completion rate

---

## Future Enhancements (Phase 2)

1. **Zoom & Pan**:
   - Pinch-to-zoom gesture
   - Two-finger pan
   - Maintain drawing accuracy at any zoom level

2. **Apple Pencil**:
   - Pressure sensitivity (optional)
   - Palm rejection
   - Pencil-specific tools

3. **Gallery**:
   - Save completed pages
   - Export to Photos
   - Share via AirDrop

4. **Progress System**:
   - Track completed pages
   - Unlock special colors/stickers
   - Achievements

---

## Technology Stack Details

| Component | Technology | Why |
|-----------|-----------|-----|
| UI | SwiftUI | Modern, declarative, animation-friendly |
| Drawing | Core Graphics | Low-level bitmap control |
| PDF | PDFKit | Native iOS PDF support |
| Image Processing | Core Image, vImage | High-performance pixel operations |
| Audio | AVFoundation | Low-latency sound |
| Haptics | UIFeedbackGenerator | Native haptic feedback |
| Architecture | MVVM + Combine | Reactive, testable |
| Language | Swift 5.9+ | Modern, safe, performant |

---

## File Structure (Detailed)

```
VictoriaApp/
├── VictoriaApp.swift                    # App entry
├── Models/
│   ├── ColoringPage.swift              # Page data model
│   ├── DrawingCommand.swift            # Command protocol
│   └── CompletionStatus.swift          # Completion data
├── Views/
│   ├── PageGalleryView.swift           # Page selection
│   ├── ColoringView.swift              # Main coloring view
│   ├── ColoringCanvas.swift            # Drawing canvas
│   ├── ColorPaletteView.swift          # Color picker
│   ├── ToolbarView.swift               # Undo/redo/tools
│   └── CelebrationView.swift           # Completion animation
├── ViewModels/
│   ├── ColoringViewModel.swift         # Main VM
│   └── PageGalleryViewModel.swift      # Gallery VM
├── Services/
│   ├── PDFLoader.swift                 # PDF import
│   ├── BoundaryExtractor.swift         # Boundary processing
│   ├── DrawingEngine.swift             # Core drawing
│   ├── BoundaryDetector.swift          # Violation detection
│   ├── CompletionAnalyzer.swift        # Completion check
│   ├── CommandManager.swift            # Undo/redo
│   ├── AudioManager.swift              # Sound effects
│   └── FeedbackManager.swift           # Haptic + visual
├── Resources/
│   ├── Assets.xcassets                 # Images, colors
│   └── Sounds/                         # Audio files
└── Utilities/
    ├── Extensions/                     # Swift extensions
    └── Constants.swift                 # App constants
```

---

## Next Steps

1. Set up Xcode project with this structure
2. Implement PDFLoader and page rendering
3. Build basic ColoringCanvas with touch handling
4. Implement DrawingEngine with flood fill
5. Add BoundaryDetector
6. Integrate audio and feedback
7. Implement undo/redo
8. Add completion detection
9. Polish UI and animations
10. Test with kids!
