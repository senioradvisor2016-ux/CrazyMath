// NarrativeDirectorTests.swift
// MathAdventureTests
// Enhetstester för NarrativeDirector och JSON-parsing

import XCTest
@testable import MathAdventure

final class NarrativeDirectorTests: XCTestCase {
    
    var director: NarrativeDirector!
    var mockClient: MockLLMClient!
    
    override func setUpWithError() throws {
        mockClient = MockLLMClient(simulateLatency: false)
        director = NarrativeDirector(llmClient: mockClient, useLLM: true)
    }
    
    // MARK: - Scene Generation Tests
    
    func testSceneGenerationReturnsValidScene() async {
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
        
        // When
        let scene = await director.scene(for: task)
        
        // Then
        XCTAssertFalse(scene.title.isEmpty)
        XCTAssertFalse(scene.story.isEmpty)
        XCTAssertFalse(scene.instruction.isEmpty)
        XCTAssertFalse(scene.hint.isEmpty)
        XCTAssertFalse(scene.celebration.isEmpty)
    }
    
    func testFallbackSceneOnLLMFailure() async {
        // Given
        mockClient.failureRate = 1.0  // Always fail
        let task = MathTask(
            grade: .g1,
            skill: .add,
            difficulty: 1,
            seed: 1,
            promptData: ["a": 5, "b": 3],
            correctInt: 8,
            levelIndex: 0
        )
        
        // When
        let scene = await director.scene(for: task)
        
        // Then - Should return fallback, not crash
        XCTAssertFalse(scene.title.isEmpty)
        XCTAssertTrue(scene.story.contains("5") || scene.story.contains("3"))  // Should contain task numbers
    }
    
    func testOfflineModeUsesFallbackDirectly() async {
        // Given
        let offlineDirector = NarrativeDirector(llmClient: mockClient, useLLM: false)
        let task = MathTask(
            grade: .g1,
            skill: .sub,
            difficulty: 1,
            seed: 1,
            promptData: ["a": 10, "b": 4],
            correctInt: 6,
            levelIndex: 0
        )
        
        // When
        let scene = await offlineDirector.scene(for: task)
        
        // Then
        XCTAssertFalse(scene.title.isEmpty)
    }
    
    func testSceneIsCached() async {
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
        
        // When
        let scene1 = await director.scene(for: task)
        let scene2 = await director.scene(for: task)
        
        // Then - Same scene should be returned from cache
        XCTAssertEqual(scene1.title, scene2.title)
        XCTAssertEqual(scene1.story, scene2.story)
    }
    
    // MARK: - Fallback Scene Tests
    
    func testFallbackSceneForAddition() {
        let task = MathTask(
            grade: .g1,
            skill: .add,
            difficulty: 1,
            seed: 1,
            promptData: ["a": 5, "b": 3],
            correctInt: 8,
            levelIndex: 0
        )
        
        let scene = Scene.fallback(for: task)
        
        XCTAssertTrue(scene.story.contains("5"))
        XCTAssertTrue(scene.story.contains("3"))
        XCTAssertTrue(scene.isValid)
    }
    
    func testFallbackSceneForSubtraction() {
        let task = MathTask(
            grade: .g1,
            skill: .sub,
            difficulty: 1,
            seed: 1,
            promptData: ["a": 10, "b": 4],
            correctInt: 6,
            levelIndex: 0
        )
        
        let scene = Scene.fallback(for: task)
        
        XCTAssertTrue(scene.story.contains("10"))
        XCTAssertTrue(scene.story.contains("4"))
        XCTAssertTrue(scene.isValid)
    }
    
    func testFallbackSceneForMultiplication() {
        let task = MathTask(
            grade: .g3,
            skill: .mult,
            difficulty: 3,
            seed: 1,
            promptData: ["a": 4, "b": 5, "groups": 4, "perGroup": 5],
            correctInt: 20,
            levelIndex: 0
        )
        
        let scene = Scene.fallback(for: task)
        
        XCTAssertTrue(scene.story.contains("4") || scene.story.contains("5"))
        XCTAssertTrue(scene.isValid)
    }
    
    func testFallbackSceneForDivision() {
        let task = MathTask(
            grade: .g3,
            skill: .div,
            difficulty: 3,
            seed: 1,
            promptData: ["a": 20, "b": 4],
            correctInt: 5,
            levelIndex: 0
        )
        
        let scene = Scene.fallback(for: task)
        
        XCTAssertTrue(scene.story.contains("20"))
        XCTAssertTrue(scene.isValid)
    }
    
    // MARK: - Scene Validation Tests
    
    func testSceneValidationPasses() {
        let validScene = Scene(
            title: "Short title",
            story: "A short story with two sentences. Here is the second one.",
            instruction: "Do this thing.",
            choices: [],
            hint: "Here is a hint.",
            celebration: "Great job!"
        )
        
        XCTAssertTrue(validScene.isValid)
    }
    
    func testSceneTruncation() {
        let longScene = Scene(
            title: String(repeating: "a", count: 100),
            story: String(repeating: "b", count: 300),
            instruction: String(repeating: "c", count: 150),
            choices: [],
            hint: String(repeating: "d", count: 200),
            celebration: String(repeating: "e", count: 150)
        )
        
        XCTAssertFalse(longScene.isValid)
        
        let truncated = longScene.truncated()
        XCTAssertTrue(truncated.isValid)
        XCTAssertLessThanOrEqual(truncated.title.count, 60)
        XCTAssertLessThanOrEqual(truncated.story.count, 200)
    }
    
