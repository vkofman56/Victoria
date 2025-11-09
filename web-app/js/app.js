/**
 * app.js
 * Main application logic and view management
 */

// Application State
const App = {
    currentView: 'gallery-view',
    currentPage: null,
    pages: []
};

// Initialize app when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    console.log('Victoria Coloring Book - Web App Started');
    initializeApp();
});

/**
 * Initialize the application
 */
function initializeApp() {
    // Load sample pages
    loadSamplePages();

    // Render page gallery
    renderPageGallery();

    // Show gallery view
    showView('gallery-view');

    // Prevent default touch behaviors
    preventDefaultTouchBehaviors();
}

/**
 * Load sample pages for demonstration
 */
function loadSamplePages() {
    // Sample Type 1 pages
    App.pages = [
        {
            id: 1,
            type: 'type1',
            number: '1',
            title: 'Animals',
            pictures: [
                { word: 'CAT', image: 'placeholder-cat.svg', coloringImage: 'cat-coloring.svg' },
                { word: 'DOG', image: 'placeholder-dog.svg', coloringImage: 'dog-coloring.svg' },
                { word: 'BIRD', image: 'placeholder-bird.svg', coloringImage: 'bird-coloring.svg' },
                { word: 'FISH', image: 'placeholder-fish.svg', coloringImage: 'fish-coloring.svg' }
            ]
        },
        {
            id: 2,
            type: 'type1',
            number: '2',
            title: 'Fruits',
            pictures: [
                { word: 'APPLE', image: 'placeholder-apple.svg', coloringImage: 'apple-coloring.svg' },
                { word: 'BANANA', image: 'placeholder-banana.svg', coloringImage: 'banana-coloring.svg' },
                { word: 'ORANGE', image: 'placeholder-orange.svg', coloringImage: 'orange-coloring.svg' },
                { word: 'GRAPE', image: 'placeholder-grape.svg', coloringImage: 'grape-coloring.svg' }
            ]
        },
        {
            id: 3,
            type: 'type1',
            number: '3',
            title: 'Colors',
            pictures: [
                { word: 'RED', image: 'placeholder-red.svg', coloringImage: 'red-coloring.svg' },
                { word: 'BLUE', image: 'placeholder-blue.svg', coloringImage: 'blue-coloring.svg' },
                { word: 'GREEN', image: 'placeholder-green.svg', coloringImage: 'green-coloring.svg' },
                { word: 'YELLOW', image: 'placeholder-yellow.svg', coloringImage: 'yellow-coloring.svg' }
            ]
        }
    ];
}

/**
 * Render the page gallery
 */
function renderPageGallery() {
    const grid = document.querySelector('.page-grid');
    grid.innerHTML = '';

    App.pages.forEach(page => {
        const card = document.createElement('div');
        card.className = 'page-card';
        card.innerHTML = `
            <h3>Page ${page.number}</h3>
            <p>${page.title}</p>
            <p style="font-size: 0.9em; color: #666;">Type ${page.type === 'type1' ? '1' : 'Unknown'}</p>
        `;
        card.addEventListener('click', () => openPage(page));
        grid.appendChild(card);
    });
}

/**
 * Open a specific page
 */
function openPage(page) {
    App.currentPage = page;

    if (page.type === 'type1') {
        initializeType1Page(page);
        showView('type1-view');
    }
}

/**
 * Show a specific view
 */
function showView(viewId) {
    // Hide all views
    document.querySelectorAll('.view').forEach(view => {
        view.classList.remove('active');
    });

    // Show requested view
    const view = document.getElementById(viewId);
    if (view) {
        view.classList.add('active');
        App.currentView = viewId;
    }
}

/**
 * Go back to gallery
 */
function goBackToGallery() {
    showView('gallery-view');
    App.currentPage = null;
}

/**
 * Exit coloring and return to page view
 */
function exitColoring() {
    if (App.currentPage && App.currentPage.type === 'type1') {
        showView('type1-view');
    } else {
        showView('gallery-view');
    }
}

/**
 * Prevent default touch behaviors
 */
function preventDefaultTouchBehaviors() {
    // Prevent scrolling
    document.body.addEventListener('touchmove', (e) => {
        if (!e.target.closest('.page-grid')) {
            e.preventDefault();
        }
    }, { passive: false });

    // Prevent zoom
    document.addEventListener('gesturestart', (e) => {
        e.preventDefault();
    });

    // Prevent double-tap zoom
    let lastTouchEnd = 0;
    document.addEventListener('touchend', (e) => {
        const now = Date.now();
        if (now - lastTouchEnd <= 300) {
            e.preventDefault();
        }
        lastTouchEnd = now;
    }, false);
}

/**
 * Generate placeholder SVG for demonstration
 */
function generatePlaceholderSVG(text, color = '#667eea') {
    return `data:image/svg+xml,${encodeURIComponent(`
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200">
            <rect width="200" height="200" fill="${color}" opacity="0.2"/>
            <text x="50%" y="50%" font-size="24" fill="${color}"
                  text-anchor="middle" dominant-baseline="middle" font-weight="bold">
                ${text}
            </text>
        </svg>
    `)}`;
}

/**
 * Generate coloring page SVG (simple outline)
 */
function generateColoringSVG(shape) {
    const shapes = {
        cat: `<circle cx="100" cy="80" r="40" fill="none" stroke="black" stroke-width="3"/>
              <circle cx="85" cy="75" r="5" fill="black"/>
              <circle cx="115" cy="75" r="5" fill="black"/>
              <path d="M 70 50 L 60 30 L 75 55" fill="none" stroke="black" stroke-width="3"/>
              <path d="M 130 50 L 140 30 L 125 55" fill="none" stroke="black" stroke-width="3"/>`,
        dog: `<circle cx="100" cy="100" r="50" fill="none" stroke="black" stroke-width="3"/>
              <circle cx="85" cy="90" r="5" fill="black"/>
              <circle cx="115" cy="90" r="5" fill="black"/>
              <ellipse cx="60" cy="80" rx="15" ry="30" fill="none" stroke="black" stroke-width="3"/>
              <ellipse cx="140" cy="80" rx="15" ry="30" fill="none" stroke="black" stroke-width="3"/>`,
        bird: `<ellipse cx="100" cy="100" rx="40" ry="50" fill="none" stroke="black" stroke-width="3"/>
               <circle cx="90" cy="90" r="5" fill="black"/>
               <path d="M 60 100 L 30 90 L 60 110" fill="none" stroke="black" stroke-width="3"/>
               <path d="M 140 100 L 170 90 L 140 110" fill="none" stroke="black" stroke-width="3"/>`,
        fish: `<ellipse cx="100" cy="100" rx="60" ry="30" fill="none" stroke="black" stroke-width="3"/>
               <circle cx="80" cy="95" r="5" fill="black"/>
               <path d="M 160 100 L 180 80 L 180 120 Z" fill="none" stroke="black" stroke-width="3"/>`,
        default: `<rect x="50" y="50" width="100" height="100" rx="10" fill="none" stroke="black" stroke-width="3"/>
                  <circle cx="100" cy="100" r="30" fill="none" stroke="black" stroke-width="3"/>`
    };

    const svgContent = shapes[shape] || shapes.default;

    return `data:image/svg+xml,${encodeURIComponent(`
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200">
            <rect width="200" height="200" fill="white"/>
            ${svgContent}
        </svg>
    `)}`;
}
