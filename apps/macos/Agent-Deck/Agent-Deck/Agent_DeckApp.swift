//
//  Agent_DeckApp.swift
//  Agent-Deck
//
//  Created by Agent Deck Team
//

import SwiftUI

/// Main app entry point for Agent Deck menubar application
/// Spec: plan.md main app section, tasks.md T017
@main
struct Agent_DeckApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Settings window (can be opened from menubar)
        // Tasks: T081-T087 - Settings UI registration
        Settings {
            SettingsView()
        }
    }
}
