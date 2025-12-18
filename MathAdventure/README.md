# Fotbollsmatten ⚽🏆

Ett spännande mattespel för barn (Åk 1–6) med kända fotbollsspelare som Zlatan, Messi, Ronaldo och fler! Byggt med SwiftUI enligt Lgr22/Skolverket där ALL matematikverifiering sker lokalt.

![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## 🎯 Översikt

Fotbollsmatten är ett utbildningsspel som kombinerar:
- **Fotbollstema** - Alla uppgifter handlar om kända fotbollsspelare som Zlatan, Messi, Ronaldo, Haaland m.fl.
- **Lokal matematikmotor** - All verifiering av rätt/fel sker i `GameEngine` (ingen LLM-hallucination påverkar korrekthet)
- **LLM som storyteller** - Genererar engagerande fotbollsberättelser via `NarrativeDirector`
- **Adaptiv svårighet** - Anpassar sig efter spelarens mastery per skill
- **Barnsäkerhet** - Strikt JSON-schema, inga personliga frågor, offline-fallback

## 🏗️ Arkitektur

```
┌─────────────────────────────────────────────────────────┐
│                         UI Layer                         │
│  ┌─────────────────┐  ┌─────────────────────────────┐  │
│  │   WorldMapView   │  │      LevelHostView          │  │
│  └─────────────────┘  └─────────────────────────────┘  │
│           │                        │                     │
│           ▼                        ▼                     │
│  ┌─────────────────────────────────────────────────┐   │
│  │     Level Views (Merge, PopAway, Bridge, etc.)   │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                           │
        ┌──────────────────┴──────────────────┐
        ▼                                      ▼
┌───────────────────┐              ┌───────────────────┐
│    GameEngine     │              │ NarrativeDirector │
│ ─────────────────  │              │ ─────────────────  │
│ • makeTask()      │              │ • scene(for:)     │
│ • verify()        │              │ • buildPrompt()   │
│ • updateMastery() │              │ • parseScene()    │
│                   │              │ • fallback()      │
│   ⚠️ ALL MATH     │              │                   │
│   VERIFIED HERE   │              │   LLMClient       │
└───────────────────┘              │   (protocol)      │
                                   └───────────────────┘
```

## 📁 Filstruktur

```
MathAdventure/
├── App/
│   ├── MathAdventureApp.swift    # Entry point
│   └── RootView.swift            # Navigationshantering
├── Models/
│   ├── GradeBand.swift           # Årskurser (g1-g6)
│   ├── Skill.swift               # Matematiska färdigheter
│   ├── MathTask.swift            # Uppgiftsrepresentation
│   ├── Scene.swift               # Narrativ scen
│   └── PlayerProfile.swift       # Sparprofil
├── Engine/
│   ├── GameEngine.swift          # Matematikmotor
│   └── MasteryModel.swift        # Adaptiv svårighet
├── LLM/
│   ├── LLMClient.swift           # Protokoll + OpenAI-klient
│   ├── MockLLMClient.swift       # Mock för test/offline
│   └── NarrativeDirector.swift   # Scengenerering
├── UI/
│   ├── WorldMapView.swift        # Världskarta
│   ├── LevelHostView.swift       # Nivåhantering
│   ├── Components/
│   │   ├── CharacterView.swift   # Blixt-Bot
│   │   ├── TokenView.swift       # Visuella tokens
│   │   ├── HapticManager.swift   # Haptisk feedback
│   │   ├── ConfettiView.swift    # Celebration
│   │   └── AnswerInputView.swift # Numpad m.m.
│   └── Levels/
│       ├── MergeLevelView.swift      # Addition
│       ├── PopAwayLevelView.swift    # Subtraktion
│       ├── BridgeLevelView.swift     # Multiplikation
│       ├── DealEqualLevelView.swift  # Division
│       ├── ChoosePathLevelView.swift # Strategi
│       └── ExplainLevelView.swift    # Resonemang
├── Content/
│   └── Grade1Levels.swift        # 20 färdiga Åk1-nivåer
└── Tests/
    ├── GameEngineTests.swift
    └── NarrativeDirectorTests.swift
```

## 🚀 Kom igång

### Krav
- Xcode 15+
- iOS 17.0+
- Swift 5.9+

### Installation

1. **Klona repot:**
   ```bash
   git clone <repo-url>
   cd MathAdventure
   ```

2. **Öppna i Xcode:**
   ```bash
   open MathAdventure.xcodeproj
   ```

3. **Kör på simulator eller enhet:**
   - Välj en iPhone simulator
   - Tryck ⌘R

### Kör utan LLM (Offline-läge)

Spelet fungerar helt utan LLM tack vare `Scene.fallback()`. För att explicit stänga av LLM:

```swift
// I NarrativeDirectorFactory.swift
static func makeOffline() -> NarrativeDirector {
    NarrativeDirector(llmClient: MockLLMClient(), useLLM: false)
}
```

## 🔧 LLM-integration

### Använda MockLLMClient (standard)

Perfekt för utveckling och testning:

```swift
let director = NarrativeDirectorFactory.makeMock()
```

### Använda OpenAI

1. Sätt API-nyckel som miljövariabel:
   ```bash
   export LLM_API_KEY="sk-..."
   ```

2. Använd production factory:
   ```swift
   let director = NarrativeDirectorFactory.makeProduction(
       apiKey: AppConfig.llmAPIKey
   )
   ```

### Egen LLM-backend

Implementera `LLMClient`-protokollet:

```swift
protocol LLMClient {
    func complete(prompt: String) async throws -> String
}

class MyCustomLLMClient: LLMClient {
    func complete(prompt: String) async throws -> String {
        // Din implementation
    }
}
```

## 🎮 Nivåtyper

| View | Skill | Beskrivning |
|------|-------|-------------|
| `MergeLevelView` | Addition | Visuellt slå ihop objekt |
| `PopAwayLevelView` | Subtraktion | Ta bort objekt |
| `BridgeLevelView` | Multiplikation | Hoppa steg på bro |
| `DealEqualLevelView` | Division | Dela lika mellan grupper |
| `ChoosePathLevelView` | Strategi | Flerval/mönster |
| `ExplainLevelView` | Resonemang | Bråk/decimal/procent |

## 📊 Mastery-system

Spelaren har en mastery (0.0–1.0) per skill som uppdateras:

```swift
newMastery = GameEngine.shared.updateMastery(
    currentMastery: 0.5,
    task: task,
    correct: true,
    responseTimeMs: 2000
)
```

Faktorer som påverkar:
- ✅ Rätt svar → ökar mastery
- ❌ Fel svar → minskar mastery
- ⚡ Snabbt svar → bonus
- 📈 Högre svårighet → mer boost vid rätt

## 🧪 Tester

Kör alla tester:
```bash
xcodebuild test -scheme MathAdventure -destination 'platform=iOS Simulator,name=iPhone 15'
```

Testtäckning inkluderar:
- `GameEngineTests` - Verifiering, task-generering, mastery
- `NarrativeDirectorTests` - JSON-parsing, fallback, child safety
- `MasteryModelTests` - Svårighetsjustering, stjärnberäkning
- `FractionValueTests` - Bråkförenkling

## 🔒 Barnsäkerhet

LLM-prompten kräver:
- **Endast JSON-output** (ingen fritext)
- **Max längder** på alla fält
- **Inga personliga frågor**
- **Inga externa länkar**
- **Endast godkända tal** från task.promptData

Vid minsta avvikelse → automatisk fallback till lokal scen.

## 📐 Lgr22-anpassning

### Åk 1–2
- Addition/subtraktion 0–20
- Positionssystemet (ental, tiotal)
- Enkla mönster

### Åk 3–4
- Multiplikationstabeller
- Division
- Bråk (grundläggande)
- Geometri

### Åk 5–6
- Decimaltal
- Procent
- Koordinater
- Statistik
- Negativa tal
- Skala
- Matematiska resonemang

## 🎨 UI/UX

- **Stora knappar** - Lätt att trycka för små fingrar
- **Visuella tokens** - Äpplen, mynt, stjärnor istället för bara siffror
- **Blixt-Bot** - En vänlig robot-guide
- **Haptisk feedback** - Känn när du svarar rätt/fel
- **Konfetti** - Celebration vid klarad nivå

## 📝 Licens

MIT License - se [LICENSE](LICENSE)

## 🤝 Bidra

1. Fork projektet
2. Skapa feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit (`git commit -m 'Add AmazingFeature'`)
4. Push (`git push origin feature/AmazingFeature`)
5. Öppna Pull Request

## 📧 Kontakt

Frågor eller förslag? Öppna ett issue!

---

**Byggt med ❤️ för svenska barn, fotboll och läroplanen Lgr22**

## ⚽ Fotbollsstjärnor i spelet

Spelet innehåller kända fotbollsspelare från hela världen:
- 🇸🇪 **Svenska stjärnor**: Zlatan, Kosovare Asllani, Fridolina Rolfö, Stina Blackstenius, Caroline Seger
- 🌍 **Internationella stjärnor**: Messi, Ronaldo, Mbappé, Haaland, Salah, Neymar, De Bruyne, Modric, Benzema, Lewandowski, Vinícius Jr, Bellingham

Lag som nämns: Barcelona, Real Madrid, Manchester City, PSG, Bayern München, Liverpool, Chelsea, Juventus m.fl.
