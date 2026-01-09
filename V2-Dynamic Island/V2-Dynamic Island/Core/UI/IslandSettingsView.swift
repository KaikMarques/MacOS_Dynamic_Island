//
//  IslandSettingsView.swift
//  V2-Dynamic Island
//
//  Ver. 12.0 - File Picker Integration & Local Path Support
//

import SwiftUI
import UniformTypeIdentifiers // Necessário para filtrar tipos de vídeo

struct IslandSettingsView: View {
    @AppStorage("staticVideoLink") private var staticVideoLink: String = ""
    @AppStorage("expandedVideoLink") private var expandedVideoLink: String = ""
    
    var onBackButton: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // HEADER
            HStack {
                Button(action: onBackButton) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .buttonStyle(.plain)
                .padding(8)
                .background(Circle().fill(.white.opacity(0.1)))
                
                Text("Ajustes da Ilha")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            // CONTENT
            ScrollView {
                VStack(spacing: 20) {
                    
                    // SEÇÃO 1: MODO REPOUSO
                    SettingsSection(title: "Modo Repouso (Fechado)", icon: "minus.circle.fill", color: .gray) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Exibido quando a ilha está recolhida.")
                                .font(.system(size: 10))
                                .foregroundStyle(.white.opacity(0.5))
                            
                            // Componente Seletor de Arquivo/Link
                            FileSelectorComponent(
                                text: $staticVideoLink,
                                placeholder: "Cole um link ou escolha um arquivo..."
                            )
                            
                            HStack(spacing: 6) {
                                Image(systemName: "info.circle")
                                Text("Proporção ideal: 285x37 (Ultrawide)")
                            }
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.orange.opacity(0.8))
                        }
                    }
                    
                    // SEÇÃO 2: MODO EXPANDIDO
                    SettingsSection(title: "Modo Expandido", icon: "arrow.up.left.and.arrow.down.right.circle.fill", color: .blue) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Exibido no fundo do painel de controle.")
                                .font(.system(size: 10))
                                .foregroundStyle(.white.opacity(0.5))
                            
                            // Componente Seletor de Arquivo/Link
                            FileSelectorComponent(
                                text: $expandedVideoLink,
                                placeholder: "Cole um link ou escolha um arquivo..."
                            )
                            
                            HStack(spacing: 6) {
                                Image(systemName: "info.circle")
                                Text("Proporção ideal: 440x255 (16:9 Adaptado)")
                            }
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.cyan.opacity(0.8))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
        }
        .background(Color(red: 0.1, green: 0.1, blue: 0.12))
    }
}

// --- COMPONENTE COMPLEXO DE SELEÇÃO DE ARQUIVO ---

struct FileSelectorComponent: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        HStack(spacing: 8) {
            // Campo de Texto (Editável Manualmente)
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.3))
                        .padding(.horizontal, 10)
                }
                
                TextField("", text: $text)
                    .textFieldStyle(.plain)
                    .font(.system(size: 11))
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.black.opacity(0.3))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.white.opacity(text.isEmpty ? 0.05 : 0.2), lineWidth: 1)
                    )
            }
            
            // Botão de Seleção de Arquivo Local
            Button(action: openFilePanel) {
                Image(systemName: "folder.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.9))
                    .frame(width: 32, height: 32) // Altura igual ao input
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .help("Escolher arquivo local")
        }
    }
    
    // Lógica do NSOpenPanel (Seletor Nativo do macOS)
    private func openFilePanel() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        // Filtra apenas arquivos de vídeo (Movies)
        panel.allowedContentTypes = [.movie, .video, .quickTimeMovie, .mpeg4Movie]
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                // Salva a URL absoluta do arquivo selecionado
                self.text = url.absoluteString
            }
        }
    }
}

// --- COMPONENTES AUXILIARES DE ESTILO ---

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: Content
    
    init(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundStyle(.white)
                    .frame(width: 22, height: 22)
                    .background(RoundedRectangle(cornerRadius: 5).fill(color))
                
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
            }
            .padding(.bottom, 8)
            .padding(.horizontal, 4)
            
            VStack(alignment: .leading) {
                content
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                    )
            )
        }
    }
}
