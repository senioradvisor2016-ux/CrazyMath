// GameEngine.swift
// MathAdventure
// Huvudmotor för matematikverifiering och task-generering

import Foundation

/// Huvudmotor som hanterar all matematik-logik lokalt
/// LLM får ALDRIG påverka vad som är rätt eller fel
final class GameEngine {
    
    // MARK: - Singleton
    
    static let shared = GameEngine()
    private init() {}
    
    // MARK: - Task Generation
    
    /// Genererar en matematisk uppgift baserat på årskurs och mastery
    /// - Parameters:
    ///   - grade: Årskurs
    ///   - skill: Specifik färdighet (eller nil för random)
    ///   - mastery: Nuvarande mastery för spelaren
    ///   - levelIndex: Nivåindex i världen
    ///   - seed: Valfri seed för deterministisk generering
    /// - Returns: En MathTask
    func makeTask(
        for grade: GradeBand,
        skill: Skill? = nil,
        mastery: Double = 0.5,
        levelIndex: Int = 0,
        seed: Int? = nil
    ) -> MathTask {
        let actualSeed = seed ?? Int.random(in: 0..<Int.max)
        var rng = SeededRandomNumberGenerator(seed: UInt64(actualSeed))
        
        // Bestäm skill om inte angiven
        let chosenSkill = skill ?? grade.primarySkills.randomElement(using: &rng) ?? .add
        
        // Bestäm svårighet baserat på mastery och levelIndex
        let baseDifficulty = MasteryModel.recommendDifficulty(mastery: mastery)
        let levelAdjust = min(levelIndex / 4, 3)  // +0 till +3 baserat på level
        let difficulty = max(1, min(10, baseDifficulty + levelAdjust))
        
        // Generera uppgift baserat på skill och grade
        switch chosenSkill {
        case .add:
            return generateAdditionTask(grade: grade, difficulty: difficulty, seed: actualSeed, levelIndex: levelIndex, rng: &rng)
        case .sub:
            return generateSubtractionTask(grade: grade, difficulty: difficulty, seed: actualSeed, levelIndex: levelIndex, rng: &rng)
        case .mult:
            return generateMultiplicationTask(grade: grade, difficulty: difficulty, seed: actualSeed, levelIndex: levelIndex, rng: &rng)
        case .div:
            return generateDivisionTask(grade: grade, difficulty: difficulty, seed: actualSeed, levelIndex: levelIndex, rng: &rng)
        case .fractions:
            return generateFractionTask(grade: grade, difficulty: difficulty, seed: actualSeed, levelIndex: levelIndex, rng: &rng)
        case .decimals:
            return generateDecimalTask(grade: grade, difficulty: difficulty, seed: actualSeed, levelIndex: levelIndex, rng: &rng)
        case .percent:
            return generatePercentTask(grade: grade, difficulty: difficulty, seed: actualSeed, levelIndex: levelIndex, rng: &rng)
        default:
            // Fallback till addition för oimplementerade skills
            return generateAdditionTask(grade: grade, difficulty: difficulty, seed: actualSeed, levelIndex: levelIndex, rng: &rng)
        }
    }
    
    // MARK: - Addition
    
