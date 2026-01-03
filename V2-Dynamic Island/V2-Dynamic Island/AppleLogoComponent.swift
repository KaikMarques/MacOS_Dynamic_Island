import SwiftUI

// Versão 5.5 - Neon "Espesso" com Respiração Lenta
struct AppleLogoComponent: View {
    let isExpanded: Bool
    let isSettingsOpen: Bool
    
    var onTap: (() -> Void)? = nil
    
    @State private var lightPos: CGFloat = -1.5
    @State private var glowOpacity: Double = 0.0
    @State private var revealProgress: CGFloat = 0.0
    
    // Intensidade inicial
    @State private var pulseIntensity: Double = 0.6
    
    private let silverColors: [Color] = [
        Color(white: 0.45),
        Color(white: 0.90),
        Color(white: 0.65),
        Color(white: 0.95),
        Color(white: 0.55)
    ]
    
    private let goldColor = Color(red: 0.85, green: 0.72, blue: 0.25)
    private let offWhite = Color(white: 0.90)

    var body: some View {
        ZStack {
            // 1. CAMADA BASE
            Image(systemName: "applelogo")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(isExpanded ? offWhite : .white)
            
            // 2. CAMADA PREMIUM (O Logo Metálico)
            ZStack {
                Image(systemName: "applelogo")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: silverColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                GoldDotsPattern(color: goldColor)
                    .mask(
                        Image(systemName: "applelogo")
                            .font(.system(size: 14, weight: .medium))
                    )
            }
            .opacity(isExpanded ? 1 : 0)
            .mask(
                Rectangle()
                    .scaleEffect(x: revealProgress, y: 1.0, anchor: .leading)
            )
            // --- GLOW DE AMBIENTE (O que ilumina o fundo) ---
            .shadow(
                color: isSettingsOpen
                    ? .white.opacity(0.8 * pulseIntensity) // Aumentado a base
                    : goldColor.opacity(0.35 * glowOpacity),
                radius: isSettingsOpen ? 12 : 6,
                x: 0,
                y: 0
            )
            .shadow(
                color: isSettingsOpen
                    ? .white.opacity(0.5 * pulseIntensity)
                    : .clear,
                radius: isSettingsOpen ? 35 : 0, // Raio maior para espalhar mais
                x: 0,
                y: 0
            )
            
            // 3. CAMADA DE NEON ESPESSO (NOVO DESIGN)
            if isSettingsOpen {
                ZStack {
                    // Núcleo Sólido (O fio do filamento)
                    Image(systemName: "applelogo")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                        .blur(radius: 0.6)
                    
                    // Corpo do Neon (A luz espessa ao redor do fio)
                    Image(systemName: "applelogo")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                        .blur(radius: 3.0) // Aumentado para dar "corpo"
                        .opacity(1.0)

                    // Aura Externa (O gás ionizado em volta)
                    Image(systemName: "applelogo")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                        .blur(radius: 6.0)
                        .opacity(0.8)
                }
                .opacity(pulseIntensity)
                .blendMode(.screen)
            }
            
            // 4. O FEIXE DE LUZ (Animação de entrada original)
            GeometryReader { geo in
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                .white.opacity(0.4),
                                .white.opacity(1.0),
                                .white.opacity(0.4),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .scaleEffect(x: 0.45)
                    .rotationEffect(.degrees(-25))
                    .offset(x: lightPos * geo.size.width)
                    .mask(
                        Image(systemName: "applelogo")
                            .font(.system(size: 14, weight: .medium))
                            .position(x: geo.size.width/2, y: geo.size.height/2)
                    )
            }
            .opacity(isExpanded ? 1 : 0)
        }
        .frame(width: 20, height: 20)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
        }
        .onChange(of: isExpanded) { oldValue, newValue in
            if newValue {
                startAnimation()
            } else {
                resetAnimation()
            }
        }
        .onChange(of: isSettingsOpen) { oldValue, newValue in
            if newValue {
                // MUDANÇA CRÍTICA: Duração aumentada para 2.5s (Respiração Lenta)
                // Intensity aumentada para 2.0 (Brilho Extremo no pico)
                withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                    pulseIntensity = 2.0
                }
            } else {
                withAnimation(.easeOut(duration: 0.5)) {
                    pulseIntensity = 0.6
                }
            }
        }
    }
    
    private func startAnimation() {
        lightPos = -1.5
        revealProgress = 0.0
        glowOpacity = 0.0
        
        let slowMotionCurve = Animation.timingCurve(0.1, 0.9, 0.9, 0.1, duration: 3.8)
        
        withAnimation(slowMotionCurve.delay(1.5)) {
            lightPos = 2.5
            revealProgress = 1.5
        }
        
        withAnimation(.easeInOut(duration: 1.5).delay(1.5)) {
            glowOpacity = 1.0
        }
    }
    
    private func resetAnimation() {
        lightPos = -1.5
        revealProgress = 0.0
        glowOpacity = 0.0
        pulseIntensity = 0.6
    }
}

struct GoldDotsPattern: View {
    let color: Color
    var body: some View {
        Canvas { context, size in
            let dotSize: CGFloat = 1.0
            let spacing: CGFloat = 3.0
            for x in stride(from: 0, to: size.width, by: spacing) {
                for y in stride(from: 0, to: size.height, by: spacing) {
                    let rect = CGRect(
                        x: x + CGFloat.random(in: -0.4...0.4),
                        y: y + CGFloat.random(in: -0.4...0.4),
                        width: dotSize,
                        height: dotSize
                    )
                    context.fill(Path(ellipseIn: rect), with: .color(color))
                }
            }
        }
    }
}
