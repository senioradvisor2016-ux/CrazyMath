// MasteryModel.swift
// MathAdventure
// Adaptiv mastery-modell för progression

import Foundation

/// Modell för att beräkna och uppdatera mastery
struct MasteryModel {
    
    // MARK: - Konstanter
    
    /// Hur mycket ett korrekt svar påverkar mastery (baserat på svårighet)
    private static let correctBoostBase: Double = 0.05
    
    /// Hur mycket ett felaktigt svar påverkar mastery
    private static let incorrectPenaltyBase: Double = 0.03
    
    /// Maximal mastery
    static let maxMastery: Double = 1.0
    
    /// Minimal mastery
    static let minMastery: Double = 0.0
    
    /// Tid i ms som anses snabb (bonus)
    private static let fastResponseThreshold: Int = 3000
    
    /// Tid i ms som anses långsam (liten bonus)
    private static let slowResponseThreshold: Int = 15000
    
    // MARK: - Uppdatering
    
    /// Uppdatera mastery baserat på spelarens prestation
    /// - Parameters:
    ///   - currentMastery: Nuvarande mastery (0.0-1.0)
    ///   - task: Uppgiften som löstes
    ///   - correct: Om svaret var korrekt
    ///   - responseTimeMs: Svarstid i millisekunder
    /// - Returns: Ny mastery-nivå
    static func updateMastery(
        currentMastery: Double,
        task: MathTask,
        correct: Bool,
        responseTimeMs: Int
    ) -> Double {
        var newMastery = currentMastery
        
        let difficultyFactor = Double(task.difficulty) / 10.0
        
        if correct {
            // Korrekt svar - öka mastery
            var boost = correctBoostBase
            
            // Högre svårighet ger mer boost
            boost *= (0.5 + difficultyFactor)
            
            // Snabbt svar ger bonus
            if responseTimeMs < fastResponseThreshold {
                boost *= 1.3
            } else if responseTimeMs > slowResponseThreshold {
                boost *= 0.7
            }
            
            // Svårare att nå hög mastery (avtagande avkastning)
            let distanceFromMax = maxMastery - currentMastery
            boost *= (0.5 + distanceFromMax * 0.5)
            
            newMastery += boost
            
        } else {
            // Felaktigt svar - minska mastery
            var penalty = incorrectPenaltyBase
            
            // Lägre svårighet ger mer penalty (borde kunna)
            penalty *= (1.5 - difficultyFactor * 0.5)
            
            // Minska inte under en rimlig nivå
            newMastery -= penalty
        }
        
        // Clamp till giltigt intervall
        return max(minMastery, min(maxMastery, newMastery))
    }
    
    // MARK: - Svårighetsjustering
    
    /// Rekommenderar svårighet baserat på mastery och senaste prestationer
    /// - Parameters:
    ///   - mastery: Nuvarande mastery
    ///   - recentCorrect: Antal korrekta svar senaste 5 uppgifterna
    ///   - recentTotal: Totalt antal senaste uppgifter
    /// - Returns: Rekommenderad svårighet 1-10
    static func recommendDifficulty(
        mastery: Double,
        recentCorrect: Int = 0,
        recentTotal: Int = 0
    ) -> Int {
        // Basnivå från mastery
        var difficulty = Int(mastery * 9) + 1
        
        // Justera baserat på senaste prestationer
        if recentTotal >= 3 {
            let recentRate = Double(recentCorrect) / Double(recentTotal)
            
            if recentRate >= 0.9 {
                // Mycket bra - öka svårighet
                difficulty += 1
            } else if recentRate <= 0.4 {
                // Kämpar - minska svårighet
                difficulty -= 1
            }
        }
        
        // Clamp till 1-10
        return max(1, min(10, difficulty))
    }
    
    // MARK: - Representationsanpassning
    
    /// Föreslår en alternativ representation vid fel
    /// - Parameters:
    ///   - task: Uppgiften som spelaren hade fel på
    ///   - attemptCount: Antal försök
    /// - Returns: Representationstyp att använda
    static func suggestRepresentation(
        for task: MathTask,
        attemptCount: Int
    ) -> RepresentationType {
        switch attemptCount {
        case 0:
            return .symbolic  // Första försöket - symbolisk
        case 1:
            return .visual    // Andra försöket - visuell
        case 2:
            return .concrete  // Tredje försöket - konkret
        default:
            return .guided    // Fjärde+ - guidad
        }
    }
    
    // MARK: - Stjärnberäkning
    
    /// Beräknar antal stjärnor (1-3) baserat på prestation
    /// - Parameters:
    ///   - correct: Om svaret var korrekt
    ///   - attemptCount: Antal försök
    ///   - responseTimeMs: Svarstid
    ///   - difficulty: Uppgiftens svårighet
    /// - Returns: Antal stjärnor (0-3)
    static func calculateStars(
        correct: Bool,
        attemptCount: Int,
        responseTimeMs: Int,
        difficulty: Int
    ) -> Int {
        guard correct else { return 0 }
        
        // Basera på försök
        var stars: Int
        switch attemptCount {
        case 0, 1:
            stars = 3  // Första eller andra försöket
        case 2:
            stars = 2  // Tredje försöket
        default:
            stars = 1  // Fler försök
        }
        
        // Snabbt svar på hög svårighet kan ge bonus
        if difficulty >= 7 && responseTimeMs < fastResponseThreshold && attemptCount <= 1 {
            stars = 3  // Garantera 3 stjärnor
        }
        
        return stars
    }
}

/// Typ av representation för matematiken
enum RepresentationType: String, Codable {
    case symbolic  // 5 + 3 = ?
    case visual    // 🔵🔵🔵🔵🔵 + 🔵🔵🔵 = ?
    case concrete  // Interaktiva objekt
    case guided    // Steg-för-steg med hints
}
