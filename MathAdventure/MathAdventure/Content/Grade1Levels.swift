// Grade1Levels.swift
// MathAdventure
// 20 nivåer för Årskurs 1 (addition och subtraktion ≤ 20)

import Foundation

/// Innehåll för Årskurs 1
enum Grade1Levels {
    
    /// Alla 20 nivåer för Åk1
    static let levels: [MathTask] = [
        // Nivå 1-5: Enkel addition (summa ≤ 10)
        MathTask(
            grade: .g1,
            skill: .add,
            difficulty: 1,
            seed: 101,
            promptData: ["a": 2, "b": 1],
            correctInt: 3,
            levelIndex: 0
        ),
        MathTask(
            grade: .g1,
            skill: .add,
            difficulty: 1,
            seed: 102,
            promptData: ["a": 3, "b": 2],
            correctInt: 5,
            levelIndex: 1
        ),
        MathTask(
            grade: .g1,
            skill: .add,
            difficulty: 2,
            seed: 103,
            promptData: ["a": 4, "b": 3],
            correctInt: 7,
            levelIndex: 2
        ),
        MathTask(
            grade: .g1,
            skill: .add,
            difficulty: 2,
            seed: 104,
            promptData: ["a": 5, "b": 4],
            correctInt: 9,
            levelIndex: 3
        ),
        MathTask(
            grade: .g1,
            skill: .add,
            difficulty: 2,
            seed: 105,
            promptData: ["a": 6, "b": 4],
            correctInt: 10,
            levelIndex: 4
        ),
        
        // Nivå 6-10: Enkel subtraktion (a ≤ 10)
        MathTask(
            grade: .g1,
            skill: .sub,
            difficulty: 1,
            seed: 106,
            promptData: ["a": 5, "b": 2],
            correctInt: 3,
            levelIndex: 5
        ),
        MathTask(
            grade: .g1,
            skill: .sub,
            difficulty: 1,
            seed: 107,
            promptData: ["a": 6, "b": 3],
            correctInt: 3,
            levelIndex: 6
        ),
        MathTask(
            grade: .g1,
            skill: .sub,
            difficulty: 2,
            seed: 108,
            promptData: ["a": 8, "b": 4],
            correctInt: 4,
            levelIndex: 7
        ),
        MathTask(
            grade: .g1,
            skill: .sub,
            difficulty: 2,
            seed: 109,
            promptData: ["a": 9, "b": 5],
            correctInt: 4,
            levelIndex: 8
        ),
        MathTask(
            grade: .g1,
            skill: .sub,
            difficulty: 3,
            seed: 110,
            promptData: ["a": 10, "b": 7],
            correctInt: 3,
            levelIndex: 9
        ),
        
        // Nivå 11-15: Addition med tiotalsövergång (summa 11-20)
        MathTask(
            grade: .g1,
            skill: .add,
            difficulty: 4,
            seed: 111,
            promptData: ["a": 7, "b": 5],
            correctInt: 12,
            levelIndex: 10
        ),
        MathTask(
            grade: .g1,
            skill: .add,
            difficulty: 4,
            seed: 112,
            promptData: ["a": 8, "b": 6],
            correctInt: 14,
            levelIndex: 11
        ),
        MathTask(
            grade: .g1,
            skill: .add,
            difficulty: 5,
            seed: 113,
            promptData: ["a": 9, "b": 7],
            correctInt: 16,
            levelIndex: 12
        ),
        MathTask(
            grade: .g1,
            skill: .add,
            difficulty: 5,
            seed: 114,
            promptData: ["a": 8, "b": 9],
            correctInt: 17,
            levelIndex: 13
        ),
        MathTask(
            grade: .g1,
            skill: .add,
            difficulty: 6,
            seed: 115,
            promptData: ["a": 9, "b": 9],
            correctInt: 18,
            levelIndex: 14
        ),
        
        // Nivå 16-20: Subtraktion från tal > 10
        MathTask(
            grade: .g1,
            skill: .sub,
            difficulty: 4,
            seed: 116,
            promptData: ["a": 12, "b": 5],
            correctInt: 7,
            levelIndex: 15
        ),
        MathTask(
            grade: .g1,
            skill: .sub,
            difficulty: 5,
            seed: 117,
            promptData: ["a": 15, "b": 8],
            correctInt: 7,
            levelIndex: 16
        ),
        MathTask(
            grade: .g1,
            skill: .sub,
            difficulty: 5,
            seed: 118,
            promptData: ["a": 17, "b": 9],
            correctInt: 8,
            levelIndex: 17
        ),
        MathTask(
            grade: .g1,
            skill: .sub,
            difficulty: 6,
            seed: 119,
            promptData: ["a": 18, "b": 9],
            correctInt: 9,
            levelIndex: 18
        ),
        MathTask(
            grade: .g1,
            skill: .sub,
            difficulty: 6,
            seed: 120,
            promptData: ["a": 20, "b": 11],
            correctInt: 9,
            levelIndex: 19
        )
    ]
    
    /// Hämta en specifik nivå
    static func level(at index: Int) -> MathTask? {
        guard index >= 0 && index < levels.count else { return nil }
        return levels[index]
    }
    
    /// Hämta nivåer efter skill
    static func levels(for skill: Skill) -> [MathTask] {
        levels.filter { $0.skill == skill }
    }
    
