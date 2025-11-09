# How to Add Your Own Pages

This guide shows you exactly how to add your own coloring book pages to the web app.

## Understanding the Page Structure

Each Type 1 page has:
- **Page number** (displayed at top)
- **4 pictures** in a 2x2 grid
- **4 words** (one for each picture)
- **Center circle** with 4 colored quadrants
- **Blinking effect** to guide selection

---

## Step 1: Prepare Your Images

For each picture, you need TWO images:

### Preview Image
- Shows in the 4-box grid
- Can be a photo, illustration, or icon
- Recommended size: 200x200 pixels
- Format: PNG or JPG
- Example: `cat.png`

### Coloring Outline
- Black lines on white background
- Used for the fullscreen coloring
- Recommended size: 800x800 pixels
- Format: SVG (best) or PNG
- Example: `cat-coloring.svg`

---

## Step 2: Add Images to Project

Place all images in the `images/` folder:

```
web-app/
├── images/
│   ├── cat.png              ← Preview
│   ├── cat-coloring.svg     ← Outline to color
│   ├── dog.png
│   ├── dog-coloring.svg
│   ├── bird.png
│   ├── bird-coloring.svg
│   ├── fish.png
│   └── fish-coloring.svg
```

---

## Step 3: Create Page Data

Open `js/app.js` and find the `loadSamplePages()` function.

### Example: Adding an Animals Page

```javascript
function loadSamplePages() {
    App.pages = [
        {
            id: 1,                    // Unique ID
            type: 'type1',            // Page type
            number: '1',              // Page number (shown at top)
            title: 'Animals',         // Page title
            pictures: [
                // Picture 1 (Top-Left quadrant)
                {
                    word: 'CAT',                          // Word to display
                    image: 'images/cat.png',              // Preview image
                    coloringImage: 'images/cat-coloring.svg'  // Coloring outline
                },
                // Picture 2 (Top-Right quadrant)
                {
                    word: 'DOG',
                    image: 'images/dog.png',
                    coloringImage: 'images/dog-coloring.svg'
                },
                // Picture 3 (Bottom-Left quadrant)
                {
                    word: 'BIRD',
                    image: 'images/bird.png',
                    coloringImage: 'images/bird-coloring.svg'
                },
                // Picture 4 (Bottom-Right quadrant)
                {
                    word: 'FISH',
                    image: 'images/fish.png',
                    coloringImage: 'images/fish-coloring.svg'
                }
            ]
        }
    ];
}
```

---

## Step 4: Add More Pages

Just add more page objects to the array:

```javascript
function loadSamplePages() {
    App.pages = [
        // Page 1: Animals
        {
            id: 1,
            type: 'type1',
            number: '1',
            title: 'Animals',
            pictures: [
                { word: 'CAT', image: 'images/cat.png', coloringImage: 'images/cat-coloring.svg' },
                { word: 'DOG', image: 'images/dog.png', coloringImage: 'images/dog-coloring.svg' },
                { word: 'BIRD', image: 'images/bird.png', coloringImage: 'images/bird-coloring.svg' },
                { word: 'FISH', image: 'images/fish.png', coloringImage: 'images/fish-coloring.svg' }
            ]
        },

        // Page 2: Fruits
        {
            id: 2,
            type: 'type1',
            number: '2',
            title: 'Fruits',
            pictures: [
                { word: 'APPLE', image: 'images/apple.png', coloringImage: 'images/apple-coloring.svg' },
                { word: 'BANANA', image: 'images/banana.png', coloringImage: 'images/banana-coloring.svg' },
                { word: 'ORANGE', image: 'images/orange.png', coloringImage: 'images/orange-coloring.svg' },
                { word: 'GRAPE', image: 'images/grape.png', coloringImage: 'images/grape-coloring.svg' }
            ]
        },

        // Page 3: Vehicles
        {
            id: 3,
            type: 'type1',
            number: '3',
            title: 'Vehicles',
            pictures: [
                { word: 'CAR', image: 'images/car.png', coloringImage: 'images/car-coloring.svg' },
                { word: 'TRUCK', image: 'images/truck.png', coloringImage: 'images/truck-coloring.svg' },
                { word: 'BIKE', image: 'images/bike.png', coloringImage: 'images/bike-coloring.svg' },
                { word: 'PLANE', image: 'images/plane.png', coloringImage: 'images/plane-coloring.svg' }
            ]
        }

        // Add as many pages as you want!
    ];
}
```

---

## Step 5: Test Your Pages

1. Save `app.js`
2. Refresh your browser
3. Check that all pages appear in the gallery
4. Click on a page
5. Verify:
   - [ ] Page number displays correctly
   - [ ] All 4 pictures show up
   - [ ] Words are spelled correctly
   - [ ] Center circle appears
   - [ ] One quadrant blinks
   - [ ] Clicking quadrant opens coloring
   - [ ] Coloring outline loads

---

## Creating Coloring Outlines

### Option 1: Use Existing Images

If you have photos or images:

1. Open in image editor (Photoshop, GIMP, Illustrator)
2. Apply "Find Edges" or "Trace" filter
3. Convert to black and white
4. Increase contrast
5. Save as PNG or SVG

