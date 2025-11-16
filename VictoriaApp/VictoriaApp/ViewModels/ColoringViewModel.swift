//
//  ColoringViewModel.swift
//  Victoria
//
//  View model managing coloring logic and state
//

import Foundation
import SwiftUI
import Combine

class ColoringViewModel: ObservableObject {
    // UI State
    @Published var selectedColor: Color = .red
    @Published var selectedTool: ColoringTool = .brush(color: .red)
    @Published var currentStroke: [CGPoint] = []
    @Published var cursorPosition: CGPoint?

    // Drawing State
    @Published var coloringBitmap: UIImage?
    @Published var baseImage: UIImage?

    // Completion State
    @Published var isComplete: Bool = false
    @Published var completionStatus: CompletionStatus = .incomplete

    // Command Manager
    @Published var commandManager = CommandManager()

    // Page Data
    private let page: ColoringPage
    private var boundaryDetector: BoundaryDetector
    private var canvasSize: CGSize = .zero

    // Stroke tracking
    private var strokePoints: [CGPoint] = []
    private var hasViolatedBoundary = false
    private var lastBoundaryCheckTime: Date?

    init(page: ColoringPage) {
        self.page = page

        // Render base image
        let size = CGSize(width: 2048, height: 2048) // iPad Pro resolution
        self.baseImage = PDFLoader.shared.renderPage(page.pdfPage, size: size)

        // Extract boundary mask
        if let base = baseImage {
            let mask = BoundaryDetector.extractBoundaryMask(from: base)
            self.boundaryDetector = BoundaryDetector(boundaryMask: mask)
        } else {
            self.boundaryDetector = BoundaryDetector(boundaryMask: nil)
        }

        // Create blank coloring layer
        if let base = baseImage {
            self.coloringBitmap = DrawingEngine.createBlankBitmap(size: base.size)
        }
    }

    // MARK: - Tool Selection

    func selectColor(_ color: Color) {
        selectedColor = color
        FeedbackManager.shared.colorSelectionHaptic()

        // Update tool with new color
        if case .brush = selectedTool {
            selectedTool = .brush(color: color)
        } else if case .fillBucket = selectedTool {
            selectedTool = .fillBucket(color: color)
        }
    }

    func selectTool(_ tool: ColoringTool) {
        selectedTool = tool
        FeedbackManager.shared.colorSelectionHaptic()
    }

    // MARK: - Touch Handling

    func handleTouch(at location: CGPoint, in canvasSize: CGSize) {
        self.canvasSize = canvasSize
        cursorPosition = location

        // Convert to bitmap coordinates
        let bitmapPoint = convertToBitmapCoordinates(location, canvasSize: canvasSize)

        switch selectedTool {
        case .brush(let color):
            handleBrushStroke(at: bitmapPoint, color: color)
        case .eraser:
            handleEraser(at: bitmapPoint)
        case .fillBucket(let color):
            handleFillBucket(at: bitmapPoint, color: color)
        }

        currentStroke.append(location)
    }

    func endStroke() {
        strokePoints.removeAll()
        currentStroke.removeAll()
        cursorPosition = nil
        hasViolatedBoundary = false

        // Check for completion
        checkCompletion()
    }

    // MARK: - Drawing Operations

    private func handleBrushStroke(at point: CGPoint, color: Color) {
        // If we have a previous point, check interpolated points along the path
        if let lastPoint = strokePoints.last {
            checkBoundaryAlongPath(from: lastPoint, to: point)
        } else {
            // First point - just check this location
            checkBoundaryViolation(at: point)
        }

        strokePoints.append(point)

        // Apply color
        guard var bitmap = coloringBitmap else { return }
        bitmap = DrawingEngine.applyColor(
            to: bitmap,
            at: [point],
            color: UIColor(color)
        )
        coloringBitmap = bitmap
    }

    private func handleEraser(at point: CGPoint) {
        strokePoints.append(point)

        guard var bitmap = coloringBitmap else { return }
        bitmap = DrawingEngine.erasePixels(in: bitmap, at: [point])
        coloringBitmap = bitmap

        if strokePoints.count % 5 == 0 {
            FeedbackManager.shared.eraserHaptic()
        }
    }

