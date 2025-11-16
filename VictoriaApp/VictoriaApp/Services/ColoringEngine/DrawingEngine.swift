//
//  DrawingEngine.swift
//  Victoria
//
//  Core drawing and coloring logic including flood fill algorithm
//

import Foundation
import UIKit
import CoreGraphics

class DrawingEngine {

    // MARK: - Flood Fill Algorithm

    /// Perform flood fill at specified point with color
    static func floodFill(bitmap: UIImage, at point: CGPoint, with color: UIColor) -> UIImage {
        guard let cgImage = bitmap.cgImage else { return bitmap }

        let width = cgImage.width
        let height = cgImage.height

        // Create bitmap context
        guard let context = createBitmapContext(width: width, height: height, from: cgImage) else {
            return bitmap
        }

        // Get pixel data
        guard let data = context.data else { return bitmap }
        let pixelData = data.bindMemory(to: UInt32.self, capacity: width * height)

        let x = Int(point.x)
        let y = Int(point.y)

        // Bounds check
        guard x >= 0 && x < width && y >= 0 && y < height else { return bitmap }

        let targetColor = pixelData[y * width + x]
        let fillColor = colorToUInt32(color)

        // Don't fill if colors are the same
        if targetColor == fillColor { return bitmap }

        // Queue-based flood fill (non-recursive)
        var queue: [(Int, Int)] = [(x, y)]
        var visited = Set<Int>()

        while !queue.isEmpty {
            let (px, py) = queue.removeFirst()
            let index = py * width + px

            // Check if already visited
            if visited.contains(index) { continue }
            visited.insert(index)

            // Check bounds
            guard px >= 0 && px < width && py >= 0 && py < height else { continue }

            // Check if pixel matches target color
            if pixelData[index] == targetColor {
                // Fill pixel
                pixelData[index] = fillColor

                // Add neighbors to queue
                queue.append((px + 1, py))
                queue.append((px - 1, py))
                queue.append((px, py + 1))
                queue.append((px, py - 1))
            }
        }

        // Create image from context
        guard let outputCGImage = context.makeImage() else { return bitmap }
        return UIImage(cgImage: outputCGImage)
    }

    // MARK: - Drawing Operations

    /// Apply color to multiple points (brush stroke)
    static func applyColor(to bitmap: UIImage, at points: [CGPoint], color: UIColor) -> UIImage {
        guard let cgImage = bitmap.cgImage else { return bitmap }

        let width = cgImage.width
        let height = cgImage.height

        guard let context = createBitmapContext(width: width, height: height, from: cgImage) else {
            return bitmap
        }

        // Set color
        context.setFillColor(color.cgColor)

        // Draw circles at each point for smooth brush
        for point in points {
            let brushSize: CGFloat = 8.0
            let rect = CGRect(
                x: point.x - brushSize / 2,
                y: point.y - brushSize / 2,
                width: brushSize,
                height: brushSize
            )
            context.fillEllipse(in: rect)
        }

        guard let outputCGImage = context.makeImage() else { return bitmap }
        return UIImage(cgImage: outputCGImage)
    }

    /// Erase pixels at specified points
    static func erasePixels(in bitmap: UIImage, at points: [CGPoint]) -> UIImage {
        guard let cgImage = bitmap.cgImage else { return bitmap }

        let width = cgImage.width
        let height = cgImage.height

        guard let context = createBitmapContext(width: width, height: height, from: cgImage) else {
            return bitmap
        }

        // Set to clear color
        context.setBlendMode(.clear)

        // Erase circles at each point
        for point in points {
            let eraserSize: CGFloat = 20.0
            let rect = CGRect(
                x: point.x - eraserSize / 2,
                y: point.y - eraserSize / 2,
                width: eraserSize,
                height: eraserSize
            )
            context.fillEllipse(in: rect)
        }

        guard let outputCGImage = context.makeImage() else { return bitmap }
        return UIImage(cgImage: outputCGImage)
    }

    /// Set a single pixel to specified color
    static func setPixel(in bitmap: UIImage, at point: CGPoint, color: UIColor) -> UIImage {
        guard let cgImage = bitmap.cgImage else { return bitmap }

        let width = cgImage.width
        let height = cgImage.height

        guard let context = createBitmapContext(width: width, height: height, from: cgImage) else {
            return bitmap
        }

        guard let data = context.data else { return bitmap }
        let pixelData = data.bindMemory(to: UInt32.self, capacity: width * height)

        let x = Int(point.x)
        let y = Int(point.y)

        guard x >= 0 && x < width && y >= 0 && y < height else { return bitmap }

        pixelData[y * width + x] = colorToUInt32(color)

        guard let outputCGImage = context.makeImage() else { return bitmap }
        return UIImage(cgImage: outputCGImage)
    }

    // MARK: - Helper Functions

    /// Create bitmap context for image manipulation
    private static func createBitmapContext(width: Int, height: Int, from cgImage: CGImage) -> CGContext? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else {
            return nil
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        return context
    }

    /// Convert UIColor to UInt32 for pixel manipulation
    private static func colorToUInt32(_ color: UIColor) -> UInt32 {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let r = UInt32(red * 255)
        let g = UInt32(green * 255)
        let b = UInt32(blue * 255)
        let a = UInt32(alpha * 255)

        // RGBA format
        return (r << 24) | (g << 16) | (b << 8) | a
    }

    /// Get color of pixel at point
    static func getPixelColor(in bitmap: UIImage, at point: CGPoint) -> UIColor? {
        guard let cgImage = bitmap.cgImage else { return nil }

        let width = cgImage.width
        let height = cgImage.height

        let x = Int(point.x)
        let y = Int(point.y)

        guard x >= 0 && x < width && y >= 0 && y < height else { return nil }

        guard let dataProvider = cgImage.dataProvider,
              let data = dataProvider.data,
              let bytes = CFDataGetBytePtr(data) else {
            return nil
        }

        let bytesPerPixel = 4
        let offset = (y * width + x) * bytesPerPixel

        let r = CGFloat(bytes[offset]) / 255.0
        let g = CGFloat(bytes[offset + 1]) / 255.0
        let b = CGFloat(bytes[offset + 2]) / 255.0
        let a = CGFloat(bytes[offset + 3]) / 255.0

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }

    /// Create blank bitmap
    static func createBlankBitmap(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
