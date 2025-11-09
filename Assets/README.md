# Assets

This directory should contain your coloring book PDF file.

## Adding Your Coloring Book PDF

1. **Prepare Your PDF**:
   - Name your file: `coloring-book.pdf`
   - Ensure each page contains line art suitable for coloring
   - Black lines work best for boundary detection
   - White/light background recommended
   - Resolution: 300 DPI or higher for best quality

2. **Place PDF in This Directory**:
   ```bash
   cp /path/to/your-coloring-book.pdf Assets/coloring-book.pdf
   ```

3. **Add to Xcode Project**:
   - Open `VictoriaApp/Victoria.xcodeproj` in Xcode
   - Drag `coloring-book.pdf` into the project navigator
   - Check "Copy items if needed"
   - Add to target: VictoriaApp
   - Ensure it appears in "Build Phases > Copy Bundle Resources"

## PDF Requirements

### Technical Specifications
- **Format**: PDF (vector or high-resolution raster)
- **Page Size**: Any (will be scaled to fit iPad screen)
- **Orientation**: Portrait or Landscape
- **Color Mode**: RGB or Grayscale
- **Resolution**: 300 DPI minimum

### Content Guidelines
- **Line Thickness**: 2-4 pt for clear boundaries
- **Line Color**: Black (#000000) for best boundary detection
- **Background**: White or very light colors
- **Complexity**: Age-appropriate for target audience (5-12 years)
- **Regions**: Clear, distinct areas for coloring
- **Text**: Minimal (this is a coloring app, not a reading app)

### Optimal Page Design
```
✅ Good:
- Clear black outlines
- Distinct coloring regions
- Simple to moderate complexity
- No tiny details that are hard to color on touch screen

❌ Avoid:
- Very thin lines (< 1pt)
- Gray or colored lines
- Extremely complex patterns
- Tiny regions that are hard to tap
```

## Example Structure

Your PDF should contain multiple pages, each with a different coloring design:

```
Page 1: Simple flower
Page 2: Cute animal
Page 3: Vehicle
Page 4: Nature scene
... etc.
```

## Testing Your PDF

Once added to the Xcode project:

1. Build and run the app on iPad simulator
2. Check that all pages appear in the gallery
3. Test coloring on each page
4. Verify boundary detection works correctly
5. Adjust PDF if needed (thicker lines, clearer boundaries)

## Boundary Detection Tips

The app uses image processing to detect boundaries:

1. **Black Lines**: Pure black (#000000) works best
2. **Line Weight**: 2-4 pt thick lines recommended
3. **Closed Shapes**: Ensure shapes are fully enclosed for flood fill
4. **Contrast**: High contrast between lines and background

If boundary detection isn't working well:
- Increase line thickness in your PDF
- Ensure lines are darker (closer to black)
- Check for gaps in outlines
- Test on a sample page first

## Copyright & Licensing

Ensure you have the rights to use the coloring book content in your app. This includes:
- Original artwork you created
- Licensed content from artists
- Public domain images
- Properly attributed Creative Commons content

Do not use copyrighted content without permission.
