//
//  CompletionAnalyzer.swift
//  Victoria
//
//  Analyzes coloring completion and quality
//

import Foundation
import UIKit

class CompletionAnalyzer {

    /// Analyze if a coloring page is complete and well-done
    static func analyzeCompletion(
        coloredBitmap: UIImage,
        boundaryMask: UIImage?,
        boundaryDetector: BoundaryDetector
    ) -> CompletionStatus {

        guard let cgImage = coloredBitmap.cgImage else {
            return .incomplete
        }

        let width = cgImage.width
        let height = cgImage.height

        var totalColorablePixels = 0
        var coloredPixels = 0
        var uniqueColors = Set<String>()
        let sampleRate = 5 // Sample every 5th pixel for performance

        // Analyze the bitmap
        for y in stride(from: 0, to: height, by: sampleRate) {
            for x in stride(from: 0, to: width, by: sampleRate) {
                let point = CGPoint(x: x, y: y)

                // Skip if it's a boundary
                if boundaryDetector.isBoundary(at: point) {
                    continue
                }

                totalColorablePixels += 1

                // Check if pixel is colored
                if let color = DrawingEngine.getPixelColor(in: coloredBitmap, at: point),
                   !isWhiteOrClear(color) {
                    coloredPixels += 1

                    // Track unique colors
                    let colorString = colorToString(color)
                    uniqueColors.insert(colorString)
                }
            }
        }

        // Calculate metrics
        let coverage = totalColorablePixels > 0
            ? Double(coloredPixels) / Double(totalColorablePixels)
            : 0.0

        // Analyze boundary violations
        let (_, violations, violationPercentage) = boundaryDetector.analyzeBitmap(coloredBitmap)
        let accuracy = 1.0 - violationPercentage

        // Calculate score (0-100)
        let score = calculateScore(
            coverage: coverage,
            accuracy: accuracy,
            uniqueColors: uniqueColors.count
        )

        // Determine if complete
        let isComplete = coverage >= 0.70 && accuracy >= 0.90 && uniqueColors.count >= 3

        return CompletionStatus(
            isComplete: isComplete,
            coverage: coverage,
            accuracy: accuracy,
            uniqueColors: uniqueColors.count,
            score: score
        )
    }

    /// Calculate overall score (0-100)
    private static func calculateScore(coverage: Double, accuracy: Double, uniqueColors: Int) -> Int {
        let coverageScore = coverage * 50 // Max 50 points
        let accuracyScore = accuracy * 40 // Max 40 points
        let colorScore = min(Double(uniqueColors) / 5.0, 1.0) * 10 // Max 10 points

        return Int((coverageScore + accuracyScore + colorScore).rounded())
    }

    /// Check if color is white or transparent
    private static func isWhiteOrClear(_ color: UIColor) -> Bool {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        // White if RGB all > 0.95
        let isWhite = red > 0.95 && green > 0.95 && blue > 0.95

        // Transparent if alpha < 0.1
        let isTransparent = alpha < 0.1

        return isWhite || isTransparent
    }

    /// Convert color to string for uniqueness tracking
    private static func colorToString(_ color: UIColor) -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        // Round to reduce noise
        let r = Int(red * 255 / 10) * 10
        let g = Int(green * 255 / 10) * 10
        let b = Int(blue * 255 / 10) * 10

        return "\(r),\(g),\(b)"
    }

    /// Get progress summary for display
    static func getProgressSummary(_ status: CompletionStatus) -> String {
        if status.isComplete {
            return "Complete! Score: \(status.score)/100"
        } else {
            let percentage = Int(status.coverage * 100)
            return "\(percentage)% colored"
        }
    }
}
