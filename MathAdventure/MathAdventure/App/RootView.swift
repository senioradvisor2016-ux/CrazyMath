// RootView.swift
// MathAdventure
// Huvud-vy som hanterar appens navigation och state

import SwiftUI

/// Appens rot-vy som hanterar navigation mellan skärmar
struct RootView: View {
    @StateObject private var appState = AppState()
    
    var body: some View {
        Group {
            switch appState.currentScreen {
            case .loading:
                loadingScreen
                
            case .welcome:
                welcomeScreen
                
            case .worldMap:
                WorldMapView(
                    playerProfile: $appState.playerProfile,
                    selectedLevel: $appState.selectedLevel
                )
                .onChange(of: appState.selectedLevel) { _, newValue in
                    if newValue != nil {
                        appState.currentScreen = .level
                    }
                }
                
            case .level:
                if let selection = appState.selectedLevel {
                    LevelHostView(
                        selection: selection,
                        playerProfile: $appState.playerProfile,
                        onComplete: { success, stars in
                            appState.handleLevelComplete(success: success, stars: stars)
                        },
                        onDismiss: {
                            appState.returnToMap()
                        }
                    )
                }
                
            case .result:
                resultScreen
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.currentScreen)
    }
    
    @ViewBuilder
    private var loadingScreen: some View {
        ZStack {
            LinearGradient(
                colors: [.green, .blue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Logo (fotbollstema)
                Text("⚽")
                    .font(.system(size: 80))
                
                Text("Fotbollsmatten")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                Text("med Zlatan, Messi & alla stjärnor!")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
        .onAppear {
            appState.loadProfile()
        }
    }
    
    @ViewBuilder
    private var welcomeScreen: some View {
        ZStack {
            LinearGradient(
                colors: [.green.opacity(0.3), .blue.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Hero
                VStack(spacing: 16) {
                    Text("⚽🏆")
                        .font(.system(size: 100))
                    
                    Text("Välkommen till\nFotbollsmatten!")
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                    
                    Text("Träna matte med Zlatan, Messi, Ronaldo och andra fotbollsstjärnor!")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // Namn-input
                VStack(spacing: 12) {
                    Text("Vad heter du?")
                        .font(.headline)
                    
                    TextField("Ditt namn", text: $appState.playerProfile.name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 250)
                }
                
                // Avatar-val
                VStack(spacing: 12) {
                    Text("Välj din avatar")
                        .font(.headline)
                    
                    HStack(spacing: 16) {
                        ForEach(0..<6, id: \.self) { index in
                            AvatarButton(
                                index: index,
                                isSelected: appState.playerProfile.avatarIndex == index
                            ) {
                                appState.playerProfile.avatarIndex = index
                                HapticManager.shared.selection()
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Start-knapp
                Button(action: {
                    appState.startGame()
                }) {
                    HStack {
                        Text("Starta Äventyret!")
                            .font(.headline)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
    
    @ViewBuilder
    private var resultScreen: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text("🎉")
                .font(.system(size: 80))
            
            Text("Nivå klar!")
                .font(.largeTitle.bold())
            
            Button("Fortsätt") {
                appState.continueAfterResult()
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
    }
}

/// Avatar-knapp (fotbollstema)
struct AvatarButton: View {
    let index: Int
    let isSelected: Bool
    let onTap: () -> Void
    
    private let avatars = ["⚽", "🥅", "🏆", "👟", "🧤", "🎯"]
    
    var body: some View {
        Button(action: onTap) {
            Text(avatars[index])
                .font(.system(size: 36))
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(isSelected ? Color.green.opacity(0.3) : Color(.secondarySystemBackground))
                        .overlay(
                            Circle()
                                .stroke(isSelected ? Color.green : Color.clear, lineWidth: 3)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// App state management
@MainActor
class AppState: ObservableObject {
    @Published var currentScreen: Screen = .loading
    @Published var playerProfile: PlayerProfile = PlayerProfile()
    @Published var selectedLevel: LevelSelection? = nil
    @Published var lastResult: LevelResult? = nil
    
    enum Screen: Equatable {
        case loading
        case welcome
        case worldMap
        case level
        case result
    }
    
    func loadProfile() {
        // Försök ladda sparad profil
        if let saved = PlayerProfile.load() {
            playerProfile = saved
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.currentScreen = .worldMap
            }
        } else {
            // Ny spelare
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.currentScreen = .welcome
            }
        }
    }
    
    func startGame() {
        playerProfile.save()
        currentScreen = .worldMap
        HapticManager.shared.impact(.medium)
    }
    
    func handleLevelComplete(success: Bool, stars: Int) {
        lastResult = LevelResult(success: success, stars: stars)
        
        // Gå till nästa nivå eller tillbaka till kartan
        if let current = selectedLevel {
            // Försök gå till nästa nivå i samma värld
            let nextIndex = current.levelIndex + 1
            if nextIndex < current.grade.levelCount {
                selectedLevel = LevelSelection(grade: current.grade, levelIndex: nextIndex)
            } else {
                returnToMap()
            }
        }
    }
    
    func returnToMap() {
        selectedLevel = nil
        currentScreen = .worldMap
    }
    
    func continueAfterResult() {
        if let current = selectedLevel {
            let nextIndex = current.levelIndex + 1
            if nextIndex < current.grade.levelCount {
                selectedLevel = LevelSelection(grade: current.grade, levelIndex: nextIndex)
                currentScreen = .level
            } else {
                returnToMap()
            }
        } else {
            returnToMap()
        }
    }
}

struct LevelResult {
    let success: Bool
    let stars: Int
}

// MARK: - Preview

#Preview("Root View") {
    RootView()
}
