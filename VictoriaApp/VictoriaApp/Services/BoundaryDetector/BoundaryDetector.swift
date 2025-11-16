//
//  BoundaryDetector.swift
//  Victoria
//
//  Detects when coloring goes outside boundary lines
//

import Foundation
import UIKit
import CoreImage

class BoundaryDetector {

    private var boundaryMask: UIImage?
    private var maskData: [UInt8]?
    private var width: Int = 0
    private var height: Int = 0

    /// Initialize with a boundary mask image
    init(boundaryMask: UIImage?) {
        self.boundaryMask = boundaryMask
        processMask()
    }

    /// Extract boundary mask from PDF page
    /// Creates a binary mask where black = boundary, white = colorable
    static func extractBoundaryMask(from image: UIImage, threshold: CGFloat = 0.3) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        let width = cgImage.width
        let height = cgImage.height

        // Create grayscale context
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else {
            return nil
        }

        // Draw original image
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        // Get pixel data
        guard let data = context.data else { return nil }
        let pixelData = data.bindMemory(to: UInt8.self, capacity: width * height)

        // Apply threshold - convert to binary (black/white)
        for i in 0..<(width * height) {
            let pixelValue = CGFloat(pixelData[i]) / 255.0
            // If pixel is dark (< threshold), it's a boundary line
            pixelData[i] = pixelValue < threshold ? 0 : 255
        }