    private func generateAdditionTask(
        grade: GradeBand,
        difficulty: Int,
        seed: Int,
        levelIndex: Int,
        rng: inout SeededRandomNumberGenerator
    ) -> MathTask {
        var a: Int
        var b: Int
        
        switch grade {
        case .g1:
            // Åk 1: Resultat 0-20
            let maxSum = min(10 + difficulty, 20)
            a = Int.random(in: 1...max(1, maxSum - 1), using: &rng)
            b = Int.random(in: 0...max(0, maxSum - a), using: &rng)
            
            // Högre svårighet = mer chans för "carry" (över 10)
            if difficulty >= 5 && a + b < 10 {
                a = Int.random(in: 5...9, using: &rng)
                b = Int.random(in: max(1, 11 - a)...min(11, 20 - a), using: &rng)
            }
            
        case .g2:
            // Åk 2: Resultat 0-100
            let maxSum = min(20 + difficulty * 8, 100)
            a = Int.random(in: 1...max(1, maxSum - 1), using: &rng)
            b = Int.random(in: 0...max(0, maxSum - a), using: &rng)
            
        case .g3, .g4:
            // Åk 3-4: Större tal
            let maxSum = min(100 + difficulty * 50, 1000)
            a = Int.random(in: 10...max(10, maxSum / 2), using: &rng)
            b = Int.random(in: 0...max(0, maxSum - a), using: &rng)
            
        case .g5, .g6:
            // Åk 5-6: Ännu större
            let maxSum = min(1000 + difficulty * 500, 10000)
            a = Int.random(in: 100...max(100, maxSum / 2), using: &rng)
            b = Int.random(in: 0...max(0, maxSum - a), using: &rng)
        }
        
        let correct = a + b
        
        return MathTask(
            grade: grade,
            skill: .add,
            difficulty: difficulty,
            seed: seed,
            promptData: ["a": a, "b": b],
            correctInt: correct,
            levelIndex: levelIndex
        )
    }
    
    // MARK: - Subtraction
    
    private func generateSubtractionTask(
        grade: GradeBand,
        difficulty: Int,
        seed: Int,
        levelIndex: Int,
        rng: inout SeededRandomNumberGenerator
    ) -> MathTask {
        var a: Int
        var b: Int
        
        switch grade {
        case .g1:
            // Åk 1: a ≤ 20, resultat ≥ 0
            let maxA = min(10 + difficulty, 20)
            a = Int.random(in: 1...maxA, using: &rng)
            b = Int.random(in: 0...a, using: &rng)
            
        case .g2:
            // Åk 2: a ≤ 100
            let maxA = min(20 + difficulty * 8, 100)
            a = Int.random(in: 5...maxA, using: &rng)
            b = Int.random(in: 0...a, using: &rng)
            
        case .g3, .g4:
            let maxA = min(100 + difficulty * 50, 1000)
            a = Int.random(in: 20...maxA, using: &rng)
            b = Int.random(in: 0...a, using: &rng)
            
        case .g5, .g6:
            let maxA = min(1000 + difficulty * 500, 10000)
            a = Int.random(in: 100...maxA, using: &rng)
            b = Int.random(in: 0...a, using: &rng)
        }
        
        let correct = a - b
        
        return MathTask(
            grade: grade,
            skill: .sub,
            difficulty: difficulty,
            seed: seed,
            promptData: ["a": a, "b": b],
            correctInt: correct,
            levelIndex: levelIndex
        )
    }
    
    // MARK: - Multiplication
    
    private func generateMultiplicationTask(
        grade: GradeBand,
        difficulty: Int,
        seed: Int,
        levelIndex: Int,
        rng: inout SeededRandomNumberGenerator
    ) -> MathTask {
        var groups: Int
        var perGroup: Int
        
        switch grade {
        case .g1, .g2:
            // Åk 1-2: Enkel "upprepad addition"
            groups = Int.random(in: 2...min(5, 2 + difficulty / 2), using: &rng)
            perGroup = Int.random(in: 2...min(5, 2 + difficulty / 2), using: &rng)
            
        case .g3:
            // Åk 3: Multiplikationstabeller 1-10
            let maxFactor = min(4 + difficulty / 2, 10)
            groups = Int.random(in: 2...maxFactor, using: &rng)
            perGroup = Int.random(in: 2...maxFactor, using: &rng)
            
        case .g4:
            // Åk 4: Större tal
            let maxFactor = min(5 + difficulty, 12)
            groups = Int.random(in: 2...maxFactor, using: &rng)
            perGroup = Int.random(in: 2...maxFactor, using: &rng)
            
        case .g5, .g6:
            // Åk 5-6: Tvåsiffriga
            groups = Int.random(in: 10...min(20 + difficulty * 3, 50), using: &rng)
            perGroup = Int.random(in: 2...min(5 + difficulty, 20), using: &rng)
        }
        
        let correct = groups * perGroup
        
        return MathTask(
            grade: grade,
            skill: .mult,
            difficulty: difficulty,
            seed: seed,
            promptData: ["a": groups, "b": perGroup, "groups": groups, "perGroup": perGroup],
            correctInt: correct,
            levelIndex: levelIndex
        )
    }
    
