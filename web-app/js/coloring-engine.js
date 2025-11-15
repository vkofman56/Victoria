/**
 * coloring-engine.js
 * Handles the coloring functionality with touch-based drawing
 */

const ColoringEngine = {
    canvas: null,
    drawingCanvas: null,
    ctx: null,
    drawingCtx: null,
    currentColor: '#FF0000',
    currentTool: 'brush',
    isDrawing: false,
    lastX: 0,
    lastY: 0,
    undoStack: [],
    currentPicture: null,
    baseImage: null,
    boundaryMask: null,
    boundaryData: null,
    hasViolatedBoundary: false
};

/**
 * Initialize the coloring engine for a specific picture
 */
function initializeColoringEngine(picture, page) {
    console.log('Initializing coloring engine for:', picture.word);

    ColoringEngine.currentPicture = picture;

    // Get canvas elements
    ColoringEngine.canvas = document.getElementById('coloring-canvas');
    ColoringEngine.drawingCanvas = document.getElementById('drawing-canvas');

    if (!ColoringEngine.canvas || !ColoringEngine.drawingCanvas) {
        console.error('Canvas elements not found');
        return;
    }

    // Get contexts
    ColoringEngine.ctx = ColoringEngine.canvas.getContext('2d');
    ColoringEngine.drawingCtx = ColoringEngine.drawingCanvas.getContext('2d');

    // Setup canvas size
    setupCanvasSize();

    // Load the coloring image
    loadColoringImage(picture);

    // Setup event listeners
    setupColoringEventListeners();

    // Initialize color palette
    initializeColorPalette();

    // Initialize tools
    initializeTools();

    // Clear undo stack
    ColoringEngine.undoStack = [];
}

/**
 * Setup canvas size to match container
 */
function setupCanvasSize() {
    const wrapper = document.querySelector('.canvas-wrapper');
    const rect = wrapper.getBoundingClientRect();

    const width = rect.width;
    const height = rect.height;

    // Set both canvases to same size
    [ColoringEngine.canvas, ColoringEngine.drawingCanvas].forEach(canvas => {
        canvas.width = width;
        canvas.height = height;
        canvas.style.width = width + 'px';
        canvas.style.height = height + 'px';
    });

    console.log('Canvas size:', width, 'x', height);
}

/**
 * Load the coloring image onto the base canvas
 */
function loadColoringImage(picture) {
    // For now, generate a simple coloring outline
    // In production, you'd load the actual SVG/image
    const img = new Image();

    // Generate a placeholder coloring page
    const word = picture.word.toLowerCase();
    img.src = generateColoringSVG(word);

    img.onload = () => {
        // Clear canvas
        ColoringEngine.ctx.clearRect(0, 0, ColoringEngine.canvas.width, ColoringEngine.canvas.height);

        // Fill background white
        ColoringEngine.ctx.fillStyle = 'white';
        ColoringEngine.ctx.fillRect(0, 0, ColoringEngine.canvas.width, ColoringEngine.canvas.height);

        // Draw the coloring outline centered
        const scale = Math.min(
            ColoringEngine.canvas.width / img.width,
            ColoringEngine.canvas.height / img.height
        ) * 0.8;

        const x = (ColoringEngine.canvas.width - img.width * scale) / 2;
        const y = (ColoringEngine.canvas.height - img.height * scale) / 2;

        ColoringEngine.ctx.drawImage(img, x, y, img.width * scale, img.height * scale);

        // Store base image for reference
        ColoringEngine.baseImage = ColoringEngine.ctx.getImageData(
            0, 0, ColoringEngine.canvas.width, ColoringEngine.canvas.height
        );

        // Extract boundary mask for detection
        extractBoundaryMask();

        console.log('Coloring image loaded');
    };

    img.onerror = () => {
        console.error('Failed to load coloring image');
        // Draw fallback
        drawFallbackImage();
    };
}

/**
 * Draw a simple fallback image if loading fails
 */
