# Victoria - Interactive Coloring Book

Interactive coloring book platform available in TWO versions:
1. **Web App** - For YouTube integration and instant browser access
2. **Native iOS App** - For premium iPad experience

Designed for school-age children featuring digital coloring, touch interaction, and engaging feedback.

## 🌐 Version 1: Web App (NEW!)

**Perfect for YouTube sharing and instant access on any device!**

### Features
- ✨ **Type 1 Pages**: 4 pictures per page with center circle selection
- 🎯 **Blinking Guide**: Animated circle guides students to select pictures
- 🎨 **Touch Coloring**: Draw with finger on iPad/iPhone
- 🖌️ **Full Toolset**: Brush, fill bucket, eraser, undo
- 📱 **Mobile Optimized**: Works in Safari on iOS devices
- 🔗 **No Download**: Direct link from YouTube videos
- 🆓 **Free Hosting**: Deploy on GitHub Pages, Netlify, or Vercel

### Quick Start
```bash
cd web-app
# Open index.html in browser or deploy to web
```

📖 **Documentation**: See `web-app/README.md` for complete setup
🚀 **Deployment**: See `web-app/DEPLOYMENT.md` for YouTube integration
📝 **Add Pages**: See `web-app/EXAMPLE_ADD_PAGES.md` for customization

---

## 📱 Version 2: Native iOS App

**Premium iPad experience with advanced features!**

### Features
- ✅ PDF page rendering with native performance
- ✅ Digital coloring with finger/Apple Pencil support
- ✅ Boundary detection with haptic/audio feedback
- ✅ Color palette with 12 vibrant colors
- ✅ Eraser and undo/redo tools
- ✅ Page completion detection with celebration animation
- ✅ Smooth 60 FPS drawing performance

### Quick Start
```bash
# Requires Xcode on macOS
open VictoriaApp/Victoria.xcodeproj
# Build and run on iPad simulator or device
```

📖 **Documentation**: See `Documentation/SETUP_GUIDE.md`
🏗️ **Architecture**: See `Documentation/ARCHITECTURE.md`
✨ **Features**: See `Documentation/FEATURES.md`

---

## Which Version Should I Use?

### Choose **Web App** if you want to:
- ✅ Share directly from YouTube videos
- ✅ Reach users on ANY device (iPad, iPhone, Android, Desktop)
- ✅ Avoid App Store submission
- ✅ Free hosting and instant updates
- ✅ No download required for users

### Choose **Native iOS App** if you want to:
- ✅ Best possible performance
- ✅ Full iPad optimization
- ✅ Apple Pencil support
- ✅ Offline functionality
- ✅ App Store distribution
- ✅ Advanced iOS features (better haptics, etc.)

### Or Use BOTH!
- Market on YouTube with web version
- Offer premium iOS app as upgrade

---

## Target Audience

School-age children (ages 5-12)

## Technology Stacks

### Web App
- **Frontend**: HTML5, CSS3, Vanilla JavaScript
- **Canvas API**: HTML5 Canvas for drawing
- **Touch Events**: Native touch support for iOS/Android
- **Hosting**: GitHub Pages, Netlify, or Vercel (FREE)
- **No Dependencies**: Pure vanilla code, no frameworks

### Native iOS App
- **Platform**: iOS (iPad optimized)
- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Drawing**: CoreGraphics + Custom Drawing Engine
- **Audio**: AVFoundation
- **Animations**: SwiftUI Animations + Core Animation
- **Minimum iOS Version**: iOS 16.0+

## Project Structure

```
Victoria/
├── web-app/                     # 🌐 Web Application
│   ├── index.html              # Main HTML entry
│   ├── css/
│   │   └── styles.css         # All styles and animations
│   ├── js/
│   │   ├── app.js            # App logic and view management
│   │   ├── type1-page.js     # Type 1 page with circle selection
│   │   └── coloring-engine.js # Drawing and coloring
│   ├── images/                # Coloring book images
│   ├── README.md              # Web app setup guide
│   ├── DEPLOYMENT.md          # How to deploy to web
│   └── EXAMPLE_ADD_PAGES.md   # How to add pages
│
├── VictoriaApp/                 # 📱 Native iOS Application
│   ├── VictoriaApp.swift       # App entry point
│   ├── Models/                  # Data models
│   ├── Views/                   # SwiftUI views
│   ├── ViewModels/             # View models (MVVM)
│   ├── Services/               # Business logic
│   │   ├── ColoringEngine/    # Core coloring logic
│   │   ├── BoundaryDetector/  # Boundary detection
│   │   ├── PDFRenderer/       # PDF processing
│   │   └── AudioManager/      # Sound effects
│   └── Utilities/              # Helper functions
│
├── Documentation/              # 📚 Technical Documentation
│   ├── ARCHITECTURE.md         # iOS app architecture
│   ├── FEATURES.md            # Feature specifications
│   └── SETUP_GUIDE.md         # iOS app setup
│
├── Assets/                      # PDF coloring book pages (iOS)
├── Sounds/                      # Audio files (iOS)
└── README.md                   # This file
```

## Prerequisites

### For Web App
- Any modern web browser (Safari, Chrome, Firefox)
- Text editor (VS Code, Sublime, or any)
- Optional: Git for deployment

### For iOS App
- macOS 13.0 or later
- Xcode 15.0 or later
- iPad running iOS 16.0+ for testing
- Swift 5.9+

## Getting Started

### Web App Quick Start

```bash
# Clone repository
git clone <repository-url>
cd Victoria/web-app

# Open in browser
open index.html

# Or deploy to web (see DEPLOYMENT.md)
```

### iOS App Quick Start

```bash
# Clone repository
git clone <repository-url>
cd Victoria

# Add your PDF
cp /path/to/coloring-book.pdf Assets/

# Open in Xcode
open VictoriaApp/Victoria.xcodeproj

# Build and run (Cmd+R)
```

## Key Implementation Highlights

### Web App Features
- **Type 1 Pages**: 4-picture grid with center circle selection
- **Blinking Animation**: CSS-based quadrant blinking to guide users
- **Touch Drawing**: HTML5 Canvas with touch event handling
- **Flood Fill**: JavaScript implementation for color filling
- **Responsive**: Works on all screen sizes
- **Zero Dependencies**: Pure vanilla JavaScript

### iOS App Features
- **Drawing Engine**: Custom SwiftUI Canvas with CoreGraphics
- **Boundary Detection**: Image processing to extract boundaries
- **Haptic Feedback**: UIFeedbackGenerator for tactile response
- **Audio**: AVFoundation for sound effects
- **Command Pattern**: Efficient undo/redo implementation
- **Performance**: 60 FPS drawing with optimized bitmap operations

## Contributing

This is a private project. For questions or suggestions, please contact the project owner.

## License

All rights reserved. This project and the associated coloring book content are proprietary.

## Contact

Project Owner: [Your Name]
Email: [Your Email]

---

Built with ❤️ for creative kids
