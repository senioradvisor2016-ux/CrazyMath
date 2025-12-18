// Skill.swift
// MathAdventure
// Matematiska färdigheter enligt Lgr22

import Foundation

/// Matematiska färdigheter som tränas i spelet
enum Skill: String, Codable, CaseIterable, Identifiable {
    case add = "addition"
    case sub = "subtraction"
    case mult = "multiplication"
    case div = "division"
    case placeValue = "place_value"
    case patterns = "patterns"
    case fractions = "fractions"
    case decimals = "decimals"
    case percent = "percent"
    case geometry = "geometry"
    case measurement = "measurement"
    case coordinates = "coordinates"
    case statistics = "statistics"
    case negatives = "negatives"
    case scale = "scale"
    case reasoning = "reasoning"
    
    var id: String { rawValue }
    
    /// Visningsnamn på svenska
    var displayName: String {
        switch self {
        case .add: return "Addition"
        case .sub: return "Subtraktion"
        case .mult: return "Multiplikation"
        case .div: return "Division"
        case .placeValue: return "Positionssystemet"
        case .patterns: return "Mönster"
        case .fractions: return "Bråk"
        case .decimals: return "Decimaltal"
        case .percent: return "Procent"
        case .geometry: return "Geometri"
        case .measurement: return "Mätning"
        case .coordinates: return "Koordinater"
        case .statistics: return "Statistik"
        case .negatives: return "Negativa tal"
        case .scale: return "Skala"
        case .reasoning: return "Resonemang"
        }
    }
    
    /// Emoji för snabb visuell identifikation
    var emoji: String {
        switch self {
        case .add: return "➕"
        case .sub: return "➖"
        case .mult: return "✖️"
        case .div: return "➗"
        case .placeValue: return "🔢"
        case .patterns: return "🔄"
        case .fractions: return "🍕"
        case .decimals: return "🔵"
        case .percent: return "💯"
        case .geometry: return "📐"
        case .measurement: return "📏"
        case .coordinates: return "🗺️"
        case .statistics: return "📊"
        case .negatives: return "🌡️"
        case .scale: return "⚖️"
        case .reasoning: return "💭"
        }
    }
    
    /// Vilken LevelView som ska användas för denna skill
    var levelViewType: LevelViewType {
        switch self {
        case .add:
            return .merge
        case .sub:
            return .popAway
        case .mult:
            return .bridge
        case .div:
            return .dealEqual
        case .placeValue, .patterns, .geometry, .measurement, .coordinates, .statistics, .negatives, .scale:
            return .choosePath
        case .fractions, .decimals, .percent, .reasoning:
            return .explain
        }
    }
    
    /// Beskrivning för föräldrar/lärare
    var educationalDescription: String {
        switch self {
        case .add:
            return "Lägga ihop tal, förstå addition som sammanläggning"
        case .sub:
            return "Ta bort, räkna bakåt, hitta skillnad"
        case .mult:
            return "Upprepad addition, grupper av lika storlek"
        case .div:
            return "Dela lika, räkna hur många gånger"
        case .placeValue:
            return "Förstå ental, tiotal, hundratal"
        case .patterns:
            return "Upptäcka och fortsätta mönster"
        case .fractions:
            return "Delar av helhet, enkel bråkräkning"
        case .decimals:
            return "Tiondelar, hundradelar, positionssystem"
        case .percent:
            return "Procent som hundradelar"
        case .geometry:
            return "Former, vinklar, symmetri"
        case .measurement:
            return "Längd, vikt, volym, tid"
        case .coordinates:
            return "Koordinatsystem, positioner"
        case .statistics:
            return "Tabeller, diagram, medelvärde"
        case .negatives:
            return "Tal under noll"
        case .scale:
            return "Förstora, förminska proportionellt"
        case .reasoning:
            return "Matematiska resonemang och bevis"
        }
    }
}

/// Typ av level-vy för olika skills
enum LevelViewType: String, Codable {
    case merge       // Addition - slå ihop objekt
    case popAway     // Subtraktion - ta bort objekt
    case bridge      // Multiplikation - steg på bro
    case dealEqual   // Division - dela lika
    case choosePath  // Strategi - välj rätt väg
    case explain     // Resonemang - förklara
}
