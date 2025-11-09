//
//  DrawingCommand.swift
//  Victoria
//
//  Command pattern implementation for undo/redo functionality
//

import Foundation
import SwiftUI

protocol DrawingCommand {
    func execute(on bitmap: inout UIImage)
    func undo(on bitmap: inout UIImage)
}

struct ColorCommand: DrawingCommand {
    let points: [CGPoint]
    let color: UIColor
    let previousPixels: [(point: CGPoint, color: UIColor)]

    func execute(on bitmap: inout UIImage) {
        // Apply color to points
        bitmap = DrawingEngine.applyColor(to: bitmap, at: points, color: color)
    }

    func undo(on bitmap: inout UIImage) {
        // Restore previous pixels
        for pixel in previousPixels {
            bitmap = DrawingEngine.setPixel(in: bitmap, at: pixel.point, color: pixel.color)
        }
    }
}

struct EraseCommand: DrawingCommand {
    let points: [CGPoint]
    let previousPixels: [(point: CGPoint, color: UIColor)]

    func execute(on bitmap: inout UIImage) {
        bitmap = DrawingEngine.erasePixels(in: bitmap, at: points)
    }

    func undo(on bitmap: inout UIImage) {
        for pixel in previousPixels {
            bitmap = DrawingEngine.setPixel(in: bitmap, at: pixel.point, color: pixel.color)
        }
    }
}

struct FillCommand: DrawingCommand {
    let startPoint: CGPoint
    let color: UIColor
    let affectedPixels: [(point: CGPoint, color: UIColor)]

    func execute(on bitmap: inout UIImage) {
        bitmap = DrawingEngine.floodFill(bitmap: bitmap, at: startPoint, with: color)
    }

    func undo(on bitmap: inout UIImage) {
        for pixel in affectedPixels {
            bitmap = DrawingEngine.setPixel(in: bitmap, at: pixel.point, color: pixel.color)
        }
    }
}

class CommandManager: ObservableObject {
    @Published private(set) var canUndo = false
    @Published private(set) var canRedo = false

    private var undoStack: [DrawingCommand] = []
    private var redoStack: [DrawingCommand] = []
    private let maxStackSize = 50

    func execute(_ command: DrawingCommand, on bitmap: inout UIImage) {
        command.execute(on: &bitmap)
        undoStack.append(command)
        redoStack.removeAll()

        // Limit stack size
        if undoStack.count > maxStackSize {
            undoStack.removeFirst()
        }

        updateState()
    }

    func undo(on bitmap: inout UIImage) {
        guard let command = undoStack.popLast() else { return }
        command.undo(on: &bitmap)
        redoStack.append(command)
        updateState()
    }

    func redo(on bitmap: inout UIImage) {
        guard let command = redoStack.popLast() else { return }
        command.execute(on: &bitmap)
        undoStack.append(command)
        updateState()
    }

    func clear() {
        undoStack.removeAll()
        redoStack.removeAll()
        updateState()
    }

    private func updateState() {
        canUndo = !undoStack.isEmpty
        canRedo = !redoStack.isEmpty
    }
}