### Option 2: Draw Your Own

1. Use **Inkscape** (free) or **Illustrator**
2. Draw simple outlines with black strokes
3. Keep lines 2-4 pixels thick
4. Use white background
5. Export as SVG

### Option 3: Use AI Tools

1. **Remove.bg** - Remove background
2. **Vectorizer.ai** - Convert to vector outline
3. **AutoDraw** - Simple drawings
4. **Canva** - Create simple graphics

### Option 4: Find Free Resources

- **Freepik.com** - Free vectors (check license)
- **OpenClipart.org** - Public domain clipart
- **Pixabay.com** - Free images
- **The Noun Project** - Simple icons (outline style)

**Important**: Ensure you have rights to use images!

---

## Advanced: Loading Pages from JSON

For many pages, use an external JSON file:

### 1. Create `pages.json`:

```json
{
  "pages": [
    {
      "id": 1,
      "type": "type1",
      "number": "1",
      "title": "Animals",
      "pictures": [
        {
          "word": "CAT",
          "image": "images/cat.png",
          "coloringImage": "images/cat-coloring.svg"
        },
        {
          "word": "DOG",
          "image": "images/dog.png",
          "coloringImage": "images/dog-coloring.svg"
        },
        {
          "word": "BIRD",
          "image": "images/bird.png",
          "coloringImage": "images/bird-coloring.svg"
        },
        {
          "word": "FISH",
          "image": "images/fish.png",
          "coloringImage": "images/fish-coloring.svg"
        }
      ]
    }
  ]
}
```

### 2. Load in `app.js`:

```javascript
async function loadSamplePages() {
    try {
        const response = await fetch('pages.json');
        const data = await response.json();
        App.pages = data.pages;
        renderPageGallery();
    } catch (error) {
        console.error('Failed to load pages:', error);
        // Fallback to hardcoded pages
        App.pages = [];
    }
}
```

---

## Page Template

Copy this template for each new page:

```javascript
{
    id: X,                    // Increment for each page
    type: 'type1',
    number: 'X',              // Page number to display
    title: 'Page Title',      // Theme name
    pictures: [
        {
            word: 'WORD1',
            image: 'images/word1.png',
            coloringImage: 'images/word1-coloring.svg'
        },
        {
            word: 'WORD2',
            image: 'images/word2.png',
            coloringImage: 'images/word2-coloring.svg'
        },
        {
            word: 'WORD3',
            image: 'images/word3.png',
            coloringImage: 'images/word3-coloring.svg'
        },
        {
            word: 'WORD4',
            image: 'images/word4.png',
            coloringImage: 'images/word4-coloring.svg'
        }
    ]
}
```

---

## Quick Reference

### File Paths
- **Preview images**: `images/filename.png`
- **Coloring outlines**: `images/filename-coloring.svg`

### Best Practices
- ✅ Use descriptive filenames (`cat.png`, not `img1.png`)
- ✅ Keep words SHORT (3-8 letters)
- ✅ Use UPPERCASE for words
- ✅ Optimize images (compress PNGs)
- ✅ Test on mobile devices
- ✅ Use SVG for coloring outlines when possible

### Recommended Themes
- Animals (Cat, Dog, Bird, Fish)
- Fruits (Apple, Banana, Orange, Grape)
- Vehicles (Car, Truck, Bike, Plane)
- Colors (Red, Blue, Green, Yellow)
- Shapes (Circle, Square, Triangle, Star)
- Numbers (One, Two, Three, Four)
- Letters (A, B, C, D)
- Weather (Sun, Cloud, Rain, Snow)
- Ocean (Whale, Dolphin, Shark, Turtle)
- Space (Star, Moon, Rocket, Planet)

---

## Example: Complete Page

Here's a fully working example you can copy:

```javascript
// Add this to loadSamplePages() in app.js
{
    id: 4,
    type: 'type1',
    number: '4',
    title: 'Ocean Animals',
    pictures: [
        {
            word: 'WHALE',
            image: 'images/whale.png',
            coloringImage: 'images/whale-coloring.svg'
        },
        {
            word: 'DOLPHIN',
            image: 'images/dolphin.png',
            coloringImage: 'images/dolphin-coloring.svg'
        },
        {
            word: 'SHARK',
            image: 'images/shark.png',
            coloringImage: 'images/shark-coloring.svg'
        },
        {
            word: 'TURTLE',
            image: 'images/turtle.png',
            coloringImage: 'images/turtle-coloring.svg'
        }
    ]
}
```

---

## Troubleshooting

### Images don't show up
- Check file paths are correct
- Verify images are in `images/` folder
- Open browser console (F12) to see errors
- Check spelling of filenames

### Words are cut off
- Use shorter words
- Adjust CSS font size in `styles.css`:
  ```css
  .word-label {
      font-size: 1.2em; /* Make smaller */
  }
  ```

### Coloring outline is too small
- Use larger source image (800x800+)
- Check SVG viewBox settings
- Verify image loads correctly in browser

---

**Now you're ready to add unlimited pages!** 🎨

Start with 3-5 pages, test thoroughly, then add more as needed.