    /// Hämta nivåer efter svårighetsgrad
    static func levels(difficulty: Int) -> [MathTask] {
        levels.filter { $0.difficulty == difficulty }
    }
}

// MARK: - Level Metadata

/// Extra metadata för nivåer
struct LevelMetadata {
    let levelIndex: Int
    let title: String
    let description: String
    let objectives: [String]
}

extension Grade1Levels {
    
    /// Metadata för alla Åk1 nivåer (fotbollstema)
    static let metadata: [LevelMetadata] = [
        LevelMetadata(
            levelIndex: 0,
            title: "Zlatans första mål ⚽",
            description: "Zlatan gör sina första mål!",
            objectives: ["Förstå addition som 'lägga ihop mål'", "Lösa 2 + 1"]
        ),
        LevelMetadata(
            levelIndex: 1,
            title: "Messis assist 🎯",
            description: "Messi delar ut assist!",
            objectives: ["Räkna till 5", "Lösa 3 + 2"]
        ),
        LevelMetadata(
            levelIndex: 2,
            title: "Ronaldos hat-trick 🎩",
            description: "CR7 jagar fler mål!",
            objectives: ["Räkna till 7", "Lösa 4 + 3"]
        ),
        LevelMetadata(
            levelIndex: 3,
            title: "Mbappés sprint 🏃",
            description: "Mbappé springer och gör mål!",
            objectives: ["Räkna till 9", "Lösa 5 + 4"]
        ),
        LevelMetadata(
            levelIndex: 4,
            title: "Haalands 10 mål! 🔟",
            description: "Haaland når tvåsiffrigt!",
            objectives: ["Förstå talet 10", "Lösa 6 + 4"]
        ),
        LevelMetadata(
            levelIndex: 5,
            title: "Röda kort! 🟥",
            description: "Spelare blir utvisade",
            objectives: ["Förstå 'ta bort spelare'", "Lösa 5 - 2"]
        ),
        LevelMetadata(
            levelIndex: 6,
            title: "Salahs skador 🏥",
            description: "Salah missar matcher",
            objectives: ["Räkna bakåt", "Lösa 6 - 3"]
        ),
        LevelMetadata(
            levelIndex: 7,
            title: "Neymars tröjor 👕",
            description: "Neymar ger bort signerade tröjor",
            objectives: ["Subtraktion med 4", "Lösa 8 - 4"]
        ),
        LevelMetadata(
            levelIndex: 8,
            title: "De Bruynes kort 🃏",
            description: "De Bruyne delar ut samlarbilder",
            objectives: ["Större subtraktion", "Lösa 9 - 5"]
        ),
        LevelMetadata(
            levelIndex: 9,
            title: "Modrics assist 🌟",
            description: "Modric delade ut 10 assist",
            objectives: ["Subtraktion från 10", "Lösa 10 - 7"]
        ),
        LevelMetadata(
            levelIndex: 10,
            title: "Benzemas comeback! 🔥",
            description: "Benzema gör mål igen!",
            objectives: ["Tiotalsövergång", "Lösa 7 + 5 = 12"]
        ),
        LevelMetadata(
            levelIndex: 11,
            title: "Lewandowskis rekord 📈",
            description: "Lewy jagar målrekord!",
            objectives: ["Övning i tiotalsövergång", "Lösa 8 + 6 = 14"]
        ),
        LevelMetadata(
            levelIndex: 12,
            title: "Vinícius Jr dansar! 💃",
            description: "Vini gör mål och firar!",
            objectives: ["Addition till 16", "Lösa 9 + 7"]
        ),
        LevelMetadata(
            levelIndex: 13,
            title: "Bellinghams genombrott 💫",
            description: "Jude Bellingham imponerar!",
            objectives: ["Addition till 17", "Lösa 8 + 9"]
        ),
        LevelMetadata(
            levelIndex: 14,
            title: "Dubbelstjärnor! ⭐⭐",
            description: "Två stjärnspelare gör mål!",
            objectives: ["Dubblor", "Lösa 9 + 9 = 18"]
        ),
        LevelMetadata(
            levelIndex: 15,
            title: "Fridolinas assist 🇸🇪",
            description: "Fridolina Rolfö spelar för Sverige!",
            objectives: ["Subtraktion från 12", "Lösa 12 - 5"]
        ),
        LevelMetadata(
            levelIndex: 16,
            title: "Kosovares mål 🌟",
            description: "Kosovare Asllani gör mål!",
            objectives: ["Tiotalsövergång i subtraktion", "Lösa 15 - 8"]
        ),
        LevelMetadata(
            levelIndex: 17,
            title: "Stinas straff ⚽",
            description: "Stina Blackstenius tar straff!",
            objectives: ["Avancerad subtraktion", "Lösa 17 - 9"]
        ),
        LevelMetadata(
            levelIndex: 18,
            title: "Caroline leder laget 👑",
            description: "Caroline Seger är kapten!",
            objectives: ["Subtraktion från 18", "Lösa 18 - 9"]
        ),
        LevelMetadata(
            levelIndex: 19,
            title: "VM-guld! 🏆🥇",
            description: "Du vann VM i fotbollsmatte!",
            objectives: ["Mästare på 0-20", "Lösa 20 - 11"]
        )
    ]
}
