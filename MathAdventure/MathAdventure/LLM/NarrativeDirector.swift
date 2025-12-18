// NarrativeDirector.swift
// MathAdventure
// Hanterar generering av narrativa scener via LLM med fallback

import Foundation

/// Ansvarig för att generera narrativa scener kring matematikuppgifter
/// Använder LLM för rik storytelling men faller tillbaka till lokala scener vid fel
actor NarrativeDirector {
    
    // MARK: - Properties
    
    private let llmClient: LLMClient
    private let useLLM: Bool
    
    /// Cache för att undvika duplicerade anrop
    private var sceneCache: [UUID: Scene] = [:]
    
    // MARK: - Initialization
    
    init(llmClient: LLMClient = MockLLMClient(), useLLM: Bool = true) {
        self.llmClient = llmClient
        self.useLLM = useLLM
    }
    
    // MARK: - Scene Generation
    
    /// Genererar en scen för en uppgift
    /// Försöker använda LLM men faller tillbaka till lokal generering
    /// - Parameter task: Matematikuppgiften
    /// - Returns: En Scene för att visualisera uppgiften
    func scene(for task: MathTask) async -> Scene {
        // Kolla cache först
        if let cached = sceneCache[task.id] {
            return cached
        }
        
        // Om LLM är avstängt, använd fallback direkt
        guard useLLM else {
            let fallback = Scene.fallback(for: task)
            sceneCache[task.id] = fallback
            return fallback
        }
        
        // Försök med LLM
        do {
            let prompt = buildPrompt(for: task)
            let response = try await llmClient.complete(prompt: prompt)
            let scene = try parseScene(from: response, task: task)
            sceneCache[task.id] = scene
            return scene
        } catch {
            // LLM misslyckades - använd fallback
            print("NarrativeDirector: LLM failed, using fallback. Error: \(error)")
            let fallback = Scene.fallback(for: task)
            sceneCache[task.id] = fallback
            return fallback
        }
    }
    
    // MARK: - Prompt Building
    
    /// Bygger en säker prompt för LLM:en
    /// Begränsar vad LLM kan returnera för barnsäkerhet
    private func buildPrompt(for task: MathTask) -> String {
        let skillDescription = describeSkill(task.skill)
        let promptDataString = task.promptData.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
        
        return """
        Du är en berättare för ett mattespel för barn. Skapa en kort, rolig scen.
        
        REGLER (VIKTIGA):
        - Svara ENDAST med JSON, inget annat.
        - Använd ENDAST talen från uppgiften: \(promptDataString)
        - Hitta INTE på nya tal eller matematiska uttryck.
        - Max längd: title 40 tecken, story 180 tecken, instruction 90 tecken, hint 120 tecken, celebration 80 tecken.
        - Inga personliga frågor, inga länkar, inga känsliga ämnen.
        - Barnvänligt och positivt språk på svenska.
        - Karaktären heter "Blixt-Bot".
        
        UPPGIFT:
        - Typ: \(skillDescription)
        - Årskurs: \(task.grade.shortName)
        - Svårighet: \(task.difficulty)/10
        - Data: \(promptDataString)
        
        JSON-SCHEMA:
        {
            "title": "string (max 40 tecken)",
            "story": "string (max 180 tecken, 2 meningar)",
            "instruction": "string (max 90 tecken, 1 mening)",
            "choices": [],
            "hint": "string (max 120 tecken)",
            "celebration": "string (max 80 tecken)"
        }
        
        VIKTIGT: Svara ENDAST med JSON. Ingen inledande text.
        """
    }
    
    private func describeSkill(_ skill: Skill) -> String {
        switch skill {
        case .add: return "Addition (lägga ihop)"
        case .sub: return "Subtraktion (ta bort)"
        case .mult: return "Multiplikation (grupper av)"
        case .div: return "Division (dela lika)"
        case .fractions: return "Bråk (delar av helhet)"
        case .decimals: return "Decimaltal"
        case .percent: return "Procent"
        case .placeValue: return "Positionssystemet"
        case .patterns: return "Mönster"
        case .geometry: return "Geometri"
        case .measurement: return "Mätning"
        case .coordinates: return "Koordinater"
        case .statistics: return "Statistik"
        case .negatives: return "Negativa tal"
        case .scale: return "Skala"
        case .reasoning: return "Resonemang"
        }
    }
    
    // MARK: - Response Parsing
    
    /// Parsar LLM-svaret till en Scene med strikt validering
    private func parseScene(from response: String, task: MathTask) throws -> Scene {
        // Säkerhetskontroll: max längd på hela svaret
        guard response.count <= SceneSchema.maxTotalLength else {
            throw SceneParseError.responseTooLong
        }
        
        // Försök extrahera JSON från svaret (kan ha extra text)
        let jsonString = extractJSON(from: response)
        
        guard let data = jsonString.data(using: .utf8) else {
            throw SceneParseError.invalidUTF8
        }
        
        let decoder = JSONDecoder()
        let scene: Scene
        
        do {
            scene = try decoder.decode(Scene.self, from: data)
        } catch {
            throw SceneParseError.jsonDecodeFailed(error)
        }
        
        // Validera och trunkera om nödvändigt
        let validatedScene = validateAndSanitize(scene, for: task)
        
        return validatedScene
    }
    
    /// Extraherar JSON från ett svar som kan innehålla extra text
    private func extractJSON(from response: String) -> String {
        let trimmed = response.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Hitta första { och sista }
        guard let startIndex = trimmed.firstIndex(of: "{"),
              let endIndex = trimmed.lastIndex(of: "}") else {
            return trimmed
        }
        
        return String(trimmed[startIndex...endIndex])
    }
    
    /// Validerar och sanerar scenen för barnsäkerhet
    private func validateAndSanitize(_ scene: Scene, for task: MathTask) -> Scene {
        var sanitized = scene.truncated()
        
        // Kontrollera att scenen inte innehåller olämpligt innehåll
        let forbidden = ["http://", "https://", "www.", "@", "email", "telefon", "adress"]
        
        for word in forbidden {
            if sanitized.story.lowercased().contains(word) ||
               sanitized.instruction.lowercased().contains(word) ||
               sanitized.hint.lowercased().contains(word) {
                // Om olämpligt innehåll hittas, använd fallback
                return Scene.fallback(for: task)
            }
        }
        
        return sanitized
    }
    
    // MARK: - Cache Management
    
    /// Rensar cache för att frigöra minne
    func clearCache() {
        sceneCache.removeAll()
    }
    
    /// Tar bort en specifik scen från cache
    func invalidateCache(for taskId: UUID) {
        sceneCache.removeValue(forKey: taskId)
    }
}

