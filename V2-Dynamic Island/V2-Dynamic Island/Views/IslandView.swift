//
//  IslandView.swift
//  V2-Dynamic Island
//
//  Ver. 6.0 - Integração Liquid Glass Transparente
//

import SwiftUI

struct IslandView: View {
    @State private var isExpanded = false
    @State private var isHovered = false
    @State private var showContent = false
    @State private var sensorPulse = false
    @State private var showSettings = false
    
    // Mola calibrada (Original)
    private let springResponse = Animation.spring(response: 0.52, dampingFraction: 0.75)

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // 1. FUNDO & CAMADAS DE MATERIAL
                ZStack {
                    // --- MODO FECHADO (Original Hardware Gradient) ---
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
                    
                    // --- MODO EXPANDIDO (LIQUID GLASS EFFECT) ---
                    if showSettings {
                        ZStack {
                            // Camada A: Blur do Sistema (Vê o wallpaper borrado atrás)
                            MacBookNotchShape(isExpanded: true)
                                .fill(.ultraThinMaterial)
                                .opacity(0.5) // Transparência agressiva para ver o fundo
                            
                            // Camada B: O Shader Líquido (Brilhos e Ondas)
                            LiquidGlassBackground()
                                .clipShape(MacBookNotchShape(isExpanded: true))
                                .opacity(0.8) // Mistura o shader com o blur
                            
                            // Camada C: Ruído sutil para textura
                            MacBookNotchShape(isExpanded: true)
                                .fill(Color.white.opacity(0.03))
                                .blendMode(.overlay)
                        }
                        .transition(.opacity)
                    }
                }
                .shadow(
                    color: .black.opacity(isExpanded ? 0.6 : 0.3),
                    radius: isExpanded ? 40 : 10,
                    y: 15
                )
                
                // 2. EFEITO AURORA (Borda Neon Original)
                AuroraBackground(isActive: isHovered || isExpanded)
                    .mask(
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0.0),
                                .init(color: .clear, location: 0.2),
                                .init(color: .white, location: 0.5),
                                .init(color: .white, location: 1.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .mask(
                        MacBookNotchShape(isExpanded: isExpanded || showSettings)
                            .stroke(lineWidth: 1.2)
                    )
                    .blendMode(.screen)
                
                // 3. CONTEÚDO (Mantido Original)
                VStack(spacing: 0) {
                    // Header
                    HStack(alignment: .center) {
                        AppleLogoComponent(
                            isExpanded: isHovered || isExpanded || showSettings,
                            isSettingsOpen: showSettings
                        ) {
                            withAnimation(springResponse) {
                                if isExpanded { showSettings.toggle() }
                            }
                        }
                        .scaleEffect((isHovered || isExpanded || showSettings) ? 1.18 : (isHovered ? 1.05 : 1.0))
                        
                        Spacer()
                        
                        // Indicadores
                        HStack(spacing: 12) {
                            if !isExpanded && !showSettings {
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
                                    Circle()
                                        .fill(Color.orange)
                                        .frame(width: 6, height: 6)
                                }
                                .transition(.opacity)
                            }
                        }
                    }
                    .padding(.horizontal, 22)
                    .frame(height: (isHovered || isExpanded || showSettings) ? 42 : 37)
                    
                    // Corpo Expandido
                    if showContent || showSettings {
                        ZStack {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("SISTEMA OPERACIONAL")
                                        .font(.system(size: 8, weight: .black))
                                        .foregroundStyle(.white.opacity(0.4))
                                        .tracking(2.5)
                                    Spacer()
                                    Image(systemName: "cpu.fill")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.white.opacity(0.15))
                                }
                                
                                Divider().background(Color.white.opacity(0.1))
                                
                                HStack(spacing: 30) {
                                    MonitorRow(label: "ECRÃ", value: "2560×1664", color: .blue)
                                    MonitorRow(label: "CPU", value: "45%", color: .green)
                                    MonitorRow(label: "STATUS", value: "OTIMIZADO", color: .green)
                                }
                            }
                            .blur(radius: showSettings ? 10 : 0)
                            
                            if showSettings {
                                VStack(spacing: 12) {
                                    HStack {
                                        Text("CENTRAL DE CONTROLE")
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundStyle(.white.opacity(0.4))
                                            .tracking(1.2)
                                        Spacer()
                                    }
                                    .padding(.leading, 4)
                                    .padding(.bottom, 2)
                                    
                                    LazyVGrid(columns: [
                                        GridItem(.flexible(), spacing: 12),
                                        GridItem(.flexible(), spacing: 12),
                                        GridItem(.flexible(), spacing: 12)
                                    ], spacing: 12) {
                                        MetalRippleButton(icon: "lock.fill", label: "Bloquear", iconColor: .white, iconBgColor: .orange)
                                        MetalRippleButton(icon: "moon.zzz.fill", label: "Repouso", iconColor: .white, iconBgColor: .indigo)
                                        MetalRippleButton(icon: "display", label: "Tela", iconColor: .white, iconBgColor: .blue)
                                        
                                        MetalRippleButton(icon: "gearshape.fill", label: "Ajustes", iconColor: .white, iconBgColor: .gray)
                                        MetalRippleButton(icon: "arrow.clockwise", label: "Reiniciar", iconColor: .white, iconBgColor: .yellow)
                                        MetalRippleButton(icon: "power", label: "Desligar", iconColor: .white, iconBgColor: .red)
                                    }
                                }
                                .padding(.top, 5)
                                .transition(.scale(scale: 0.95).combined(with: .opacity))
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
            }
            .frame(width: (isExpanded || showSettings) ? 440 : (isHovered ? 315 : 285),
                   height: (isExpanded || showSettings) ? 255 : 37)
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
            .onChange(of: isExpanded) { _, newValue in
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
