// ChoosePathLevelView.swift
// MathAdventure
// Strategival - välj rätt svar/väg

import SwiftUI

/// Level-vy för strategiska val
/// Används för mönster, positionssystem, geometri mm
struct ChoosePathLevelView: View {
    let task: MathTask
    let scene: Scene
    @Binding var isComplete: Bool
    var onAnswer: ((PlayerAnswer) -> Void)?
    
    @State private var selectedChoice: Int? = nil
    @State private var showHint = false
    @State private var showResult = false
    @State private var isCorrect = false
    
    private var choices: [String] {
        if !scene.choices.isEmpty {
            return scene.choices
        }
        // Generera val baserat på uppgiften
        return generateChoices()
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Karaktär med story
                CharacterView(
                    message: scene.story,
                    mood: showResult ? (isCorrect ? .celebrating : .encouraging) : .happy
                )
                .padding(.top)
                
                // Visuell presentation baserat på skill
                visualContent
                
                // Instruktion
                Text(scene.instruction)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Svarsalternativ
                MultipleChoiceView(
                    choices: choices,
                    selectedIndex: $selectedChoice
                ) { index in
                    checkAnswer(choiceIndex: index)
                }
                
                // Hint
                if !showHint && !showResult {
                    Button(action: {
                        showHint = true
                        HapticManager.shared.hint()
                    }) {
                        Label("Visa ledtråd", systemImage: "lightbulb")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }
                } else if showHint {
                    CompactCharacterView(message: scene.hint, mood: .thinking)
                        .transition(.scale.combined(with: .opacity))
                }
                
                // Resultat
                if showResult {
                    resultView
                }
                
                Spacer(minHeight: 40)
            }
        }
        .animation(.spring(), value: showHint)
        .animation(.spring(), value: showResult)
    }
    
    @ViewBuilder
    private var visualContent: some View {
        switch task.skill {
        case .placeValue:
            placeValueVisual
        case .patterns:
            patternVisual
        case .geometry:
            geometryVisual
        default:
            // Generisk visuell för andra skills
            EmptyView()
        }
    }
    
    @ViewBuilder
    private var placeValueVisual: some View {
        let number = task.a
        VStack(spacing: 16) {
            Text("\(number)")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundColor(.blue)
            
            HStack(spacing: 24) {
                placeValueBox(label: "Hundratal", value: number / 100)
                placeValueBox(label: "Tiotal", value: (number / 10) % 10)
                placeValueBox(label: "Ental", value: number % 10)
            }
        }
        .padding()
    }
    
    private func placeValueBox(label: String, value: Int) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text("\(value)")
                .font(.title.bold())
                .foregroundColor(.primary)
        }
        .frame(width: 80, height: 60)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    @ViewBuilder
    private var patternVisual: some View {
        // Visa ett mönster att fortsätta
        let basePattern = ["🔵", "🔴", "🔵", "🔴", "🔵", "?"]
        
        HStack(spacing: 8) {
            ForEach(Array(basePattern.enumerated()), id: \.offset) { index, item in
                Text(item)
                    .font(.system(size: 32))
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(item == "?" ? Color.orange.opacity(0.2) : Color(.secondarySystemBackground))
                    )
            }
        }
        .padding()
    }
    
    @ViewBuilder
    private var geometryVisual: some View {
        // Visa en geometrisk form
        HStack(spacing: 40) {
            // Exempel: triangel
            Image(systemName: "triangle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Sidor: ?")
                Text("Hörn: ?")
            }
            .font(.headline)
        }
        .padding()
    }
    
    @ViewBuilder
    private var resultView: some View {
        VStack(spacing: 12) {
            if isCorrect {
                Text(scene.celebration)
                    .font(.headline)
                    .foregroundColor(.green)
                    .multilineTextAlignment(.center)
                
                Button("Fortsätt") {
                    isComplete = true
                }
                .buttonStyle(.borderedProminent)
            } else {
                Text("Försök igen!")
                    .font(.headline)
                    .foregroundColor(.orange)
                
                Button("Nytt försök") {
                    selectedChoice = nil
                    showResult = false
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    private func generateChoices() -> [String] {
        guard let correct = task.correctInt else {
            return ["A", "B", "C", "D"]
        }
        
        // Generera felaktiga alternativ nära det korrekta svaret
        var choices = [String(correct)]
        let offsets = [-2, -1, 1, 2, 3].shuffled()
        
        for offset in offsets {
            let wrong = correct + offset
            if wrong >= 0 && !choices.contains(String(wrong)) {
                choices.append(String(wrong))
            }
            if choices.count >= 4 { break }
        }
        
        return choices.shuffled()
    }
    
    private func checkAnswer(choiceIndex: Int) {
        guard choiceIndex < choices.count else { return }
        
        let selectedAnswer = choices[choiceIndex]
        
        // Försök konvertera till Int
        if let intAnswer = Int(selectedAnswer) {
            let playerAnswer = PlayerAnswer(int: intAnswer, responseTimeMs: 0)
            onAnswer?(playerAnswer)
            
            isCorrect = GameEngine.shared.verify(task: task, answer: playerAnswer)
        } else {
            // String-jämförelse som fallback
            isCorrect = selectedAnswer == task.correctAnswer
        }
        
        showResult = true
        
        if isCorrect {
            HapticManager.shared.correctAnswer()
        } else {
            HapticManager.shared.wrongAnswer()
        }
    }
}

// MARK: - Preview

#Preview("Choose Path Level") {
    struct PreviewWrapper: View {
        @State var isComplete = false
        
        var body: some View {
            ChoosePathLevelView(
                task: MathTask(
                    grade: .g2,
                    skill: .placeValue,
                    difficulty: 3,
                    seed: 42,
                    promptData: ["a": 47],
                    correctInt: 4,
                    levelIndex: 0
                ),
                scene: Scene(
                    title: "Positionshemligheten",
                    story: "Blixt-Bot ser talet 47. Hur många tiotal finns det?",
                    instruction: "Välj rätt antal tiotal!",
                    choices: ["3", "4", "5", "7"],
                    hint: "Tiotal är siffran på tiotalens plats.",
                    celebration: "Rätt! 4 tiotal!"
                ),
                isComplete: $isComplete
            )
        }
    }
    
    return PreviewWrapper()
}
