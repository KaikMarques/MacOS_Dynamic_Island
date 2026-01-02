import SwiftUI

// Versão 5.1 - Revelação "Liquid Paint" com Estabilidade de Estado
struct AppleLogoComponent: View {
    let isExpanded: Bool
    
    // Estados internos para controlar a animação de varredura e revelação
    @State private var lightPos: CGFloat = -1.5
    @State private var glowOpacity: Double = 0.0
    @State private var revealProgress: CGFloat = 0.0
    
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
            // 1. CAMADA BASE: Off-White (Visível quando expandido, antes da revelação)
            Image(systemName: "applelogo")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(isExpanded ? offWhite : .white)
            
            // 2. CAMADA PREMIUM: Silver & Gold (Revelada permanentemente pela luz)
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
            // MÁSCARA DE REVELAÇÃO: Um retângulo que escala para a direita conforme a luz passa
            .mask(
                Rectangle()
                    // O progresso da escala segue a posição da luz para "pintar" o logo
                    .scaleEffect(x: revealProgress, y: 1.0, anchor: .leading)
            )
            .shadow(color: goldColor.opacity(0.35 * glowOpacity), radius: 6, x: 0, y: 0)
            
            // 3. O FEIXE DE LUZ (A ferramenta que revela a cor)
            GeometryReader { geo in
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                .white.opacity(0.4),
                                .white.opacity(1.0), // Brilho central
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
        .drawingGroup()
        // Sincronização da animação quando o estado de expansão muda
        .onChange(of: isExpanded) { oldValue, newValue in
            if newValue {
                startAnimation()
            } else {
                resetAnimation()
            }
        }
    }
    
    private func startAnimation() {
        // Reset inicial antes de começar
        lightPos = -1.5
        revealProgress = 0.0
        glowOpacity = 0.0
        
        // Curva Rápida-Lenta-Rápida com Slow Motion estendido no centro
        let slowMotionCurve = Animation.timingCurve(0.1, 0.9, 0.9, 0.1, duration: 3.8)
        
        // Dispara a varredura de luz
        withAnimation(slowMotionCurve.delay(1.5)) {
            lightPos = 2.5
        }
        
        // Dispara a revelação da cor (O retângulo de máscara crescendo)
        withAnimation(slowMotionCurve.delay(1.5)) {
            // revealProgress vai para 1.5 para garantir que cubra 100% da largura
            revealProgress = 1.5
        }
        
        // Suavização do brilho/glow
        withAnimation(.easeInOut(duration: 1.5).delay(1.5)) {
            glowOpacity = 1.0
        }
    }
    
    private func resetAnimation() {
        // Quando fecha, reseta tudo sem animação para estar pronto para a próxima
        lightPos = -1.5
        revealProgress = 0.0
        glowOpacity = 0.0
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
