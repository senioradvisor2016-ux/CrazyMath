// MathAdventureApp.swift
// MathAdventure
// Huvudingång för appen

import SwiftUI

/// Huvudappen
@main
struct MathAdventureApp: App {
    
    init() {
        configureAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
    
    /// Konfigurerar global UI-appearance
    private func configureAppearance() {
        // Navigation bar
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        navAppearance.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        
        // Tab bar (om vi lägger till senare)
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
}

// MARK: - App Configuration

/// Konfiguration för appen
enum AppConfig {
    /// Använd LLM för narrativ (kan stängas av för offline)
    static var useLLM: Bool = true
    
    /// API-nyckel för LLM (läs från miljövariabel eller config)
    static var llmAPIKey: String {
        ProcessInfo.processInfo.environment["LLM_API_KEY"] ?? ""
    }
    
    /// Debug-läge
    static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    /// App-version
    static var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    /// Build-nummer
    static var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}
