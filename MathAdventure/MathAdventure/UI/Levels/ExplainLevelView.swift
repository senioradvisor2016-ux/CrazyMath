// ExplainLevelView.swift
// MathAdventure
// Resonemang och förklaring - för högre årskurser

import SwiftUI

/// Level-vy för resonemang och förklaring
/// Används för bråk, decimaltal, procent och matematiska resonemang
struct ExplainLevelView: View {
    let task: MathTask
    let scene: Scene
    @Binding var isComplete: Bool
    var onAnswer: ((PlayerAnswer) -> Void)?
    
    @State private var answer = ""
    @State private var showHint = false
    @State private var showExplanation = false
    @State private var currentStep = 0
    
    private var steps: [String] {
        generateSteps()
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
                
                // Visuellt baserat på skill
                visualContent
                
                // Stegvis förklaring
                if showExplanation {
                    explanationSteps
                }
                
                // Instruktion
                Text(scene.instruction)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Matematiskt uttryck
                mathExpression
                
                // Knappar
                HStack(spacing: 16) {
                    if !showExplanation {
                        Button(action: {
                            showExplanation = true
                            HapticManager.shared.hint()
                        }) {
                            Label("Visa steg", systemImage: "list.number")
                                .font(.subheadline)
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    if !showHint {
                        Button(action: {
                            showHint = true
                            HapticManager.shared.hint()
                        }) {
                            Label("Ledtråd", systemImage: "lightbulb")
                                .font(.subheadline)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                if showHint {
                    CompactCharacterView(message: scene.hint, mood: .thinking)
                        .transition(.scale.combined(with: .opacity))
                }
                
                Spacer(minLength: 20)
                
                // Input baserat på skill
                inputArea
            }
        }
        .animation(.spring(), value: showHint)
        .animation(.spring(), value: showExplanation)
        .animation(.spring(), value: currentStep)
    }
    
    @ViewBuilder
    private var visualContent: some View {
        switch task.skill {
        case .fractions:
            fractionVisual
        case .decimals:
            decimalVisual
        case .percent:
            percentVisual
        case .reasoning:
            reasoningVisual
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private var fractionVisual: some View {
        let numerator = task.getValue("numerator", default: 1)
        let denominator = task.getValue("denominator", default: 4)
        
        VStack(spacing: 16) {
            // Cirkeldiagram för bråk
            ZStack {
                // Hela cirkeln
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 20)
                    .frame(width: 150, height: 150)
                
                // Fylld del
                Circle()
                    .trim(from: 0, to: CGFloat(numerator) / CGFloat(denominator))
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                
                // Bråktext
                VStack(spacing: 4) {
                    Text("\(numerator)")
                        .font(.title.bold())
                    Rectangle()
                        .fill(Color.primary)
                        .frame(width: 30, height: 2)
                    Text("\(denominator)")
                        .font(.title.bold())
                }
            }
            
            Text("\(numerator) av \(denominator) delar")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    @ViewBuilder
    private var decimalVisual: some View {
        let decimalValue = task.getValue("decimalValue", default: 50)
        let displayValue = Double(decimalValue) / 100.0
        
        VStack(spacing: 16) {
            // Tallinje
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Bakgrundslinje
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    // Markör
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 24, height: 24)
                        .offset(x: geometry.size.width * CGFloat(displayValue) - 12)
                }
            }
            .frame(height: 24)
            .padding(.horizontal)
            
            // Labels
            HStack {
                Text("0")
                Spacer()
                Text("0,5")
                Spacer()
                Text("1")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.horizontal)
            
            Text(String(format: "%.2f", displayValue))
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.blue)
        }
        .padding()
    }
    
    @ViewBuilder
    private var percentVisual: some View {
        let percent = task.getValue("percent", default: 50)
        
        VStack(spacing: 16) {
            // Procentcirkel
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 15)
                    .frame(width: 150, height: 150)
                
                Circle()
                    .trim(from: 0, to: CGFloat(percent) / 100.0)
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 15, lineCap: .round))
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                
                Text("\(percent)%")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
            }
            
