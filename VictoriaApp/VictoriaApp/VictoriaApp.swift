//
//  VictoriaApp.swift
//  Victoria - Interactive Coloring Book
//
//  Main app entry point
//

import SwiftUI

@main
struct VictoriaApp: App {
    @StateObject private var audioManager = AudioManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(audioManager)
        }
    }
}

struct ContentView: View {
    var body: some View {
        PageGalleryView()
    }
}
