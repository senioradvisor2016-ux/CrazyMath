// MockLLMClient.swift
// MathAdventure
// Mock-klient för testning och utveckling

import Foundation

/// Mock LLM-klient som returnerar fördefinierade svar
/// Perfekt för utveckling, testning, och offline-spel
final class MockLLMClient: LLMClient {
    
    /// Om mock ska simulera nätverkslatens
    var simulateLatency: Bool = true
    
    /// Om mock ska ibland misslyckas (för att testa error handling)
    var failureRate: Double = 0.0
    
    /// Latensintervall i sekunder
    var latencyRange: ClosedRange<Double> = 0.1...0.5
    
    init(simulateLatency: Bool = true, failureRate: Double = 0.0) {
        self.simulateLatency = simulateLatency
        self.failureRate = failureRate
    }
    
    func complete(prompt: String) async throws -> String {
        // Simulera latens
        if simulateLatency {
            let delay = Double.random(in: latencyRange)
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        // Simulera fel ibland
        if Double.random(in: 0...1) < failureRate {
            throw LLMError.networkError(underlying: NSError(domain: "Mock", code: -1))
        }
        
        // Försök parsa uppgiften från prompten och skapa passande svar
        return generateMockResponse(for: prompt)
    }
    
    private func generateMockResponse(for prompt: String) -> String {
        // Försök identifiera vilken typ av uppgift det är
        let lowercased = prompt.lowercased()
        
        // Extrahera siffror från prompten
        let numbers = extractNumbers(from: prompt)
        let a = numbers.count > 0 ? numbers[0] : 5
        let b = numbers.count > 1 ? numbers[1] : 3
        
        if lowercased.contains("addition") || lowercased.contains("plus") || lowercased.contains("add") {
            return generateAdditionScene(a: a, b: b)
        } else if lowercased.contains("subtra") || lowercased.contains("minus") || lowercased.contains("sub") {
            return generateSubtractionScene(a: a, b: b)
        } else if lowercased.contains("multipli") || lowercased.contains("mult") || lowercased.contains("gånger") {
            return generateMultiplicationScene(a: a, b: b)
        } else if lowercased.contains("divis") || lowercased.contains("div") || lowercased.contains("dela") {
            return generateDivisionScene(a: a, b: b)
        } else {
            return generateGenericScene(a: a, b: b)
        }
    }
    
    private func extractNumbers(from text: String) -> [Int] {
        let pattern = "\\b\\d+\\b"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let range = NSRange(text.startIndex..., in: text)
        let matches = regex.matches(in: text, range: range)
        
        return matches.compactMap { match in
            guard let range = Range(match.range, in: text) else { return nil }
            return Int(text[range])
        }
    }
    
    private func generateAdditionScene(a: Int, b: Int) -> String {
        let scenarios: [(title: String, story: String, instruction: String, hint: String, celebration: String)] = [
            (
                "Skatten i grottan!",
                "Blixt-Bot hittade \(a) guldmynt i grottan. Sedan glittrade \(b) till bland stenarna!",
                "Hur många guldmynt har Blixt-Bot nu?",
                "Lägg ihop alla mynt du ser.",
                "Grymt! Du är en riktig skattjägare!"
            ),
            (
                "Äppelplockning!",
                "I trädgården plockade Blixt-Bot \(a) röda äpplen. Sedan hittade hen \(b) gröna äpplen!",
                "Hur många äpplen blev det totalt?",
                "Räkna alla äpplen tillsammans.",
                "Mmm! Så många äpplen! Bravo!"
            ),
            (
                "Stjärnsamlaren!",
                "Blixt-Bot har \(a) lysande stjärnor. Nu kommer \(b) till flygande!",
                "Hur många stjärnor har Blixt-Bot totalt?",
                "Addera stjärnorna.",
                "Du lyser som en superstjärna!"
            ),
            (
                "Ballongfesten!",
                "På festen finns \(a) röda ballonger. Någon tar med \(b) blå ballonger!",
                "Hur många ballonger finns det på festen?",
                "Räkna alla ballonger.",
                "Vilken fest! Du räknade rätt!"
            )
        ]
        
        let scenario = scenarios.randomElement()!
        return createJSON(scenario)
    }
    
    private func generateSubtractionScene(a: Int, b: Int) -> String {
        let scenarios: [(title: String, story: String, instruction: String, hint: String, celebration: String)] = [
            (
                "Kakakatastrofen!",
                "Blixt-Bot hade \(a) chokladkakor. Hen åt upp \(b) stycken! Nom nom!",
                "Hur många kakor finns kvar?",
                "Ta bort de uppätna kakorna.",
                "Utsökt! Och du räknade rätt!"
            ),
            (
                "Fågelflykten!",
                "På tråden satt \(a) fåglar. Plötsligt flög \(b) av dem iväg!",
                "Hur många fåglar sitter kvar?",
                "Räkna bort de som flög.",
                "Pip pip! Rätt svar!"
            ),
            (
                "Ballongsmällen!",
                "Blixt-Bot hade \(a) ballonger. Aj! \(b) stycken small!",
                "Hur många ballonger har Blixt-Bot kvar?",
                "Ta bort de trasiga ballongerna.",
                "Pang! Och rätt svar!"
            )
        ]
        
        let scenario = scenarios.randomElement()!
        return createJSON(scenario)
    }
    
    private func generateMultiplicationScene(a: Int, b: Int) -> String {
        let scenarios: [(title: String, story: String, instruction: String, hint: String, celebration: String)] = [
            (
                "Äggjakten!",
                "Blixt-Bot hittade \(a) fågelbon. I varje bo ligger \(b) ägg!",
                "Hur många ägg finns det totalt?",
                "Räkna \(b) ägg \(a) gånger.",
                "Vilken äggsplosion av rätt svar!"
            ),
            (
                "Godisbutiken!",
                "Det finns \(a) burkar. Varje burk har \(b) godisar.",
                "Hur många godisar finns det sammanlagt?",
                "Multiplicera burkarna med godisarna.",
                "Söt! Du löste det!"
            )
        ]
        
        let scenario = scenarios.randomElement()!
        return createJSON(scenario)
    }
    
    private func generateDivisionScene(a: Int, b: Int) -> String {
        let scenarios: [(title: String, story: String, instruction: String, hint: String, celebration: String)] = [
            (
                "Rättvis delning!",
                "Blixt-Bot har \(a) kex att dela lika mellan \(b) vänner.",
                "Hur många kex får varje vän?",
                "Dela \(a) i \(b) lika högar.",
                "Alla blir glada! Rätt delat!"
            ),
            (
                "Skattdelningen!",
                "\(a) guldmynt ska delas mellan \(b) pirater.",
                "Hur många mynt får varje pirat?",
                "Fördela mynten jämnt.",
                "Arrr! Perfekt fördelning!"
            )
        ]
        
        let scenario = scenarios.randomElement()!
        return createJSON(scenario)
    }
    
    private func generateGenericScene(a: Int, b: Int) -> String {
        let scenario = (
            title: "Matematikäventyret!",
            story: "Blixt-Bot ställde en mattegåta med talen \(a) och \(b).",
            instruction: "Kan du lösa gåtan?",
            hint: "Tänk på talen och vad du ska göra med dem.",
            celebration: "Fantastiskt! Du löste gåtan!"
        )
        return createJSON(scenario)
    }
    
    private func createJSON(_ scenario: (title: String, story: String, instruction: String, hint: String, celebration: String)) -> String {
        """
        {
            "title": "\(scenario.title)",
            "story": "\(scenario.story)",
            "instruction": "\(scenario.instruction)",
            "choices": [],
            "hint": "\(scenario.hint)",
            "celebration": "\(scenario.celebration)"
        }
        """
    }
}

// MARK: - Test Helpers

extension MockLLMClient {
    /// Skapar en mock som alltid returnerar en specifik scene
    static func withFixedScene(_ scene: Scene) -> MockLLMClient {
        let client = FixedSceneMockClient(scene: scene)
        return client as! MockLLMClient
    }
}

/// Mock som alltid returnerar samma scene
final class FixedSceneMockClient: LLMClient {
    private let scene: Scene
    
    init(scene: Scene) {
        self.scene = scene
    }
    
    func complete(prompt: String) async throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(scene)
        return String(data: data, encoding: .utf8) ?? "{}"
    }
}
