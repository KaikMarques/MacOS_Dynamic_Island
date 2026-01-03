import SwiftUI

// --- COMPONENTE AUXILIAR (Movido para o topo para garantir visibilidade) ---
struct MonitorRow: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 14, design: .monospaced))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// Versão 5.7 - Topo Invisível (Sem borda no Notch Físico)
struct MacBookNotchShape: Shape {
    var isExpanded: Bool
    
    var animatableData: CGFloat {
        get { isExpanded ? 1 : 0 }
        set { }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        let transitionRadius: CGFloat = 10
        let cornerRadius: CGFloat = isExpanded ? 32 : 14
        
        path.move(to: CGPoint(x: 0, y: 0))
        path.addArc(center: CGPoint(x: 0, y: transitionRadius),
                    radius: transitionRadius,
                    startAngle: Angle(degrees: -90),
                    endAngle: Angle(degrees: 0),
                    clockwise: false)
        path.addLine(to: CGPoint(x: transitionRadius, y: height - cornerRadius))
        path.addArc(center: CGPoint(x: transitionRadius + cornerRadius, y: height - cornerRadius),
                    radius: cornerRadius,
                    startAngle: Angle(degrees: 180),
                    endAngle: Angle(degrees: 90),
                    clockwise: true)
        path.addLine(to: CGPoint(x: width - transitionRadius - cornerRadius, y: height))
        path.addArc(center: CGPoint(x: width - transitionRadius - cornerRadius, y: height - cornerRadius),
                    radius: cornerRadius,
                    startAngle: Angle(degrees: 90),
                    endAngle: Angle(degrees: 0),
                    clockwise: true)
        path.addLine(to: CGPoint(x: width - transitionRadius, y: transitionRadius))
        path.addArc(center: CGPoint(x: width, y: transitionRadius),
                    radius: transitionRadius,
                    startAngle: Angle(degrees: 180),
                    endAngle: Angle(degrees: 270),
                    clockwise: false)
        path.closeSubpath()
        return path
    }
}

struct IslandView: View {
    @State private var isExpanded = false
    @State private var isHovered = false
    @State private var showContent = false
    @State private var sensorPulse = false
    @State private var showSettings = false
    
