//
//  IslandSettingsView.swift
//  V2-Dynamic Island
//
//  Ver. 21.3 - Neomorphic Depth (Right Side) & Liquid Glass
//

import SwiftUI

// Enum para o Tema
enum IslandTheme: String, CaseIterable, Identifiable {
    case classic = "Clássico (Preto)"
    case liquid = "Liquid Glass (Vidro)"
    var id: String { self.rawValue }
}

struct IslandSettingsView: View {
    // --- PERSISTÊNCIA ---
    @AppStorage("islandTheme") private var selectedTheme: IslandTheme = .classic
    @AppStorage("showWeather") private var showWeather: Bool = true
    @AppStorage("showCalendar") private var showCalendar: Bool = true
    @AppStorage("enableFileDrop") private var enableFileDrop: Bool = true
    @AppStorage("staticVideoLink") private var staticVideoLink: String = ""
    @AppStorage("expandedVideoLink") private var expandedVideoLink: String = ""
    
    var onClose: () -> Void
    
    // Gradiente da Borda dos Grupos (Mais suave)
    private let glassBorder = LinearGradient(
        stops: [
            .init(color: .white.opacity(0.4), location: 0.0),
            .init(color: .white.opacity(0.1), location: 0.5),
            .init(color: .clear, location: 1.0)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        VStack(spacing: 0) {
            // HEADER
            HStack {
                Button(action: onClose) {
                    HStack(spacing: 3) {
                        Image(systemName: "chevron.left").font(.system(size: 10, weight: .bold))
                        Text("Voltar").font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text("Ajustes")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.primary)
                    .offset(x: -15)
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            // Fundo do Header sutil
            .background(.white.opacity(0.05))
            
            Divider().background(.white.opacity(0.1))
            
            // CONTEÚDO
            ScrollView {
                VStack(spacing: 16) {
                    
                    // SEÇÃO 1: APARÊNCIA
                    SettingsGroup(title: "APARÊNCIA", border: glassBorder) {
                        HStack {
                            Image(systemName: "sparkles")
                                .font(.system(size: 10))
                                .frame(width: 20, height: 20)
                                .background(RoundedRectangle(cornerRadius: 5).fill(Color.purple))
                                .foregroundStyle(.white)
                            
                            Text("Estilo Visual")
                                .font(.system(size: 10, weight: .medium))
                            
                            Spacer()
                            
                            Picker("", selection: $selectedTheme) {
                                ForEach(IslandTheme.allCases) { theme in
                                    Text(theme.rawValue).tag(theme)
                                }
                            }
                            .labelsHidden()
                            .scaleEffect(0.8)
                            .frame(width: 140)
                        }
                        .padding(8)
                    }
                    
                    // SEÇÃO 2: WIDGETS
                    SettingsGroup(title: "WIDGETS", border: glassBorder) {
                        ToggleRow(icon: "cloud.sun.fill", color: .blue, title: "Clima", isOn: $showWeather)
                        Divider().padding(.leading, 32)
                        ToggleRow(icon: "calendar", color: .red, title: "Calendário", isOn: $showCalendar)
                    }
                    
                    // SEÇÃO 3: FERRAMENTAS
                    SettingsGroup(title: "FERRAMENTAS", border: glassBorder) {
                        ToggleRow(icon: "doc.badge.arrow.up.fill", color: .green, title: "File Drop (Conversor)", isOn: $enableFileDrop)
                    }
                    
                    // SEÇÃO 4: BACKGROUND
                    SettingsGroup(title: "BACKGROUND", border: glassBorder) {
                        VStack(alignment: .leading, spacing: 8) {
                            FileSelectorComponent(text: $staticVideoLink, placeholder: "Vídeo Fechado...")
                            Divider()
                            FileSelectorComponent(text: $expandedVideoLink, placeholder: "Vídeo Aberto...")
                        }
                        .padding(8)
                    }
                    
                    // SEÇÃO 5: SOBRE
                    SettingsGroup(title: "SOBRE", border: glassBorder) {
                        NavigationRow(icon: "info.circle.fill", color: .gray, title: "Versão", subtitle: "AppleLake 2.3")
                    }
                }
                .padding(14)
            }
        }
        // --- APLICANDO O EFEITO NEOMORFICO LÍQUIDO ---
        .background(.ultraThinMaterial)
        .neomorphicGlassRight() // <--- A MÁGICA AQUI
    }
}

// --- EXTENSÃO PARA EFEITO NEOMÓRFICO ---
extension View {
    func neomorphicGlassRight() -> some View {
        self.overlay(
            ZStack {
                // 1. Sombra Interna na Direita (Profundidade)
                HStack {
                    Spacer()
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0.0),
                            .init(color: .black.opacity(0.05), location: 0.7), // Sombra suave
                            .init(color: .black.opacity(0.2), location: 1.0)   // Sombra mais escura na borda
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 40) // Largura da área de "curva"
                }
                
                // 2. Bevel de Luz na Borda Direita (Espessura do Vidro)
                HStack {
                    Spacer()
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.1), .white.opacity(0.4), .white.opacity(0.1)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 1) // Borda fina
                }
            }
            .allowsHitTesting(false) // Não interfere no clique
        )
    }
}

// --- COMPONENTES AUXILIARES ---

struct SettingsGroup<Content: View>: View {
    let title: String
    let border: LinearGradient
    let content: Content
    
    init(title: String, border: LinearGradient, @ViewBuilder content: () -> Content) {
        self.title = title
        self.border = border
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.secondary)
                .padding(.leading, 6)
            
            VStack(spacing: 0) { content }
                .background(.regularMaterial) // Vidro interno
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(border, lineWidth: 0.8)
                )
        }
    }
}

struct ToggleRow: View {
    let icon: String; let color: Color; let title: String; @Binding var isOn: Bool
    var body: some View {
        HStack {
            Image(systemName: icon).font(.system(size: 10)).foregroundStyle(.white)
                .frame(width: 20, height: 20).background(RoundedRectangle(cornerRadius: 5).fill(color))
            Text(title).font(.system(size: 10, weight: .medium)).foregroundStyle(.primary)
            Spacer()
            Toggle("", isOn: $isOn).toggleStyle(.switch).labelsHidden().scaleEffect(0.6)
        }.padding(8)
    }
}

struct NavigationRow: View {
    let icon: String; let color: Color; let title: String; let subtitle: String
    var body: some View {
        HStack {
            Image(systemName: icon).font(.system(size: 10)).foregroundStyle(.white)
                .frame(width: 20, height: 20).background(RoundedRectangle(cornerRadius: 5).fill(color))
            Text(title).font(.system(size: 10, weight: .medium)).foregroundStyle(.primary)
            Spacer()
            Text(subtitle).font(.system(size: 10)).foregroundStyle(.secondary)
        }.padding(8)
    }
}
