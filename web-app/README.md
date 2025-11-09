# Victoria Web Coloring Book

Interactive web-based coloring book that works on iPad and iPhone through web browsers. Perfect for YouTube links and instant access!

## Features

### Type 1 Pages
- **Number Display**: Page number shown at top
- **4 Picture Layout**: Grid of 4 pictures/words in boxes
- **Interactive Center Circle**: Colored circle overlapping all 4 pictures
- **Blinking Guide**: One quadrant blinks to guide student selection
- **Touch Selection**: Tap the blinking quadrant to open that picture
- **Fullscreen Coloring**: Selected picture expands to full screen
- **Touch Drawing**: Color with finger or Apple Pencil
- **Color Palette**: 10 vibrant colors
- **Tools**: Brush, Fill bucket, Eraser, Undo

## Technology

- **HTML5** for structure
- **CSS3** for styling and animations
- **JavaScript (Vanilla)** for interactivity
- **HTML5 Canvas** for drawing
- **Touch Events** for iPad/iPhone support
- **No frameworks** - lightweight and fast!

## File Structure

```
web-app/
├── index.html              # Main HTML file
├── css/
│   └── styles.css         # All styles and animations
├── js/
│   ├── app.js            # Main app logic
│   ├── type1-page.js     # Type 1 page functionality
│   └── coloring-engine.js # Coloring/drawing engine
├── images/               # Your coloring book images
└── pages/                # Additional page types (future)
```

## Quick Start

### Option 1: Open Locally

1. **Download** this folder to your computer
2. **Double-click** `index.html`
3. Opens in your default browser
4. **Done!** Start coloring

### Option 2: Host on Web Server

For YouTube sharing, you need to host the app online:

#### A. Using GitHub Pages (FREE)

1. **Create GitHub repository**
   ```bash
   cd web-app
   git init
   git add .
   git commit -m "Initial web coloring book"
   git branch -M main
   git remote add origin https://github.com/YOUR-USERNAME/victoria-coloring.git
   git push -u origin main
   ```

2. **Enable GitHub Pages**
   - Go to repository Settings
   - Scroll to "Pages" section
   - Source: Select "main" branch
   - Click "Save"

3. **Your URL will be**:
   ```
   https://YOUR-USERNAME.github.io/victoria-coloring/
   ```

4. **Share on YouTube**:
   - Add link to video description
   - Pin comment with link
   - Add to video end screen

#### B. Using Netlify (FREE & Easy)

