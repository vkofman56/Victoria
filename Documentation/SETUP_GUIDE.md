# Victoria Setup Guide

Complete guide to setting up and running the Victoria interactive coloring book app.

## Prerequisites

### Required
- **macOS**: 13.0 (Ventura) or later
- **Xcode**: 15.0 or later ([Download from Mac App Store](https://apps.apple.com/us/app/xcode/id497799835))
- **iOS Device or Simulator**: iPad running iOS 16.0+
- **Coloring Book PDF**: Your PDF coloring book file

### Optional
- **Apple Developer Account**: Required for testing on physical devices and App Store distribution
- **iPad with Apple Pencil**: For optimal testing (not required for development)

---

## Step 1: Install Xcode

1. Open Mac App Store
2. Search for "Xcode"
3. Click "Get" or "Download"
4. Wait for installation (this may take 30-60 minutes)
5. Open Xcode and accept license agreement
6. Install additional components when prompted

### Verify Installation
```bash
xcode-select --version
# Should output: xcode-select version 2396 (or similar)

swift --version
# Should output: Swift version 5.9 (or later)
```

---

## Step 2: Create Xcode Project

Since this repository contains Swift code but not an .xcodeproj file, you need to create the Xcode project:

### Option A: Create New Project in Xcode (Recommended)

1. **Open Xcode**
2. **Create New Project**:
   - Click "Create a new Xcode project"
   - Select "iOS" > "App"
   - Click "Next"

3. **Configure Project**:
   - **Product Name**: Victoria
   - **Team**: Select your team (or None for simulator only)
   - **Organization Identifier**: com.yourname.victoria
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Storage**: None
   - **Include Tests**: Optional
   - Click "Next"

4. **Save Location**:
   - Navigate to this repository's `VictoriaApp/` folder
   - Click "Create"

5. **Copy Source Files**:
   - Delete the default `ContentView.swift` and `VictoriaApp.swift` files Xcode created
   - In Finder, copy all files from the repository's `VictoriaApp/VictoriaApp/` folder into the Xcode project
   - In Xcode, right-click project > "Add Files to Victoria"
   - Select all the copied files and folders
   - Check "Copy items if needed"
   - Check "Create groups"
   - Add to target: Victoria

### Option B: Use Swift Package (Advanced)

If you're familiar with Swift Package Manager, you can structure this as a package. See Documentation/ADVANCED_SETUP.md.

---

## Step 3: Add Your PDF Coloring Book

1. **Prepare PDF**:
   - Ensure your PDF meets requirements (see Assets/README.md)
   - Rename to: `coloring-book.pdf`

2. **Add to Xcode**:
   - In Xcode project navigator, right-click on "Victoria" folder
   - Select "Add Files to Victoria"
   - Navigate to your `coloring-book.pdf`
   - Check "Copy items if needed"
   - Click "Add"

3. **Verify**:
   - Click on `coloring-book.pdf` in Xcode
   - In right panel, check "Target Membership" > Victoria is checked
   - Click on project > Build Phases > Copy Bundle Resources
   - Confirm `coloring-book.pdf` is listed

---

## Step 4: Add Sound Effects

1. **Obtain Sound Files**:
   - See `Sounds/README.md` for required files
   - Download or create 6 sound files (.mp3 or .m4a)

2. **Add to Xcode**:
   - Create a new group: Right-click project > New Group > "Sounds"
   - Drag all sound files into the Sounds group
   - Check "Copy items if needed"
   - Add to target: Victoria

3. **Required Files**:
   - boundary_violation.mp3
   - eraser.mp3
   - color_select.mp3
   - undo.mp3
   - redo.mp3
   - celebration.mp3

**Note**: The app will run without sound files, but you'll see warnings in console.

---

## Step 5: Configure Project Settings

1. **Select Target**:
   - In Xcode, click on project name in navigator
   - Select "Victoria" target

2. **General Settings**:
   - **Bundle Identifier**: com.yourname.victoria
   - **Version**: 1.0.0
   - **Deployment Target**: iOS 16.0
   - **Supported Destinations**: iPad

3. **Signing & Capabilities**:
   - **Team**: Select your team (or "None" for simulator)
   - **Signing Certificate**: Automatic (if using team)

4. **Deployment Info**:
   - **iPhone Orientation**: Uncheck all (iPad only app)
   - **iPad Orientation**: Check all
   - **Device**: iPad only
   - **Status Bar**: Default

5. **Info Settings**:
   - Add Privacy descriptions (if needed in future):
     - Camera (if you add AR features)
     - Photos (if you add save/share features)

---

## Step 6: Build and Run

### Run on Simulator

1. **Select Simulator**:
   - In Xcode toolbar, click device dropdown
   - Select an iPad simulator (e.g., "iPad Pro 12.9-inch")

2. **Build and Run**:
   - Click the "Play" button (▶) or press `Cmd + R`
   - Wait for build to complete
   - Simulator will launch automatically

3. **First Run**:
   - App should open to page gallery
   - If PDF loaded correctly, you'll see page thumbnails
   - Tap a page to start coloring

### Run on Physical iPad

1. **Connect iPad**:
   - Connect iPad to Mac via USB
   - Unlock iPad
   - Trust computer if prompted

2. **Select Device**:
   - In Xcode, select your iPad from device dropdown
   - May need to wait for Xcode to prepare device

3. **Configure Signing**:
   - If using free Apple ID:
     - Xcode > Settings > Accounts > Add Apple ID
     - Select team in project settings
   - If using paid Developer Account:
     - Select your team

4. **Build and Run**:
   - Click "Play" or press `Cmd + R`
   - iPad may ask to trust developer certificate
   - On iPad: Settings > General > VPN & Device Management > Trust

---

## Step 7: Test the App

### Basic Functionality Tests

1. **Page Gallery**:
   - [ ] All pages from PDF appear
   - [ ] Thumbnails are clear
   - [ ] Tapping page opens coloring view

2. **Coloring**:
   - [ ] Can select colors
   - [ ] Drawing with finger works
   - [ ] Colors fill correctly
   - [ ] Boundary detection triggers feedback

3. **Tools**:
   - [ ] Brush tool colors
   - [ ] Eraser removes color
   - [ ] Fill bucket works
   - [ ] Undo/redo functions

4. **Feedback**:
   - [ ] Haptic feedback works (on device only)
   - [ ] Sound effects play (if added)
   - [ ] Completion celebration appears

---

## Troubleshooting

### Build Errors

**"Cannot find type 'PDFDocument' in scope"**
- Add `import PDFKit` to the file

**"No such module 'SwiftUI'"**
- Check Deployment Target is iOS 16.0+
- Clean build folder: Product > Clean Build Folder

**"Command CodeSign failed"**
- Check signing settings
- Try selecting "Automatically manage signing"
- Or use simulator instead of device

### Runtime Errors

**App crashes on launch**
- Check console for error messages
- Verify all files are added to target
- Clean and rebuild

**PDF doesn't load**
- Verify `coloring-book.pdf` is in project
- Check it's added to Copy Bundle Resources
- Try renaming PDF or updating code with actual filename

**Sounds don't play**
- Sound files are optional
- Check files are in Copy Bundle Resources
- Verify file names match exactly
- Check device isn't on silent mode

**Boundary detection doesn't work**
- PDF lines may be too thin
- Try PDF with thicker black lines
- Check BoundaryDetector threshold value

---

## Next Steps

### Development Roadmap

1. **Phase 1** (Current):
   - ✅ Basic structure
   - ⏳ Test with your PDF
   - ⏳ Fine-tune boundary detection
   - ⏳ Add all sound effects

2. **Phase 2** (Future):
   - Zoom & pan functionality
   - Save completed pages
   - Apple Pencil support
   - Progress tracking
   - Unlockable features

### Customization

- **Colors**: Edit `AppConstants.colorPalette` in Constants.swift
- **Thresholds**: Adjust completion criteria in Constants.swift
- **UI**: Modify views in Views/ folder
- **Sounds**: Replace sound files in Sounds/

### Testing with Kids

1. Install on iPad
2. Observe how children interact
3. Note confusion points
4. Gather feedback on:
   - Tool clarity
   - Color selection ease
   - Boundary feedback helpfulness
   - Celebration excitement
5. Iterate and improve

---

## Getting Help

### Resources

- **Apple Documentation**: [developer.apple.com/documentation](https://developer.apple.com/documentation)
- **SwiftUI Tutorials**: [developer.apple.com/tutorials/swiftui](https://developer.apple.com/tutorials/swiftui)
- **Swift Forums**: [forums.swift.org](https://forums.swift.org)

### Common Questions

**Q: Can I use this on Android?**
A: Not directly. This is iOS-only. You'd need to port to Android using Kotlin/Java or use a cross-platform framework like Flutter.

**Q: Do I need a paid Apple Developer account?**
A: No, for simulator testing. Yes, for physical device testing beyond 7 days or App Store distribution.

**Q: Can I sell this app?**
A: Yes, if you own the rights to the coloring book content and follow Apple's guidelines.

**Q: How do I publish to App Store?**
A: See Documentation/APP_STORE_GUIDE.md (to be created) and [Apple's distribution guide](https://developer.apple.com/distribute/).

---

## Support

For issues with this project:
1. Check Documentation/
2. Review code comments
3. Search GitHub issues
4. Create new issue with details

---

**Happy Coding!** 🎨📱

Let's bring your coloring book to life on iPad!