    // MARK: - Division
    
    private func generateDivisionTask(
        grade: GradeBand,
        difficulty: Int,
        seed: Int,
        levelIndex: Int,
        rng: inout SeededRandomNumberGenerator
    ) -> MathTask {
        var dividend: Int
        var divisor: Int
        
        switch grade {
        case .g1, .g2:
            // Enkel delning (resultat 1-5)
            let quotient = Int.random(in: 1...min(5, 2 + difficulty / 2), using: &rng)
            divisor = Int.random(in: 2...min(5, 2 + difficulty / 2), using: &rng)
            dividend = quotient * divisor
            
        case .g3:
            // Åk 3: Delning inom tabellerna
            let quotient = Int.random(in: 1...min(10, 3 + difficulty), using: &rng)
            divisor = Int.random(in: 2...min(10, 3 + difficulty), using: &rng)
            dividend = quotient * divisor
            
        case .g4:
            let quotient = Int.random(in: 2...min(12, 4 + difficulty), using: &rng)
            divisor = Int.random(in: 2...min(12, 4 + difficulty), using: &rng)
            dividend = quotient * divisor
            
        case .g5, .g6:
            let quotient = Int.random(in: 5...min(50, 10 + difficulty * 4), using: &rng)
            divisor = Int.random(in: 2...min(20, 5 + difficulty * 2), using: &rng)
            dividend = quotient * divisor
        }
        
        let correct = dividend / divisor
        
        return MathTask(
            grade: grade,
            skill: .div,
            difficulty: difficulty,
            seed: seed,
            promptData: ["a": dividend, "b": divisor],
            correctInt: correct,
            levelIndex: levelIndex
        )
    }
    
    // MARK: - Fractions
    
    private func generateFractionTask(
        grade: GradeBand,
        difficulty: Int,
        seed: Int,
        levelIndex: Int,
        rng: inout SeededRandomNumberGenerator
    ) -> MathTask {
        // Enkel bråk-identifiering
        let denominators = [2, 3, 4, 5, 6, 8, 10]
        let maxDenomIndex = min(difficulty / 2, denominators.count - 1)
        let denominator = denominators[Int.random(in: 0...maxDenomIndex, using: &rng)]
        let numerator = Int.random(in: 1..<denominator, using: &rng)
        
        return MathTask(
            grade: grade,
            skill: .fractions,
            difficulty: difficulty,
            seed: seed,
            promptData: ["numerator": numerator, "denominator": denominator],
            correctFraction: FractionValue(numerator: numerator, denominator: denominator),
            levelIndex: levelIndex
        )
    }
    
    // MARK: - Decimals
    
    private func generateDecimalTask(
        grade: GradeBand,
        difficulty: Int,
        seed: Int,
        levelIndex: Int,
        rng: inout SeededRandomNumberGenerator
    ) -> MathTask {
        // Konvertering bråk -> decimal eller tvärtom
        let denominators = [10, 100]
        let denominator = denominators[min(difficulty / 5, 1)]
        let numerator = Int.random(in: 1..<denominator, using: &rng)
        
        // correctInt representerar decimal * 100 för precision
        let decimalValue = numerator * (100 / denominator)
        
        return MathTask(
            grade: grade,
            skill: .decimals,
            difficulty: difficulty,
            seed: seed,
            promptData: ["numerator": numerator, "denominator": denominator, "decimalValue": decimalValue],
            correctInt: decimalValue,
            levelIndex: levelIndex
        )
    }
    
    // MARK: - Percent
    
    private func generatePercentTask(
        grade: GradeBand,
        difficulty: Int,
        seed: Int,
        levelIndex: Int,
        rng: inout SeededRandomNumberGenerator
    ) -> MathTask {
        // Enkla procentsatser
        let percentages = [10, 20, 25, 50, 75, 100]
        let maxIndex = min(difficulty / 2, percentages.count - 1)
        let percent = percentages[Int.random(in: 0...maxIndex, using: &rng)]
        
        return MathTask(
            grade: grade,
            skill: .percent,
            difficulty: difficulty,
            seed: seed,
            promptData: ["percent": percent],
            correctInt: percent,
            levelIndex: levelIndex
        )
    }
    
