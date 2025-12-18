// PlayerProfile.swift
// MathAdventure
// Spelarens profil och progression

import Foundation

/// Spelarens profil med progression och mastery
struct PlayerProfile: Codable, Identifiable {
    let id: UUID
    var name: String
    var avatarIndex: Int
    var currentGrade: GradeBand
    var completedLevels: [GradeBand: Set<Int>]  // Vilka nivåer som är avklarade per årskurs
    var masteryScores: [Skill: Double]  // 0.0 - 1.0 per skill
    var totalStars: Int
    var streakDays: Int
    var lastPlayedDate: Date?
    
    /// Skapar en ny spelar med startprofil
    init(name: String = "Äventyrare", avatarIndex: Int = 0) {
        self.id = UUID()
        self.name = name
        self.avatarIndex = avatarIndex
        self.currentGrade = .g1
        self.completedLevels = [:]
        self.masteryScores = [:]
        self.totalStars = 0
        self.streakDays = 0
        self.lastPlayedDate = nil
        
        // Initiera alla skills till 0.0
        for skill in Skill.allCases {
            masteryScores[skill] = 0.0
        }
    }
    
    /// Hämta mastery för en skill (default 0.0)
    func mastery(for skill: Skill) -> Double {
        masteryScores[skill] ?? 0.0
    }
    
    /// Hur många nivåer har spelaren klarat i en årskurs
    func completedCount(for grade: GradeBand) -> Int {
        completedLevels[grade]?.count ?? 0
    }
    
    /// Är en specifik nivå klarad?
    func isLevelCompleted(grade: GradeBand, levelIndex: Int) -> Bool {
        completedLevels[grade]?.contains(levelIndex) ?? false
    }
    
    /// Är en nivå upplåst?
    func isLevelUnlocked(grade: GradeBand, levelIndex: Int) -> Bool {
        // Första nivån är alltid upplåst
        if levelIndex == 0 { return true }
        // Annars måste föregående nivå vara klar
        return isLevelCompleted(grade: grade, levelIndex: levelIndex - 1)
    }
    
    /// Uppdatera profilen efter avslutat level
    mutating func completeLevelAndUpdateProfile(
        grade: GradeBand,
        levelIndex: Int,
        skill: Skill,
        earnedStars: Int,
        newMastery: Double
    ) {
        // Markera nivån som klar
        if completedLevels[grade] == nil {
            completedLevels[grade] = []
        }
        completedLevels[grade]?.insert(levelIndex)
        
        // Uppdatera mastery
        masteryScores[skill] = newMastery
        
        // Lägg till stjärnor
        totalStars += earnedStars
        
        // Uppdatera streak
        updateStreak()
    }
    
    /// Uppdatera streak baserat på dagens datum
    private mutating func updateStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastPlayed = lastPlayedDate {
            let lastDay = Calendar.current.startOfDay(for: lastPlayed)
            let daysDiff = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0
            
            if daysDiff == 1 {
                // Speldagen efter, fortsätt streak
                streakDays += 1
            } else if daysDiff > 1 {
                // Missade dagar, nollställ streak
                streakDays = 1
            }
            // Om daysDiff == 0, samma dag, ingen ändring
        } else {
            // Första gången
            streakDays = 1
        }
        
        lastPlayedDate = Date()
    }
    
    /// Genomsnittlig mastery för en årskurs
    func averageMastery(for grade: GradeBand) -> Double {
        let skills = grade.primarySkills
        guard !skills.isEmpty else { return 0.0 }
        
        let total = skills.reduce(0.0) { $0 + mastery(for: $1) }
        return total / Double(skills.count)
    }
    
    /// Rekommenderad svårighetsgrad baserad på mastery
    func recommendedDifficulty(for skill: Skill) -> Int {
        let m = mastery(for: skill)
        // Mastery 0.0-1.0 mappas till difficulty 1-10
        return max(1, min(10, Int(m * 9) + 1))
    }
}

/// Hjälpstruktur för att spara profilen
extension PlayerProfile {
    static let storageKey = "player_profile"
    
    /// Ladda profil från UserDefaults
    static func load() -> PlayerProfile? {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return nil
        }
        return try? JSONDecoder().decode(PlayerProfile.self, from: data)
    }
    
    /// Spara profil till UserDefaults
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: PlayerProfile.storageKey)
        }
    }
}
