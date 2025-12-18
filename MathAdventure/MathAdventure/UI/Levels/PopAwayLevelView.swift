// PopAwayLevelView.swift
// MathAdventure
// Subtraktion - ta bort objekt visuellt

import SwiftUI

/// Level-vy för subtraktion
/// Visar objekt som tas bort/försvinner
struct PopAwayLevelView: View {
    let task: MathTask
    let scene: Scene
    @Binding var isComplete: Bool
    var onAnswer: ((PlayerAnswer) -> Void)?
    
    @State private var answer = ""
    @State private var removedCount = 0
    @State private var showHint = false
    @State private var isAnimating = false
    
    private var tokenType: TokenType {
        let types: [TokenType] = [.apple, .cookie, .ball, .heart, .flower]
        return types[task.seed % types.count]
    }
    
    private var remaining: Int {
        max(0, task.a - removedCount)
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
                
                // Visuell representation
                visualRepresentation
                
                // Instruktion
                Text(scene.instruction)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Matematiskt uttryck
                HStack(spacing: 16) {
                    Text("\(task.a)")
                        .foregroundColor(.blue)
                    Text("−")
                        .foregroundColor(.primary)
                    Text("\(task.b)")
                        .foregroundColor(.red)
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
                
                // Ta bort-knapp
                if removedCount < task.b {
                    Button(action: removeOne) {
                        Label("Ta bort en \(tokenType.name)", systemImage: "minus.circle.fill")
                            .font(.headline)
                            .foregroundColor(.red)
                            .padding()
                            .background(
                                Capsule()
                                    .fill(Color.red.opacity(0.1))
                            )
                    }
                    .disabled(isAnimating)
                }
                
                // Hint-knapp
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
                NumberPadView(value: $answer, maxDigits: 3) {
                    submitAnswer()
                }
            }
        }
        .animation(.spring(), value: showHint)
        .animation(.spring(), value: removedCount)
    }
    
    @ViewBuilder
    private var visualRepresentation: some View {
        VStack(spacing: 12) {
            // Tokens med strikethrough för borttagna
            TokenGroupView(
                count: task.a,
                type: tokenType,
                columns: min(task.a, 10),
                strikethroughCount: removedCount
            )
            
            // Räknare
            HStack {
                Text("Hade: \(task.a)")
                    .foregroundColor(.blue)
                Spacer()
                Text("Tog bort: \(removedCount)/\(task.b)")
                    .foregroundColor(.red)
                Spacer()
                Text("Kvar: \(remaining)")
                    .foregroundColor(.green)
            }
            .font(.subheadline.weight(.medium))
            .padding(.horizontal)
        }
        .padding()
    }
    
    private func removeOne() {
        guard removedCount < task.b else { return }
        
        isAnimating = true
        HapticManager.shared.impact(.light)
        
        withAnimation(.spring(response: 0.3)) {
            removedCount += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isAnimating = false
        }
    }
    
    private func submitAnswer() {
        guard let intAnswer = Int(answer) else { return }
        
        let responseTimeMs = 0 // Förenklat för demo
        let playerAnswer = PlayerAnswer(int: intAnswer, responseTimeMs: responseTimeMs)
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

#Preview("PopAway Level - Subtraction") {
    struct PreviewWrapper: View {
        @State var isComplete = false
        
        var body: some View {
            PopAwayLevelView(
                task: MathTask(
                    grade: .g1,
                    skill: .sub,
                    difficulty: 3,
                    seed: 42,
                    promptData: ["a": 8, "b": 3],
                    correctInt: 5,
                    levelIndex: 0
                ),
                scene: Scene.fallback(for: MathTask(
                    grade: .g1,
                    skill: .sub,
                    difficulty: 3,
                    seed: 42,
                    promptData: ["a": 8, "b": 3],
                    correctInt: 5,
                    levelIndex: 0
                )),
                isComplete: $isComplete
            )
        }
    }
    
    return PreviewWrapper()
}