            // Förklaring
            Text("\(percent) av 100")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    @ViewBuilder
    private var reasoningVisual: some View {
        // Tankekarta eller logiskt problem
        VStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 60))
                .foregroundColor(.purple)
            
            Text("Tänk steg för steg...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    @ViewBuilder
    private var explanationSteps: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 12) {
                    // Stegnummer
                    Circle()
                        .fill(index <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Text("\(index + 1)")
                                .font(.caption.bold())
                                .foregroundColor(index <= currentStep ? .white : .gray)
                        )
                    
                    // Stegtext
                    Text(step)
                        .font(.subheadline)
                        .foregroundColor(index <= currentStep ? .primary : .secondary)
                        .opacity(index <= currentStep ? 1.0 : 0.5)
                }
                .onTapGesture {
                    if index == currentStep + 1 && currentStep < steps.count - 1 {
                        withAnimation {
                            currentStep += 1
                        }
                        HapticManager.shared.selection()
                    }
                }
            }
            
            if currentStep < steps.count - 1 {
                Button("Nästa steg") {
                    withAnimation {
                        currentStep += 1
                    }
                    HapticManager.shared.selection()
                }
                .font(.subheadline)
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var mathExpression: some View {
        Text(task.mathExpression)
            .font(.system(size: 32, weight: .bold, design: .rounded))
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
            )
    }
    
    @ViewBuilder
    private var inputArea: some View {
        switch task.skill {
        case .fractions:
            // Bråk-input
            FractionInputView { fraction in
                let playerAnswer = PlayerAnswer(fraction: fraction, responseTimeMs: 0)
                submitAnswer(playerAnswer)
            }
        default:
            // Standard numpad
            NumberPadView(value: $answer, maxDigits: 4) {
                if let intAnswer = Int(answer) {
                    let playerAnswer = PlayerAnswer(int: intAnswer, responseTimeMs: 0)
                    submitAnswer(playerAnswer)
                }
            }
        }
    }
    
    private func generateSteps() -> [String] {
        switch task.skill {
        case .fractions:
            return [
                "Titta på hur många delar helheten är delad i",
                "Räkna hur många delar som är markerade",
                "Skriv bråket: markerade/totala delar"
            ]
        case .decimals:
            return [
                "Titta på var markören är på tallinjen",
                "Läs av värdet mellan 0 och 1",
                "Skriv svaret som decimaltal"
            ]
        case .percent:
            return [
                "Procent betyder 'per hundra'",
                "Titta på hur stor del av cirkeln som är fylld",
                "Det fyllda området visar procentandelen"
            ]
        default:
            return [
                "Läs uppgiften noggrant",
                "Tänk på vad du ska räkna ut",
                "Skriv ditt svar"
            ]
        }
    }
    
    private func submitAnswer(_ playerAnswer: PlayerAnswer) {
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

/// Input för bråktal
struct FractionInputView: View {
    var onSubmit: ((FractionValue) -> Void)?
    
    @State private var numerator = ""
    @State private var denominator = ""
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                // Täljare
                TextField("", text: $numerator)
                    .keyboardType(.numberPad)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .frame(width: 60)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.secondarySystemBackground))
                    )
                
                // Bråkstreck
                VStack(spacing: 4) {
                    Rectangle()
                        .fill(Color.primary)
                        .frame(width: 40, height: 3)
                }
                
                // Nämnare
                TextField("", text: $denominator)
                    .keyboardType(.numberPad)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .frame(width: 60)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.secondarySystemBackground))
                    )
            }
            
            Button("Svara") {
                if let num = Int(numerator), let den = Int(denominator), den != 0 {
                    onSubmit?(FractionValue(numerator: num, denominator: den))
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(numerator.isEmpty || denominator.isEmpty)
        }
        .padding()
    }
}

// MARK: - Preview

#Preview("Explain Level - Fractions") {
    struct PreviewWrapper: View {
        @State var isComplete = false
        
        var body: some View {
            ExplainLevelView(
                task: MathTask(
                    grade: .g5,
                    skill: .fractions,
                    difficulty: 4,
                    seed: 42,
                    promptData: ["numerator": 3, "denominator": 4],
                    correctFraction: FractionValue(numerator: 3, denominator: 4),
                    levelIndex: 0
                ),
                scene: Scene(
                    title: "Dela pizza!",
                    story: "En pizza är delad i 4 lika stora bitar. Blixt-Bot äter 3 bitar!",
                    instruction: "Hur stor del av pizzan åt Blixt-Bot?",
                    choices: [],
                    hint: "Räkna hur många bitar som åts av totalt antal bitar.",
                    celebration: "Mmm! Tre fjärdedelar pizza! 🍕"
                ),
                isComplete: $isComplete
            )
        }
    }
    
    return PreviewWrapper()
}
