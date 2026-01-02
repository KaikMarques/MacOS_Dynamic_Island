import SwiftUI

// Versão 3.9 - Brilho Intenso com Animação "Fast-Slow-Fast" e Delay de 1.5s
struct AppleLogoComponent: View {
    let isExpanded: Bool
    @State private var lightPos: CGFloat = -1.5
    @State private var glowOpacity: Double = 0.0
    
    // Cores P3 vibrantes para o efeito de fundo (Arco-Íris Apple)
    private let rainbowColors: [Color] = [
        Color(red: 0.95, green: 0.20, blue: 0.20),
        Color(red: 1.00, green: 0.50, blue: 0.00),
        Color(red: 1.00, green: 0.85, blue: 0.00),
        Color(red: 0.20, green: 0.80, blue: 0.20),
        Color(red: 0.00, green: 0.50, blue: 1.00),
        Color(red: 0.60, green: 0.20, blue: 1.00)
    ]

    var body: some View {
        ZStack {
            // Logótipo em repouso (Branco sólido)
            Image(systemName: "applelogo")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(isExpanded ? .white.opacity(0.12) : .white)
            
            if isExpanded {
                // Camada Arco-Íris (Fica visível após a expansão)
                Image(systemName: "applelogo")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: rainbowColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    // Brilho externo aumentado
                    .shadow(color: .blue.opacity(0.45), radius: glowOpacity * 12, x: 0, y: 0)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                
                // Light Scan: O brilho de "vidro" intenso
                GeometryReader { geo in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .clear,
                                    .white.opacity(0.4),
                                    .white.opacity(1.0), // Brilho central máximo
                                    .white.opacity(0.4),
                                    .clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .scaleEffect(x: 0.35)
                        .rotationEffect(.degrees(-25))
                        .offset(x: lightPos * geo.size.width)
                        .mask(
                            Image(systemName: "applelogo")
                                .font(.system(size: 14, weight: .medium))
                                .position(x: geo.size.width/2, y: geo.size.height/2)
                        )
                }
                .onAppear {
                    lightPos = -1.5
                    glowOpacity = 0.0
                    
                    // Curva customizada: Rápido-Lento-Rápido
                    let customCurve = Animation.timingCurve(0.15, 0.85, 0.85, 0.15, duration: 2.0)
                    
                    withAnimation(customCurve.delay(1.5)) {
                        lightPos = 2.5
                    }
                    
                    withAnimation(.easeInOut(duration: 1.0).delay(1.5)) {
                        glowOpacity = 1.0
                    }
                }
            }
        }
        .frame(width: 20, height: 20)
        .drawingGroup()
    }
}