// MARK: - Errors

enum SceneParseError: Error, LocalizedError {
    case responseTooLong
    case invalidUTF8
    case jsonDecodeFailed(Error)
    case invalidContent
    
    var errorDescription: String? {
        switch self {
        case .responseTooLong:
            return "LLM-svaret var för långt"
        case .invalidUTF8:
            return "Kunde inte tolka svaret som text"
        case .jsonDecodeFailed(let error):
            return "JSON-fel: \(error.localizedDescription)"
        case .invalidContent:
            return "Svaret innehöll ogiltigt innehåll"
        }
    }
}

// MARK: - Director Factory

/// Factory för att skapa NarrativeDirector med rätt konfiguration
enum NarrativeDirectorFactory {
    /// Skapar en director med mock-LLM för utveckling/test
    static func makeMock() -> NarrativeDirector {
        NarrativeDirector(llmClient: MockLLMClient(), useLLM: true)
    }
    
    /// Skapar en director utan LLM (endast fallback)
    static func makeOffline() -> NarrativeDirector {
        NarrativeDirector(llmClient: MockLLMClient(), useLLM: false)
    }
    
    /// Skapar en director med riktig LLM
    static func makeProduction(apiKey: String) -> NarrativeDirector {
        let config = LLMConfig(
            apiKey: apiKey,
            baseURL: "https://api.openai.com/v1",
            model: "gpt-4o-mini",
            maxTokens: 300,
            temperature: 0.7
        )
        let client = OpenAILLMClient(config: config)
        return NarrativeDirector(llmClient: client, useLLM: true)
    }
}
