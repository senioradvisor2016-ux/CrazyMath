// TokenView.swift
// MathAdventure
// Visuella tokens för att representera tal (mynt, stenar, äpplen etc)

import SwiftUI

/// Typ av visuell token (fotbollstema)
enum TokenType: String, CaseIterable {
    case soccerBall = "⚽"
    case trophy = "🏆"
    case medal = "🥇"
    case jersey = "👕"
    case boot = "👟"
    case goal = "🥅"
    case whistle = "📯"
    case card = "🟨"
    case flag = "🚩"
    case star = "⭐"
    
    var name: String {
        switch self {
        case .soccerBall: return "bollar"
        case .trophy: return "pokaler"
        case .medal: return "medaljer"
        case .jersey: return "tröjor"
        case .boot: return "skor"
        case .goal: return "mål"
        case .whistle: return "visselpipor"
        case .card: return "kort"
        case .flag: return "flaggor"
        case .star: return "stjärnor"
        }
    }
}

/// En enskild token
struct TokenView: View {
    let type: TokenType
    var size: CGFloat = 40
    var isHighlighted: Bool = false
    var isStrikethrough: Bool = false
    
    var body: some View {
        Text(type.rawValue)
            .font(.system(size: size))
            .opacity(isStrikethrough ? 0.4 : 1.0)
            .overlay {
                if isStrikethrough {
                    Rectangle()
                        .fill(Color.red)
                        .frame(height: 3)
                        .rotationEffect(.degrees(-15))
                }
            }
            .scaleEffect(isHighlighted ? 1.2 : 1.0)
            .animation(.spring(response: 0.3), value: isHighlighted)
            .accessibilityLabel("\(type.name)")
    }
}

/// Grupp av tokens arrangerade i ett grid
struct TokenGroupView: View {
    let count: Int
    let type: TokenType
    var columns: Int = 5
    var tokenSize: CGFloat = 36
    var strikethroughCount: Int = 0
    var highlightedIndices: Set<Int> = []
    
    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.fixed(tokenSize + 8), spacing: 4), count: columns)
    }
    
    var body: some View {
        LazyVGrid(columns: gridColumns, spacing: 4) {
            ForEach(0..<count, id: \.self) { index in
                TokenView(
                    type: type,
                    size: tokenSize,
                    isHighlighted: highlightedIndices.contains(index),
                    isStrikethrough: index >= count - strikethroughCount
                )
                .id(index)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

/// Två grupper av tokens med operator mellan (för addition/subtraktion)
struct TokenOperationView: View {
    let leftCount: Int
    let rightCount: Int
    let tokenType: TokenType
    let operation: Operation
    
    enum Operation {
        case add, subtract
        
        var symbol: String {
            switch self {
            case .add: return "+"
            case .subtract: return "−"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Vänster grupp
            TokenGroupView(count: leftCount, type: tokenType)
            
            // Operator
            Text(operation.symbol)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            // Höger grupp
            TokenGroupView(
                count: rightCount,
                type: tokenType,
                strikethroughCount: operation == .subtract ? rightCount : 0
            )
        }
    }
}

/// Interaktiv token som kan tryckas på
struct InteractiveTokenView: View {
    let type: TokenType
    let index: Int
    var isSelected: Bool = false
    var onTap: ((Int) -> Void)?
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            onTap?(index)
            HapticManager.shared.impact(.light)
        }) {
            Text(type.rawValue)
                .font(.system(size: 44))
                .scaleEffect(isPressed ? 0.9 : (isSelected ? 1.15 : 1.0))
                .opacity(isSelected ? 1.0 : 0.8)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .animation(.spring(response: 0.2), value: isPressed)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

/// Grid av interaktiva tokens
struct InteractiveTokenGrid: View {
    let totalCount: Int
    let type: TokenType
    @Binding var selectedCount: Int
    var columns: Int = 5
    
    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: columns),
            spacing: 8
        ) {
            ForEach(0..<totalCount, id: \.self) { index in
                InteractiveTokenView(
                    type: type,
                    index: index,
                    isSelected: index < selectedCount
                ) { tappedIndex in
                    if tappedIndex < selectedCount {
                        selectedCount = tappedIndex
                    } else {
                        selectedCount = tappedIndex + 1
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

// MARK: - Previews

#Preview("Token Views") {
    ScrollView {
        VStack(spacing: 24) {
            Text("Enskild Token")
                .font(.headline)
            
            HStack(spacing: 16) {
                TokenView(type: .coin)
                TokenView(type: .apple, isHighlighted: true)
                TokenView(type: .star, isStrikethrough: true)
            }
            
            Divider()
            
            Text("Token Grupp (8 st)")
                .font(.headline)
            
            TokenGroupView(count: 8, type: .gem)
            
            Divider()
            
            Text("Addition: 5 + 3")
                .font(.headline)
            
            TokenOperationView(
                leftCount: 5,
                rightCount: 3,
                tokenType: .apple,
                operation: .add
            )
            
            Divider()
            
            Text("Subtraktion: 7 - 2")
                .font(.headline)
            
            TokenOperationView(
                leftCount: 7,
                rightCount: 2,
                tokenType: .cookie,
                operation: .subtract
            )
        }
        .padding()
    }
}
