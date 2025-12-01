# Victoria Interactive Coloring Book - Web App

Interactive coloring book web application for children featuring number-themed pages with rhyming words from "From 1 to 10 with Rhymes".

## Quick Start

1. Open `web-app/index.html` in a modern web browser
2. Select a number page from the gallery
3. Click a picture quadrant to start coloring
4. Choose colors and draw within the lines!

## Features

- **Gallery View**: Browse all number pages (1-10)
- **Interactive Selection**: Central circle with 4 picture quadrants
- **Full Coloring Canvas**:
  - 10-color palette
  - Brush and eraser tools
  - Undo functionality
  - Clear canvas option
- **Zoom & Pan**:
  - Zoom 1x to 3x
  - Pinch-to-zoom on touch devices
  - Pan when zoomed in
- **Boundary Detection**: Audio feedback when coloring outside lines
- **Responsive Design**: Works on desktop, tablets, and phones

## Current Content

### Pages Available
- **Page 1 (ONE)**: Sun, Fun, Run, Bun
- **Page 2 (TWO)**: Tattoo, Cockatoo, I Am Too, Fondue
- **Page 3 (THREE)**: Tree, Agree, Free, Debris
- **Page 4 (FOUR)**: Door, Snore, Roar, Core

## Project Structure

```
web-app/
├── index.html              # Main app (self-contained)
├── images/                 # Coloring page PNGs
│   ├── sun.png
│   ├── fun.png
│   └── ... (15 total images)
├── js/                     # Legacy/unused
└── css/                    # Legacy/unused
```

## Technical Details

- **Framework**: Vanilla JavaScript (no dependencies)
- **Architecture**: Single-file app with dual canvas system
- **Browser Support**: Modern browsers with Web Audio API
- **Target Devices**: iPad/iPhone (primary), Desktop (secondary)

## Controls

### Desktop
- **Draw**: Click and drag
- **Zoom**: Mouse wheel or zoom buttons
- **Pan**: Shift+Drag or Right-Click+Drag (when zoomed)

### Touch Devices (iPad/iPhone)
- **Draw**: Single finger
- **Zoom**: Pinch gesture or zoom buttons
- **Pan**: Two-finger drag (when zoomed)

## Development

See `WEB-APP-DEVELOPMENT-NOTES.md` for complete development history, architecture details, and technical documentation.

**Active Branch**: `claude/web-app-only-011CV4nxBQnNmtK15assLMD7`

## Adding New Pages

1. Extract images from PDF (see `web-app/EXTRACT-IMAGES-GUIDE.md`)
2. Add images to `web-app/images/`
3. Update `pages` array in `index.html` (around line 865)
4. Test in browser

## Deployment

Deploy `web-app/` folder to any static hosting service:
- GitHub Pages
- Netlify
- Vercel
- AWS S3 + CloudFront

**Requirements**: HTTPS needed for Web Audio API

## License

Educational project - Victoria Book Series

## Version

**Current Version**: 2024-FIX-CORS-V2 (see index.html:578)

**Last Updated**: December 1, 2025
