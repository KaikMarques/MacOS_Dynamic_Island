//
//  IslandView.swift
//  V2-Dynamic Island
//
//  Ver. 14.0 - Integration of AppleLake Dashboard
//

import SwiftUI

struct IslandView: View {
    // --- ESTADOS ---
    @State private var isExpanded = false
    @State private var isHovered = false
    @State private var showContent = false
    @State private var sensorPulse = false
    
    // Controle de Navegação Interna
    @State private var showMenu = false
    @State private var showSettingsPanel = false
    
    // --- SETTINGS STORAGE ---
    @AppStorage("staticVideoLink") private var staticVideoLink: String = ""
    @AppStorage("expandedVideoLink") private var expandedVideoLink: String = ""
    
    // Configuração de Animação: "Spring Physics" conforme spec
    private let springResponse = Animation.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.2)

    var body: some View {
        GeometryReader { _ in
            
            VStack(spacing: 0) {
                ZStack {
                    // 1. CAMADA DE FUNDO
                    backgroundLayer
                    
                    // 2. BORDAS E EFEITOS
                    borderEffectLayer
                    
                    // 3. CAMADA DE CONTEÚDO (UI)
                    contentLayer
                }
                // Controle de Tamanho Dinâmico (Morphing)
                .frame(width: (isExpanded || showMenu || showSettingsPanel) ? 440 : (isHovered ? 315 : 285),
                       height: (isExpanded || showMenu || showSettingsPanel) ? 140 : 37) // Altura ajustada para Widgets (140)
                
                // --- GESTOS ---
                .onHover { hovering in
                    if !showMenu && !showSettingsPanel {
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
                        if showMenu || showSettingsPanel {
                            showMenu = false
                            showSettingsPanel = false
                        } else {
                            isExpanded.toggle()
                        }
                    }
                }
                .onChange(of: isExpanded) { _, newValue in
                    if newValue {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            if isExpanded {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showContent = true
                                }
                            }
                        }
                    } else {
                        showContent = false
                        showMenu = false
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .ignoresSafeArea()
        }
    }
    
    // --- SUBVIEWS PARA ORGANIZAÇÃO ---
    
    private var backgroundLayer: some View {
        ZStack {
            // A. FUNDO BASE (Static)
            if !staticVideoLink.isEmpty && !isExpanded && !showMenu,
               let url = VideoURLFactory.makeURL(from: staticVideoLink) {
                
                LoopingVideoPlayer(videoURL: url)
                    .opacity(1.0)
                    .transition(.opacity)
            } else {
                MacBookNotchShape(isExpanded: isExpanded)
                    .fill(Color.appleLakeBlack) // Design System Color
                    .opacity(showMenu || showSettingsPanel ? 0 : 1)
            }

            // B. FUNDO EXPANDIDO
            if showMenu || showSettingsPanel || isExpanded {
                ZStack {
                    MacBookNotchShape(isExpanded: true)
                        .fill(Color.appleLakeCharcoal) // Design System Color
                    
                    if !expandedVideoLink.isEmpty,
                       let url = VideoURLFactory.makeURL(from: expandedVideoLink) {
                        
                        LoopingVideoPlayer(videoURL: url)
                            .clipShape(MacBookNotchShape(isExpanded: true))
                            .opacity(0.4)
                            .allowsHitTesting(false)
                    } else {
                        // Liquid Glass sutil
                        LiquidGlassBackground()
                            .clipShape(MacBookNotchShape(isExpanded: true))
                            .opacity(0.3)
                    }
                }
                .transition(.opacity)
            }
        }
        .shadow(
            color: .black.opacity((isExpanded || showMenu) ? 0.5 : 0.2),
            radius: (isExpanded || showMenu) ? 30 : 10,
            y: 10
        )
    }
    
    private var borderEffectLayer: some View {
        AuroraBackground(isActive: isHovered || isExpanded)
            .mask(
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0.0),
                        .init(color: .white, location: 0.5),
                        .init(color: .white, location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .mask(
                MacBookNotchShape(isExpanded: isExpanded || showMenu || showSettingsPanel)
                    .stroke(lineWidth: 1.0)
            )
            .blendMode(.screen)
            .opacity(0.6)
    }
    
    private var contentLayer: some View {
        VStack(spacing: 0) {
            // HEADER (Logo e Status)
            HStack(alignment: .center) {
                AppleLogoComponent(
                    isExpanded: isHovered || isExpanded || showMenu || showSettingsPanel,
                    isSettingsOpen: showMenu
                ) {
                    withAnimation(springResponse) {
                        if isExpanded || showSettingsPanel {
                            if showSettingsPanel {
                                showSettingsPanel = false
                                showMenu = true
                            } else {
                                showMenu.toggle()
                            }
                        }
                    }
                }
                .scaleEffect((isHovered || isExpanded || showMenu) ? 1.1 : 1.0)
                
                Spacer()
                
                // Indicadores de Privacidade
                HStack(spacing: 12) {
                    if !isExpanded && !showMenu && !showSettingsPanel {
                        HStack(spacing: 6) {
                            Circle().fill(Color.appleLakeGreen).frame(width: 5, height: 5)
                            Circle().fill(Color.orange).frame(width: 5, height: 5)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .frame(height: 37) // Altura fixa do Header (Notch original)
            
            // CORPO DINÂMICO
            if showContent || showMenu || showSettingsPanel {
                ZStack {
                    // A. SETTINGS
                    if showSettingsPanel {
                        IslandSettingsView(onBackButton: {
                            withAnimation(springResponse) {
                                showSettingsPanel = false
                                showMenu = true
                            }
                        })
                        .transition(.move(edge: .trailing))
                    }
                    // B. MENU DE CONTROLE (ÍCONES)
                    else if showMenu {
                        // (Mantenha seu grid de ícones aqui, simplificado para brevidade)
                        // ... Pode usar o código anterior do Menu Grid aqui ...
                        Text("Menu Grid Placeholder") // Substitua pelo seu código de Grid
                            .foregroundStyle(.white)
                    }
                    // C. DASHBOARD WIDGETS (PADRÃO AO CLICAR)
                    else {
                        DashboardView() // A nova View de Widgets
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .padding(.top, 8)
                .frame(maxHeight: .infinity)
            }
        }
    }
}
