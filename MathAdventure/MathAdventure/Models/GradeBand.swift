// GradeBand.swift
// MathAdventure
// Representerar årskurser enligt Lgr22

import Foundation

/// Årskurser (Grade 1-6) enligt svensk läroplan
enum GradeBand: Int, Codable, CaseIterable, Comparable {
    case g1 = 1
    case g2 = 2
    case g3 = 3
    case g4 = 4
    case g5 = 5
    case g6 = 6
    
    /// Visningsnamn för årskurs
    var displayName: String {
        switch self {
        case .g1: return "Årskurs 1"
        case .g2: return "Årskurs 2"
        case .g3: return "Årskurs 3"
        case .g4: return "Årskurs 4"
        case .g5: return "Årskurs 5"
        case .g6: return "Årskurs 6"
        }
    }
    
    /// Kortnamn
    var shortName: String {
        "Åk \(rawValue)"
    }
    
    /// Tema/världsnamn för varje årskurs (fotbollstema)
    var worldName: String {
        switch self {
        case .g1: return "Ungdomsakademin ⚽"
        case .g2: return "Division 2 🥉"
        case .g3: return "Allsvenskan 🥈"
        case .g4: return "Champions League 🏆"
        case .g5: return "VM-slutspelet 🌍"
        case .g6: return "Ballon d'Or 🏅"
        }
    }
    
    /// Färg för varje värld (för UI)
    var worldColorName: String {
        switch self {
        case .g1: return "meadowGreen"
        case .g2: return "forestGreen"
        case .g3: return "mountainBlue"
        case .g4: return "swampPurple"
        case .g5: return "desertOrange"
        case .g6: return "castleGold"
        }
    }
    
    /// Vilka skills som introduceras i denna årskurs
    var primarySkills: [Skill] {
        switch self {
        case .g1:
            return [.add, .sub, .placeValue]
        case .g2:
            return [.add, .sub, .placeValue, .patterns]
        case .g3:
            return [.mult, .div, .patterns]
        case .g4:
            return [.mult, .div, .fractions, .geometry]
        case .g5:
            return [.fractions, .decimals, .percent, .measurement]
        case .g6:
            return [.decimals, .percent, .coordinates, .statistics, .negatives, .scale, .reasoning]
        }
    }
    
    /// Antal levels som finns i denna värld
    var levelCount: Int {
        switch self {
        case .g1: return 20
        case .g2: return 20
        case .g3: return 20
        case .g4: return 20
        case .g5: return 20
        case .g6: return 20
        }
    }
    
    static func < (lhs: GradeBand, rhs: GradeBand) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