        // Create image from processed data
        guard let outputImage = context.makeImage() else { return nil }
        return UIImage(cgImage: outputImage)
    }

    /// Process mask for fast pixel lookup
    private func processMask() {
        guard let mask = boundaryMask,
              let cgImage = mask.cgImage else {
            return
        }

        width = cgImage.width
        height = cgImage.height

        // Extract pixel data into array for O(1) lookup
        let colorSpace = CGColorSpaceCreateDeviceGray()
        var pixelData = [UInt8](repeating: 0, count: width * height)

        guard let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ) else {
            return
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        maskData = pixelData
    }

    /// Check if point is on a boundary
    /// Returns true if point is on a black line (boundary)
    func isBoundary(at point: CGPoint) -> Bool {
        guard let data = maskData else { return false }

        let x = Int(point.x)
        let y = Int(point.y)

        // Bounds check
        guard x >= 0 && x < width && y >= 0 && y < height else {
            return true // Out of bounds = boundary
        }

        let index = y * width + x
        guard index < data.count else { return true }

        // Black pixel (0) = boundary, White pixel (255) = colorable
        return data[index] < 128
    }

    /// Check if any point around the brush circumference touches a boundary
    /// This provides more accurate boundary detection by checking the brush edges
    /// - Parameters:
    ///   - center: Center point of the brush
    ///   - brushRadius: Radius of the brush in pixels
    ///   - numPoints: Number of points to check around the circumference (default: 12)
    /// - Returns: True if any point on the brush edge touches a boundary
    func isBoundaryAtBrushEdge(center: CGPoint, brushRadius: CGFloat, numPoints: Int = 12) -> Bool {
        guard let data = maskData else { return false }

        // Check the center first
        if isBoundary(at: center) {
            return true
        }

        // Check points around the circumference
        for i in 0..<numPoints {
            let angle = (CGFloat(i) / CGFloat(numPoints)) * 2.0 * .pi
            let x = center.x + cos(angle) * brushRadius
            let y = center.y + sin(angle) * brushRadius

            let edgePoint = CGPoint(x: x, y: y)

            // Check this edge point
            let pixelX = Int(edgePoint.x)
            let pixelY = Int(edgePoint.y)

            // Bounds check
            if pixelX < 0 || pixelX >= width || pixelY < 0 || pixelY >= height {
                return true // Out of bounds = boundary
            }

            let index = pixelY * width + pixelX
            guard index < data.count else { return true }

            // Black pixel (0) = boundary
            if data[index] < 128 {
                return true
            }
        }

        return false
    }

    /// Calculate penetration percentage of brush into boundary
    /// Returns the percentage of brush circumference points that are on a boundary
    /// - Parameters:
    ///   - center: Center point of the brush
    ///   - brushRadius: Radius of the brush in pixels
    ///   - numPoints: Number of points to check around the circumference (default: 12)
    /// - Returns: Percentage of points on boundary (0.0 to 1.0)
    func calculateBrushPenetration(center: CGPoint, brushRadius: CGFloat, numPoints: Int = 12) -> CGFloat {
        guard let data = maskData else { return 0.0 }

        var boundaryPoints = 0
        var totalPoints = 0

        // Check the center
        totalPoints += 1
        if isBoundary(at: center) {
            boundaryPoints += 1
        }

        // Check points around the circumference
        for i in 0..<numPoints {
            let angle = (CGFloat(i) / CGFloat(numPoints)) * 2.0 * .pi
            let x = center.x + cos(angle) * brushRadius
            let y = center.y + sin(angle) * brushRadius

            let edgePoint = CGPoint(x: x, y: y)

            // Check this edge point
            let pixelX = Int(edgePoint.x)
            let pixelY = Int(edgePoint.y)

            totalPoints += 1

            // Bounds check - out of bounds counts as boundary
            if pixelX < 0 || pixelX >= width || pixelY < 0 || pixelY >= height {
                boundaryPoints += 1
                continue
            }

            let index = pixelY * width + pixelX
            guard index < data.count else {
                boundaryPoints += 1
                continue
            }

            // Black pixel (0) = boundary
            if data[index] < 128 {
                boundaryPoints += 1
            }
        }

        return totalPoints > 0 ? CGFloat(boundaryPoints) / CGFloat(totalPoints) : 0.0
    }

    /// Check if any point in array crosses boundary
    func detectBoundaryViolation(in points: [CGPoint]) -> Bool {
        // Sample points (don't check every single one for performance)
        let stride = max(1, points.count / 10)
        for i in stride(from: 0, to: points.count, by: stride) {
            if isBoundary(at: points[i]) {
                return true
            }
        }
        return false
    }

    /// Get percentage of points that are on boundaries
    func getBoundaryViolationPercentage(in points: [CGPoint]) -> Double {
        guard !points.isEmpty else { return 0.0 }

        let violations = points.filter { isBoundary(at: $0) }.count
        return Double(violations) / Double(points.count)
    }

    /// Check entire colored bitmap for boundary violations
    func analyzeBitmap(_ bitmap: UIImage) -> (totalPixels: Int, violationPixels: Int, percentage: Double) {
        guard let cgImage = bitmap.cgImage else {
            return (0, 0, 0.0)
        }

        let bitmapWidth = cgImage.width
        let bitmapHeight = cgImage.height

        // Sample pixels (checking every pixel is too slow)
        var totalColored = 0
        var violations = 0
        let sampleRate = 5 // Check every 5th pixel

        for y in stride(from: 0, to: bitmapHeight, by: sampleRate) {
            for x in stride(from: 0, to: bitmapWidth, by: sampleRate) {
                let point = CGPoint(x: x, y: y)

                // Check if pixel is colored (not white/transparent)
                if let color = DrawingEngine.getPixelColor(in: bitmap, at: point),
                   !isWhiteOrClear(color) {
                    totalColored += 1

                    // Check if it's on a boundary
                    if isBoundary(at: point) {
                        violations += 1
                    }
                }
            }
        }

        let percentage = totalColored > 0 ? Double(violations) / Double(totalColored) : 0.0
        return (totalColored, violations, percentage)
    }

    /// Helper to check if color is white or transparent
    private func isWhiteOrClear(_ color: UIColor) -> Bool {
        var white: CGFloat = 0
        var alpha: CGFloat = 0
        color.getWhite(&white, alpha: &alpha)
        return white > 0.95 || alpha < 0.1
    }
}