function drawFallbackImage() {
    ColoringEngine.ctx.fillStyle = 'white';
    ColoringEngine.ctx.fillRect(0, 0, ColoringEngine.canvas.width, ColoringEngine.canvas.height);

    ColoringEngine.ctx.strokeStyle = 'black';
    ColoringEngine.ctx.lineWidth = 3;
    ColoringEngine.ctx.strokeRect(
        100, 100,
        ColoringEngine.canvas.width - 200,
        ColoringEngine.canvas.height - 200
    );

    ColoringEngine.ctx.font = '24px Arial';
    ColoringEngine.ctx.fillStyle = 'black';
    ColoringEngine.ctx.textAlign = 'center';
    ColoringEngine.ctx.fillText(
        ColoringEngine.currentPicture.word,
        ColoringEngine.canvas.width / 2,
        ColoringEngine.canvas.height / 2
    );
}

/**
 * Setup event listeners for drawing
 */
function setupColoringEventListeners() {
    const canvas = ColoringEngine.drawingCanvas;

    // Mouse events
    canvas.addEventListener('mousedown', startDrawing);
    canvas.addEventListener('mousemove', draw);
    canvas.addEventListener('mouseup', stopDrawing);
    canvas.addEventListener('mouseout', stopDrawing);

    // Touch events for mobile
    canvas.addEventListener('touchstart', handleTouchStart, { passive: false });
    canvas.addEventListener('touchmove', handleTouchMove, { passive: false });
    canvas.addEventListener('touchend', handleTouchEnd, { passive: false });
}

/**
 * Get coordinates from mouse event
 * Properly handles CSS transforms (scale, translate) by using the rect dimensions
 */
function getMousePos(e) {
    const canvas = ColoringEngine.drawingCanvas;
    const rect = canvas.getBoundingClientRect();

    // Calculate the scale between canvas internal dimensions and displayed dimensions
    // rect dimensions include all CSS transforms (zoom, scale, etc.)
    const scaleX = canvas.width / rect.width;
    const scaleY = canvas.height / rect.height;

    // Get position relative to the transformed rect
    const relX = e.clientX - rect.left;
    const relY = e.clientY - rect.top;

    // Map from displayed coordinates to canvas coordinates
    const x = relX * scaleX;
    const y = relY * scaleY;

    return { x, y };
}

/**
 * Get coordinates from touch event
 * Properly handles CSS transforms (scale, translate) by using the rect dimensions
 */
function getTouchPos(e) {
    const canvas = ColoringEngine.drawingCanvas;
    const rect = canvas.getBoundingClientRect();
    const touch = e.touches[0];

    // Calculate the scale between canvas internal dimensions and displayed dimensions
    // rect dimensions include all CSS transforms (zoom, scale, etc.)
    const scaleX = canvas.width / rect.width;
    const scaleY = canvas.height / rect.height;

    // Get position relative to the transformed rect
    const relX = touch.clientX - rect.left;
    const relY = touch.clientY - rect.top;

    // Map from displayed coordinates to canvas coordinates
    const x = relX * scaleX;
    const y = relY * scaleY;

    return { x, y };
}

/**
 * Start drawing
 */
function startDrawing(e) {
    ColoringEngine.isDrawing = true;
    const pos = getMousePos(e);
    ColoringEngine.lastX = pos.x;
    ColoringEngine.lastY = pos.y;

    // Save state for undo
    saveState();
}

/**
 * Draw on canvas
 */
function draw(e) {
    if (!ColoringEngine.isDrawing) return;

    const pos = getMousePos(e);

    if (ColoringEngine.currentTool === 'brush') {
        // Check boundary along path before drawing
        checkBoundaryAlongPath(ColoringEngine.lastX, ColoringEngine.lastY, pos.x, pos.y);
        drawBrush(ColoringEngine.lastX, ColoringEngine.lastY, pos.x, pos.y);
    } else if (ColoringEngine.currentTool === 'eraser') {
        drawEraser(ColoringEngine.lastX, ColoringEngine.lastY, pos.x, pos.y);
    }

    ColoringEngine.lastX = pos.x;
    ColoringEngine.lastY = pos.y;
}

/**
 * Stop drawing
 */
function stopDrawing() {
    ColoringEngine.isDrawing = false;
    ColoringEngine.hasViolatedBoundary = false;
}

