# Victoria - Interactive iPad Coloring Book App

An interactive coloring book application for iPad designed for school-age children, featuring digital coloring, boundary detection, animations, and sound effects.

## Overview

Victoria transforms your PDF coloring book into an engaging, interactive digital experience where children can:
- Color with their fingers using an intuitive touch interface
- Receive immediate feedback when coloring outside the lines
- Enjoy celebrations when completing a page correctly
- Use a full color palette with eraser and undo/redo features
- Experience smooth, responsive drawing performance

## Target Audience

School-age children (ages 5-12)

## Technology Stack

- **Platform**: iOS (iPad optimized)
- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Drawing**: CoreGraphics + Custom Drawing Engine
- **Audio**: AVFoundation
- **Animations**: SwiftUI Animations + Core Animation
- **Minimum iOS Version**: iOS 16.0+

## Key Features

### Phase 1 (MVP)
- ✅ PDF page rendering
- ✅ Digital coloring with finger touch
- ✅ Boundary detection with visual/audio feedback
- ✅ Color palette selection
- ✅ Eraser tool
- ✅ Undo/Redo functionality
- ✅ Page completion detection with celebration animation
- ✅ Sound effects for interactions

### Phase 2 (Future)
- 🔄 Zoom and pan functionality
- 🔄 Apple Pencil support
- 🔄 Save and share colored pages
- 🔄 Progress tracking
- 🔄 Unlockable color palettes

## Project Structure

```
Victoria/
├── VictoriaApp/                 # Main iOS Application
│   ├── VictoriaApp.swift       # App entry point
│   ├── Models/                  # Data models
│   ├── Views/                   # SwiftUI views
│   ├── ViewModels/             # View models (MVVM)
│   ├── Services/               # Business logic
│   │   ├── ColoringEngine/    # Core coloring logic
│   │   ├── BoundaryDetector/  # Boundary detection
│   │   ├── PDFRenderer/       # PDF processing
│   │   └── AudioManager/      # Sound effects
│   ├── Resources/              # Assets, sounds, etc.
│   └── Utilities/              # Helper functions
├── Assets/                      # PDF coloring book pages
├── Sounds/                      # Audio files
└── Documentation/              # Technical docs

```

## Prerequisites

- macOS 13.0 or later
- Xcode 15.0 or later
- iPad running iOS 16.0+ for testing
- Swift 5.9+

## Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd Victoria
```

### 2. Add Your Coloring Book PDF

Place your PDF file in the `Assets/` directory:
```bash
cp /path/to/your/coloring-book.pdf Assets/coloring-book.pdf
```

### 3. Open in Xcode

```bash
open VictoriaApp/Victoria.xcodeproj
```

### 4. Build and Run

1. Select an iPad simulator or connected iPad device
2. Press `Cmd + R` to build and run

## Development Roadmap

### Week 1-2: Foundation
- [x] Project setup
- [ ] PDF import and page rendering
- [ ] Basic UI layout
- [ ] Page navigation

### Week 3-4: Core Coloring
- [ ] Touch-based drawing implementation
- [ ] Color palette UI
- [ ] Eraser tool
- [ ] Undo/Redo stack

### Week 5-6: Boundary Detection
- [ ] Image processing for boundary detection
- [ ] Flood fill algorithm implementation
- [ ] Boundary violation detection
- [ ] Visual and audio feedback

### Week 7-8: Polish
- [ ] Completion detection algorithm
- [ ] Celebration animations
- [ ] Sound effects integration
- [ ] Performance optimization
- [ ] Testing with kids

## Architecture Highlights

### Drawing Engine
- Custom `ColoringCanvas` view using SwiftUI Canvas
- Bitmap-based coloring with flood fill algorithm
- Real-time boundary checking using pixel color comparison

### Boundary Detection
- Pre-process PDF pages to extract boundary lines
- Create mask images for each colorable region
- Detect when drawing extends beyond masks
- Trigger haptic and audio feedback

### Performance
- Lazy loading of PDF pages
- Optimized bitmap operations
- Background thread processing for boundary checks
- Efficient undo/redo using command pattern

## Contributing

This is a private project. For questions or suggestions, please contact the project owner.

## License

All rights reserved. This project and the associated coloring book content are proprietary.

## Contact

Project Owner: [Your Name]
Email: [Your Email]

---

Built with ❤️ for creative kids
