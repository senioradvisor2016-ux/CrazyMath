// DealEqualLevelView.swift
// MathAdventure
// Division - dela lika mellan grupper

import SwiftUI

/// Level-vy för division
/// Visar objekt som delas ut lika
struct DealEqualLevelView: View {
    let task: MathTask
    let scene: Scene
    @Binding var isComplete: Bool
    var onAnswer: ((PlayerAnswer) -> Void)?
    
    @State private var answer = ""
    @State private var dealt: [[Int]] = []
    @State private var remaining: Int = 0
    @State private var showHint = false
    @State private var isDealing = false
    
    private var dividend: Int { task.a }
    private var divisor: Int { task.b }
    private var quotient: Int { task.correctInt ?? 0 }
    
    private var tokenType: TokenType {
        let types: [TokenType] = [.cookie, .coin, .apple, .gem, .star]
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
                dealingVisualization
                
                // Instruktion
                Text(scene.instruction)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Matematiskt uttryck
                HStack(spacing: 16) {
                    Text("\(dividend)")
                        .foregroundColor(.blue)
                    Text("÷")
                        .foregroundColor(.primary)
                    Text("\(divisor)")
                        .foregroundColor(.purple)
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
                
                // Dela-knapp
                if remaining > 0 {
                    Button(action: dealOne) {
                        HStack {
                            Image(systemName: "arrow.down.circle.fill")
                            Text("Dela ut en \(tokenType.name)")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            Capsule()
                                .fill(Color.purple)
                        )
                    }
                    .disabled(isDealing)
                    
                    // "Dela alla" för snabbhet
                    Button(action: dealAll) {
                        Text("Dela ut alla")
                            .font(.subheadline)
                            .foregroundColor(.purple)
                    }
                }
                
                // Status
                Text("Kvar att dela: \(remaining)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
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
                NumberPadView(value: $answer, maxDigits: 3) {
                    submitAnswer()
                }
            }
        }
        .onAppear {
            setupDealing()
        }
        .animation(.spring(), value: showHint)
        .animation(.spring(), value: dealt)
    }
    
    @ViewBuilder
    private var dealingVisualization: some View {
        VStack(spacing: 16) {
            // Källan (objekt att dela)
            if remaining > 0 {
                VStack {
                    Text("Att dela:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        ForEach(0..<min(remaining, 20), id: \.self) { _ in
                            Text(tokenType.rawValue)
                                .font(.system(size: 20))
                        }
                        if remaining > 20 {
                            Text("+\(remaining - 20)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue.opacity(0.1))
                    )
                }
            }
            
            // Mottagare (grupper)
            HStack(spacing: 12) {
                ForEach(0..<divisor, id: \.self) { groupIndex in
                    VStack(spacing: 4) {
                        // Grupp-ikon
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(.purple)
                        
                        // Tokens i denna grupp
                        VStack(spacing: 2) {
                            ForEach(dealt.indices.contains(groupIndex) ? dealt[groupIndex] : [], id: \.self) { tokenId in
                                Text(tokenType.rawValue)
                                    .font(.system(size: 20))
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .frame(minHeight: 40)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.tertiarySystemBackground))
                        )
                        
                        // Antal
                        Text("\(dealt.indices.contains(groupIndex) ? dealt[groupIndex].count : 0)")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .padding()
    }
    
    private func setupDealing() {
        dealt = Array(repeating: [], count: divisor)
        remaining = dividend
    }
    
    private func dealOne() {
        guard remaining > 0 else { return }
        
        isDealing = true
        HapticManager.shared.impact(.light)
        
        // Hitta gruppen med minst tokens
        let minCount = dealt.map { $0.count }.min() ?? 0
        if let targetIndex = dealt.firstIndex(where: { $0.count == minCount }) {
            withAnimation(.spring(response: 0.3)) {
                dealt[targetIndex].append(dividend - remaining)
                remaining -= 1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            isDealing = false
        }
    }
    
    private func dealAll() {
        // Dela ut alla automatiskt
        for _ in 0..<remaining {
            let minCount = dealt.map { $0.count }.min() ?? 0
            if let targetIndex = dealt.firstIndex(where: { $0.count == minCount }) {
                dealt[targetIndex].append(dividend - remaining)
                remaining -= 1
                if remaining <= 0 { break }
            }
        }
        remaining = 0
        HapticManager.shared.impact(.medium)
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

#Preview("Deal Equal Level - Division") {
    struct PreviewWrapper: View {
        @State var isComplete = false
        
        var body: some View {
            DealEqualLevelView(
                task: MathTask(
                    grade: .g3,
                    skill: .div,
                    difficulty: 3,
                    seed: 42,
                    promptData: ["a": 12, "b": 3],
                    correctInt: 4,
                    levelIndex: 0
                ),
                scene: Scene.fallback(for: MathTask(
                    grade: .g3,
                    skill: .div,
                    difficulty: 3,
                    seed: 42,
                    promptData: ["a": 12, "b": 3],
                    correctInt: 4,
                    levelIndex: 0
                )),
                isComplete: $isComplete
            )
        }
    }
    
    return PreviewWrapper()
}
