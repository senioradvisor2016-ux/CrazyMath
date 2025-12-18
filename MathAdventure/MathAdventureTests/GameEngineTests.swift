// GameEngineTests.swift
// MathAdventureTests
// Enhetstester för GameEngine

import XCTest
@testable import MathAdventure

final class GameEngineTests: XCTestCase {
    
    var engine: GameEngine!
    
    override func setUpWithError() throws {
        engine = GameEngine.shared
    }
    
    // MARK: - Task Generation Tests
    
    func testMakeTaskReturnsValidTask() {
        // Given
        let grade = GradeBand.g1
        let mastery = 0.5
        
        // When
        let task = engine.makeTask(for: grade, mastery: mastery)
        
        // Then
        XCTAssertEqual(task.grade, grade)
        XCTAssertTrue(task.difficulty >= 1 && task.difficulty <= 10)
        XCTAssertNotNil(task.correctInt)
    }
    
    func testMakeTaskWithSpecificSkill() {
        // Given
        let grade = GradeBand.g1
        let skill = Skill.add
        
        // When
        let task = engine.makeTask(for: grade, skill: skill, mastery: 0.5)
        
        // Then
        XCTAssertEqual(task.skill, skill)
    }
    
    func testMakeTaskIsDeterministicWithSeed() {
        // Given
        let grade = GradeBand.g1
        let seed = 12345
        
        // When
        let task1 = engine.makeTask(for: grade, skill: .add, mastery: 0.5, seed: seed)
        let task2 = engine.makeTask(for: grade, skill: .add, mastery: 0.5, seed: seed)
        
        // Then
        XCTAssertEqual(task1.a, task2.a)
        XCTAssertEqual(task1.b, task2.b)
        XCTAssertEqual(task1.correctInt, task2.correctInt)
    }
    
    func testMakeTaskDifficultyAffectsRange() {
        // Given
        let grade = GradeBand.g1
        
        // When - Generate many tasks at different mastery levels
        var lowMasteryTasks: [MathTask] = []
        var highMasteryTasks: [MathTask] = []
        
        for i in 0..<20 {
            lowMasteryTasks.append(engine.makeTask(for: grade, skill: .add, mastery: 0.1, seed: i))
            highMasteryTasks.append(engine.makeTask(for: grade, skill: .add, mastery: 0.9, seed: i + 1000))
        }
        
        // Then - High mastery should generally have higher difficulty
        let avgLowDifficulty = Double(lowMasteryTasks.map { $0.difficulty }.reduce(0, +)) / Double(lowMasteryTasks.count)
        let avgHighDifficulty = Double(highMasteryTasks.map { $0.difficulty }.reduce(0, +)) / Double(highMasteryTasks.count)
        
        XCTAssertLessThan(avgLowDifficulty, avgHighDifficulty)
    }
    
    // MARK: - Verification Tests
    
    func testVerifyAdditionCorrect() {
        // Given
        let task = MathTask(
            grade: .g1,
            skill: .add,
            difficulty: 1,
            seed: 1,
            promptData: ["a": 5, "b": 3],
            correctInt: 8,
            levelIndex: 0
        )
        let answer = PlayerAnswer(int: 8)
        
        // When
        let result = engine.verify(task: task, answer: answer)
        
        // Then
        XCTAssertTrue(result)
    }
    
    func testVerifyAdditionIncorrect() {
        // Given
        let task = MathTask(
            grade: .g1,
            skill: .add,
            difficulty: 1,
            seed: 1,
            promptData: ["a": 5, "b": 3],
            correctInt: 8,
            levelIndex: 0
        )
        let answer = PlayerAnswer(int: 7)
        
        // When
        let result = engine.verify(task: task, answer: answer)
        
        // Then
        XCTAssertFalse(result)
    }
    
    func testVerifySubtractionCorrect() {
        // Given
        let task = MathTask(
            grade: .g1,
            skill: .sub,
            difficulty: 1,
            seed: 1,
            promptData: ["a": 10, "b": 4],
            correctInt: 6,
            levelIndex: 0
        )
        let answer = PlayerAnswer(int: 6)
        
        // When
        let result = engine.verify(task: task, answer: answer)
        
        // Then
        XCTAssertTrue(result)
    }
    
