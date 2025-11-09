//
//  ColoringView.swift
//  Victoria
//
//  Main coloring view with canvas and tools
//

import SwiftUI

struct ColoringView: View {
    @StateObject private var viewModel: ColoringViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showCelebration = false

    init(page: ColoringPage) {
        _viewModel = StateObject(wrappedValue: ColoringViewModel(page: page))
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Top toolbar
                TopToolbar(
                    onBack: { dismiss() },
                    onUndo: { viewModel.undo() },
                    onRedo: { viewModel.redo() },
                    canUndo: viewModel.commandManager.canUndo,
                    canRedo: viewModel.commandManager.canRedo
                )

                // Main canvas
                ColoringCanvas(viewModel: viewModel)
                    .background(Color.white)

                // Bottom toolbar with color palette
                BottomToolbar(
                    selectedColor: $viewModel.selectedColor,
                    selectedTool: $viewModel.selectedTool,
                    onColorSelect: { color in
                        viewModel.selectColor(color)
                    },
                    onToolSelect: { tool in
                        viewModel.selectTool(tool)
                    }
                )
            }

            // Celebration overlay
            if showCelebration {
                FeedbackManager.createCelebrationView()
                    .onTapGesture {
                        showCelebration = false
                    }
            }
        }
        .navigationBarHidden(true)
        .onChange(of: viewModel.isComplete) { isComplete in
            if isComplete {
                showCelebration = true
                FeedbackManager.shared.celebrationHaptic()
            }
        }
    }
}

struct TopToolbar: View {
    let onBack: () -> Void
    let onUndo: () -> Void
    let onRedo: () -> Void
    let canUndo: Bool
    let canRedo: Bool

    var body: some View {
        HStack(spacing: 20) {
            Button(action: onBack) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .font(.headline)
            }

            Spacer()

            Button(action: onUndo) {
                Image(systemName: "arrow.uturn.backward.circle.fill")
                    .font(.system(size: 32))
            }
            .disabled(!canUndo)
            .opacity(canUndo ? 1.0 : 0.3)

            Button(action: onRedo) {
                Image(systemName: "arrow.uturn.forward.circle.fill")
                    .font(.system(size: 32))
            }
            .disabled(!canRedo)
            .opacity(canRedo ? 1.0 : 0.3)
        }
        .padding()
        .background(Color(.systemGray6))
    }
}

struct BottomToolbar: View {
    @Binding var selectedColor: Color
    @Binding var selectedTool: ColoringTool

    let onColorSelect: (Color) -> Void
    let onToolSelect: (ColoringTool) -> Void

    let colors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple,
        .pink, .brown, .black, .cyan, .mint, .indigo
    ]

    var body: some View {
        VStack(spacing: 12) {
            // Tool selection
            HStack(spacing: 20) {
                ToolButton(
                    icon: "paintbrush.fill",
                    label: "Brush",
                    isSelected: selectedTool == .brush(color: selectedColor)
                ) {
                    onToolSelect(.brush(color: selectedColor))
                }

                ToolButton(
                    icon: "eraser.fill",
                    label: "Eraser",
                    isSelected: selectedTool == .eraser
                ) {
                    onToolSelect(.eraser)
                }

                ToolButton(
                    icon: "paintbucket.fill",
                    label: "Fill",
                    isSelected: isFillTool(selectedTool)
                ) {
                    onToolSelect(.fillBucket(color: selectedColor))
                }
            }
            .padding(.horizontal)

            // Color palette
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(colors, id: \.self) { color in
                        ColorSwatch(
                            color: color,
                            isSelected: selectedColor == color
                        ) {
                            onColorSelect(color)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
    }

    private func isFillTool(_ tool: ColoringTool) -> Bool {
        if case .fillBucket = tool {
            return true
        }
        return false
    }
}

struct ToolButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                Text(label)
                    .font(.caption)
            }
            .frame(width: 80, height: 60)
            .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct ColorSwatch: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 50, height: 50)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                )
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.black : Color.clear, lineWidth: 3)
                )
                .scaleEffect(isSelected ? 1.15 : 1.0)
                .shadow(radius: isSelected ? 5 : 2)
        }
    }
}

enum ColoringTool: Equatable {
    case brush(color: Color)
    case eraser
    case fillBucket(color: Color)
}

struct ColoringView_Previews: PreviewProvider {
    static var previews: some View {
        if PDFLoader.shared.loadPDF(named: "coloring-book"),
           let firstPage = PDFLoader.shared.getAllPages().first {
            ColoringView(page: firstPage)
        } else {
            Text("No PDF loaded")
        }
    }
}
