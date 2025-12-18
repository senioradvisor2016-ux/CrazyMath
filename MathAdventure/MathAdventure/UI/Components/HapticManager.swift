// HapticManager.swift
// MathAdventure
// Hanterar haptisk feedback

import UIKit

/// Hanterar haptisk feedback i spelet
final class HapticManager {
    
    // MARK: - Singleton
    
    static let shared = HapticManager()
    private init() {
        prepareGenerators()
    }
    
    // MARK: - Generators
    
    private var lightImpact: UIImpactFeedbackGenerator?
    private var mediumImpact: UIImpactFeedbackGenerator?
    private var heavyImpact: UIImpactFeedbackGenerator?
    private var selectionGenerator: UISelectionFeedbackGenerator?
    private var notificationGenerator: UINotificationFeedbackGenerator?
    
    /// Förbereder generatorer för snabbare respons
    private func prepareGenerators() {
        lightImpact = UIImpactFeedbackGenerator(style: .light)
        mediumImpact = UIImpactFeedbackGenerator(style: .medium)
        heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
        selectionGenerator = UISelectionFeedbackGenerator()
        notificationGenerator = UINotificationFeedbackGenerator()
        
        lightImpact?.prepare()
        mediumImpact?.prepare()
        heavyImpact?.prepare()
        selectionGenerator?.prepare()
        notificationGenerator?.prepare()
    }
    
    // MARK: - Impact Feedback
    
    /// Typ av impact feedback
    enum ImpactStyle {
        case light
        case medium
        case heavy
        case soft
        case rigid
    }
    
    /// Utlöser impact feedback
    /// - Parameter style: Typ av impact
    func impact(_ style: ImpactStyle) {
        switch style {
        case .light:
            lightImpact?.impactOccurred()
        case .medium:
            mediumImpact?.impactOccurred()
        case .heavy:
            heavyImpact?.impactOccurred()
        case .soft:
            let generator = UIImpactFeedbackGenerator(style: .soft)
            generator.impactOccurred()
        case .rigid:
            let generator = UIImpactFeedbackGenerator(style: .rigid)
            generator.impactOccurred()
        }
        
        // Förbered för nästa
        prepareGenerators()
    }
    
    // MARK: - Selection Feedback
    
    /// Utlöser selection feedback (för UI-val)
    func selection() {
        selectionGenerator?.selectionChanged()
        selectionGenerator?.prepare()
    }
    
    // MARK: - Notification Feedback
    
    /// Typ av notification feedback
    enum NotificationType {
        case success
        case warning
        case error
    }
    
    /// Utlöser notification feedback
    /// - Parameter type: Typ av notifikation
    func notification(_ type: NotificationType) {
        let feedbackType: UINotificationFeedbackGenerator.FeedbackType
        
        switch type {
        case .success:
            feedbackType = .success
        case .warning:
            feedbackType = .warning
        case .error:
            feedbackType = .error
        }
        
        notificationGenerator?.notificationOccurred(feedbackType)
        notificationGenerator?.prepare()
    }
    
    // MARK: - Game-Specific Haptics
    
    /// Haptics för rätt svar
    func correctAnswer() {
        notification(.success)
        
        // Dubbel-tap för extra effekt
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.impact(.medium)
        }
    }
    
    /// Haptics för fel svar
    func wrongAnswer() {
        notification(.error)
    }
    
    /// Haptics för nivå klarad
    func levelComplete() {
        notification(.success)
        
        // Celebration sequence
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.impact(.heavy)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.impact(.medium)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { [weak self] in
            self?.impact(.light)
        }
    }
    
    /// Haptics för knapptryck
    func buttonTap() {
        impact(.light)
    }
    
    /// Haptics för drag/flytt
    func drag() {
        selection()
    }
    
    /// Haptics för att få hint
    func hint() {
        impact(.soft)
    }
    
    /// Haptics för stjärnor
    func star() {
        impact(.rigid)
    }
}
