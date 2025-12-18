// CharacterView.swift
// MathAdventure
// Blixt-Bot karaktären med textbubbla

import SwiftUI

/// Blixt-Bot karaktären som guidar spelaren
struct CharacterView: View {
    let message: String
    var isThinking: Bool = false
    var mood: Mood = .happy
    
    enum Mood {
        case happy, thinking, celebrating, encouraging
        
        var emoji: String {
            switch self {
            case .happy: return "🤖"
            case .thinking: return "🤔"
            case .celebrating: return "🎉"
            case .encouraging: return "💪"
            }
        }
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            // Blixt-Bot avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Text(mood.emoji)
                    .font(.system(size: 32))
            }
            .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)
            
            // Textbubbla
            SpeechBubble(isThinking: isThinking) {
                Text(message)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(.horizontal)
    }
}

/// Textbubbla med pilspets
struct SpeechBubble<Content: View>: View {
    let isThinking: Bool
    @ViewBuilder let content: Content
    
    var body: some View {
        HStack(spacing: 0) {
            // Pilspets
            Triangle()
                .fill(Color(.systemBackground))
                .frame(width: 12, height: 20)
                .rotationEffect(.degrees(-90))
                .offset(x: 6)
            
            // Bubbla
            content
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
        }
        .opacity(isThinking ? 0.7 : 1.0)
        .overlay {
            if isThinking {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
    }
}

/// Triangelform för pratbubblepil
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Compact Character

/// Kompakt version av Blixt-Bot för mindre utrymmen
struct CompactCharacterView: View {
    let message: String
    var mood: CharacterView.Mood = .happy
    
    var body: some View {
        HStack(spacing: 8) {
            Text(mood.emoji)
                .font(.title2)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color(.secondarySystemBackground))
        )
    }
}

// MARK: - Previews

#Preview("Character View") {
    VStack(spacing: 20) {
        CharacterView(
            message: "Hej! Jag är Blixt-Bot och jag älskar matte!",
            mood: .happy
        )
        
        CharacterView(
            message: "Hmm, låt mig tänka...",
            isThinking: true,
            mood: .thinking
        )
        
        CharacterView(
            message: "FANTASTISKT! Du klarade det! 🌟",
            mood: .celebrating
        )
        
        CompactCharacterView(
            message: "Bra jobbat!",
            mood: .encouraging
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
