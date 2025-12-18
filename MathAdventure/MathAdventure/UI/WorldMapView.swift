// WorldMapView.swift
// MathAdventure
// Världskarta med progression

import SwiftUI

/// Huvudmeny med världskarta
struct WorldMapView: View {
    @Binding var playerProfile: PlayerProfile
    @Binding var selectedLevel: LevelSelection?
    
    @State private var selectedWorld: GradeBand? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Spelarinfo
                    playerHeader
                    
                    // Världar
                    ForEach(GradeBand.allCases, id: \.rawValue) { grade in
                        WorldCard(
                            grade: grade,
                            completedLevels: playerProfile.completedCount(for: grade),
                            totalLevels: grade.levelCount,
                            isExpanded: selectedWorld == grade
                        ) {
                            withAnimation(.spring(response: 0.4)) {
                                if selectedWorld == grade {
                                    selectedWorld = nil
                                } else {
                                    selectedWorld = grade
                                }
                            }
                        }
                        
                        // Nivå-noder om världen är expanderad
                        if selectedWorld == grade {
                            levelNodes(for: grade)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationTitle("⚽ Fotbollsmatten")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    @ViewBuilder
    private var playerHeader: some View {
        HStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 60, height: 60)
                
                Text(avatarEmoji)
                    .font(.system(size: 30))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(playerProfile.name)
                    .font(.headline)
                
                HStack(spacing: 12) {
                    Label("\(playerProfile.totalStars)", systemImage: "star.fill")
                        .foregroundColor(.yellow)
                    
                    Label("\(playerProfile.streakDays) dagar", systemImage: "flame.fill")
                        .foregroundColor(.orange)
                }
                .font(.subheadline)
            }
            
            Spacer()
            
            // Inställningar
            Button(action: {}) {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        )
    }
    
    private var avatarEmoji: String {
        let avatars = ["⚽", "🥅", "🏆", "👟", "🧤", "🎯", "🏅", "⭐"]
        return avatars[playerProfile.avatarIndex % avatars.count]
    }
    
    @ViewBuilder
    private func levelNodes(for grade: GradeBand) -> some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            ForEach(0..<grade.levelCount, id: \.self) { levelIndex in
                LevelNode(
                    index: levelIndex,
                    isCompleted: playerProfile.isLevelCompleted(grade: grade, levelIndex: levelIndex),
                    isUnlocked: playerProfile.isLevelUnlocked(grade: grade, levelIndex: levelIndex),
                    stars: starsForLevel(grade: grade, levelIndex: levelIndex)
                ) {
                    if playerProfile.isLevelUnlocked(grade: grade, levelIndex: levelIndex) {
                        selectedLevel = LevelSelection(grade: grade, levelIndex: levelIndex)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func starsForLevel(grade: GradeBand, levelIndex: Int) -> Int {
        // Här kan vi lagra stjärnor per nivå i profilen
        // För demo returnerar vi random eller 0
        playerProfile.isLevelCompleted(grade: grade, levelIndex: levelIndex) ? Int.random(in: 1...3) : 0
    }
}

/// Kort för en värld (årskurs)
struct WorldCard: View {
    let grade: GradeBand
    let completedLevels: Int
    let totalLevels: Int
    let isExpanded: Bool
    let onTap: () -> Void
    
    private var progress: Double {
        guard totalLevels > 0 else { return 0 }
        return Double(completedLevels) / Double(totalLevels)
    }
    
    private var worldColor: Color {
        switch grade {
        case .g1: return .green
        case .g2: return .mint
        case .g3: return .blue
        case .g4: return .purple
        case .g5: return .orange
        case .g6: return .yellow
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                HStack {
                    // Världsikon
                    ZStack {
                        Circle()
                            .fill(worldColor.opacity(0.2))
                            .frame(width: 50, height: 50)
                        
                        Text(worldEmoji)
                            .font(.title)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(grade.worldName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(grade.displayName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Progression
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(completedLevels)/\(totalLevels)")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.secondary)
                    }
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                        
                        Capsule()
                            .fill(worldColor)
                            .frame(width: geometry.size.width * progress, height: 8)
                    }
                }
                .frame(height: 8)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var worldEmoji: String {
        switch grade {
        case .g1: return "⚽"
        case .g2: return "🥉"
        case .g3: return "🥈"
        case .g4: return "🏆"
        case .g5: return "🌍"
        case .g6: return "🏅"
        }
    }
}

/// En nivå-nod på kartan
struct LevelNode: View {
    let index: Int
    let isCompleted: Bool
    let isUnlocked: Bool
    let stars: Int
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(backgroundColor)
                        .frame(width: 44, height: 44)
                    
                    if isUnlocked {
                        Text("\(index + 1)")
                            .font(.headline)
                            .foregroundColor(isCompleted ? .white : .primary)
                    } else {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                    }
                }
                
                // Stjärnor
                if isCompleted {
                    HStack(spacing: 1) {
                        ForEach(0..<3, id: \.self) { starIndex in
                            Image(systemName: starIndex < stars ? "star.fill" : "star")
                                .font(.system(size: 8))
                                .foregroundColor(.yellow)
                        }
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isUnlocked)
    }
    
    private var backgroundColor: Color {
        if !isUnlocked {
            return Color.gray.opacity(0.3)
        } else if isCompleted {
            return .green
        } else {
            return Color(.secondarySystemBackground)
        }
    }
}

/// Struktur för att hålla vald nivå
struct LevelSelection: Identifiable, Equatable {
    var id: String { "\(grade.rawValue)-\(levelIndex)" }
    let grade: GradeBand
    let levelIndex: Int
}

// MARK: - Preview

#Preview("World Map") {
    struct PreviewWrapper: View {
        @State var profile = PlayerProfile(name: "Äventyrare")
        @State var selectedLevel: LevelSelection? = nil
        
        var body: some View {
            WorldMapView(
                playerProfile: $profile,
                selectedLevel: $selectedLevel
            )
        }
    }
    
    return PreviewWrapper()
}
