import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - Configuration Structure
/// Define a configuração visual e comportamental do Liquid Slider.
struct LiquidSliderConfig {
    var height: CGFloat = 50
    var barColor: Color = Color.gray.opacity(0.2)
    var activeColor: Color = Color.blue
    // Configurações do efeito Metaball (Líquido)
    var liquidRadius: CGFloat = 15
    var blurRadius: CGFloat = 10
    var iconName: String? = "speaker.wave.3.fill"
    
    static let `default` = LiquidSliderConfig()
}

// MARK: - Haptic Feedback Engine
/// Gerenciador unificado de feedback tátil para macOS e iOS.
final class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    func impact(style: HapticStyle) {
        #if os(macOS)
        let pattern: NSHapticFeedbackManager.FeedbackPattern
        switch style {
        case .light: pattern = .alignment
        case .medium: pattern = .levelChange
        case .heavy: pattern = .generic
        }
        NSHapticFeedbackManager.defaultPerformer.perform(pattern, performanceTime: .now)
        #elseif os(iOS)
        let styleUI: UIImpactFeedbackGenerator.FeedbackStyle
        switch style {
        case .light: styleUI = .light
        case .medium: styleUI = .medium
        case .heavy: styleUI = .heavy
        }
        let generator = UIImpactFeedbackGenerator(style: styleUI)
        generator.impactOccurred()
        #endif
    }
    
    enum HapticStyle {
        case light, medium, heavy
    }
}

// MARK: - Liquid Slider Component
struct LiquidSlider: View {
    // MARK: - Properties
    @Binding var value: CGFloat // Valor de 0.0 a 1.0
    var config: LiquidSliderConfig = .default
    
    // Estado interno para animações de arrasto
    @State private var isDragging: Bool = false
    @State private var viewWidth: CGFloat = 0
    
    // Identificadores para os Símbolos do Canvas
    private enum LayerID: Int {
        case background
        case liquid
    }
    
    // MARK: - Computed Properties
    private var progressWidth: CGFloat {
        // Garante que a largura nunca seja menor que a altura (para manter o círculo inicial)
        max(config.height, min(viewWidth * value, viewWidth))
    }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Camada Base (Trilha inativa)
                Capsule()
                    .fill(config.barColor)
                    .frame(height: config.height)
                    .overlay(iconOverlay, alignment: .leading)
                
                // Camada de Renderização Líquida (Canvas)
                // Usamos Canvas para desenhar os símbolos e aplicar filtros gráficos nativos
                Canvas { context, size in
                    // Desenha os símbolos (Barra + Bolinha) com Blur
                    context.addFilter(.alphaThreshold(min: 0.5, color: config.activeColor))
                    context.addFilter(.blur(radius: config.blurRadius))
                    
                    // Desenha a camada 'liquid' que contém as formas unidas
                    context.drawLayer { ctx in
                        if let resolvedSymbol = context.resolveSymbol(id: LayerID.liquid) {
                            ctx.draw(resolvedSymbol, at: CGPoint(x: size.width / 2, y: size.height / 2))
                        }
                    }
                } symbols: {
                    // Definição dos elementos geométricos que serão "liquefeitos"
                    liquidSymbols(width: progressWidth)
                        .tag(LayerID.liquid)
                }
                // Importante: O Canvas precisa acompanhar o tamanho da view pai
                .frame(width: geo.size.width, height: config.height * 2) // Altura extra para o blur não cortar
                .offset(y: -config.height / 2) // Re-centraliza devido à altura extra
                
