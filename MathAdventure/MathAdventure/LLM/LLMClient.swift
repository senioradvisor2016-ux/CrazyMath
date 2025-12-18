// LLMClient.swift
// MathAdventure
// Abstrakt protokoll för LLM-klienter

import Foundation

/// Protokoll för LLM-klienter
/// Abstraherat så vi kan byta mellan mock, lokal och moln-LLM
protocol LLMClient {
    /// Skickar en prompt och returnerar LLM:s svar
    /// - Parameter prompt: Prompten att skicka
    /// - Returns: LLM:s svar som String
    /// - Throws: LLMError vid fel
    func complete(prompt: String) async throws -> String
}

/// Fel som kan uppstå vid LLM-anrop
enum LLMError: Error, LocalizedError {
    case networkError(underlying: Error)
    case invalidResponse
    case timeout
    case rateLimited
    case contentFiltered
    case invalidJSON
    case responseTooLong
    case serverError(statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Nätverksfel: \(error.localizedDescription)"
        case .invalidResponse:
            return "Ogiltigt svar från servern"
        case .timeout:
            return "Timeout - servern svarade inte i tid"
        case .rateLimited:
            return "För många förfrågningar - vänta en stund"
        case .contentFiltered:
            return "Innehållet filtrerades"
        case .invalidJSON:
            return "Kunde inte tolka svaret som JSON"
        case .responseTooLong:
            return "Svaret var för långt"
        case .serverError(let code):
            return "Serverfel: \(code)"
        }
    }
}

/// Konfiguration för LLM-klient
struct LLMConfig {
    let apiKey: String
    let baseURL: String
    let model: String
    let maxTokens: Int
    let temperature: Double
    
    /// Standard konfiguration för OpenAI-kompatibla API:er
    static let defaultOpenAI = LLMConfig(
        apiKey: "",  // Sätt via miljövariabel eller config
        baseURL: "https://api.openai.com/v1",
        model: "gpt-4o-mini",
        maxTokens: 300,
        temperature: 0.7
    )
    
    /// Konfiguration för lokal modell (t.ex. Ollama)
    static let localOllama = LLMConfig(
        apiKey: "",
        baseURL: "http://localhost:11434/v1",
        model: "llama3",
        maxTokens: 300,
        temperature: 0.7
    )
}

// MARK: - OpenAI-kompatibel klient

/// En riktig LLM-klient för OpenAI-kompatibla API:er
final class OpenAILLMClient: LLMClient {
    private let config: LLMConfig
    private let session: URLSession
    
    init(config: LLMConfig = .defaultOpenAI) {
        self.config = config
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: sessionConfig)
    }
    
    func complete(prompt: String) async throws -> String {
        let url = URL(string: "\(config.baseURL)/chat/completions")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "model": config.model,
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "max_tokens": config.maxTokens,
            "temperature": config.temperature
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw LLMError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200:
                break
            case 429:
                throw LLMError.rateLimited
            case 400...499:
                throw LLMError.serverError(statusCode: httpResponse.statusCode)
            case 500...599:
                throw LLMError.serverError(statusCode: httpResponse.statusCode)
            default:
                throw LLMError.invalidResponse
            }
            
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                throw LLMError.invalidResponse
            }
            
            // Säkerhetskontroll: max längd
            guard content.count <= 2000 else {
                throw LLMError.responseTooLong
            }
            
            return content
            
        } catch let error as LLMError {
            throw error
        } catch {
            throw LLMError.networkError(underlying: error)
        }
    }
}
