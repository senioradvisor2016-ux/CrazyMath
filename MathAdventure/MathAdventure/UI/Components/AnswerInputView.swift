// AnswerInputView.swift
// MathAdventure
// Komponenter för att mata in svar

import SwiftUI

/// Numpad för att mata in svar
struct NumberPadView: View {
    @Binding var value: String
    var maxDigits: Int = 4
    var onSubmit: (() -> Void)?
    
    private let buttons: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["C", "0", "✓"]
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            // Visar aktuellt värde
            Text(value.isEmpty ? "?" : value)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .frame(height: 60)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                )
            
            // Knappar
            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { button in
                        NumberPadButton(
                            title: button,
                            style: buttonStyle(for: button)
                        ) {
                            handleButtonTap(button)
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    private func buttonStyle(for button: String) -> NumberPadButton.Style {
        switch button {
        case "C": return .destructive
        case "✓": return .primary
        default: return .secondary
        }
    }
    
    private func handleButtonTap(_ button: String) {
        HapticManager.shared.buttonTap()
        
        switch button {
        case "C":
            value = ""
        case "✓":
            onSubmit?()
        default:
            if value.count < maxDigits {
                value += button
            }
        }
    }
}

/// Enskild knapp i numpad
struct NumberPadButton: View {
    let title: String
    let style: Style
    let action: () -> Void
    
    enum Style {
        case primary, secondary, destructive
        
        var backgroundColor: Color {
            switch self {
            case .primary: return .blue
            case .secondary: return Color(.tertiarySystemBackground)
            case .destructive: return .red.opacity(0.2)
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary: return .white
            case .secondary: return .primary
            case .destructive: return .red
            }
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundColor(style.foregroundColor)
                .frame(width: 72, height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(style.backgroundColor)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Flervalssvar
struct MultipleChoiceView: View {
    let choices: [String]
    @Binding var selectedIndex: Int?
    var onSelect: ((Int) -> Void)?
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(Array(choices.enumerated()), id: \.offset) { index, choice in
                Button(action: {
                    HapticManager.shared.selection()
                    selectedIndex = index
                    onSelect?(index)
                }) {
                    HStack {
                        Text(choice)
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if selectedIndex == index {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedIndex == index ? Color.blue.opacity(0.15) : Color(.secondarySystemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedIndex == index ? Color.blue : Color.clear, lineWidth: 2)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal)
    }
}

/// Stora knappar för enkla val (t.ex. ja/nej)
struct LargeChoiceButtonsView: View {
    let choices: [String]
    var emojis: [String] = []
    var onSelect: ((Int) -> Void)?
    
    var body: some View {
        HStack(spacing: 16) {
            ForEach(Array(choices.enumerated()), id: \.offset) { index, choice in
                Button(action: {
                    HapticManager.shared.buttonTap()
                    onSelect?(index)
                }) {
                    VStack(spacing: 8) {
                        if index < emojis.count {
                            Text(emojis[index])
                                .font(.system(size: 40))
                        }
                        Text(choice)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.secondarySystemBackground))
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal)
    }
}

/// Slider för att välja ett tal
struct NumberSliderView: View {
    @Binding var value: Int
    var range: ClosedRange<Int>
    var step: Int = 1
    
    var body: some View {
        VStack(spacing: 16) {
            Text("\(value)")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundColor(.blue)
            
            HStack(spacing: 24) {
                Button(action: {
                    if value > range.lowerBound {
                        value -= step
                        HapticManager.shared.selection()
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(value > range.lowerBound ? .blue : .gray)
                }
                .disabled(value <= range.lowerBound)
                
                Slider(
                    value: Binding(
                        get: { Double(value) },
                        set: { value = Int($0) }
                    ),
                    in: Double(range.lowerBound)...Double(range.upperBound),
                    step: Double(step)
                )
                .tint(.blue)
                
                Button(action: {
                    if value < range.upperBound {
                        value += step
                        HapticManager.shared.selection()
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(value < range.upperBound ? .blue : .gray)
                }
                .disabled(value >= range.upperBound)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
        .padding(.horizontal)
    }
}

// MARK: - Previews

#Preview("Number Pad") {
    struct PreviewWrapper: View {
        @State var value = ""
        
        var body: some View {
            NumberPadView(value: $value) {
                print("Submitted: \(value)")
            }
        }
    }
    
    return PreviewWrapper()
}

#Preview("Multiple Choice") {
    struct PreviewWrapper: View {
        @State var selected: Int? = nil
        
        var body: some View {
            MultipleChoiceView(
                choices: ["12", "14", "16", "18"],
                selectedIndex: $selected
            )
        }
    }
    
    return PreviewWrapper()
}

#Preview("Large Buttons") {
    LargeChoiceButtonsView(
        choices: ["Rätt", "Fel"],
        emojis: ["✅", "❌"]
    )
}

#Preview("Number Slider") {
    struct PreviewWrapper: View {
        @State var value = 10
        
        var body: some View {
            NumberSliderView(value: $value, range: 0...20)
        }
    }
    
    return PreviewWrapper()
}