    private func handleFillBucket(at point: CGPoint, color: Color) {
        // Check if tapping on or near boundary (using small radius for fill bucket)
        if boundaryDetector.isBoundaryAtBrushEdge(center: point, brushRadius: 3.0) {
            FeedbackManager.shared.boundaryViolationHaptic()
            return
        }

        // Perform flood fill
        guard var bitmap = coloringBitmap else { return }

        let previousBitmap = bitmap
        bitmap = DrawingEngine.floodFill(
            bitmap: bitmap,
            at: point,
            with: UIColor(color)
        )

        // Save previous state for undo
        // TODO: Implement proper command
        coloringBitmap = bitmap

        // Check for completion after fill
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.checkCompletion()
        }
    }

    // MARK: - Boundary Detection

    private func checkBoundaryViolation(at point: CGPoint) {
        // Don't check if we've already detected a violation in this stroke
        if hasViolatedBoundary {
            return
        }

        // Use brush radius of 4.0 (half of 8.0 pixel brush diameter)
        let brushRadius: CGFloat = AppConstants.defaultBrushSize / 2.0

        // Calculate penetration percentage
        let penetration = boundaryDetector.calculateBrushPenetration(
            center: point,
            brushRadius: brushRadius,
            numPoints: 12
        )

        // Only trigger boundary violation if penetration exceeds threshold (10%)
        if penetration > AppConstants.boundaryPenetrationThreshold {
            hasViolatedBoundary = true
            lastBoundaryCheckTime = Date()
            FeedbackManager.shared.boundaryViolationHaptic()
            AudioManager.shared.play(.boundaryViolation)
        }
    }

    /// Check boundary along the path from last point to current point
    /// This ensures we detect boundaries even during fast brush movements
    private func checkBoundaryAlongPath(from start: CGPoint, to end: CGPoint) {
        // If we've already violated, don't check again
        if hasViolatedBoundary {
            return
        }

        // Calculate distance between points
        let dx = end.x - start.x
        let dy = end.y - start.y
        let distance = sqrt(dx * dx + dy * dy)

        // If points are very close, just check the end point
        if distance < 2.0 {
            checkBoundaryViolation(at: end)
            return
        }

        // Interpolate points along the path (check every ~5 pixels)
        let steps = max(Int(distance / 5.0), 1)
        for i in 0...steps {
            let t = CGFloat(i) / CGFloat(steps)
            let interpolatedPoint = CGPoint(
                x: start.x + dx * t,
                y: start.y + dy * t
            )
            checkBoundaryViolation(at: interpolatedPoint)

            // Stop checking if we found a violation
            if hasViolatedBoundary {
                break
            }
        }
    }

    // MARK: - Completion Detection

    private func checkCompletion() {
        guard let bitmap = coloringBitmap else { return }

        let status = CompletionAnalyzer.analyzeCompletion(
            coloredBitmap: bitmap,
            boundaryMask: nil,
            boundaryDetector: boundaryDetector
        )

        completionStatus = status

        if status.isComplete && !isComplete {
            isComplete = true
        }
    }

    // MARK: - Undo/Redo

    func undo() {
        guard var bitmap = coloringBitmap else { return }
        commandManager.undo(on: &bitmap)
        coloringBitmap = bitmap
        FeedbackManager.shared.undoHaptic()
    }

    func redo() {
        guard var bitmap = coloringBitmap else { return }
        commandManager.redo(on: &bitmap)
        coloringBitmap = bitmap
        FeedbackManager.shared.redoHaptic()
    }

    // MARK: - Coordinate Conversion

    private func convertToBitmapCoordinates(_ point: CGPoint, canvasSize: CGSize) -> CGPoint {
        guard let bitmap = coloringBitmap else { return point }

        let bitmapSize = bitmap.size

        // Calculate scale factor
        let scaleX = bitmapSize.width / canvasSize.width
        let scaleY = bitmapSize.height / canvasSize.height

        return CGPoint(
            x: point.x * scaleX,
            y: point.y * scaleY
        )
    }
}
