# Setup Instructions - Victoria Coloring Book

## Problem: Pictures Not Showing?

If you see empty squares with just word names (like "TREE", "SUN", etc.), it means the HTML can't find the images.

## Solution: Download Files in Correct Structure

### Step 1: Create Folder Structure

On your D drive, create this structure:

```
D:\Victoria-Coloring\
├── VICTORIA-BOOK-WITH-IMAGES.html
└── images\
    └── (all .png files go here)
```

### Step 2: Download the HTML File

1. Go to your GitHub repository
2. Navigate to: `web-app/VICTORIA-BOOK-WITH-IMAGES.html`
3. Click "Raw" button
4. Right-click → "Save As"
5. Save to: `D:\Victoria-Coloring\VICTORIA-BOOK-WITH-IMAGES.html`

### Step 3: Download ALL Image Files

You need to download these 16 images:

**From repository: `web-app/images/`**

Download each file:
1. sun.png
2. fun.png
3. run.png
4. bun.png
5. tattoo.png
6. cockatoo.png
7. i-am-too.png
8. fondue.png
9. tree.png
10. agree.png
11. free.png
12. debris.png
13. door.png
14. snore.png
15. roar.png
16. core.png

Save ALL of them to: `D:\Victoria-Coloring\images\`

### Step 4: Verify Structure

Your folder should look like this:

```
D:\Victoria-Coloring\
│
├── VICTORIA-BOOK-WITH-IMAGES.html  ← The main file
│
└── images\
    ├── sun.png
    ├── fun.png
    ├── run.png
    ├── bun.png
    ├── tattoo.png
    ├── cockatoo.png
    ├── i-am-too.png
    ├── fondue.png
    ├── tree.png
    ├── agree.png
    ├── free.png
    ├── debris.png
    ├── door.png
    ├── snore.png
    ├── roar.png
    └── core.png
```

### Step 5: Open the HTML

Double-click: `VICTORIA-BOOK-WITH-IMAGES.html`

Now you should see all the pictures!

---

## Alternative: Download Entire Folder from GitHub

### Easier Method:

1. **Go to your GitHub repository**
2. **Click the green "Code" button**
3. **Select "Download ZIP"**
4. **Extract the ZIP**
5. **Find the `web-app` folder**
6. **Open `VICTORIA-BOOK-WITH-IMAGES.html` from there**

This ensures all files are in the correct structure!

---

## Still Not Working?

### Check These Things:

1. **Are the images in a folder called `images`?**
   - NOT `Images` or `IMAGES` (case matters!)
   - Must be lowercase: `images`

2. **Is the `images` folder in the SAME folder as the HTML?**
   ```
   ✅ Correct:
   D:\Victoria\
   ├── VICTORIA-BOOK-WITH-IMAGES.html
   └── images\
       └── sun.png

   ❌ Wrong:
   D:\Victoria\
   ├── VICTORIA-BOOK-WITH-IMAGES.html
   D:\images\
       └── sun.png
   ```

3. **Did you download ALL 16 images?**
   - Check the `images` folder has 16 .png files

4. **Try opening in a different browser**
   - Try Chrome, Firefox, or Edge
   - Some browsers have stricter security for local files

---

## Quick Test

Open the HTML file and:
1. Press `F12` (opens Developer Tools)
2. Click "Console" tab
3. Look for errors like "Failed to load resource"
4. This will tell you which images it can't find

---

Need more help? Check the file paths in the Console errors!
