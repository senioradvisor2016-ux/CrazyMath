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
    
    /// Metadata för alla Åk1 nivåer
    static let metadata: [LevelMetadata] = [
        LevelMetadata(
            levelIndex: 0,
            title: "Första stegen",
            description: "Lär dig att lägga ihop små tal",
            objectives: ["Förstå addition som 'lägga ihop'", "Lösa 2 + 1"]
        ),
        LevelMetadata(
            levelIndex: 1,
            title: "Fler stenar",
            description: "Öva på lite större tal",
            objectives: ["Räkna till 5", "Lösa 3 + 2"]
        ),
        LevelMetadata(
            levelIndex: 2,
            title: "Äppelskörden",
            description: "Samla äpplen tillsammans",
            objectives: ["Räkna till 7", "Lösa 4 + 3"]
        ),
        LevelMetadata(
            levelIndex: 3,
            title: "Stjärnjakten",
            description: "Samla glänsande stjärnor",
            objectives: ["Räkna till 9", "Lösa 5 + 4"]
        ),
        LevelMetadata(
            levelIndex: 4,
            title: "Tio är toppen!",
            description: "Nå det magiska talet 10",
            objectives: ["Förstå talet 10", "Lösa 6 + 4"]
        ),
        LevelMetadata(
            levelIndex: 5,
            title: "Dela med dig",
            description: "Lär dig subtraktion",
            objectives: ["Förstå 'ta bort'", "Lösa 5 - 2"]
        ),
        LevelMetadata(
            levelIndex: 6,
            title: "Kakan försvann!",
            description: "Vad händer när vi äter kakor?",
            objectives: ["Räkna bakåt", "Lösa 6 - 3"]
        ),
        LevelMetadata(
            levelIndex: 7,
            title: "Ballongsmällen",
            description: "Aj! Några ballonger small!",
            objectives: ["Subtraktion med 4", "Lösa 8 - 4"]
        ),
        LevelMetadata(
            levelIndex: 8,
            title: "Fåglarna flyger",
            description: "Fåglar flyger iväg från grenen",
            objectives: ["Större subtraktion", "Lösa 9 - 5"]
        ),
        LevelMetadata(
            levelIndex: 9,
            title: "Från tio",
            description: "Räkna tillbaka från 10",
            objectives: ["Subtraktion från 10", "Lösa 10 - 7"]
        ),
        LevelMetadata(
            levelIndex: 10,
            title: "Över tiogränsen",
            description: "Nu blir det spännande - över 10!",
            objectives: ["Tiotalsövergång", "Lösa 7 + 5 = 12"]
        ),
        LevelMetadata(
            levelIndex: 11,
            title: "Dubbelt så roligt",
            description: "Fortsätt samla!",
            objectives: ["Övning i tiotalsövergång", "Lösa 8 + 6 = 14"]
        ),
        LevelMetadata(
            levelIndex: 12,
            title: "Höga tal",
            description: "Nu närmar vi oss 20!",
            objectives: ["Addition till 16", "Lösa 9 + 7"]
        ),
        LevelMetadata(
            levelIndex: 13,
            title: "Nästan där",
            description: "Snart når vi toppen!",
            objectives: ["Addition till 17", "Lösa 8 + 9"]
        ),
        LevelMetadata(
            levelIndex: 14,
            title: "Dubbelnia",
            description: "Två nior tillsammans!",
            objectives: ["Dubblor", "Lösa 9 + 9 = 18"]
        ),
        LevelMetadata(
            levelIndex: 15,
            title: "Tillbaka från tolv",
            description: "Subtraktion från tvåsiffriga tal",
            objectives: ["Subtraktion från 12", "Lösa 12 - 5"]
        ),
        LevelMetadata(
            levelIndex: 16,
            title: "Femton minus",
            description: "Svårare subtraktion",
            objectives: ["Tiotalsövergång i subtraktion", "Lösa 15 - 8"]
        ),
        LevelMetadata(
            levelIndex: 17,
            title: "Sjutton utmaning",
            description: "Du är nästan en mästare!",
            objectives: ["Avancerad subtraktion", "Lösa 17 - 9"]
        ),
        LevelMetadata(
            levelIndex: 18,
            title: "Arton adventure",
            description: "Näst sista utmaningen!",
            objectives: ["Subtraktion från 18", "Lösa 18 - 9"]
        ),
        LevelMetadata(
            levelIndex: 19,
            title: "Tjugo toppen!",
            description: "Du klarade alla nivåer i Åk1!",
            objectives: ["Mästare på 0-20", "Lösa 20 - 11"]
        )
    ]
}
