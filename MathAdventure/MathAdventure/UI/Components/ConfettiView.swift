// ConfettiView.swift
// MathAdventure
// Konfetti-animation för firande

import SwiftUI

/// Konfetti-animation som visas vid rätt svar eller level complete
struct ConfettiView: View {
    @Binding var isActive: Bool
    var intensity: Intensity = .medium
    
    enum Intensity {
        case light, medium, heavy
        
        var particleCount: Int {
            switch self {
            case .light: return 30
            case .medium: return 60
            case .heavy: return 100
            }
        }
    }
    
    @State private var particles: [ConfettiParticle] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    ConfettiParticleView(particle: particle)
                }
            }
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    startConfetti(in: geometry.size)
                } else {
                    particles.removeAll()
                }
            }
        }
        .allowsHitTesting(false)
    }
    
    private func startConfetti(in size: CGSize) {
        particles = (0..<intensity.particleCount).map { _ in
            ConfettiParticle(
                startX: CGFloat.random(in: 0...size.width),
                startY: -20
            )
        }
        
        // Rensa efter animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            isActive = false
        }
    }
}

/// En enskild konfetti-partikel
struct ConfettiParticle: Identifiable {
    let id = UUID()
    let startX: CGFloat
    let startY: CGFloat
    let color: Color
    let shape: ConfettiShape
    let size: CGFloat
    let rotationSpeed: Double
    let fallSpeed: Double
    let swayAmount: CGFloat
    
    init(startX: CGFloat, startY: CGFloat) {
        self.startX = startX
        self.startY = startY
        self.color = [.red, .blue, .green, .yellow, .orange, .purple, .pink].randomElement()!
        self.shape = ConfettiShape.allCases.randomElement()!
        self.size = CGFloat.random(in: 8...16)
        self.rotationSpeed = Double.random(in: 2...5)
        self.fallSpeed = Double.random(in: 2...4)
        self.swayAmount = CGFloat.random(in: 30...60)
    }
}

enum ConfettiShape: CaseIterable {
    case circle, square, triangle, star
}

/// Vy för en enskild partikel
struct ConfettiParticleView: View {
    let particle: ConfettiParticle
    
    @State private var yOffset: CGFloat = 0
    @State private var xOffset: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1
    
    var body: some View {
        Group {
            switch particle.shape {
            case .circle:
                Circle()
                    .fill(particle.color)
            case .square:
                Rectangle()
                    .fill(particle.color)
            case .triangle:
                Triangle()
                    .fill(particle.color)
            case .star:
                Image(systemName: "star.fill")
                    .foregroundColor(particle.color)
            }
        }
        .frame(width: particle.size, height: particle.size)
        .rotationEffect(.degrees(rotation))
        .position(
            x: particle.startX + xOffset,
            y: particle.startY + yOffset
        )
        .opacity(opacity)
        .onAppear {
            withAnimation(.linear(duration: particle.fallSpeed)) {
                yOffset = UIScreen.main.bounds.height + 100
            }
            
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                xOffset = particle.swayAmount
            }
            
            withAnimation(.linear(duration: particle.rotationSpeed).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            
            withAnimation(.linear(duration: particle.fallSpeed).delay(particle.fallSpeed * 0.7)) {
                opacity = 0
            }
        }
    }
}

/// Enkel stjärn-animation vid rätt svar
struct StarBurstView: View {
    @Binding var isActive: Bool
    var starCount: Int = 5
    
    @State private var stars: [StarParticle] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(stars) { star in
                    Image(systemName: "star.fill")
                        .font(.system(size: star.size))
                        .foregroundColor(.yellow)
                        .position(star.position)
                        .scaleEffect(star.scale)
                        .opacity(star.opacity)
                }
            }
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    startStarBurst(in: geometry.size)
                }
            }
        }
        .allowsHitTesting(false)
    }
    
    private func startStarBurst(in size: CGSize) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        
        stars = (0..<starCount).map { i in
            let angle = (Double(i) / Double(starCount)) * 2 * .pi
            return StarParticle(
                position: center,
                targetPosition: CGPoint(
                    x: center.x + cos(angle) * 150,
                    y: center.y + sin(angle) * 150
                )
            )
        }
        
        // Animera ut
        withAnimation(.easeOut(duration: 0.6)) {
            for i in stars.indices {
                stars[i].position = stars[i].targetPosition
                stars[i].scale = 1.5
            }
        }
        
        // Fade out
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeOut(duration: 0.3)) {
                for i in stars.indices {
                    stars[i].opacity = 0
                }
            }
        }
        
        // Cleanup
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            stars.removeAll()
            isActive = false
        }
    }
}

struct StarParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let targetPosition: CGPoint
    var scale: CGFloat = 0.5
    var opacity: Double = 1
    let size: CGFloat = CGFloat.random(in: 20...35)
}

// MARK: - Previews

#Preview("Confetti") {
    struct PreviewWrapper: View {
        @State var showConfetti = false
        
        var body: some View {
            ZStack {
                Color.gray.opacity(0.2)
                
                Button("Visa Konfetti! 🎉") {
                    showConfetti = true
                }
                .buttonStyle(.borderedProminent)
                
                ConfettiView(isActive: $showConfetti, intensity: .heavy)
            }
        }
    }
    
    return PreviewWrapper()
}
