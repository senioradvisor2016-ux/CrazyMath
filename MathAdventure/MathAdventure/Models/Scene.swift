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
    
    /// Kända fotbollsspelare för variation
    private static let players = [
        "Zlatan", "Messi", "Ronaldo", "Mbappé", "Haaland",
        "Salah", "Neymar", "De Bruyne", "Modric", "Benzema",
        "Lewandowski", "Vinícius Jr", "Bellingham", "Kosovare Asllani",
        "Fridolina Rolfö", "Stina Blackstenius", "Caroline Seger"
    ]
    
    /// Fotbollslag för variation
    private static let teams = [
        "Barcelona", "Real Madrid", "Manchester City", "PSG",
        "Bayern München", "Liverpool", "Chelsea", "Juventus",
        "Milan", "Inter", "Arsenal", "Dortmund"
    ]
    
    /// Hämta en spelare baserat på seed
    private static func player(seed: Int) -> String {
        players[abs(seed) % players.count]
    }
    
    /// Hämta ett lag baserat på seed
    private static func team(seed: Int) -> String {
        teams[abs(seed) % teams.count]
    }
    
    /// Skapar en fallback-scen för en uppgift
    static func fallback(for task: MathTask) -> Scene {
        let a = task.a
        let b = task.b
        let player1 = player(seed: task.seed)
        let player2 = player(seed: task.seed + 7)
        let team1 = team(seed: task.seed)
        let team2 = team(seed: task.seed + 3)
        
        switch task.skill {
        case .add:
            return Scene(
                title: "Målkalas! ⚽",
                story: "\(player1) gjorde \(a) mål i första halvlek. I andra halvlek sköt hen \(b) mål till!",
                instruction: "Hur många mål gjorde \(player1) totalt?",
                choices: [],
                hint: "Lägg ihop målen: \(a) + \(b).",
                celebration: "MÅÅÅL! Du räknade som en riktig fotbollsexpert! ⚽🎉"
            )
            
        case .sub:
            return Scene(
                title: "Fotbollskort! 🃏",
                story: "\(player1) hade \(a) samlarbilder. Hen gav bort \(b) kort till en kompis.",
                instruction: "Hur många kort har \(player1) kvar?",
                choices: [],
                hint: "Börja med \(a) och ta bort \(b).",
                celebration: "Bra räknat! Du är en samlarmästare! 🏆"
            )
            
        case .mult:
            let groups = task.groups
            let perGroup = task.perGroup
            return Scene(
                title: "Lagets poäng! 🏟️",
                story: "\(team1) vann \(groups) matcher. Varje vinst ger \(perGroup) poäng.",
                instruction: "Hur många poäng fick laget totalt?",
                choices: [],
                hint: "Räkna \(perGroup) poäng × \(groups) matcher.",
                celebration: "Tabelltoppen! Du räknar som en sportjournalist! 📊"
            )
            
        case .div:
            return Scene(
                title: "Dela tröjor! 👕",
                story: "Tränaren har \(a) fotbollströjor att dela ut till \(b) lag.",
                instruction: "Hur många tröjor får varje lag?",
                choices: [],
                hint: "Dela \(a) tröjor i \(b) lika högar.",
                celebration: "Perfekt fördelat! Alla lag är nöjda! ⚽"
            )
            
        case .fractions:
            return Scene(
                title: "Matchminuter! ⏱️",
                story: "Matchen är 90 minuter. \(player1) spelade en del av matchen.",
                instruction: "Hur stor del av matchen spelade hen?",
                choices: [],
                hint: "Jämför spelade minuter med hela matchen.",
                celebration: "Snyggt! Du förstår speltid! ⚽"
            )
            
        case .decimals:
            return Scene(
                title: "Löparsträcka! 🏃",
                story: "\(player1) sprang många kilometer under matchen.",
                instruction: "Hur långt sprang hen?",
                choices: [],
                hint: "Läs av decimaltalet på skärmen.",
                celebration: "Rätt! \(player1) skulle vara imponerad! 🏃⚽"
            )
            
        case .percent:
            return Scene(
                title: "Skottstatistik! 📈",
                story: "\(player1) träffade målet med några av sina skott.",
                instruction: "Hur många procent av skotten blev mål?",
                choices: [],
                hint: "Procent = antal av 100.",
                celebration: "100% korrekt statistik! Du är som en sportanalytiker! 📊"
            )
            
        case .placeValue:
            return Scene(
                title: "Publikrekord! 🏟️",
                story: "Det var rekordpublik på \(team1)s arena.",
                instruction: "Vad betyder siffran på tiotalens plats?",
                choices: [],
                hint: "Ental, tiotal, hundratal...",
                celebration: "Du kan läsa publiksiffror som ett proffs! 🎉"
            )
            
        case .patterns:
            return Scene(
                title: "Passmönster! ⚽",
                story: "\(team1) spelar med ett speciellt passmönster.",
                instruction: "Vem får bollen härnäst i mönstret?",
                choices: [],
                hint: "Titta på hur bollinnehavet upprepas.",
                celebration: "Du ser mönstret som en tränare! 🧠⚽"
            )
            
        case .geometry:
            return Scene(
                title: "Planens form! 📐",
                story: "Fotbollsplanen och straffområdet har speciella former.",
                instruction: "Vilken form har straffområdet?",
                choices: [],
                hint: "Räkna sidor och hörn.",
                celebration: "Formexpert på planen! ⚽📐"
            )
            
        case .measurement:
            return Scene(
                title: "Mät bollen! ⚽",
                story: "\(player1) ska välja rätt storlek på fotbollen.",
                instruction: "Hur stor är bollens omkrets?",
                choices: [],
                hint: "Mät runt om bollen.",
                celebration: "Perfekt mått! FIFA godkänt! ⚽✓"
            )
            
        case .coordinates:
            return Scene(
                title: "Taktiktavlan! 🗺️",
                story: "Tränaren visar var \(player1) ska stå på planen.",
                instruction: "Vilka koordinater har positionen?",
                choices: [],
                hint: "X = sidled, Y = framåt.",
                celebration: "Du hittade positionen! Taktikgeni! 🧠⚽"
            )
            
        case .statistics:
            return Scene(
                title: "Ligatabellen! 📊",
                story: "\(team1) och \(team2) kämpar om toppen.",
                instruction: "Vad visar statistiken?",
                choices: [],
                hint: "Läs av tabellen noga.",
                celebration: "Statistikexpert! Du borde jobba på Fotbollskanalen! 📺"
            )
            
        case .negatives:
            return Scene(
                title: "Målskillnad! ➖",
                story: "\(team1) har släppt in fler mål än de gjort.",
                instruction: "Vad är lagets målskillnad?",
                choices: [],
                hint: "Minus betyder negativ målskillnad.",
                celebration: "Rätt målskillnad! Du kan tabellen! 📊"
            )
            
        case .scale:
            return Scene(
                title: "Arenans karta! 🏟️",
                story: "\(team1)s arena visas på en karta i skala.",
                instruction: "Hur lång är planen i verkligheten?",
                choices: [],
                hint: "Multiplicera med skalan.",
                celebration: "Skalexpert! Du skulle kunna designa arenor! 🏟️"
            )
            
        case .reasoning:
            return Scene(
                title: "Tränartänk! 🧠",
                story: "\(player1) förklarar en spelstrategi.",
                instruction: "Kan du förklara varför det fungerar?",
                choices: [],
                hint: "Tänk steg för steg som en tränare.",
                celebration: "Briljant resonemang! Du tänker som Guardiola! 🧠⚽"
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