/**
 * Handle touch start
 */
function handleTouchStart(e) {
    e.preventDefault();
    ColoringEngine.isDrawing = true;
    const pos = getTouchPos(e);
    ColoringEngine.lastX = pos.x;
    ColoringEngine.lastY = pos.y;

    // Save state for undo
    saveState();

    // If using fill tool, fill immediately
    if (ColoringEngine.currentTool === 'fill') {
        floodFill(Math.floor(pos.x), Math.floor(pos.y));
        ColoringEngine.isDrawing = false;
    }
}

/**
 * Handle touch move
 */
function handleTouchMove(e) {
    e.preventDefault();
    if (!ColoringEngine.isDrawing) return;

    const pos = getTouchPos(e);

    if (ColoringEngine.currentTool === 'brush') {
        // Check boundary along path before drawing
        checkBoundaryAlongPath(ColoringEngine.lastX, ColoringEngine.lastY, pos.x, pos.y);
        drawBrush(ColoringEngine.lastX, ColoringEngine.lastY, pos.x, pos.y);
    } else if (ColoringEngine.currentTool === 'eraser') {
        drawEraser(ColoringEngine.lastX, ColoringEngine.lastY, pos.x, pos.y);
    }

    ColoringEngine.lastX = pos.x;
    ColoringEngine.lastY = pos.y;
}

/**
 * Handle touch end
 */
function handleTouchEnd(e) {
    e.preventDefault();
    ColoringEngine.isDrawing = false;
}

/**
 * Draw with brush
 */
function drawBrush(x1, y1, x2, y2) {
    const ctx = ColoringEngine.drawingCtx;

    ctx.strokeStyle = ColoringEngine.currentColor;
    ctx.lineWidth = 15;
    ctx.lineCap = 'round';
    ctx.lineJoin = 'round';

    ctx.beginPath();
    ctx.moveTo(x1, y1);
    ctx.lineTo(x2, y2);
    ctx.stroke();
}

/**
 * Erase
 */
function drawEraser(x1, y1, x2, y2) {
    const ctx = ColoringEngine.drawingCtx;

    ctx.globalCompositeOperation = 'destination-out';
    ctx.lineWidth = 25;
    ctx.lineCap = 'round';
    ctx.lineJoin = 'round';

    ctx.beginPath();
    ctx.moveTo(x1, y1);
    ctx.lineTo(x2, y2);
    ctx.stroke();

    ctx.globalCompositeOperation = 'source-over';
}

/**
 * Flood fill algorithm (simplified version)
 */
function floodFill(startX, startY) {
    const ctx = ColoringEngine.drawingCtx;
    const imageData = ctx.getImageData(0, 0, ctx.canvas.width, ctx.canvas.height);
    const pixels = imageData.data;

    const targetColor = getPixelColor(pixels, startX, startY, ctx.canvas.width);
    const fillColor = hexToRgb(ColoringEngine.currentColor);

    // Don't fill if same color
    if (colorsMatch(targetColor, fillColor)) return;

    const stack = [[startX, startY]];
    const visited = new Set();

    while (stack.length > 0) {
        const [x, y] = stack.pop();
        const key = `${x},${y}`;

        if (visited.has(key)) continue;
        if (x < 0 || x >= ctx.canvas.width || y < 0 || y >= ctx.canvas.height) continue;

        visited.add(key);

        const currentColor = getPixelColor(pixels, x, y, ctx.canvas.width);

        if (colorsMatch(currentColor, targetColor)) {
            setPixelColor(pixels, x, y, ctx.canvas.width, fillColor);

            stack.push([x + 1, y]);
            stack.push([x - 1, y]);
            stack.push([x, y + 1]);
            stack.push([x, y - 1]);
        }

        // Limit iterations to prevent freeze
        if (visited.size > 50000) break;
    }

    ctx.putImageData(imageData, 0, 0);
}

/**
 * Get pixel color at position
 */
function getPixelColor(pixels, x, y, width) {
    const index = (y * width + x) * 4;
    return {
        r: pixels[index],
        g: pixels[index + 1],
        b: pixels[index + 2],
        a: pixels[index + 3]
    };
}

