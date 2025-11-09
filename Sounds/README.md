# Sound Effects

This directory should contain the audio files for the Victoria coloring book app.

## Required Sound Files

All files should be in MP3 or M4A format, optimized for iOS.

### 1. boundary_violation.mp3
- **Purpose**: Played when user colors outside the lines
- **Duration**: 200-300ms
- **Tone**: Gentle, friendly "oops" sound
- **Volume**: Moderate
- **Example**: Soft "boop" or gentle bubble pop

### 2. eraser.mp3
- **Purpose**: Played when eraser tool is used
- **Duration**: 100-200ms
- **Tone**: Soft rubbing/erasing sound
- **Volume**: Low to moderate
- **Example**: Soft pencil eraser on paper

### 3. color_select.mp3
- **Purpose**: Played when selecting a new color
- **Duration**: 50-100ms
- **Tone**: Click or tap sound
- **Volume**: Low
- **Example**: UI click, soft tap

### 4. undo.mp3
- **Purpose**: Played when undo button pressed
- **Duration**: 200-300ms
- **Tone**: Whoosh backward
- **Volume**: Moderate
- **Example**: Reverse sweep sound

### 5. redo.mp3
- **Purpose**: Played when redo button pressed
- **Duration**: 200-300ms
- **Tone**: Whoosh forward
- **Volume**: Moderate
- **Example**: Forward sweep sound

### 6. celebration.mp3
- **Purpose**: Played when page completed successfully
- **Duration**: 3-5 seconds
- **Tone**: Exciting, congratulatory
- **Volume**: Higher
- **Example**: Applause + success chime, kids cheering

## Where to Find Sounds

### Free Resources:
- **Freesound.org**: Free sound effects (CC licenses)
- **Zapsplat.com**: Free sound effects for games
- **Mixkit.co**: Free sound effects
- **BBC Sound Effects**: Public domain sounds

### Paid Resources:
- **AudioJungle**: Professional sound effects
- **Pond5**: Sound effects library
- **Epidemic Sound**: Subscription service

## Format Requirements

- **File Format**: MP3 (recommended) or M4A
- **Sample Rate**: 44.1 kHz
- **Bit Rate**: 128-192 kbps
- **Channels**: Mono (stereo acceptable for celebration)
- **File Size**: Keep under 100KB each (except celebration < 500KB)

## Adding to Xcode

1. Open Victoria.xcodeproj in Xcode
2. Drag sound files into the Resources folder
3. Ensure "Copy items if needed" is checked
4. Add to target: VictoriaApp

## Testing Sounds

The AudioManager will automatically preload all sounds on app launch. If a sound file is missing, a warning will be printed to the console, but the app will continue to function.
