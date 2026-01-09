//
//  IslandSettingsView.swift
//  V2-Dynamic Island
//
//  Ver. 17.0 - Added File Drop Toggle & Tools Section
//

import SwiftUI

struct IslandSettingsView: View {
    // --- PERSISTÊNCIA DE DADOS ---
    
    // Configurações de Personalização
    @AppStorage("showWeather") private var showWeather: Bool = true
    @AppStorage("showCalendar") private var showCalendar: Bool = true
    
    // Configurações de Ferramentas (NOVO)
    @AppStorage("enableFileDrop") private var enableFileDrop: Bool = true
    
    // Configurações de Vídeo
    @AppStorage("staticVideoLink") private var staticVideoLink: String = ""
    @AppStorage("expandedVideoLink") private var expandedVideoLink: String = ""
    
    // Callback para fechar o painel
    var onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // --- HEADER DE NAVEGAÇÃO ---
            HStack {
                Button(action: onClose) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 12, weight: .bold))
                        Text("Voltar")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundStyle(Color.appleLakeGrey)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text("Ajustes da Ilha")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .offset(x: -20) // Ajuste visual para centralizar
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.appleLakeCharcoal.opacity(0.8))
            
            Divider().background(Color.white.opacity(0.1))
            
            // --- CONTEÚDO (SCROLL) ---
            ScrollView {
                VStack(spacing: 24) {
                    
                    // SEÇÃO 1: PERSONALIZAÇÃO
                    SettingsGroup(title: "PERSONALIZAÇÃO") {
                        ToggleRow(icon: "cloud.sun.fill", color: .blue, title: "Mostrar Clima", isOn: $showWeather)
                        
                        Divider()
                            .background(Color.white.opacity(0.05))
                            .padding(.leading, 36)
                        
                        ToggleRow(icon: "calendar", color: .red, title: "Mostrar Calendário", isOn: $showCalendar)
                        
                        Divider()
                            .background(Color.white.opacity(0.05))
                            .padding(.leading, 36)
                            
                        NavigationRow(icon: "textformat", color: .gray, title: "Estilo da Fonte", subtitle: "San Francisco Pro")
                    }
                    
                    // SEÇÃO 2: FERRAMENTAS (NOVO NA VER. 17.0)
                    SettingsGroup(title: "FERRAMENTAS") {
                        ToggleRow(
                            icon: "doc.badge.arrow.up.fill",
                            color: .green,
                            title: "Conversor de Arquivos (Drag & Drop)",
                            isOn: $enableFileDrop
                        )
                        
                        if enableFileDrop {
                            Divider()
                                .background(Color.white.opacity(0.05))
                                .padding(.leading, 36)
                            
                            HStack {
                                Text("Arraste arquivos para o notch para converter formatos.")
                                    .font(.system(size: 10))
                                    .foregroundStyle(Color.appleLakeGrey)
                                    .fixedSize(horizontal: false, vertical: true)
                                Spacer()
                            }
                            .padding(12)
                        }
                    }
                    
                    // SEÇÃO 3: BACKGROUND DINÂMICO
                    SettingsGroup(title: "BACKGROUND DINÂMICO") {
                        VStack(alignment: .leading, spacing: 12) {
                            // Configuração Notch Fechado
                            VStack(alignment: .leading, spacing: 6) {
                                Label("Modo Repouso (Fechado)", systemImage: "minus.circle.fill")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.8))
                                
                                // Componente externo FileSelectorComponent
                                FileSelectorComponent(text: $staticVideoLink, placeholder: "Selecione vídeo mp4/mov...")
                                
                                Text("Recomendado: 285x37 pixels (Loop infinito)")
                                    .font(.system(size: 9))
                                    .foregroundStyle(Color.appleLakeGrey)
                            }
                            
                            Divider().background(Color.white.opacity(0.05))
                            
                            // Configuração Notch Expandido
                            VStack(alignment: .leading, spacing: 6) {
                                Label("Modo Expandido (Aberto)", systemImage: "arrow.up.left.and.arrow.down.right.circle.fill")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.8))
                                
                                FileSelectorComponent(text: $expandedVideoLink, placeholder: "Selecione vídeo mp4/mov...")
                                
                                Text("Recomendado: 440x140 pixels")
                                    .font(.system(size: 9))
                                    .foregroundStyle(Color.appleLakeGrey)
                            }
                        }
                        .padding(12)
                    }
                    
                    // SEÇÃO 4: SOBRE
                    SettingsGroup(title: "SOBRE") {
                        NavigationRow(icon: "info.circle.fill", color: .appleLakeGrey, title: "Versão do Sistema", subtitle: "AppleLake OS 1.0")
                    }
                }
                .padding(20)
            }
        }
        .background(Color.appleLakeBlack)
    }
}

// --- COMPONENTES AUXILIARES DE DESIGN ---

struct SettingsGroup<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color.appleLakeGrey)
                .padding(.leading, 8)
            
            VStack(spacing: 0) {
                content
            }
            .background(Color.appleLakeCharcoal)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
        }
    }
}

struct ToggleRow: View {
    let icon: String
    let color: Color
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(RoundedRectangle(cornerRadius: 6).fill(color))
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(.switch)
                .labelsHidden()
                .scaleEffect(0.7)
        }
        .padding(10)
    }
}

struct NavigationRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(RoundedRectangle(cornerRadius: 6).fill(color))
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white)
            
            Spacer()
            
            Text(subtitle)
                .font(.system(size: 12))
                .foregroundStyle(Color.appleLakeGrey)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color.appleLakeGrey.opacity(0.5))
        }
        .padding(10)
    }
}