/**
 * Set pixel color at position
 */
function setPixelColor(pixels, x, y, width, color) {
    const index = (y * width + x) * 4;
    pixels[index] = color.r;
    pixels[index + 1] = color.g;
    pixels[index + 2] = color.b;
    pixels[index + 3] = 255;
}

/**
 * Check if two colors match
 */
function colorsMatch(c1, c2, tolerance = 10) {
    return Math.abs(c1.r - c2.r) < tolerance &&
           Math.abs(c1.g - c2.g) < tolerance &&
           Math.abs(c1.b - c2.b) < tolerance;
}

/**
 * Convert hex color to RGB
 */
function hexToRgb(hex) {
    const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result ? {
        r: parseInt(result[1], 16),
        g: parseInt(result[2], 16),
        b: parseInt(result[3], 16)
    } : { r: 0, g: 0, b: 0 };
}

/**
 * Initialize color palette
 */
function initializeColorPalette() {
    const swatches = document.querySelectorAll('.color-swatch');

    swatches.forEach(swatch => {
        swatch.addEventListener('click', () => {
            const color = swatch.dataset.color;
            ColoringEngine.currentColor = color;

            // Update selected state
            swatches.forEach(s => s.classList.remove('selected'));
            swatch.classList.add('selected');

            // Switch to brush tool when selecting color
            if (ColoringEngine.currentTool === 'eraser') {
                selectTool('brush');
            }
        });
    });

    // Select first color by default
    if (swatches[0]) {
        swatches[0].click();
    }
}

/**
 * Initialize tools
 */
function initializeTools() {
    document.getElementById('brush-tool')?.addEventListener('click', () => selectTool('brush'));
    document.getElementById('fill-tool')?.addEventListener('click', () => selectTool('fill'));
    document.getElementById('eraser-tool')?.addEventListener('click', () => selectTool('eraser'));
    document.getElementById('undo-tool')?.addEventListener('click', () => undo());

    // Select brush by default
    selectTool('brush');
}

/**
 * Select a tool
 */
function selectTool(tool) {
    ColoringEngine.currentTool = tool;

    // Update button states
    document.querySelectorAll('.tool-button').forEach(btn => {
        btn.classList.remove('active');
    });

    const buttons = {
        brush: document.getElementById('brush-tool'),
        fill: document.getElementById('fill-tool'),
        eraser: document.getElementById('eraser-tool')
    };

    if (buttons[tool]) {
        buttons[tool].classList.add('active');
    }

    console.log('Selected tool:', tool);
}

/**
 * Save current state for undo
 */
function saveState() {
    const imageData = ColoringEngine.drawingCtx.getImageData(
        0, 0,
        ColoringEngine.drawingCanvas.width,
        ColoringEngine.drawingCanvas.height
    );

    ColoringEngine.undoStack.push(imageData);

    // Limit stack size
    if (ColoringEngine.undoStack.length > 20) {
        ColoringEngine.undoStack.shift();
    }
}

/**
 * Undo last action
 */
function undo() {
    if (ColoringEngine.undoStack.length > 0) {
        const previousState = ColoringEngine.undoStack.pop();
        ColoringEngine.drawingCtx.putImageData(previousState, 0, 0);
        console.log('Undo performed');
    } else {
        console.log('Nothing to undo');
    }
}

/**
 * Extract boundary mask from base image
 * Creates a binary mask where dark pixels are boundaries
 */
function extractBoundaryMask() {
    if (!ColoringEngine.baseImage) return;

    const width = ColoringEngine.canvas.width;
    const height = ColoringEngine.canvas.height;
    const imageData = ColoringEngine.baseImage;
    const pixels = imageData.data;

    // Create boundary data array
    ColoringEngine.boundaryData = new Uint8Array(width * height);

    const threshold = 0.3 * 255; // 30% threshold for detecting dark lines

    for (let i = 0; i < width * height; i++) {
        const pixelIndex = i * 4;
        const r = pixels[pixelIndex];
        const g = pixels[pixelIndex + 1];
        const b = pixels[pixelIndex + 2];

        // Convert to grayscale
        const gray = 0.299 * r + 0.587 * g + 0.114 * b;

        // Dark pixels are boundaries (1), light pixels are colorable (0)
        ColoringEngine.boundaryData[i] = gray < threshold ? 1 : 0;
    }

    console.log('Boundary mask extracted');
}