    // MARK: - Verification
    
    /// Verifierar spelarens svar mot det korrekta svaret
    /// KRITISK: All matematisk verifiering sker här, ALDRIG i LLM
    /// - Parameters:
    ///   - task: Uppgiften
    ///   - answer: Spelarens svar
    /// - Returns: true om svaret är korrekt
    func verify(task: MathTask, answer: PlayerAnswer) -> Bool {
        switch task.skill {
        case .add:
            return verifyAddition(task: task, answer: answer)
        case .sub:
            return verifySubtraction(task: task, answer: answer)
        case .mult:
            return verifyMultiplication(task: task, answer: answer)
        case .div:
            return verifyDivision(task: task, answer: answer)
        case .fractions:
            return verifyFraction(task: task, answer: answer)
        case .decimals:
            return verifyDecimal(task: task, answer: answer)
        case .percent:
            return verifyPercent(task: task, answer: answer)
        default:
            // Fallback - jämför direkt med correctInt
            if let correct = task.correctInt, let playerAnswer = answer.intValue {
                return correct == playerAnswer
            }
            return false
        }
    }
    
    private func verifyAddition(task: MathTask, answer: PlayerAnswer) -> Bool {
        let a = task.a
        let b = task.b
        let correct = a + b
        return answer.intValue == correct
    }
    
    private func verifySubtraction(task: MathTask, answer: PlayerAnswer) -> Bool {
        let a = task.a
        let b = task.b
        let correct = a - b
        return answer.intValue == correct
    }
    
    private func verifyMultiplication(task: MathTask, answer: PlayerAnswer) -> Bool {
        let a = task.a
        let b = task.b
        let correct = a * b
        return answer.intValue == correct
    }
    
    private func verifyDivision(task: MathTask, answer: PlayerAnswer) -> Bool {
        let a = task.a
        let b = task.b
        guard b != 0 else { return false }
        let correct = a / b
        return answer.intValue == correct
    }
    
    private func verifyFraction(task: MathTask, answer: PlayerAnswer) -> Bool {
        guard let correctFrac = task.correctFraction,
              let playerFrac = answer.fractionValue else {
            return false
        }
        
        // Jämför förenklat
        let correctSimplified = correctFrac.simplified
        let playerSimplified = playerFrac.simplified
        
        return correctSimplified == playerSimplified
    }
    
    private func verifyDecimal(task: MathTask, answer: PlayerAnswer) -> Bool {
        // Decimaltal lagras som heltal * 100
        guard let correct = task.correctInt,
              let playerAnswer = answer.intValue else {
            return false
        }
        return correct == playerAnswer
    }
    
    private func verifyPercent(task: MathTask, answer: PlayerAnswer) -> Bool {
        guard let correct = task.correctInt,
              let playerAnswer = answer.intValue else {
            return false
        }
        return correct == playerAnswer
    }
    
    // MARK: - Mastery Update
    
    /// Uppdaterar mastery efter ett svar
    /// - Parameters:
    ///   - currentMastery: Nuvarande mastery för skill
    ///   - task: Uppgiften
    ///   - correct: Om svaret var korrekt
    ///   - responseTimeMs: Svarstid i millisekunder
    /// - Returns: Ny mastery-nivå
    func updateMastery(
        currentMastery: Double,
        task: MathTask,
        correct: Bool,
        responseTimeMs: Int
    ) -> Double {
        return MasteryModel.updateMastery(
            currentMastery: currentMastery,
            task: task,
            correct: correct,
            responseTimeMs: responseTimeMs
        )
    }
}

// MARK: - Seeded Random Number Generator

/// Deterministic random number generator för reproducerbara tasks
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64
    
    init(seed: UInt64) {
        self.state = seed
    }
    
    mutating func next() -> UInt64 {
        // Xorshift64
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}
