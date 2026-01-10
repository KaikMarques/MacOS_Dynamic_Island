import SwiftUI

struct ContentView: View {
    // Estado para controlar o tema
    @State private var useLiquidGlassTheme: Bool = true
    
    var body: some View {
        ZStack {
            // Background Dinâmico da Janela
            if useLiquidGlassTheme {
                // Fundo com leve ruído ou cor sólida escura para contraste com o vidro
                Color.black.opacity(0.12)
                    .ignoresSafeArea()
            } else {
                Color(NSColor.windowBackgroundColor)
                    .ignoresSafeArea()
            }
            
            VStack {
                // Header com Toggle de Tema
                HStack {
                    Label("V2 Dynamic Island", systemImage: "macwindow")
                        .font(.headline)
                        .opacity(0.7)
                    
                    Spacer()
                    
                    Toggle("Modo Liquid Glass", isOn: $useLiquidGlassTheme)
                        .toggleStyle(.switch)
                        .controlSize(.small)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
                
                // Renderização condicional do conteúdo principal
                if useLiquidGlassTheme {
                    OnboardingSliderView()
                        // Transição suave ao ativar/desativar o tema
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.95)),
                            removal: .opacity.combined(with: .scale(scale: 1.05))
                        ))
                } else {
                    // Placeholder para o estilo clássico/antigo
                    VStack {
                        Image(systemName: "cube.box")
                            .font(.system(size: 60))
                            .foregroundStyle(.tertiary)
                        Text("Modo Clássico")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                Spacer()
            }
        }
        .frame(minWidth: 1000, minHeight: 700) // Janela inicial ajustada para telas maiores
        .animation(.easeInOut(duration: 0.8), value: useLiquidGlassTheme)
    }
}