    private let springResponse = Animation.spring(response: 0.52, dampingFraction: 0.75)

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // 1. FUNDO DINÂMICO (Background Preto)
                ZStack {
                    MacBookNotchShape(isExpanded: isExpanded)
                        .fill(
                            LinearGradient(
                                stops: [
                                    .init(color: .black, location: 0),
                                    .init(color: .black, location: isExpanded ? 0.85 : 1.0),
                                    .init(color: Color(white: 0.08), location: 1.0)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .opacity(showSettings ? 0 : 1)
                    
                    if showSettings {
                        MacBookNotchShape(isExpanded: true)
                            .fill(.ultraThinMaterial)
                            .transition(.opacity)
                    }
                }
                .shadow(color: .black.opacity(isExpanded ? 0.7 : 0.3), radius: isExpanded ? 40 : 10, y: 15)
                
                // 2. BORDA METALIZADA (A Mágica acontece aqui)
                // Usamos o AuroraBackground como um overlay, mas cortado no formato da borda
                AuroraBackground(isActive: isHovered || isExpanded || showSettings)
                    // Aplica máscara de opacidade PRIMEIRO para esconder o topo (Notch físico)
                    .mask(
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0.0), // Topo invisível
                                .init(color: .clear, location: 0.2),
                                .init(color: .white, location: 0.5), // Começa a aparecer
                                .init(color: .white, location: 1.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    // DEPOIS corta no formato da linha fina (Stroke)
                    .mask(
                        MacBookNotchShape(isExpanded: isExpanded || showSettings)
                            .stroke(lineWidth: 1.2) // Espessura da borda
                    )
                    // Blend mode para garantir que o brilho interaja bem
                    .blendMode(.screen)
                
                // 3. CONTEÚDO DA ILHA
                VStack(spacing: 0) {
                    HStack(alignment: .center) {
                        AppleLogoComponent(
                            isExpanded: isExpanded || showSettings,
                            isSettingsOpen: showSettings
                        ) {
                            withAnimation(springResponse) {
                                if isExpanded {
                                    showSettings.toggle()
                                }
                            }
                        }
                        .scaleEffect((isExpanded || showSettings) ? 1.18 : (isHovered ? 1.05 : 1.0))
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
                            // Barras de áudio
                            HStack(spacing: 2.8) {
                                ForEach(0..<3) { i in
                                    RoundedRectangle(cornerRadius: 1.5)
                                        .fill(Color.blue.gradient)
                                        .frame(width: 2.5, height: (isHovered || isExpanded) ? 10 : 0)
                                        .animation(
                                            (isHovered || isExpanded)
                                            ? .easeInOut(duration: 0.6).repeatForever(autoreverses: true).delay(Double(i) * 0.12)
                                            : .easeInOut(duration: 0.2),
                                            value: isHovered || isExpanded
                                        )
                                }
                            }
                            .opacity((isExpanded || showSettings) ? 0 : 1)
                            
                            // Sensores
                            HStack(spacing: 7) {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 6, height: 6)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.green, lineWidth: 1.5)
                                            .scaleEffect(sensorPulse ? 1.8 : 1.0)
                                            .opacity(sensorPulse ? 0 : 0.5)
                                    )
                                Circle().fill(Color.orange).frame(width: 6, height: 6)
                            }
                        }
                    }
                    .padding(.horizontal, 22)
                    .frame(height: (isExpanded || showSettings) ? 42 : 37)
                    
                    if showContent || showSettings {
                        ZStack {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("SISTEMA OPERACIONAL")
                                        .font(.system(size: 8, weight: .black))
                                        .foregroundStyle(.white.opacity(0.35))
                                        .tracking(2.5)
                                    Spacer()
                                    Image(systemName: "cpu.fill")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.white.opacity(0.15))
                                }
                                
                                Divider().background(Color.white.opacity(0.04))
                                
                                HStack(spacing: 30) {
                                    // MonitorRow agora deve ser encontrado sem problemas
                                    MonitorRow(label: "ECRÃ", value: "2560×1664", color: Color.blue)
                                    MonitorRow(label: "STATUS", value: "OTIMIZADO", color: Color.green)
                                }
                            }
                            .blur(radius: showSettings ? 10 : 0)
                            
                            if showSettings {
                                VStack(spacing: 12) {
                                    Text("CONFIGURAÇÕES")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(.white)
                                    
                                    HStack(spacing: 20) {
                                        VStack {
                                            Image(systemName: "circle.grid.cross.fill")
                                            Text("Sensores").font(.system(size: 8))
                                        }
                                        VStack {
                                            Image(systemName: "gauge.with.needle.fill")
                                            Text("Velocidade").font(.system(size: 8))
                                        }
                                    }
                                    .foregroundStyle(.white.opacity(0.8))
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, 28)
                        .padding(.bottom, 24)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.85)).combined(with: .move(edge: .top)),
                            removal: .opacity.combined(with: .scale(scale: 0.01))
                        ))
                    }
                }
                .animation(springResponse, value: isExpanded)
                .animation(springResponse, value: showSettings)
            }
            .frame(width: (isExpanded || showSettings) ? 440 : (isHovered ? 315 : 285),
                   height: (isExpanded || showSettings) ? 200 : 37)
            .onHover { hovering in
                if !showSettings {
                    withAnimation(springResponse) {
                        isHovered = hovering
                        if !hovering {
                            showContent = false
                            isExpanded = false
                        }
                    }
                }
            }
            .onTapGesture {
                withAnimation(springResponse) {
                    if showSettings {
                        showSettings = false
                    } else {
                        isExpanded.toggle()
                    }
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: false)) {
                    sensorPulse = true
                }
            }
            .onChange(of: isExpanded) { oldValue, newValue in
                if newValue {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                        if isExpanded {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                showContent = true
                            }
                        }
                    }
                } else {
                    showContent = false
                    showSettings = false
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .ignoresSafeArea()
    }
}
