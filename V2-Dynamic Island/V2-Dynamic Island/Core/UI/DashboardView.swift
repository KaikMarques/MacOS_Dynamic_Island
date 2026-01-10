import SwiftUI

// MARK: - Dashboard View Structure
/// A visualização principal do painel de controle, orquestrando múltiplos LiquidSliders
/// e outros componentes de UI em um layout de grid responsivo.
struct DashboardView: View {
    
    // MARK: - State Properties
    // Gerenciamento de estado local para os controles
    @State private var volumeLevel: CGFloat = 0.65
    @State private var brightnessLevel: CGFloat = 0.4
    @State private var micLevel: CGFloat = 0.8
    
    // Estados de animação da UI
    @State private var isVisible: Bool = false
    
    // MARK: - Configuration Constants
    // Definições de layout para manter consistência
    private let gridSpacing: CGFloat = 16
    private let cardCornerRadius: CGFloat = 24
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background Layer (Blur Material)
            VisualEffectBackground()
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Header Section
                    headerView
                    
                    Divider()
                        .background(Color.white.opacity(0.2))
                    
                    // Sliders Section
                    VStack(spacing: 20) {
                        sectionTitle("Audio & Display")
                        
                        // Volume Control (Configuração Azul)
                        controlCard {
                            LiquidSlider(
                                value: $volumeLevel,
                                config: LiquidSliderConfig(
                                    height: 44,
                                    barColor: Color.black.opacity(0.1),
                                    activeColor: Color.blue,
                                    liquidRadius: 16,
                                    blurRadius: 10,
                                    iconName: "speaker.wave.3.fill" // O ícone agora vive aqui dentro
                                )
                            )
                        }
                        
                        // Brightness Control (Configuração Laranja/Amarela)
                        controlCard {
                            LiquidSlider(
                                value: $brightnessLevel,
                                config: LiquidSliderConfig(
                                    height: 44,
                                    barColor: Color.black.opacity(0.1),
                                    activeColor: Color.orange,
                                    liquidRadius: 16,
                                    blurRadius: 10,
                                    iconName: "sun.max.fill"
                                )
                            )
                        }
                        
                        // Mic Sensitivity (Configuração Vermelha)
                        controlCard {
                            LiquidSlider(
                                value: $micLevel,
                                config: LiquidSliderConfig(
                                    height: 44,
                                    barColor: Color.black.opacity(0.1),
                                    activeColor: Color.red,
                                    liquidRadius: 14,
                                    blurRadius: 8,
                                    iconName: "mic.fill"
                                )
                            )
                        }
                    }
                }
                .padding(24)
            }
        }
        .frame(width: 400, height: 600) // Tamanho padrão para preview ou janela popover
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                isVisible = true
            }
        }
    }
    
    // MARK: - Subcomponents
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Control Center")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Dynamic Island V2")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            
            // Status Indicator Simulation
            Circle()
                .fill(Color.green)
                .frame(width: 8, height: 8)
                .padding(8)
                .background(.ultraThinMaterial, in: Circle())
        }
    }
    
    private func sectionTitle(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.secondary)
            .padding(.leading, 4)
    }
    
    /// Wrapper para encapsular os sliders em cartões visuais
    private func controlCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
            
            content()
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
        }
        .frame(height: 70) // Altura fixa para o cartão do controle
    }
}

// MARK: - Helper Views

/// Fundo visual adaptativo para macOS/iOS
struct VisualEffectBackground: View {
    var body: some View {
        #if os(macOS)
        VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
        #else
        Rectangle()
            .fill(.ultraThinMaterial)
        #endif
    }
}

#if os(macOS)
/// Wrapper do NSVisualEffectView para SwiftUI no macOS
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        return visualEffectView
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
#endif

// MARK: - Preview
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
