import SwiftUI

// Versão 4.9 - Revelação Permanente "Silver & Gold" sobre Off-White
struct AppleLogoComponent: View {
    let isExpanded: Bool
    @State private var lightPos: CGFloat = -1.5
    @State private var glowOpacity: Double = 0.0
    
    // Tons metálicos premium (Silver/Platina)
    private let silverColors: [Color] = [
        Color(white: 0.4),
        Color(white: 0.85),
        Color(white: 0.6),
        Color(white: 0.9),
        Color(white: 0.5)
    ]
    
    private let goldColor = Color(red: 0.83, green: 0.69, blue: 0.22)
    // Cor Off-White para o estado inicial
    private let offWhite = Color(white: 0.92)

    var body: some View {
        ZStack {
            // 1. Base Inicial: Off-White (Visível antes da luz passar)
            Image(systemName: "applelogo")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(isExpanded ? offWhite : .white)
            
            if isExpanded {
                ZStack {
                    // 2. Camada Premium Revelada (Prata + Ouro)
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
                    // MÁSCARA DE REVELAÇÃO PERMANENTE:
                    // À medida que lightPos avança, esta máscara "abre" a cor premium
                    .mask(
                        GeometryReader { geo in
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        stops: [
                                            .init(color: .black, location: 0),
                                            .init(color: .black, location: 0.9), // Borda da revelação
                                            .init(color: .clear, location: 1.0)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * 2.5)
                                // O offset move a "janela" de visibilidade junto com a luz
                                .offset(x: (lightPos - 1.2) * geo.size.width)
                        }
                    )
                }
                .shadow(color: goldColor.opacity(0.3 * glowOpacity), radius: 8, x: 0, y: 0)
                
                // 3. O Feixe de Luz (O Scanner que transforma a cor)
                GeometryReader { geo in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .clear,
                                    .white.opacity(0.3),
                                    .white.opacity(1.0), // Centro do brilho
                                    .white.opacity(0.3),
                                    .clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .scaleEffect(x: 0.4)
                        .rotationEffect(.degrees(-25))
                        .offset(x: lightPos * geo.size.width)
                        .mask(
                            Image(systemName: "applelogo")
                                .font(.system(size: 14, weight: .medium))
                                .position(x: geo.size.width/2, y: geo.size.height/2)
                        )
                }
                .onAppear {
                    // Reiniciar estados ao expandir
                    lightPos = -1.8
                    glowOpacity = 0.0
                    
                    // CURVA CUSTOMIZADA: Entrada rápida, MEIO MUITO LENTO (Slow Motion), Saída rápida
                    // Aumentamos o tempo no centro (platô) para fixar a cor
                    let extremeSlowCenter = Animation.timingCurve(0.1, 1.0, 0.9, 0.0, duration: 3.5)
                    
                    withAnimation(extremeSlowCenter.delay(1.5)) {
                        lightPos = 2.8
                    }
                    
                    withAnimation(.easeInOut(duration: 1.5).delay(1.5)) {
                        glowOpacity = 1.0
                    }
                }
            }
        }
        .frame(width: 20, height: 20)
        .drawingGroup()
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
