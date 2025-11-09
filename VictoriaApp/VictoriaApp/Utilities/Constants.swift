//
//  Constants.swift
//  Victoria
//
//  App-wide constants and configuration
//

import Foundation
import SwiftUI

struct AppConstants {

    // MARK: - App Info
    static let appName = "Victoria"
    static let appVersion = "1.0.0"

    // MARK: - Drawing Constants
    static let defaultBrushSize: CGFloat = 10.0
    static let defaultEraserSize: CGFloat = 20.0
    static let canvasResolution = CGSize(width: 2048, height: 2048)

    // MARK: - Completion Thresholds
    static let completionCoverageThreshold: Double = 0.70 // 70%
    static let completionAccuracyThreshold: Double = 0.90 // 90%
    static let completionMinColors: Int = 3

    // MARK: - Performance
    static let maxUndoStackSize: Int = 50
    static let pixelSampleRate: Int = 5 // Sample every Nth pixel
    static let boundaryCheckDebounce: TimeInterval = 0.2

    // MARK: - Audio
    static let defaultSoundVolume: Float = 0.7
    static let celebrationVolume: Float = 0.8
    static let soundDebounceInterval: TimeInterval = 0.3

    // MARK: - UI
    static let colorSwatchSize: CGFloat = 50.0
    static let toolButtonSize = CGSize(width: 80, height: 60)
    static let minTouchTargetSize: CGFloat = 44.0 // Apple HIG

    // MARK: - Kid-Friendly Colors
    static let colorPalette: [Color] = [
        Color(red: 1.0, green: 0.0, blue: 0.0),   // Red
        Color(red: 1.0, green: 0.549, blue: 0.0), // Orange
        Color(red: 1.0, green: 0.843, blue: 0.0), // Yellow
        Color(red: 0.0, green: 1.0, blue: 0.0),   // Green
        Color(red: 0.0, green: 0.0, blue: 1.0),   // Blue
        Color(red: 0.58, green: 0.439, blue: 0.859), // Purple
        Color(red: 1.0, green: 0.412, blue: 0.706), // Pink
        Color(red: 0.545, green: 0.271, blue: 0.075), // Brown
        Color(red: 0.0, green: 0.0, blue: 0.0),   // Black
        Color(red: 0.0, green: 1.0, blue: 1.0),   // Cyan
        Color(red: 0.596, green: 0.984, blue: 0.596), // Mint
        Color(red: 0.294, green: 0.0, blue: 0.51)  // Indigo
    ]

    // MARK: - Animations
    static let celebrationDuration: TimeInterval = 3.0
    static let confettiCount: Int = 50
    static let shakeDuration: TimeInterval = 0.3
    static let shakeDistance: CGFloat = 3.0
}

// MARK: - Color Extension

extension Color {
    static let kidFriendlyColors = AppConstants.colorPalette

    var uiColor: UIColor {
        UIColor(self)
    }
}

// MARK: - Haptic Feedback Styles

enum HapticStyle {
    case light
    case medium
    case heavy
    case selection
    case success
    case warning
    case error
}