/**
 * Check if a point is on a boundary
 */
function isBoundary(x, y) {
    if (!ColoringEngine.boundaryData) return false;

    const width = ColoringEngine.canvas.width;
    const height = ColoringEngine.canvas.height;

    // Convert to integers
    const ix = Math.floor(x);
    const iy = Math.floor(y);

    // Bounds check
    if (ix < 0 || ix >= width || iy < 0 || iy >= height) {
        return true; // Out of bounds = boundary
    }

    const index = iy * width + ix;
    return ColoringEngine.boundaryData[index] === 1;
}

/**
 * Check if the brush has crossed enough into a boundary (20-25% threshold)
 * This allows the brush to touch the line without immediately triggering the sound
 */
function isBoundaryAtBrushEdge(centerX, centerY, brushRadius, numPoints = 12) {
    if (!ColoringEngine.boundaryData) return false;

    // Check the center first - if center is on boundary, we've definitely crossed enough
    if (isBoundary(centerX, centerY)) {
        return true;
    }

    // Penetration threshold: 22.5% of brush radius (midpoint of 20-25%)
    const penetrationThreshold = brushRadius * 0.225;

    // Maximum allowed distance from center for boundary detection
    // This creates an inner circle - only boundaries within this circle trigger the sound
    const maxAllowedDistance = brushRadius - penetrationThreshold;

    // Check radial lines from center outward
    for (let i = 0; i < numPoints; i++) {
        const angle = (i / numPoints) * 2.0 * Math.PI;
        const dx = Math.cos(angle);
        const dy = Math.sin(angle);

        // Sample points along the radius from center to edge
        // We want to find the closest boundary pixel to the center
        const steps = 10;
        for (let step = 1; step <= steps; step++) {
            const distance = (step / steps) * brushRadius;
            const x = centerX + dx * distance;
            const y = centerY + dy * distance;

            if (isBoundary(x, y)) {
                // Found a boundary at this distance from center
                // Only trigger if it's close enough (within the threshold)
                if (distance <= maxAllowedDistance) {
                    return true;
                }
                // If boundary is farther out (just touching edge), skip this radial
                break;
            }
        }
    }

    return false;
}

/**
 * Check boundary along the path from start to end
 * Interpolates points to catch boundaries during fast movements
 */
function checkBoundaryAlongPath(x1, y1, x2, y2) {
    // Don't check if we've already violated in this stroke
    if (ColoringEngine.hasViolatedBoundary) {
        return;
    }

    const dx = x2 - x1;
    const dy = y2 - y1;
    const distance = Math.sqrt(dx * dx + dy * dy);

    // If points are very close, just check the end point
    if (distance < 2.0) {
        if (isBoundaryAtBrushEdge(x2, y2, 12.0)) {
            triggerBoundaryFeedback();
        }
        return;
    }

    // Interpolate points along the path (check every ~5 pixels)
    const steps = Math.max(Math.floor(distance / 5.0), 1);
    for (let i = 0; i <= steps; i++) {
        const t = i / steps;
        const x = x1 + dx * t;
        const y = y1 + dy * t;

        // Check with brush radius of 12.0 (matching iOS version)
        if (isBoundaryAtBrushEdge(x, y, 12.0)) {
            triggerBoundaryFeedback();
            break;
        }
    }
}

/**
 * Trigger feedback when boundary is crossed
 */
function triggerBoundaryFeedback() {
    ColoringEngine.hasViolatedBoundary = true;

    // Play sound if available
    if (typeof playSound === 'function') {
        playSound('boundary');
    }

    // Vibrate if supported
    if ('vibrate' in navigator) {
        navigator.vibrate(50);
    }

    console.log('Boundary violation detected');
}

// Export for use in other modules
window.ColoringEngine = ColoringEngine;
