// Scene.swift
// MathAdventure
// Narrativ scen genererad av LLM eller fallback

import Foundation

/// En narrativ scen som omger en matematisk uppgift
struct Scene: Codable, Equatable {
    let title: String           // Max ~40 tecken
    let story: String           // Max 180 tecken, 2 meningar
    let instruction: String     // Max 90 tecken, 1 mening
    let choices: [String]       // Svarsalternativ (kan vara tom)
    let hint: String            // Max 120 tecken
    let celebration: String     // Max 80 tecken
    
    /// Validerar att scenen följer längdbegränsningar
    var isValid: Bool {
        story.count <= 200 &&
        instruction.count <= 100 &&
        hint.count <= 140 &&
        celebration.count <= 100 &&
        title.count <= 60
    }
    
    /// Trunkerar alla fält till max-längder
    func truncated() -> Scene {
        Scene(
            title: String(title.prefix(60)),
            story: String(story.prefix(200)),
            instruction: String(instruction.prefix(100)),
            choices: choices.map { String($0.prefix(40)) },
            hint: String(hint.prefix(140)),
            celebration: String(celebration.prefix(100))
        )
    }
    
    /// Skapar en fallback-scen för en uppgift
    static func fallback(for task: MathTask) -> Scene {
        let a = task.a
        let b = task.b
        
        switch task.skill {
        case .add:
            return Scene(
                title: "Samla ihop!",
                story: "Blixt-Bot har hittat \(a) glänsande stenar. Sedan hittar hen \(b) till!",
                instruction: "Hur många stenar har Blixt-Bot totalt?",
                choices: [],
                hint: "Räkna alla stenar tillsammans: \(a) och \(b).",
                celebration: "Fantastiskt! Du räknade helt rätt! 🎉"
            )
            
        case .sub:
            return Scene(
                title: "Dela med dig!",
                story: "Blixt-Bot har \(a) äpplen. Hen ger bort \(b) äpplen till sina vänner.",
                instruction: "Hur många äpplen har Blixt-Bot kvar?",
                choices: [],
                hint: "Börja med \(a) och ta bort \(b).",
                celebration: "Snyggt jobbat! Du är en mästare! ⭐"
            )
            
        case .mult:
            let groups = task.groups
            let perGroup = task.perGroup
            return Scene(
                title: "Många grupper!",
                story: "Det finns \(groups) korgar. I varje korg ligger \(perGroup) äpplen.",
                instruction: "Hur många äpplen finns det totalt?",
                choices: [],
                hint: "Räkna \(perGroup) + \(perGroup) + ... (\(groups) gånger).",
                celebration: "Helt rätt! Du tänker smart! 🌟"
            )
            
        case .div:
            return Scene(
                title: "Dela lika!",
                story: "Blixt-Bot ska dela \(a) kakor lika mellan \(b) vänner.",
                instruction: "Hur många kakor får varje vän?",
                choices: [],
                hint: "Fördela \(a) lika i \(b) högar.",
                celebration: "Perfekt delat! Alla blir glada! 🎂"
            )
            
        case .fractions:
            return Scene(
                title: "Dela pizza!",
                story: "En pizza är delad i lika stora bitar.",
                instruction: "Hur stor del av pizzan är markerad?",
                choices: [],
                hint: "Räkna bitarna och jämför med helheten.",
                celebration: "Mmm, du förstår bråk! 🍕"
            )
            
        case .decimals:
            return Scene(
                title: "Decimaläventyret!",
                story: "Blixt-Bot mäter längder med decimaler.",
                instruction: "Vilket tal visar mätningen?",
                choices: [],
                hint: "Titta på siffran efter kommatecknet.",
                celebration: "Precis rätt decimal! 📏"
            )
            
        case .percent:
            return Scene(
                title: "Procentjakten!",
                story: "Blixt-Bot vill veta hur stor del det är.",
                instruction: "Hur många procent är det?",
                choices: [],
                hint: "Tänk på att 100% är allt.",
                celebration: "100% korrekt! 💯"
            )
            
        case .placeValue:
            return Scene(
                title: "Positionshemligheten!",
                story: "Varje siffra har sin speciella plats.",
                instruction: "Vad betyder siffran på den platsen?",
                choices: [],
                hint: "Ental, tiotal, hundratal...",
                celebration: "Du förstår positioner! 🔢"
            )
            
        case .patterns:
            return Scene(
                title: "Mönstermästaren!",
                story: "Blixt-Bot har upptäckt ett mönster.",
                instruction: "Vad kommer härnäst i mönstret?",
                choices: [],
                hint: "Titta noga på vad som upprepas.",
                celebration: "Du hittade mönstret! 🔄"
            )
            
        case .geometry:
            return Scene(
                title: "Formernas värld!",
                story: "Blixt-Bot utforskar former och figurer.",
                instruction: "Vilken form är detta?",
                choices: [],
                hint: "Räkna sidor och hörn.",
                celebration: "Formexpert! 📐"
            )
            
        case .measurement:
            return Scene(
                title: "Mät äventyret!",
                story: "Blixt-Bot behöver mäta något.",
                instruction: "Hur långt/tungt/stort är det?",
                choices: [],
                hint: "Använd rätt enhet.",
                celebration: "Perfekt mätt! 📏"
            )
            
        case .coordinates:
            return Scene(
                title: "Kartskattjakten!",
                story: "Blixt-Bot letar efter skatten på kartan.",
                instruction: "Var ligger punkten?",
                choices: [],
                hint: "Först x (höger), sedan y (upp).",
                celebration: "Du hittade platsen! 🗺️"
            )
            
        case .statistics:
            return Scene(
                title: "Datadeckaren!",
                story: "Blixt-Bot samlar in data.",
                instruction: "Vad visar diagrammet?",
                choices: [],
                hint: "Läs av axlarna noga.",
                celebration: "Dataexpert! 📊"
            )
            
        case .negatives:
            return Scene(
                title: "Under noll!",
                story: "Termometern visar kallt!",
                instruction: "Vilket tal visar termometern?",
                choices: [],
                hint: "Under noll är minus.",
                celebration: "Coolt räknat! 🌡️"
            )
            
        case .scale:
            return Scene(
                title: "Förstora och förminska!",
                story: "Blixt-Bot har en magisk karta.",
                instruction: "Hur långt är det i verkligheten?",
                choices: [],
                hint: "Multiplicera med skalan.",
                celebration: "Skalexpert! ⚖️"
            )
            
        case .reasoning:
            return Scene(
                title: "Tänk och förklara!",
                story: "Blixt-Bot undrar varför...",
                instruction: "Kan du förklara ditt tänkande?",
                choices: [],
                hint: "Berätta steg för steg.",
                celebration: "Fantastiskt resonemang! 💭"
            )
        }
    }
}

/// JSON-schema för validering av LLM-svar
struct SceneSchema {
    static let maxTitleLength = 60
    static let maxStoryLength = 200
    static let maxInstructionLength = 100
    static let maxHintLength = 140
    static let maxCelebrationLength = 100
    static let maxChoiceLength = 40
    static let maxChoices = 6
    static let maxTotalLength = 800
}
