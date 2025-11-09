/**
 * type1-page.js
 * Logic for Type 1 pages with 4 pictures and center circle selection
 */

let currentBlinkingQuadrant = null;

/**
 * Initialize Type 1 page layout
 */
function initializeType1Page(page) {
    console.log('Initializing Type 1 page:', page);

    // Set page number
    document.querySelector('#type1-view .page-number').textContent = page.number;

    // Populate the 4 picture boxes
    const boxes = document.querySelectorAll('#type1-view .picture-box');
    boxes.forEach((box, index) => {
        if (page.pictures[index]) {
            const picture = page.pictures[index];
            const img = box.querySelector('.picture-image');
            const label = box.querySelector('.word-label');

            // Set placeholder image (you'll replace with actual images)
            img.src = generatePlaceholderSVG(picture.word);
            label.textContent = picture.word;

            // Store picture data for later use
            box.dataset.pictureIndex = index;
        }
    });

    // Setup circle quadrant click handlers
    setupCircleQuadrants(page);

    // Start blinking on a random quadrant (or first one)
    startBlinkingSequence();
}

/**
 * Setup click handlers for circle quadrants
 */
function setupCircleQuadrants(page) {
    const quadrants = document.querySelectorAll('#type1-view .quadrant');

    quadrants.forEach((quadrant, index) => {
        // Remove existing listeners
        const newQuadrant = quadrant.cloneNode(true);
        quadrant.parentNode.replaceChild(newQuadrant, quadrant);

        // Add click handler
        newQuadrant.addEventListener('click', (e) => {
            e.stopPropagation();
            handleQuadrantClick(index, page);
        });

        // Add touch handler for better mobile support
        newQuadrant.addEventListener('touchstart', (e) => {
            e.preventDefault();
            e.stopPropagation();
            handleQuadrantClick(index, page);
        });
    });
}

/**
 * Start the blinking sequence on quadrants
 * This guides the student which picture to select
 */
function startBlinkingSequence() {
    // Stop any existing blinking
    stopAllBlinking();

    // Choose a random quadrant to blink (or sequential)
    // For demo, we'll blink quadrant 0 (top-left) first
    const quadrantIndex = Math.floor(Math.random() * 4);
    const quadrants = document.querySelectorAll('#type1-view .quadrant');

    if (quadrants[quadrantIndex]) {
        quadrants[quadrantIndex].classList.add('blinking');
        currentBlinkingQuadrant = quadrantIndex;
    }
}

/**
 * Stop all blinking animations
 */
function stopAllBlinking() {
    document.querySelectorAll('#type1-view .quadrant').forEach(q => {
        q.classList.remove('blinking');
    });
    currentBlinkingQuadrant = null;
}

/**
 * Handle quadrant click - open that picture in fullscreen coloring mode
 */
function handleQuadrantClick(quadrantIndex, page) {
    console.log('Quadrant clicked:', quadrantIndex);

    // Stop blinking
    stopAllBlinking();

    // Get the selected picture
    const picture = page.pictures[quadrantIndex];
    if (!picture) {
        console.error('No picture found for quadrant:', quadrantIndex);
        return;
    }

    // Visual feedback - highlight the quadrant briefly
    const quadrants = document.querySelectorAll('#type1-view .quadrant');
    if (quadrants[quadrantIndex]) {
        quadrants[quadrantIndex].style.opacity = '1';
        quadrants[quadrantIndex].style.transform = 'scale(1.1)';

        setTimeout(() => {
            quadrants[quadrantIndex].style.transform = 'scale(1)';
        }, 200);
    }

    // Wait a moment for visual feedback, then open coloring view
    setTimeout(() => {
        openColoringView(picture, page);
    }, 300);
}

/**
 * Open the fullscreen coloring view for selected picture
 */
function openColoringView(picture, page) {
    console.log('Opening coloring view for:', picture.word);

    // Initialize the coloring engine with this picture
    initializeColoringEngine(picture, page);

    // Show the coloring view
    showView('coloring-view');
}

/**
 * Move to next quadrant in sequence (optional feature)
 */
function moveToNextQuadrant() {
    if (currentBlinkingQuadrant === null) {
        startBlinkingSequence();
        return;
    }

    // Stop current blinking
    stopAllBlinking();

    // Move to next quadrant (circular)
    const nextQuadrant = (currentBlinkingQuadrant + 1) % 4;
    const quadrants = document.querySelectorAll('#type1-view .quadrant');

    if (quadrants[nextQuadrant]) {
        quadrants[nextQuadrant].classList.add('blinking');
        currentBlinkingQuadrant = nextQuadrant;
    }
}

/**
 * Auto-advance blinking quadrant (optional feature for guided learning)
 */
function enableAutoAdvance(intervalSeconds = 3) {
    return setInterval(() => {
        moveToNextQuadrant();
    }, intervalSeconds * 1000);
}

// Export for potential use in other modules
window.Type1Page = {
    initialize: initializeType1Page,
    startBlinking: startBlinkingSequence,
    stopBlinking: stopAllBlinking,
    moveToNext: moveToNextQuadrant,
    enableAutoAdvance: enableAutoAdvance
};
