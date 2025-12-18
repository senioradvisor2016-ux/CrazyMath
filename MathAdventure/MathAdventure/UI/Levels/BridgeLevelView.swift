// BridgeLevelView.swift
// MathAdventure
// Multiplikation - steg på en bro/grupper

import SwiftUI

/// Level-vy för multiplikation
/// Visar grupper som en bro med steg
struct BridgeLevelView: View {
    let task: MathTask
    let scene: Scene
    @Binding var isComplete: Bool
    var onAnswer: ((PlayerAnswer) -> Void)?
    
    @State private var answer = ""
    @State private var currentStep = 0
    @State private var showHint = false
    @State private var runningTotal = 0
    
    private var groups: Int { task.groups }
    private var perGroup: Int { task.perGroup }
    
    private var tokenType: TokenType {
        let types: [TokenType] = [.soccerBall, .star, .trophy, .medal, .goal]
        return types[task.seed % types.count]
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Karaktär med story
                CharacterView(
                    message: scene.story,
                    mood: .happy
                )
                .padding(.top)
                
                // Bro-visualisering
                bridgeVisualization
                
                // Räkneinstruktion
                Text(scene.instruction)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Matematiskt uttryck
                HStack(spacing: 16) {
                    Text("\(groups)")
                        .foregroundColor(.purple)
                    Text("×")
                        .foregroundColor(.primary)
                    Text("\(perGroup)")
                        .foregroundColor(.blue)
                    Text("=")
                        .foregroundColor(.primary)
                    Text(answer.isEmpty ? "?" : answer)
                        .foregroundColor(.orange)
                }
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                )
                
                // Hoppa-knapp
                if currentStep < groups {
                    Button(action: takeStep) {
                        HStack {
                            Image(systemName: "figure.walk")
                            Text("Hoppa till nästa grupp (+\(perGroup))")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            Capsule()
                                .fill(Color.purple)
                        )
                    }
                    
                    Text("Steg \(currentStep)/\(groups) | Summa: \(runningTotal)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Hint
                if !showHint {
                    Button(action: {
                        showHint = true
                        HapticManager.shared.hint()
                    }) {
                        Label("Visa ledtråd", systemImage: "lightbulb")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }
                } else {
                    CompactCharacterView(message: scene.hint, mood: .thinking)
                        .transition(.scale.combined(with: .opacity))
                }
                
                Spacer(minLength: 20)
                
                // Numpad
                NumberPadView(value: $answer, maxDigits: 4) {
                    submitAnswer()
                }
            }
        }
        .animation(.spring(), value: showHint)
        .animation(.spring(), value: currentStep)
    }
    
    @ViewBuilder
    private var bridgeVisualization: some View {
        VStack(spacing: 8) {
            // Grupper som "plattor" på bron
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(0..<groups, id: \.self) { groupIndex in
                        VStack(spacing: 4) {
                            // Grupp med tokens
                            VStack(spacing: 2) {
                                ForEach(0..<perGroup, id: \.self) { _ in
                                    Text(tokenType.rawValue)
                                        .font(.system(size: 24))
                                }
                            }
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(groupIndex < currentStep ? Color.green.opacity(0.2) : Color(.tertiarySystemBackground))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(groupIndex < currentStep ? Color.green : Color.gray.opacity(0.3), lineWidth: 2)
                                    )
                            )
                            
                            // Nummer
                            Text("\(perGroup)")
                                .font(.caption.bold())
                                .foregroundColor(groupIndex < currentStep ? .green : .secondary)
                        }
                        .opacity(groupIndex <= currentStep ? 1.0 : 0.5)
                    }
                }
                .padding(.horizontal)
            }
            
            // "Bro"-linje
            Rectangle()
                .fill(Color.brown)
                .frame(height: 8)
                .cornerRadius(4)
                .padding(.horizontal)
        }
        .padding()
    }
    
    private func takeStep() {
        guard currentStep < groups else { return }
        
        HapticManager.shared.impact(.medium)
        
        withAnimation(.spring(response: 0.4)) {
            currentStep += 1
            runningTotal += perGroup
        }
    }
    
    private func submitAnswer() {
        guard let intAnswer = Int(answer) else { return }
        
        let playerAnswer = PlayerAnswer(int: intAnswer, responseTimeMs: 0)
        onAnswer?(playerAnswer)
        
        let correct = GameEngine.shared.verify(task: task, answer: playerAnswer)
        
        if correct {
            HapticManager.shared.correctAnswer()
            isComplete = true
        } else {
            HapticManager.shared.wrongAnswer()
            answer = ""
        }
    }
}

// MARK: - Preview

#Preview("Bridge Level - Multiplication") {
    struct PreviewWrapper: View {
        @State var isComplete = false
        
        var body: some View {
            BridgeLevelView(
                task: MathTask(
                    grade: .g3,
                    skill: .mult,
                    difficulty: 3,
                    seed: 42,
                    promptData: ["a": 4, "b": 3, "groups": 4, "perGroup": 3],
                    correctInt: 12,
                    levelIndex: 0
                ),
                scene: Scene.fallback(for: MathTask(
                    grade: .g3,
                    skill: .mult,
                    difficulty: 3,
                    seed: 42,
                    promptData: ["a": 4, "b": 3, "groups": 4, "perGroup": 3],
                    correctInt: 12,
                    levelIndex: 0
                )),
                isComplete: $isComplete
            )
        }
    }
    
    return PreviewWrapper()
}