    func testVerifyMultiplicationCorrect() {
        // Given
        let task = MathTask(
            grade: .g3,
            skill: .mult,
            difficulty: 3,
            seed: 1,
            promptData: ["a": 4, "b": 5, "groups": 4, "perGroup": 5],
            correctInt: 20,
            levelIndex: 0
        )
        let answer = PlayerAnswer(int: 20)
        
        // When
        let result = engine.verify(task: task, answer: answer)
        
        // Then
        XCTAssertTrue(result)
    }
    
    func testVerifyDivisionCorrect() {
        // Given
        let task = MathTask(
            grade: .g3,
            skill: .div,
            difficulty: 3,
            seed: 1,
            promptData: ["a": 20, "b": 4],
            correctInt: 5,
            levelIndex: 0
        )
        let answer = PlayerAnswer(int: 5)
        
        // When
        let result = engine.verify(task: task, answer: answer)
        
        // Then
        XCTAssertTrue(result)
    }
    
    func testVerifyDivisionByZeroReturnsFalse() {
        // Given
        let task = MathTask(
            grade: .g3,
            skill: .div,
            difficulty: 3,
            seed: 1,
            promptData: ["a": 10, "b": 0],
            correctInt: 0,
            levelIndex: 0
        )
        let answer = PlayerAnswer(int: 0)
        
        // When
        let result = engine.verify(task: task, answer: answer)
        
        // Then
        XCTAssertFalse(result)
    }
    
    func testVerifyFractionCorrect() {
        // Given
        let task = MathTask(
            grade: .g5,
            skill: .fractions,
            difficulty: 4,
            seed: 1,
            promptData: ["numerator": 2, "denominator": 4],
            correctFraction: FractionValue(numerator: 2, denominator: 4),
            levelIndex: 0
        )
        
        // Answer is equivalent (simplified)
        let answer = PlayerAnswer(fraction: FractionValue(numerator: 1, denominator: 2))
        
        // When
        let result = engine.verify(task: task, answer: answer)
        
        // Then
        XCTAssertTrue(result)
    }
    
    // MARK: - Mastery Update Tests
    
    func testUpdateMasteryIncreasesOnCorrectAnswer() {
        // Given
        let task = MathTask(
            grade: .g1,
            skill: .add,
            difficulty: 5,
            seed: 1,
            promptData: ["a": 5, "b": 3],
            correctInt: 8,
            levelIndex: 0
        )
        let currentMastery = 0.5
        
        // When
        let newMastery = engine.updateMastery(
            currentMastery: currentMastery,
            task: task,
            correct: true,
            responseTimeMs: 2000
        )
        
        // Then
        XCTAssertGreaterThan(newMastery, currentMastery)
    }
    
    func testUpdateMasteryDecreasesOnIncorrectAnswer() {
        // Given
        let task = MathTask(
            grade: .g1,
            skill: .add,
            difficulty: 5,
            seed: 1,
            promptData: ["a": 5, "b": 3],
            correctInt: 8,
            levelIndex: 0
        )
        let currentMastery = 0.5
        
        // When
        let newMastery = engine.updateMastery(
            currentMastery: currentMastery,
            task: task,
            correct: false,
            responseTimeMs: 2000
        )
        
        // Then
        XCTAssertLessThan(newMastery, currentMastery)
    }
    
    func testUpdateMasteryStaysWithinBounds() {
        // Given
        let task = MathTask(
            grade: .g1,
            skill: .add,
            difficulty: 10,
            seed: 1,
            promptData: ["a": 5, "b": 3],
            correctInt: 8,
            levelIndex: 0
        )
        
        // When - Try to exceed max
        var mastery = 0.95
        for _ in 0..<100 {
            mastery = engine.updateMastery(
                currentMastery: mastery,
                task: task,
                correct: true,
                responseTimeMs: 1000
            )
        }
        
        // Then
        XCTAssertLessThanOrEqual(mastery, 1.0)
        
        // When - Try to go below min
        mastery = 0.05
        for _ in 0..<100 {
            mastery = engine.updateMastery(
                currentMastery: mastery,
                task: task,
                correct: false,
                responseTimeMs: 1000
            )
        }
        
        // Then
        XCTAssertGreaterThanOrEqual(mastery, 0.0)
    }
    
