import SwiftUI

// MARK: - Liquid Glass Theme Configuration
struct LiquidGlassConfig {
    var cornerRadius: CGFloat = 20
    var intensity: Material = .ultraThin
    var borderOpacity: Double = 0.4
    var shadowRadius: CGFloat = 10
}

// MARK: - Liquid Glass View Modifier
struct LiquidGlassStyle: ViewModifier {
    var config: LiquidGlassConfig
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Camada de Material (Blur Nativo do macOS)
                    config.intensity
                        .opacity(0.85)
                    
                    // Gradiente Sutil para simular reflexo de "líquido"
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(colorScheme == .dark ? 0.1 : 0.4),
                            Color.white.opacity(0.0)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            )
            .cornerRadius(config.cornerRadius)
            // Borda interna brilhante (efeito de espessura do vidro)
            .overlay(
                RoundedRectangle(cornerRadius: config.cornerRadius)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(config.borderOpacity),
                                Color.white.opacity(0.1),
                                Color.black.opacity(0.1),
                                Color.white.opacity(config.borderOpacity)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            // Sombra difusa para profundidade
            .shadow(
                color: Color.black.opacity(0.15),
                radius: config.shadowRadius,
                x: 0,
                y: 5
            )
    }
}

// MARK: - Extension for Easy Usage
extension View {
    func liquidGlass(cornerRadius: CGFloat = 20) -> some View {
        self.modifier(LiquidGlassStyle(config: LiquidGlassConfig(cornerRadius: cornerRadius)))
    }
}
