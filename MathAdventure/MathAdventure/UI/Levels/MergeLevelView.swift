// MergeLevelView.swift
// MathAdventure
// Addition - slå ihop objekt visuellt

import SwiftUI

/// Level-vy för addition
/// Visar två grupper som slås ihop
struct MergeLevelView: View {
    let task: MathTask
    let scene: Scene
    @Binding var isComplete: Bool
    var onAnswer: ((PlayerAnswer) -> Void)?
    
    @State private var answer = ""
    @State private var showMergeAnimation = false
    @State private var showResult = false
    @State private var showHint = false
    
    private var tokenType: TokenType {
        // Välj fotbollsrelaterad token baserat på seed för variation
        let types: [TokenType] = [.soccerBall, .trophy, .medal, .jersey, .star]
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
                    Text("+")
                        .foregroundColor(.primary)
                    Text("\(task.b)")
                        .foregroundColor(.green)
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
    }
    
    @ViewBuilder
    private var visualRepresentation: some View {
        if showMergeAnimation {
            // Sammanslagen grupp
            TokenGroupView(
                count: task.a + task.b,
                type: tokenType,
                columns: min(task.a + task.b, 10)
            )
            .transition(.scale)
        } else {
            // Två separata grupper
            HStack(spacing: 20) {
                VStack {
                    TokenGroupView(count: task.a, type: tokenType, columns: min(task.a, 5))
                    Text("\(task.a)")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5)) {
                            showMergeAnimation = true
                        }
                        HapticManager.shared.impact(.medium)
                    }
                
                VStack {
                    TokenGroupView(count: task.b, type: tokenType, columns: min(task.b, 5))
                    Text("\(task.b)")
                        .font(.headline)
                        .foregroundColor(.green)
                }
            }
            .padding()
        }
    }
    
    private func submitAnswer() {
        guard let intAnswer = Int(answer) else { return }
        
        let startTime = Date()
        let responseTimeMs = Int(Date().timeIntervalSince(startTime) * 1000)
        
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

#Preview("Merge Level - Addition") {
    struct PreviewWrapper: View {
        @State var isComplete = false
        
        var body: some View {
            MergeLevelView(
                task: MathTask(
                    grade: .g1,
                    skill: .add,
                    difficulty: 3,
                    seed: 42,
                    promptData: ["a": 5, "b": 3],
                    correctInt: 8,
                    levelIndex: 0
                ),
                scene: Scene.fallback(for: MathTask(
                    grade: .g1,
                    skill: .add,
                    difficulty: 3,
                    seed: 42,
                    promptData: ["a": 5, "b": 3],
                    correctInt: 8,
                    levelIndex: 0
                )),
                isComplete: $isComplete
            )
        }
    }
    
    return PreviewWrapper()
}