                // Overlay de Brilho (Glossy Effect) - Desenhado por cima do líquido
                glossyOverlay
                    .frame(width: progressWidth, height: config.height)
                    .allowsHitTesting(false)
            }
            .onAppear {
                self.viewWidth = geo.size.width
            }
            .onChange(of: geo.size.width) { _, newValue in
                self.viewWidth = newValue
            }
            // Gesture Handling
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        handleDrag(value: gesture, geoWidth: geo.size.width)
                    }
                    .onEnded { _ in
                        handleDragEnd()
                    }
            )
        }
        .frame(height: config.height)
    }
    
    // MARK: - Component Subviews
    
    private var iconOverlay: some View {
        Group {
            if let icon = config.iconName {
                Image(systemName: icon)
                    .font(.system(size: config.height * 0.4, weight: .bold))
                    .foregroundColor(.secondary.opacity(0.5))
                    .padding(.leading, config.height / 3)
            }
        }
    }
    
    private var glossyOverlay: some View {
        Capsule()
            .stroke(Color.white.opacity(0.3), lineWidth: 1)
            .padding(1)
            .blur(radius: 0.5)
    }
    
    // MARK: - Liquid Symbols Definition
    /// Define as formas geométricas puras que serão passadas ao Canvas para sofrerem o blur
    @ViewBuilder
    private func liquidSymbols(width: CGFloat) -> some View {
        // Usamos um container maior para garantir coordenadas corretas no Canvas
        ZStack(alignment: .leading) {
            // 1. A Barra de Progresso
            Capsule()
                .fill(Color.white) // A cor aqui não importa, será substituída pelo filtro do Canvas
                .frame(width: width, height: config.height)
            
            // 2. O "Thumb" (A bolinha da ponta)
            // Movemos ela levemente para simular a tensão
            Circle()
                .fill(Color.white)
                .frame(width: config.height, height: config.height)
                .offset(x: width - config.height + (isDragging ? 5 : 0))
            
            // 3. Partícula de arrasto (Rastro)
            if isDragging {
                Circle()
                    .fill(Color.white)
                    .frame(width: config.height * 0.5, height: config.height * 0.5)
                    .offset(x: width - config.height - 10)
            }
        }
        // Centraliza o conteúdo no Canvas (que tem height * 2)
        .frame(width: viewWidth, height: config.height * 2)
    }
    
    // MARK: - Logic Helpers
    
    private func handleDrag(value gesture: DragGesture.Value, geoWidth: CGFloat) {
        if !isDragging {
            isDragging = true
            HapticManager.shared.impact(style: .light)
        }
        
        let locationX = gesture.location.x
        let percentage = locationX / geoWidth
        
        // Clamp value between 0 and 1
        let newValue = max(0, min(1, percentage))
        
        // Feedback tátil ao atingir extremos
        if (newValue == 0 || newValue == 1) && (self.value > 0.01 && self.value < 0.99) {
             HapticManager.shared.impact(style: .medium)
        }
        
        // Animação suave no valor
        withAnimation(.interactiveSpring(response: 0.2, dampingFraction: 0.8)) {
            self.value = newValue
        }
    }
    
    private func handleDragEnd() {
        isDragging = false
        HapticManager.shared.impact(style: .heavy)
        
        // Efeito elástico final ("Snap")
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 15)) {
            // O trigger de animação aqui é apenas visual, pois o valor já está setado
        }
    }
}

// MARK: - Preview Provider
struct LiquidSlider_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 80) {
                // Exemplo 1: Padrão
                LiquidSlider(value: .constant(0.5))
                    .frame(width: 300)
                
                // Exemplo 2: Customizado (Roxo e Maior)
                LiquidSlider(
                    value: .constant(0.7),
                    config: LiquidSliderConfig(
                        height: 60,
                        activeColor: .purple,
                        liquidRadius: 20,
                        blurRadius: 12,
                        iconName: "lightbulb.fill"
                    )
                )
                .frame(width: 300)
                
                // Exemplo 3: Pequeno (Estilo Volume Control)
                LiquidSlider(
                    value: .constant(0.3),
                    config: LiquidSliderConfig(
                        height: 30,
                        activeColor: .green,
                        liquidRadius: 10,
                        blurRadius: 5,
                        iconName: nil
                    )
                )
                .frame(width: 200)
            }
        }
    }
}
