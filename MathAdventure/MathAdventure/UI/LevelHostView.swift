// LevelHostView.swift
// MathAdventure
// Värd för nivåspel - hanterar state och routing till rätt level-vy

import SwiftUI

/// Värd-vy som omsluter och hanterar en specifik nivå
struct LevelHostView: View {
    let selection: LevelSelection
    @Binding var playerProfile: PlayerProfile
    var onComplete: ((Bool, Int) -> Void)?
    var onDismiss: (() -> Void)?
    
    @StateObject private var viewModel: LevelViewModel
    
    @State private var showConfetti = false
    @State private var earnedStars = 0
    
    init(
        selection: LevelSelection,
        playerProfile: Binding<PlayerProfile>,
        onComplete: ((Bool, Int) -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.selection = selection
        self._playerProfile = playerProfile
        self.onComplete = onComplete
        self.onDismiss = onDismiss
        self._viewModel = StateObject(wrappedValue: LevelViewModel(
            grade: selection.grade,
            levelIndex: selection.levelIndex
        ))
    }
    
    var body: some View {
        ZStack {
            // Bakgrund
            LinearGradient(
                colors: [.blue.opacity(0.05), .purple.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Huvudinnehåll
            VStack(spacing: 0) {
                // Header
                levelHeader
                
                // Level-innehåll
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.isComplete {
                    completionView
                } else {
                    levelContent
                }
            }
            
            // Konfetti-overlay
            ConfettiView(isActive: $showConfetti, intensity: .heavy)
        }
        .task {
            await viewModel.loadLevel()
        }
        .onChange(of: viewModel.isComplete) { _, isComplete in
            if isComplete {
                handleCompletion()
            }
        }
    }
    
    @ViewBuilder
    private var levelHeader: some View {
        HStack {
            // Stäng-knapp
            Button(action: { onDismiss?() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Nivåinfo
            VStack(spacing: 2) {
                Text(selection.grade.shortName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("Nivå \(selection.levelIndex + 1)")
                    .font(.headline)
            }
            
            Spacer()
            
            // Försök/liv (placeholder)
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    Image(systemName: i < (3 - viewModel.attemptCount) ? "heart.fill" : "heart")
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.5)
            
            CharacterView(
                message: "Förbereder äventyret...",
                isThinking: true,
                mood: .thinking
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    private var levelContent: some View {
        if let task = viewModel.currentTask,
           let scene = viewModel.currentScene {
            
            // Välj rätt level-vy baserat på skill
            switch task.skill.levelViewType {
            case .merge:
                MergeLevelView(
                    task: task,
                    scene: scene,
                    isComplete: $viewModel.isComplete,
                    onAnswer: { answer in
                        viewModel.submitAnswer(answer)
                    }
                )
                
            case .popAway:
                PopAwayLevelView(
                    task: task,
                    scene: scene,
                    isComplete: $viewModel.isComplete,
                    onAnswer: { answer in
                        viewModel.submitAnswer(answer)
                    }
                )
                
            case .bridge:
                BridgeLevelView(
                    task: task,
                    scene: scene,
                    isComplete: $viewModel.isComplete,
                    onAnswer: { answer in
                        viewModel.submitAnswer(answer)
                    }
                )
                
            case .dealEqual:
                DealEqualLevelView(
                    task: task,
                    scene: scene,
                    isComplete: $viewModel.isComplete,
                    onAnswer: { answer in
                        viewModel.submitAnswer(answer)
                    }
                )
                
            case .choosePath:
                ChoosePathLevelView(
                    task: task,
                    scene: scene,
                    isComplete: $viewModel.isComplete,
                    onAnswer: { answer in
                        viewModel.submitAnswer(answer)
                    }
                )
                
            case .explain:
                ExplainLevelView(
                    task: task,
                    scene: scene,
                    isComplete: $viewModel.isComplete,
                    onAnswer: { answer in
                        viewModel.submitAnswer(answer)
                    }
                )
            }
        } else {
            // Fallback om något gick fel
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                    .foregroundColor(.orange)
                
                Text("Något gick fel")
                    .font(.headline)
                
                Button("Försök igen") {
                    Task {
                        await viewModel.loadLevel()
                    }
                }
                .buttonStyle(.bordered)
            }
        }
    }
    
    @ViewBuilder
    private var completionView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Celebration character
            CharacterView(
                message: viewModel.currentScene?.celebration ?? "Fantastiskt! Du klarade nivån!",
                mood: .celebrating
            )
            
            // Stjärnor
            HStack(spacing: 20) {
                ForEach(0..<3, id: \.self) { index in
                    Image(systemName: index < earnedStars ? "star.fill" : "star")
                        .font(.system(size: 50))
                        .foregroundColor(.yellow)
                        .scaleEffect(index < earnedStars ? 1.2 : 0.8)
                        .animation(.spring(response: 0.5).delay(Double(index) * 0.2), value: earnedStars)
                }
            }
            .onAppear {
                earnedStars = viewModel.earnedStars
            }
            
            // Statistik
            VStack(spacing: 8) {
                Text("Försök: \(viewModel.attemptCount)")
                Text("Tid: \(formatTime(viewModel.totalTimeMs))")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            Spacer()
            
            // Knappar
            VStack(spacing: 12) {
                Button(action: {
                    onComplete?(true, earnedStars)
                }) {
                    HStack {
                        Text("Fortsätt")
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                Button("Tillbaka till kartan") {
                    onDismiss?()
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
    }
    
    private func handleCompletion() {
        // Visa konfetti
        showConfetti = true
        HapticManager.shared.levelComplete()
        
        // Beräkna stjärnor
        earnedStars = MasteryModel.calculateStars(
            correct: true,
            attemptCount: viewModel.attemptCount,
            responseTimeMs: viewModel.totalTimeMs,
            difficulty: viewModel.currentTask?.difficulty ?? 5
        )
        
        // Uppdatera profilen
        if let task = viewModel.currentTask {
            let newMastery = viewModel.updatedMastery(for: playerProfile)
            playerProfile.completeLevelAndUpdateProfile(
                grade: selection.grade,
                levelIndex: selection.levelIndex,
                skill: task.skill,
                earnedStars: earnedStars,
                newMastery: newMastery
            )
            playerProfile.save()
        }
    }
    
    private func formatTime(_ ms: Int) -> String {
        let seconds = ms / 1000
        if seconds < 60 {
            return "\(seconds) sek"
        } else {
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            return "\(minutes):\(String(format: "%02d", remainingSeconds))"
        }
    }
}

/// ViewModel för en nivå
@MainActor
class LevelViewModel: ObservableObject {
    @Published var currentTask: MathTask?
    @Published var currentScene: Scene?
    @Published var isLoading = true
    @Published var isComplete = false
    @Published var attemptCount = 0
    @Published var totalTimeMs = 0
    @Published var earnedStars = 0
    
    private let grade: GradeBand
    private let levelIndex: Int
    private let gameEngine = GameEngine.shared
    private let narrativeDirector: NarrativeDirector
    
    private var startTime: Date?
    private var lastAnswer: PlayerAnswer?
    private var wasCorrect = false
    
    init(grade: GradeBand, levelIndex: Int) {
        self.grade = grade
        self.levelIndex = levelIndex
        self.narrativeDirector = NarrativeDirectorFactory.makeMock()
    }
    
    func loadLevel() async {
        isLoading = true
        
        // Generera task
        let task = gameEngine.makeTask(
            for: grade,
            skill: nil,  // Välj automatiskt baserat på grade
            mastery: 0.5,
            levelIndex: levelIndex,
            seed: nil
        )
        
        // Hämta scene från NarrativeDirector
        let scene = await narrativeDirector.scene(for: task)
        
        // Uppdatera state
        currentTask = task
        currentScene = scene
        isLoading = false
        startTime = Date()
    }
    
    func submitAnswer(_ answer: PlayerAnswer) {
        guard let task = currentTask else { return }
        
        attemptCount += 1
        lastAnswer = answer
        
        // Beräkna tid
        if let start = startTime {
            totalTimeMs = Int(Date().timeIntervalSince(start) * 1000)
        }
        
        // Verifiera svaret
        wasCorrect = gameEngine.verify(task: task, answer: answer)
        
        if wasCorrect {
            earnedStars = MasteryModel.calculateStars(
                correct: true,
                attemptCount: attemptCount,
                responseTimeMs: totalTimeMs,
                difficulty: task.difficulty
            )
            isComplete = true
        }
    }
    
    func updatedMastery(for profile: PlayerProfile) -> Double {
        guard let task = currentTask else { return 0.5 }
        
        let currentMastery = profile.mastery(for: task.skill)
        return gameEngine.updateMastery(
            currentMastery: currentMastery,
            task: task,
            correct: wasCorrect,
            responseTimeMs: totalTimeMs
        )
    }
}

// MARK: - Preview

#Preview("Level Host") {
    struct PreviewWrapper: View {
        @State var profile = PlayerProfile(name: "Test")
        
        var body: some View {
            LevelHostView(
                selection: LevelSelection(grade: .g1, levelIndex: 0),
                playerProfile: $profile
            )
        }
    }
    
    return PreviewWrapper()
}
