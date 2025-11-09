//
//  ColoringCanvas.swift
//  Victoria
//
//  Interactive canvas for drawing and coloring
//

import SwiftUI

struct ColoringCanvas: View {
    @ObservedObject var viewModel: ColoringViewModel

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base image (PDF page)
                if let baseImage = viewModel.baseImage {
                    Image(uiImage: baseImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                // Coloring layer
                if let coloringLayer = viewModel.coloringBitmap {
                    Image(uiImage: coloringLayer)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .blendMode(.multiply)
                }

                // Current stroke preview
                Canvas { context, size in
                    if !viewModel.currentStroke.isEmpty {
                        var path = Path()
                        path.addLines(viewModel.currentStroke)

                        if viewModel.selectedTool == .eraser {
                            context.stroke(
                                path,
                                with: .color(.gray.opacity(0.5)),
                                lineWidth: 20
                            )
                        } else {
                            context.stroke(
                                path,
                                with: .color(viewModel.selectedColor),
                                lineWidth: 10
                            )
                        }
                    }
                }

                // Finger cursor
                if let cursorPosition = viewModel.cursorPosition {
                    Circle()
                        .stroke(viewModel.selectedColor, lineWidth: 2)
                        .frame(width: 30, height: 30)
                        .position(cursorPosition)
                        .allowsHitTesting(false)
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        viewModel.handleTouch(at: value.location, in: geometry.size)
                    }
                    .onEnded { value in
                        viewModel.endStroke()
                    }
            )
        }
    }
}
