//
//  IslandView.swift
//  V2-Dynamic Island
//
//  Ver. 21.3 - Stable Light Beam & Neomorphic Integration
//

import SwiftUI
import UniformTypeIdentifiers

struct IslandView: View {
    // --- ESTADOS ---
    @State private var isExpanded = false
    @State private var isHovered = false
    @State private var showContent = false
    @State private var showSettingsPanel = false
    
    // Drag & Drop
    @State private var isDropTargeted = false
    @State private var droppedFileURL: URL?
    @State private var showConverter = false
    
    // Configurações e Tema
    @AppStorage("islandTheme") private var selectedTheme: IslandTheme = .classic
    @AppStorage("enableFileDrop") private var enableFileDrop: Bool = true
    @AppStorage("staticVideoLink") private var staticVideoLink: String = ""
    @AppStorage("expandedVideoLink") private var expandedVideoLink: String = ""
    
    // Animações
    private let springResponse = Animation.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.2)
    private let smoothShine = Animation.easeInOut(duration: 0.5) // Mais lento para ser sorrateiro

    var body: some View {
        GeometryReader { _ in
            VStack(spacing: 0) {
                ZStack {
                    // 1. FUNDO
                    backgroundLayer
                    
                    // 2. DROP ZONE
                    if isDropTargeted && enableFileDrop {
                        dropOverlayLayer.transition(.opacity)
                    }
                    
                    // 3. BORDAS (FEIXE DE LUZ ESTÁVEL)
                    borderEffectLayer
                    
                    // 4. CONTEÚDO
                    contentLayer
                }
                .frame(width: calculateWidth(), height: calculateHeight())
                
                // --- EVENTOS ---
                .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
                    guard enableFileDrop else { return false }
                    guard let provider = providers.first else { return false }
                    provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { (item, error) in
                        var finalURL: URL?
                        if let data = item as? Data { finalURL = URL(dataRepresentation: data, relativeTo: nil) }
                        else if let url = item as? URL { finalURL = url }
                        if let url = finalURL {
                            DispatchQueue.main.async {
                                self.droppedFileURL = url
                                withAnimation(springResponse) { self.isExpanded = true; self.showConverter = true; self.showContent = true }
                            }
                        }
                    }
                    return true
                }
                .onHover { hovering in
                    if !showSettingsPanel && !showConverter {
                        withAnimation(smoothShine) {
                            isHovered = hovering
                        }
                        if !hovering && isExpanded {
                             withAnimation(springResponse) { isExpanded = false }
                        }
                    }
                }
                .onChange(of: isExpanded) { _, newValue in
                    if newValue {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            if isExpanded { withAnimation { showContent = true } }
                        }
                    } else {
                        showContent = false
                        if !showSettingsPanel { showConverter = false }
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .ignoresSafeArea()
        }
    }
    
    // --- GEOMETRIA ---
    private func calculateWidth() -> CGFloat {
        if isExpanded || showSettingsPanel || showConverter || isDropTargeted { return 420 }
        return isHovered ? 300 : 285
    }
    
    private func calculateHeight() -> CGFloat {
        if isDropTargeted && enableFileDrop { return 70 }
        if showSettingsPanel { return 240 }
        if showConverter { return 80 }
        if isExpanded { return 190 }
        return 37
    }
    
    // --- GRADIENTE SORRATEIRO (ESTÁVEL) ---
    private var dynamicGlassBorder: LinearGradient {
        // Define se está ativo (mouse em cima ou aberto)
        let isActive = isHovered || isExpanded
        
        // Intensidade do brilho: Aumenta sutilmente, sem explodir
        let brightness = isActive ? 0.4 : 0.15
        
        // Posição da "Cauda" da luz:
        // Em repouso (0.3) ela é curta. Ativo (0.45) ela cresce um POUQUINHO, quase imperceptível.
        // O segredo para não "esticar" é manter esses valores próximos.
        let tailPosition = isActive ? 0.45 : 0.3
        
        return LinearGradient(
            stops: [
                .init(color: .white.opacity(brightness), location: 0.0), // Cabeça da luz (Canto)
                .init(color: .white.opacity(brightness * 0.5), location: tailPosition * 0.5),
                .init(color: .white.opacity(0.0), location: tailPosition) // Fim da luz
            ],
            // Pontos FIXOS para não deformar a geometria
            startPoint: .topLeading,
            endPoint: .trailing
        )
    }
    
    // --- CAMADAS VISUAIS ---
    
    private var backgroundLayer: some View {
        ZStack {
            // MODO REPOUSO
            if !staticVideoLink.isEmpty && !isExpanded && !isDropTargeted,
               let url = VideoURLFactory.makeURL(from: staticVideoLink) {
                LoopingVideoPlayer(videoURL: url).opacity(1.0)
            } else {
                if selectedTheme == .liquid {
                    MacBookNotchShape(isExpanded: isExpanded || isDropTargeted)
                        .fill(.ultraThinMaterial)
                        .overlay(MacBookNotchShape(isExpanded: isExpanded || isDropTargeted).fill(Color.black.opacity(0.3)))
                } else {
                    MacBookNotchShape(isExpanded: isExpanded || isDropTargeted).fill(Color.black)
                }
            }

            // MODO EXPANDIDO
            if isExpanded || showSettingsPanel || isDropTargeted {
                ZStack {
                    if !showSettingsPanel {
                        if selectedTheme == .liquid {
                            MacBookNotchShape(isExpanded: true)
                                .fill(.ultraThinMaterial)
                                .overlay(MacBookNotchShape(isExpanded: true).fill(Color.black.opacity(0.4)))
                        } else {
                            MacBookNotchShape(isExpanded: true).fill(Color(red: 0.11, green: 0.11, blue: 0.12))
                        }
                    }
                    
                    if !expandedVideoLink.isEmpty && !isDropTargeted && !showSettingsPanel,
                       let url = VideoURLFactory.makeURL(from: expandedVideoLink) {
                        LoopingVideoPlayer(videoURL: url)
                            .clipShape(MacBookNotchShape(isExpanded: true))
                            .opacity(0.3)
                    }
                }
                .transition(.opacity)
            }
        }
        .shadow(
            color: (isDropTargeted && enableFileDrop) ? Color.green.opacity(0.4) : .black.opacity(0.4),
            radius: (isDropTargeted && enableFileDrop) ? 20 : (isExpanded ? 20 : 10),
            y: 8
        )
    }
    
    private var borderEffectLayer: some View {
        MacBookNotchShape(isExpanded: isExpanded || showSettingsPanel || isDropTargeted)
            .stroke(
                (isDropTargeted && enableFileDrop) ?
                    AnyShapeStyle(Color.green) :
                    AnyShapeStyle(dynamicGlassBorder), // Gradiente Estável
                lineWidth: (isDropTargeted && enableFileDrop) ? 2.0 : 1.0
            )
            .blendMode(.screen)
    }
    
    private var dropOverlayLayer: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 35).stroke(Color.green, lineWidth: 1.5).background(Color.green.opacity(0.1)).clipShape(MacBookNotchShape(isExpanded: true))
            HStack(spacing: 8) {
                Image(systemName: "arrow.down.doc.fill").font(.system(size: 20)).foregroundStyle(.white)
                Text("Solte para Converter").font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
            }
        }
    }

    private var contentLayer: some View {
        VStack(spacing: 0) {
            if !showConverter && !isDropTargeted { headerView }
            
            if showContent || showSettingsPanel || showConverter {
                ZStack {
                    if showConverter, let file = droppedFileURL {
                        ConverterView(fileURL: file, onCancel: {
                            withAnimation(springResponse) { showConverter = false; isExpanded = false }
                        }).transition(.move(edge: .top).combined(with: .opacity))
                    }
                    else if showSettingsPanel {
                        IslandSettingsView(onClose: {
                            withAnimation(springResponse) { showSettingsPanel = false; if !isHovered { isExpanded = false } }
                        })
                        .transition(.move(edge: .trailing))
                        .clipShape(MacBookNotchShape(isExpanded: true))
                    }
                    else if !isDropTargeted {
                        DashboardView().transition(.opacity)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
                .padding(.top, showConverter ? 10 : 6)
                .frame(maxHeight: .infinity)
            }
        }
    }
    
    private var headerView: some View {
        ZStack {
            Color.black.opacity(0.001).contentShape(Rectangle()).onTapGesture { if !showSettingsPanel { withAnimation(springResponse) { isExpanded.toggle() } } }
            HStack(alignment: .center) {
                Image(systemName: "apple.logo").font(.system(size: 12)).foregroundStyle(.white).shadow(color: .white.opacity(0.3), radius: 5).scaleEffect(isHovered || isExpanded ? 1.1 : 1.0)
                Spacer()
                if isExpanded && !showSettingsPanel && !showConverter {
                    Button(action: { withAnimation(springResponse) { showSettingsPanel = true } }) {
                        ZStack { Circle().fill(Color.white.opacity(0.1)).frame(width: 22, height: 22); Image(systemName: "gearshape.fill").font(.system(size: 10)).foregroundStyle(selectedTheme == .liquid ? .primary : .secondary) }
                    }.buttonStyle(.plain).zIndex(1)
                }
                if !isExpanded && !isDropTargeted { HStack(spacing: 5) { Circle().fill(Color.green).frame(width: 4, height: 4); Circle().fill(Color.orange).frame(width: 4, height: 4) } }
            }.padding(.horizontal, 16)
        }.frame(height: 37).opacity(isDropTargeted ? 0 : 1)
    }
}
