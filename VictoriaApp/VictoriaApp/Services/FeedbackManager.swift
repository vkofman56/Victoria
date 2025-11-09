//
//  FeedbackManager.swift
//  Victoria
//
//  Manages haptic and visual feedback for user interactions
//

import Foundation
import UIKit
import SwiftUI

class FeedbackManager {
    static let shared = FeedbackManager()

    private var impactLight = UIImpactFeedbackGenerator(style: .light)
    private var impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private var impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private var selectionFeedback = UISelectionFeedbackGenerator()
    private var notificationFeedback = UINotificationFeedbackGenerator()

    private var lastHapticTime: Date?
    private let hapticDebounce: TimeInterval = 0.2

    private init() {
        // Prepare generators
        impactLight.prepare()
        impactMedium.prepare()
        selectionFeedback.prepare()
        notificationFeedback.prepare()
    }

    // MARK: - Haptic Feedback

    /// Trigger haptic for boundary violation
    func boundaryViolationHaptic() {
        guard shouldTriggerHaptic() else { return }
        impactLight.impactOccurred()
        AudioManager.shared.play(.boundaryViolation)
    }

    /// Trigger haptic for color selection
    func colorSelectionHaptic() {
        selectionFeedback.selectionChanged()
        AudioManager.shared.play(.colorSelect, volume: 0.5)
    }

    /// Trigger haptic for undo
    func undoHaptic() {
        impactMedium.impactOccurred()
        AudioManager.shared.play(.undo)
    }

    /// Trigger haptic for redo
    func redoHaptic() {
        impactMedium.impactOccurred()
        AudioManager.shared.play(.redo)
    }

    /// Trigger haptic for eraser
    func eraserHaptic() {
        selectionFeedback.selectionChanged()
        AudioManager.shared.play(.eraser, volume: 0.4)
    }

    /// Trigger celebration haptic pattern
    func celebrationHaptic() {
        notificationFeedback.notificationOccurred(.success)
        AudioManager.shared.play(.celebration, volume: 0.8, force: true)

        // Additional impact pattern for excitement
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.impactMedium.impactOccurred()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.impactMedium.impactOccurred()
        }
    }

    // MARK: - Debouncing

    private func shouldTriggerHaptic() -> Bool {
        if let lastTime = lastHapticTime {
            let elapsed = Date().timeIntervalSince(lastTime)
            if elapsed < hapticDebounce {
                return false
            }
        }
        lastHapticTime = Date()
        return true
    }

    // MARK: - Visual Feedback

    /// Create shake animation for boundary violation
    static func shakeAnimation() -> Animation {
        Animation.default.repeatCount(3, autoreverses: true).speed(6)
    }

    /// Create celebration confetti view
    static func createCelebrationView() -> some View {
        CelebrationView()
    }
}

// MARK: - Celebration View

struct CelebrationView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                // Success message
                Text("🎉 Great Job! 🎉")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(isAnimating ? 1.2 : 0.5)
                    .opacity(isAnimating ? 1 : 0)

                Text("You colored it perfectly!")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                    .opacity(isAnimating ? 1 : 0)

                // Continue button
                Button(action: {}) {
                    Text("Continue")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 15)
                        .background(Color.white)
                        .cornerRadius(25)
                }
                .scaleEffect(isAnimating ? 1 : 0.8)
                .opacity(isAnimating ? 1 : 0)
            }

            // Confetti particles
            ForEach(0..<50, id: \.self) { index in
                ConfettiPiece(index: index, isAnimating: isAnimating)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isAnimating = true
            }
        }
    }
}

struct ConfettiPiece: View {
    let index: Int
    let isAnimating: Bool

    @State private var yOffset: CGFloat = -100
    @State private var xOffset: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1

    var body: some View {
        Rectangle()
            .fill(randomColor())
            .frame(width: 10, height: 10)
            .rotationEffect(.degrees(rotation))
            .offset(x: xOffset, y: yOffset)
            .opacity(opacity)
            .onAppear {
                let randomDelay = Double.random(in: 0...0.5)
                let randomDuration = Double.random(in: 1.5...3.0)
                let randomX = CGFloat.random(in: -200...200)
                let randomRotation = Double.random(in: 0...720)

                withAnimation(.easeIn(duration: randomDuration).delay(randomDelay)) {
                    yOffset = 1000
                    xOffset = randomX
                    rotation = randomRotation
                    opacity = 0
                }
            }
    }

    private func randomColor() -> Color {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
        return colors[index % colors.count]
    }
}