    func testUpdateMasteryFastResponseGivesBonus() {
        // Given
        let task = MathTask(
            grade: .g1,
            skill: .add,
            difficulty: 5,
            seed: 1,
            promptData: ["a": 5, "b": 3],
            correctInt: 8,
            levelIndex: 0
        )
        let currentMastery = 0.5
        
        // When
        let fastMastery = engine.updateMastery(
            currentMastery: currentMastery,
            task: task,
            correct: true,
            responseTimeMs: 1000  // Fast
        )
        
        let slowMastery = engine.updateMastery(
            currentMastery: currentMastery,
            task: task,
            correct: true,
            responseTimeMs: 20000  // Slow
        )
        
        // Then
        XCTAssertGreaterThan(fastMastery, slowMastery)
    }
    
    // MARK: - Grade 1 Specific Tests
    
    func testGrade1AdditionResultsWithin20() {
        // When
        for i in 0..<50 {
            let task = engine.makeTask(for: .g1, skill: .add, mastery: 0.5, seed: i)
            
            // Then
            XCTAssertNotNil(task.correctInt)
            XCTAssertLessThanOrEqual(task.correctInt!, 20, "Addition result should be ≤ 20 for grade 1")
            XCTAssertGreaterThanOrEqual(task.correctInt!, 0)
        }
    }
    
    func testGrade1SubtractionResultsNonNegative() {
        // When
        for i in 0..<50 {
            let task = engine.makeTask(for: .g1, skill: .sub, mastery: 0.5, seed: i)
            
            // Then
            XCTAssertNotNil(task.correctInt)
            XCTAssertGreaterThanOrEqual(task.correctInt!, 0, "Subtraction result should be ≥ 0 for grade 1")
        }
    }
}

// MARK: - MasteryModel Tests

final class MasteryModelTests: XCTestCase {
    
    func testRecommendDifficultyBasedOnMastery() {
        // Low mastery -> low difficulty
        XCTAssertEqual(MasteryModel.recommendDifficulty(mastery: 0.0), 1)
        
        // Mid mastery -> mid difficulty
        let midDifficulty = MasteryModel.recommendDifficulty(mastery: 0.5)
        XCTAssertTrue(midDifficulty >= 4 && midDifficulty <= 6)
        
        // High mastery -> high difficulty
        XCTAssertEqual(MasteryModel.recommendDifficulty(mastery: 1.0), 10)
    }
    
    func testRecommendDifficultyAdjustsForRecentPerformance() {
        // Good recent performance should increase difficulty
        let highPerformance = MasteryModel.recommendDifficulty(
            mastery: 0.5,
            recentCorrect: 5,
            recentTotal: 5
        )
        
        // Poor recent performance should decrease difficulty
        let lowPerformance = MasteryModel.recommendDifficulty(
            mastery: 0.5,
            recentCorrect: 1,
            recentTotal: 5
        )
        
        XCTAssertGreaterThan(highPerformance, lowPerformance)
    }
    
    func testCalculateStarsFirstAttempt() {
        let stars = MasteryModel.calculateStars(
            correct: true,
            attemptCount: 1,
            responseTimeMs: 2000,
            difficulty: 5
        )
        
        XCTAssertEqual(stars, 3)
    }
    
    func testCalculateStarsMultipleAttempts() {
        let stars = MasteryModel.calculateStars(
            correct: true,
            attemptCount: 3,
            responseTimeMs: 2000,
            difficulty: 5
        )
        
        XCTAssertEqual(stars, 2)
    }
    
    func testCalculateStarsIncorrect() {
        let stars = MasteryModel.calculateStars(
            correct: false,
            attemptCount: 1,
            responseTimeMs: 2000,
            difficulty: 5
        )
        
        XCTAssertEqual(stars, 0)
    }
    