1. **Go to** [netlify.com](https://netlify.com)
2. **Drag and drop** the `web-app` folder
3. **Instant deployment!**
4. **Your URL**: `https://random-name.netlify.app`
5. **Custom domain**: Optional (can change to your domain)

#### C. Using Vercel (FREE)

1. **Go to** [vercel.com](https://vercel.com)
2. **Import** your GitHub repository
3. **Deploy automatically**
4. **Your URL**: `https://victoria-coloring.vercel.app`

## Adding Your Own Images

### Step 1: Prepare Images

You need two versions of each image:

1. **Preview Image** (for the 4-box grid):
   - Format: PNG, JPG, or SVG
   - Size: 200x200 pixels recommended
   - Shows the word/object to color

2. **Coloring Outline** (for fullscreen coloring):
   - Format: SVG (best) or PNG
   - Black lines on white background
   - Clear, simple outlines
   - Size: 800x800 pixels or larger

### Step 2: Add Images to Project

Place images in `images/` folder:
```
images/
  ├── cat.png              # Preview
  ├── cat-coloring.svg     # Outline to color
  ├── dog.png
  ├── dog-coloring.svg
  └── ...
```

### Step 3: Update Page Data

Edit `js/app.js`, find `loadSamplePages()` function:

```javascript
App.pages = [
    {
        id: 1,
        type: 'type1',
        number: '1',
        title: 'Animals',
        pictures: [
            {
                word: 'CAT',
                image: 'images/cat.png',              // ← Your preview image
                coloringImage: 'images/cat-coloring.svg'  // ← Your outline
            },
            {
                word: 'DOG',
                image: 'images/dog.png',
                coloringImage: 'images/dog-coloring.svg'
            },
            // ... add more
        ]
    },
    // Add more pages...
];
```

## Customization

### Change Colors

Edit `css/styles.css`:

```css
/* Background gradient */
body {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    /* Change to your colors */
}
```

Edit color palette in `index.html`:
```html
<div class="color-swatch" data-color="#YOUR_COLOR" style="background-color: #YOUR_COLOR;"></div>
```

### Change Circle Quadrant Colors

Edit `index.html`, find the SVG paths:

```html
<path id="quadrant-1" fill="#FF6B6B" ... />  <!-- Top-left: Red -->
<path id="quadrant-2" fill="#4ECDC4" ... />  <!-- Top-right: Teal -->
<path id="quadrant-3" fill="#FFE66D" ... />  <!-- Bottom-left: Yellow -->
<path id="quadrant-4" fill="#95E1D3" ... />  <!-- Bottom-right: Mint -->
```

### Adjust Blinking Speed

Edit `css/styles.css`:

```css
@keyframes blink {
    0%, 100% { opacity: 0.8; }
    50% { opacity: 0.3; }
}
/* Speed controlled by: animation: blink 1s ... */
/* Change "1s" to "0.5s" for faster, "2s" for slower */
```

## YouTube Integration

### Method 1: Link in Description

```
🎨 Color along with this video!
Try the interactive coloring book: https://your-site.com

👉 Works on iPad and iPhone!
👉 No download needed!
👉 Touch to color!
```

### Method 2: End Screen

- Add end screen element
- Link to external website
- Use your deployed URL

### Method 3: Pinned Comment

Pin a comment with the link so viewers see it first.

### Method 4: Cards (if eligible)

Add a card that appears during the video with your link.

## Browser Compatibility

✅ **Supported**:
- Safari (iOS 12+)
- Chrome (iOS, Android, Desktop)
- Firefox (Desktop, Mobile)
- Edge (Desktop)

⚠️ **Limited**:
- Internet Explorer (not recommended)
- Very old browsers

## Performance Tips

1. **Optimize Images**:
   - Use SVG for coloring outlines (scalable, small file size)
   - Compress PNGs/JPGs (use TinyPNG.com)
   - Keep images under 100KB each

2. **Limit Pages**:
   - Start with 5-10 pages
   - Add more as needed
   - Each page adds ~200KB

3. **Cache Settings**:
   - Images load once and are cached
   - Browser remembers for faster return visits

## Troubleshooting

### Images Don't Show

1. Check file paths in `app.js`
2. Verify images are in `images/` folder
3. Check browser console for errors (F12)

### Touch Not Working

1. Ensure `touch-action: none` in CSS
2. Check that event listeners use `{ passive: false }`
3. Test in Safari (best iOS support)

### Coloring Lags

1. Reduce canvas size in `coloring-engine.js`
2. Optimize drawing algorithm
3. Use simpler images

### Won't Work on iPhone

1. Add viewport meta tag (already included)
2. Test in Safari specifically
3. Check for JavaScript errors

## Future Enhancements

### Planned Features:
- [ ] More page types (Type 2, 3, 4)
- [ ] Sound effects
- [ ] Completion celebrations
- [ ] Save colored pages
- [ ] Share on social media
- [ ] Print colored pages
- [ ] Multiple language support
- [ ] Progress tracking
- [ ] Parental dashboard

### Want to Add These?

Features can be added by editing the JavaScript files. The codebase is modular and well-commented for easy customization.

## Support

### Need Help?

1. Check browser console for errors (F12)
2. Review this README
3. Test with sample data first
4. Contact developer

## License

All rights reserved. This is a private project.

## Credits

Built for Victoria's Coloring Book
Web version for YouTube integration

---

**Ready to share your coloring book with the world!** 🎨📱

Host on GitHub Pages, Netlify, or Vercel, then share the link on YouTube!
