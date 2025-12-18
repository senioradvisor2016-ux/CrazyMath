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
    
    /// Kända fotbollsspelare
    private let players = [
        "Zlatan", "Messi", "Ronaldo", "Mbappé", "Haaland",
        "Salah", "Neymar", "De Bruyne", "Bellingham", "Vinícius Jr"
    ]
    
    /// Fotbollslag
    private let teams = [
        "Barcelona", "Real Madrid", "Manchester City", "PSG",
        "Bayern München", "Liverpool", "Chelsea", "Juventus"
    ]
    
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
        let player = players.randomElement()!
        let player2 = players.randomElement()!
        let team = teams.randomElement()!
        
        let scenarios: [(title: String, story: String, instruction: String, hint: String, celebration: String)] = [
            (
                "Målkalas! ⚽",
                "\(player) gjorde \(a) mål i första halvlek mot \(team). Sen smällde hen in \(b) till efter paus!",
                "Hur många mål gjorde \(player) totalt?",
                "Lägg ihop målen från båda halvlekarna.",
                "MÅÅÅL! Du räknar som en sportkommentator! ⚽🎉"
            ),
            (
                "Assistkungen! 🎯",
                "\(player) gav \(a) assist på bortaplan. På hemmaplan blev det \(b) assist till!",
                "Hur många assist totalt?",
                "Addera assisten från båda matcherna.",
                "Vilken speluppläggare! Du har koll! ⚽"
            ),
            (
                "Champions League-kväll! 🏆",
                "\(team) mötte \(teams.randomElement()!). \(player) gjorde \(a) mål och \(player2) gjorde \(b)!",
                "Hur många mål gjorde stjärnorna tillsammans?",
                "Räkna \(a) + \(b).",
                "Europakväll! Snyggt räknat! 🌟⚽"
            ),
            (
                "Samlarbilderna! 🃏",
                "\(player) samlar fotbollskort. Hen har \(a) kort och köper \(b) nya!",
                "Hur många kort har \(player) nu?",
                "Lägg ihop gamla och nya kort.",
                "Komplett samling snart! Bra räknat! 🏆"
            )
        ]
        
        let scenario = scenarios.randomElement()!
        return createJSON(scenario)
    }
    
    private func generateSubtractionScene(a: Int, b: Int) -> String {
        let player = players.randomElement()!
        let team = teams.randomElement()!
        
        let scenarios: [(title: String, story: String, instruction: String, hint: String, celebration: String)] = [
            (
                "Utvisning! 🟥",
                "\(team) hade \(a) spelare på plan. Sen fick \(b) spelare rött kort!",
                "Hur många spelare har \(team) kvar på planen?",
                "Ta bort de utvisade spelarna.",
                "Rätt! Nu spelar de med färre! ⚽"
            ),
            (
                "Skadade stjärnor! 🏥",
                "\(player) hade \(a) matcher kvar. Hen missade \(b) på grund av skada.",
                "Hur många matcher spelade \(player)?",
                "Dra bort de missade matcherna.",
                "Hoppas hen blir frisk! Snyggt räknat! 💪"
            ),
            (
                "Bortbytta tröjor! 👕",
                "\(player) hade \(a) signerade tröjor. Hen gav bort \(b) till fans!",
                "Hur många tröjor har \(player) kvar?",
                "Ta bort de bortgivna tröjorna.",
                "Så generöst! Och rätt svar! ⚽🎁"
            )
        ]
        
        let scenario = scenarios.randomElement()!
        return createJSON(scenario)
    }
    
    private func generateMultiplicationScene(a: Int, b: Int) -> String {
        let player = players.randomElement()!
        let team = teams.randomElement()!
        
        let scenarios: [(title: String, story: String, instruction: String, hint: String, celebration: String)] = [
            (
                "Ligapoäng! 📊",
                "\(team) vann \(a) matcher. Varje vinst ger \(b) poäng!",
                "Hur många poäng fick laget?",
                "Multiplicera vinster med poäng per vinst.",
                "Tabelltoppen! Du räknar som en sportjournalist! 🏆"
            ),
            (
                "Hat-trick x \(a)! ⚽⚽⚽",
                "\(player) gjorde hat-trick (\(b) mål) i \(a) matcher i rad!",
                "Hur många mål totalt?",
                "Räkna \(b) mål × \(a) matcher.",
                "LEGENDAR! Snyggt räknat! 🌟⚽"
            ),
            (
                "Arenans läktare! 🏟️",
                "\(team)s arena har \(a) sektioner med \(b) platser var.",
                "Hur många platser finns det?",
                "Multiplicera sektioner med platser.",
                "Fullsatt! Du kan din matte! 🏟️⚽"
            )
        ]
        
        let scenario = scenarios.randomElement()!
        return createJSON(scenario)
    }
    
    private func generateDivisionScene(a: Int, b: Int) -> String {
        let player = players.randomElement()!
        let team = teams.randomElement()!
        
        let scenarios: [(title: String, story: String, instruction: String, hint: String, celebration: String)] = [
            (
                "Dela prispengar! 💰",
                "\(team) vann \(a) miljoner och ska dela lika mellan \(b) spelare.",
                "Hur mycket får varje spelare?",
                "Dela summan med antalet spelare.",
                "Rättvist delat! Alla stjärnor nöjda! ⚽💰"
            ),
            (
                "Tröjnummer! 👕",
                "Utrustaren har \(a) fotbollströjor till \(b) lag.",
                "Hur många tröjor får varje lag?",
                "Dela tröjorna jämnt.",
                "Alla lag har tröjor! Snyggt! ⚽👕"
            ),
            (
                "Träningsgrupper! 🏃",
                "\(player) är tränare och ska dela in \(a) spelare i \(b) grupper.",
                "Hur många i varje grupp?",
                "Dela spelarna lika.",
                "Perfekta grupper! Du tänker som en tränare! 🧠⚽"
            )
        ]
        
        let scenario = scenarios.randomElement()!
        return createJSON(scenario)
    }
    
    private func generateGenericScene(a: Int, b: Int) -> String {
        let player = players.randomElement()!
        let scenario = (
            title: "Fotbollsmatte! ⚽",
            story: "\(player) ställde en mattegåta med talen \(a) och \(b) på träningen.",
            instruction: "Kan du lösa \(player)s gåta?",
            hint: "Tänk på talen och vad du ska göra.",
            celebration: "MÅÅÅL! \(player) är imponerad! ⚽🌟"
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