    func testSuggestRepresentationProgression() {
        let task = MathTask(
            grade: .g1,
            skill: .add,
            difficulty: 1,
            seed: 1,
            promptData: ["a": 1, "b": 1],
            correctInt: 2,
            levelIndex: 0
        )
        
        XCTAssertEqual(MasteryModel.suggestRepresentation(for: task, attemptCount: 0), .symbolic)
        XCTAssertEqual(MasteryModel.suggestRepresentation(for: task, attemptCount: 1), .visual)
        XCTAssertEqual(MasteryModel.suggestRepresentation(for: task, attemptCount: 2), .concrete)
        XCTAssertEqual(MasteryModel.suggestRepresentation(for: task, attemptCount: 3), .guided)
    }
}

// MARK: - FractionValue Tests

final class FractionValueTests: XCTestCase {
    
    func testFractionSimplification() {
        let fraction = FractionValue(numerator: 4, denominator: 8)
        let simplified = fraction.simplified
        
        XCTAssertEqual(simplified.numerator, 1)
        XCTAssertEqual(simplified.denominator, 2)
    }
    
    func testFractionDecimalValue() {
        let fraction = FractionValue(numerator: 1, denominator: 4)
        
        XCTAssertEqual(fraction.decimalValue, 0.25, accuracy: 0.001)
    }
    
    func testFractionDisplayString() {
        let fraction = FractionValue(numerator: 3, denominator: 4)
        
        XCTAssertEqual(fraction.displayString, "3/4")
    }
    
    func testEquivalentFractionsSimplifyToSame() {
        let frac1 = FractionValue(numerator: 2, denominator: 4)
        let frac2 = FractionValue(numerator: 3, denominator: 6)
        
        XCTAssertEqual(frac1.simplified, frac2.simplified)
    }
}

// MARK: - PlayerProfile Tests

final class PlayerProfileTests: XCTestCase {
    
    func testNewProfileHasDefaultValues() {
        let profile = PlayerProfile(name: "Test")
        
        XCTAssertEqual(profile.name, "Test")
        XCTAssertEqual(profile.currentGrade, .g1)
        XCTAssertEqual(profile.totalStars, 0)
        XCTAssertEqual(profile.streakDays, 0)
    }
    
    func testMasteryDefaultsToZero() {
        let profile = PlayerProfile()
        
        for skill in Skill.allCases {
            XCTAssertEqual(profile.mastery(for: skill), 0.0)
        }
    }
    
    func testCompleteLevelUpdatesProfile() {
        var profile = PlayerProfile()
        
        profile.completeLevelAndUpdateProfile(
            grade: .g1,
            levelIndex: 0,
            skill: .add,
            earnedStars: 3,
            newMastery: 0.6
        )
        
        XCTAssertTrue(profile.isLevelCompleted(grade: .g1, levelIndex: 0))
        XCTAssertEqual(profile.mastery(for: .add), 0.6)
        XCTAssertEqual(profile.totalStars, 3)
    }
    
    func testLevelUnlockProgression() {
        var profile = PlayerProfile()
        
        // First level always unlocked
        XCTAssertTrue(profile.isLevelUnlocked(grade: .g1, levelIndex: 0))
        
        // Second level not unlocked
        XCTAssertFalse(profile.isLevelUnlocked(grade: .g1, levelIndex: 1))
        
        // Complete first level
        profile.completeLevelAndUpdateProfile(
            grade: .g1,
            levelIndex: 0,
            skill: .add,
            earnedStars: 1,
            newMastery: 0.5
        )
        
        // Now second level is unlocked
        XCTAssertTrue(profile.isLevelUnlocked(grade: .g1, levelIndex: 1))
    }
    
    func testRecommendedDifficultyBasedOnMastery() {
        var profile = PlayerProfile()
        
        // Low mastery
        XCTAssertEqual(profile.recommendedDifficulty(for: .add), 1)
        
        // Set higher mastery
        profile.masteryScores[.add] = 0.8
        XCTAssertGreaterThan(profile.recommendedDifficulty(for: .add), 5)
    }
}
