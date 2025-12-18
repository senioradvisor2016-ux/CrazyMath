// MathTask.swift
// MathAdventure
// Representerar en matematisk uppgift

import Foundation

/// En matematisk uppgift som spelaren ska lösa
struct MathTask: Identifiable, Codable, Equatable {
    let id: UUID
    let grade: GradeBand
    let skill: Skill
    let difficulty: Int         // 1-10
    let seed: Int               // För deterministisk generering
    let promptData: [String: Int]  // a, b, n, groups, etc.
    let correctInt: Int?        // Korrekt svar när relevant
    let correctFraction: FractionValue?  // För bråkuppgifter
    let levelIndex: Int         // Vilken nivå i världen (0-19)
    
    init(
        id: UUID = UUID(),
        grade: GradeBand,
        skill: Skill,
        difficulty: Int,
        seed: Int,
        promptData: [String: Int],
        correctInt: Int? = nil,
        correctFraction: FractionValue? = nil,
        levelIndex: Int = 0
    ) {
        self.id = id
        self.grade = grade
        self.skill = skill
        self.difficulty = max(1, min(10, difficulty))
        self.seed = seed
        self.promptData = promptData
        self.correctInt = correctInt
        self.correctFraction = correctFraction
        self.levelIndex = levelIndex
    }
    
    /// Hämta värde från promptData med default
    func getValue(_ key: String, default defaultValue: Int = 0) -> Int {
        promptData[key] ?? defaultValue
    }
    
    /// Beräknad egenskap för a-värdet
    var a: Int { getValue("a") }
    
    /// Beräknad egenskap för b-värdet
    var b: Int { getValue("b") }
    
    /// Beräknad egenskap för antal grupper
    var groups: Int { getValue("groups", default: 1) }
    
    /// Beräknad egenskap för antal per grupp
    var perGroup: Int { getValue("perGroup", default: 1) }
    
    /// Genererar en enkel textrepresentation av uppgiften
    var mathExpression: String {
        switch skill {
        case .add:
            return "\(a) + \(b)"
        case .sub:
            return "\(a) - \(b)"
        case .mult:
            return "\(a) × \(b)"
        case .div:
            return "\(a) ÷ \(b)"
        default:
            return "?"
        }
    }
    
    /// Korrekta svaret som String
    var correctAnswer: String {
        if let intVal = correctInt {
            return String(intVal)
        }
        if let frac = correctFraction {
            return frac.displayString
        }
        return "?"
    }
}

/// Representation av ett bråktal
struct FractionValue: Codable, Equatable {
    let numerator: Int
    let denominator: Int
    
    var displayString: String {
        "\(numerator)/\(denominator)"
    }
    
    var decimalValue: Double {
        guard denominator != 0 else { return 0 }
        return Double(numerator) / Double(denominator)
    }
    
    /// Förenkla bråket
    var simplified: FractionValue {
        let gcd = gcd(abs(numerator), abs(denominator))
        guard gcd > 0 else { return self }
        return FractionValue(
            numerator: numerator / gcd,
            denominator: denominator / gcd
        )
    }
    
    /// Beräkna största gemensamma delare
    private func gcd(_ a: Int, _ b: Int) -> Int {
        b == 0 ? a : gcd(b, a % b)
    }
}

/// Spelarens svar på en uppgift
struct PlayerAnswer: Codable, Equatable {
    let intValue: Int?
    let fractionValue: FractionValue?
    let stringValue: String?
    let responseTimeMs: Int
    
    init(int: Int, responseTimeMs: Int = 0) {
        self.intValue = int
        self.fractionValue = nil
        self.stringValue = nil
        self.responseTimeMs = responseTimeMs
    }
    
    init(fraction: FractionValue, responseTimeMs: Int = 0) {
        self.intValue = nil
        self.fractionValue = fraction
        self.stringValue = nil
        self.responseTimeMs = responseTimeMs
    }
    
    init(string: String, responseTimeMs: Int = 0) {
        self.intValue = nil
        self.fractionValue = nil
        self.stringValue = string
        self.responseTimeMs = responseTimeMs
    }
}
