//
//  AudioManager.swift
//  Victoria
//
//  Manages sound effects and audio playback
//

import Foundation
import AVFoundation
import Combine

class AudioManager: ObservableObject {
    static let shared = AudioManager()

    @Published var isMuted: Bool = false

    private var players: [SoundEffect: AVAudioPlayer] = [:]
    private var lastPlayTime: [SoundEffect: Date] = [:]
    private let debounceInterval: TimeInterval = 0.3 // Prevent sound spam

    enum SoundEffect: String {
        case boundaryViolation = "boundary_violation"
        case eraser = "eraser"
        case colorSelect = "color_select"
        case undo = "undo"
        case redo = "redo"
        case celebration = "celebration"
        case pageComplete = "page_complete"
    }

    private init() {
        preloadSounds()
    }

    /// Preload all sound effects
    private func preloadSounds() {
        for sound in SoundEffect.allCases {
            loadSound(sound)
        }
    }

    /// Load a specific sound file
    private func loadSound(_ sound: SoundEffect) {
        // In a real app, these files would be in the Resources folder
        // For now, we'll create a placeholder that won't crash
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else {
            print("Warning: Sound file not found: \(sound.rawValue).mp3")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            players[sound] = player
        } catch {
            print("Error loading sound \(sound.rawValue): \(error)")
        }
    }

    /// Play a sound effect
    func play(_ sound: SoundEffect, volume: Float = 0.7, force: Bool = false) {
        guard !isMuted else { return }

        // Debounce: prevent playing same sound too frequently
        if !force, let lastTime = lastPlayTime[sound] {
            if Date().timeIntervalSince(lastTime) < debounceInterval {
                return
            }
        }

        guard let player = players[sound] else {
            print("Player not found for sound: \(sound.rawValue)")
            return
        }

        player.volume = volume
        player.currentTime = 0
        player.play()

        lastPlayTime[sound] = Date()
    }

    /// Stop all currently playing sounds
    func stopAll() {
        for player in players.values {
            player.stop()
        }
    }

    /// Stop specific sound
    func stop(_ sound: SoundEffect) {
        players[sound]?.stop()
    }

    /// Toggle mute
    func toggleMute() {
        isMuted.toggle()
        if isMuted {
            stopAll()
        }
    }
}

// Make SoundEffect CaseIterable for preloading
extension AudioManager.SoundEffect: CaseIterable {}