    func testAllSkillsHaveFallbackScenes() {
        for skill in Skill.allCases {
            let task = MathTask(
                grade: .g1,
                skill: skill,
                difficulty: 1,
                seed: 1,
                promptData: ["a": 5, "b": 3],
                correctInt: 8,
                levelIndex: 0
            )
            
            let scene = Scene.fallback(for: task)
            
            XCTAssertFalse(scene.title.isEmpty, "Fallback missing for skill: \(skill)")
            XCTAssertFalse(scene.story.isEmpty, "Fallback story missing for skill: \(skill)")
            XCTAssertTrue(scene.isValid, "Fallback invalid for skill: \(skill)")
        }
    }
}

// MARK: - JSON Parsing Tests

final class JSONParsingTests: XCTestCase {
    
    func testValidSceneJSONDecoding() throws {
        let json = """
        {
            "title": "Test Title",
            "story": "This is a test story.",
            "instruction": "Do this.",
            "choices": ["A", "B", "C"],
            "hint": "Here is a hint.",
            "celebration": "Well done!"
        }
        """
        
        let data = json.data(using: .utf8)!
        let scene = try JSONDecoder().decode(Scene.self, from: data)
        
        XCTAssertEqual(scene.title, "Test Title")
        XCTAssertEqual(scene.choices.count, 3)
    }
    
    func testSceneJSONDecodingWithEmptyChoices() throws {
        let json = """
        {
            "title": "Test",
            "story": "Story",
            "instruction": "Instruction",
            "choices": [],
            "hint": "Hint",
            "celebration": "Celebration"
        }
        """
        
        let data = json.data(using: .utf8)!
        let scene = try JSONDecoder().decode(Scene.self, from: data)
        
        XCTAssertTrue(scene.choices.isEmpty)
    }
    
    func testMathTaskEncoding() throws {
        let task = MathTask(
            grade: .g1,
            skill: .add,
            difficulty: 5,
            seed: 123,
            promptData: ["a": 5, "b": 3],
            correctInt: 8,
            levelIndex: 0
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(task)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(MathTask.self, from: data)
        
        XCTAssertEqual(decoded.grade, task.grade)
        XCTAssertEqual(decoded.skill, task.skill)
        XCTAssertEqual(decoded.difficulty, task.difficulty)
        XCTAssertEqual(decoded.correctInt, task.correctInt)
    }
    
    func testInvalidJSONFails() {
        let invalidJSON = "{ not valid json }"
        let data = invalidJSON.data(using: .utf8)!
        
        XCTAssertThrowsError(try JSONDecoder().decode(Scene.self, from: data))
    }
    
    func testMissingFieldsFails() {
        let incompleteJSON = """
        {
            "title": "Test"
        }
        """
        let data = incompleteJSON.data(using: .utf8)!
        
        XCTAssertThrowsError(try JSONDecoder().decode(Scene.self, from: data))
    }
}

// MARK: - MockLLMClient Tests

final class MockLLMClientTests: XCTestCase {
    
    func testMockClientReturnsJSON() async throws {
        let client = MockLLMClient(simulateLatency: false)
        
        let response = try await client.complete(prompt: "Test prompt about addition with a=5 b=3")
        
        // Should return valid JSON
        XCTAssertTrue(response.contains("{"))
        XCTAssertTrue(response.contains("}"))
    }
    
    func testMockClientFailureRate() async {
        let client = MockLLMClient(simulateLatency: false, failureRate: 1.0)
        
        do {
            _ = try await client.complete(prompt: "Test")
            XCTFail("Should have thrown an error")
        } catch {
            // Expected
            XCTAssertTrue(error is LLMError)
        }
    }
    
    func testMockClientRecognizesSkills() async throws {
        let client = MockLLMClient(simulateLatency: false)
        
        // Addition
        let addResponse = try await client.complete(prompt: "addition with a=5 b=3")
        XCTAssertTrue(addResponse.contains("title"))
        
        // Subtraction
        let subResponse = try await client.complete(prompt: "subtraction with a=10 b=4")
        XCTAssertTrue(subResponse.contains("title"))
        
        // Multiplication
        let multResponse = try await client.complete(prompt: "multiplication with groups=3 perGroup=4")
        XCTAssertTrue(multResponse.contains("title"))
        
        // Division
        let divResponse = try await client.complete(prompt: "division with a=12 b=3")
        XCTAssertTrue(divResponse.contains("title"))
    }
}

// MARK: - Child Safety Tests

final class ChildSafetyTests: XCTestCase {
    
    func testFallbackScenesAreChildSafe() {
        for skill in Skill.allCases {
            let task = MathTask(
                grade: .g1,
                skill: skill,
                difficulty: 1,
                seed: 1,
                promptData: ["a": 5, "b": 3],
                correctInt: 8,
                levelIndex: 0
            )
            
            let scene = Scene.fallback(for: task)
            
            // No URLs
            XCTAssertFalse(scene.story.contains("http"))
            XCTAssertFalse(scene.story.contains("www."))
            
            // No email patterns
            XCTAssertFalse(scene.story.contains("@"))
            
            // No personal data requests
            let personalKeywords = ["namn", "ålder", "adress", "telefon", "email"]
            for keyword in personalKeywords {
                XCTAssertFalse(
                    scene.instruction.lowercased().contains(keyword),
                    "Scene should not ask for personal info: \(keyword)"
                )
            }
        }
    }
    
    func testSceneSchemaLimits() {
        XCTAssertEqual(SceneSchema.maxTitleLength, 60)
        XCTAssertEqual(SceneSchema.maxStoryLength, 200)
        XCTAssertEqual(SceneSchema.maxInstructionLength, 100)
        XCTAssertEqual(SceneSchema.maxHintLength, 140)
        XCTAssertEqual(SceneSchema.maxCelebrationLength, 100)
        XCTAssertLessThanOrEqual(SceneSchema.maxTotalLength, 1000)
    }
}
