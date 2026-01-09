//
//  IslandView.swift
//  V2-Dynamic Island
//
//  Ver. 18.0 - Dynamic Height Adjustment for New Features
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
    
    // Configurações
    @AppStorage("enableFileDrop") private var enableFileDrop: Bool = true
    @AppStorage("staticVideoLink") private var staticVideoLink: String = ""
    @AppStorage("expandedVideoLink") private var expandedVideoLink: String = ""
    
    // Física
    private let springResponse = Animation.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.2)

    var body: some View {
        GeometryReader { _ in
            VStack(spacing: 0) {
                ZStack {
                    // CAMADAS DE FUNDO E EFEITO
                    backgroundLayer
                    if isDropTargeted && enableFileDrop { dropOverlayLayer.transition(.opacity) }
                    borderEffectLayer
                    
                    // CONTEÚDO
                    contentLayer
                }
                // --- CONTROLE DE ALTURA INTELIGENTE ---
                .frame(
                    width: (isExpanded || showSettingsPanel || showConverter || isDropTargeted) ? 440 : (isHovered ? 315 : 285),
                    height: calculateHeight()
                )
                
                // GESTOS
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
                                withAnimation(springResponse) {
                                    self.isExpanded = true
                                    self.showConverter = true
                                    self.showContent = true
                                }
                            }
                        }
                    }
                    return true
                }
                .onHover { hovering in
                    if !showSettingsPanel && !showConverter {
                        withAnimation(springResponse) {
                            isHovered = hovering
                            if !hovering && isExpanded { isExpanded = false }
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
    
    // --- LÓGICA DE ALTURA ATUALIZADA (Ver. 18.0) ---
    private func calculateHeight() -> CGFloat {
        if isDropTargeted && enableFileDrop { return 80 }
        if showSettingsPanel { return 255 }
        if showConverter { return 90 }
        
        // Dashboard Completo (Widgets + Media + Sliders)
        // Precisa ser mais alto para caber tudo confortavelmente
        if isExpanded { return 220 }
        
        return 37 // Altura padrão fechado
    }
    
    // --- COMPONENTES VISUAIS (Mantidos para brevidade, código inalterado) ---
    // Copiar backgroundLayer, dropOverlayLayer, borderEffectLayer da Ver. 17.0
    // Eles não mudaram nesta versão.
    
    private var backgroundLayer: some View {
        ZStack {
            if !staticVideoLink.isEmpty && !isExpanded && !isDropTargeted,
               let url = VideoURLFactory.makeURL(from: staticVideoLink) {
                LoopingVideoPlayer(videoURL: url).opacity(1.0)
            } else {
                MacBookNotchShape(isExpanded: isExpanded || isDropTargeted)
                    .fill(Color.appleLakeBlack)
            }

            if isExpanded || showSettingsPanel || isDropTargeted {
                ZStack {
                    MacBookNotchShape(isExpanded: true)
                        .fill(Color.appleLakeCharcoal)
                    
                    if !expandedVideoLink.isEmpty && !isDropTargeted,
                       let url = VideoURLFactory.makeURL(from: expandedVideoLink) {
                        LoopingVideoPlayer(videoURL: url)
                            .clipShape(MacBookNotchShape(isExpanded: true))
                            .opacity(0.3)
                    }
                }
                .transition(.opacity)
            }
        }
        .shadow(color: (isDropTargeted && enableFileDrop) ? Color.appleLakeGreen.opacity(0.4) : .black.opacity(0.5),
                radius: (isDropTargeted && enableFileDrop) ? 20 : (isExpanded ? 30 : 10), y: 10)
    }
    
    private var dropOverlayLayer: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 40)
                .stroke(Color.appleLakeGreen, lineWidth: 2)
                .background(Color.appleLakeGreen.opacity(0.15))
                .clipShape(MacBookNotchShape(isExpanded: true))
            
            HStack(spacing: 12) {
                Image(systemName: "arrow.down.doc.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.white)
                Text("Solte para Converter")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
    }
    
    private var borderEffectLayer: some View {
        MacBookNotchShape(isExpanded: isExpanded || showSettingsPanel || isDropTargeted)
            .stroke(
                (isDropTargeted && enableFileDrop) ? Color.appleLakeGreen : .white.opacity(0.12),
                lineWidth: (isDropTargeted && enableFileDrop) ? 2.0 : 1.0
            )
            .blendMode(.screen)
    }

    private var contentLayer: some View {
        VStack(spacing: 0) {
            if !showConverter && !isDropTargeted { headerView }
            
            if showContent || showSettingsPanel || showConverter {
                ZStack {
                    if showConverter, let file = droppedFileURL {
                        ConverterView(fileURL: file, onCancel: {
                            withAnimation(springResponse) {
                                showConverter = false
                                isExpanded = false
                            }
                        })
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    else if showSettingsPanel {
                        IslandSettingsView(onClose: {
                            withAnimation(springResponse) {
                                showSettingsPanel = false
                                if !isHovered { isExpanded = false }
                            }
                        })
                        .transition(.move(edge: .trailing))
                    }
                    else if !showConverter && !isDropTargeted {
                        DashboardView() // Agora contém Media e Sliders
                            .transition(.opacity)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
                .padding(.top, showConverter ? 12 : 8)
                .frame(maxHeight: .infinity)
            }
        }
    }
    
    private var headerView: some View {
        ZStack {
            Color.black.opacity(0.001)
                .contentShape(Rectangle())
                .onTapGesture {
                    if !showSettingsPanel { withAnimation(springResponse) { isExpanded.toggle() } }
                }
            
            HStack(alignment: .center) {
                Image(systemName: "apple.logo")
                    .font(.system(size: 14))
                    .foregroundStyle(.white)
                    .shadow(color: .white.opacity(0.3), radius: 5)
                    .scaleEffect(isHovered || isExpanded ? 1.1 : 1.0)
                
                Spacer()
                
                if isExpanded && !showSettingsPanel && !showConverter {
                    Button(action: { withAnimation(springResponse) { showSettingsPanel = true } }) {
                        ZStack {
                            Circle().fill(Color.white.opacity(0.1)).frame(width: 24, height: 24)
                            Image(systemName: "gearshape.fill").font(.system(size: 11)).foregroundStyle(Color.appleLakeGrey)
                        }
                    }
                    .buttonStyle(.plain)
                    .zIndex(1)
                }
                
                if !isExpanded && !isDropTargeted {
                    HStack(spacing: 6) {
                        Circle().fill(Color.appleLakeGreen).frame(width: 5, height: 5)
                        Circle().fill(Color.orange).frame(width: 5, height: 5)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 37)
        .opacity(isDropTargeted ? 0 : 1)
    }
}
