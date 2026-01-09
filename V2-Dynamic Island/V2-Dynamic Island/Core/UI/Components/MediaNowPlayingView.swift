//
//  MediaNowPlayingView.swift
//  V2-Dynamic Island
//
//  Ver. 18.0 - Media Player Component
//

import SwiftUI

struct MediaNowPlayingView: View {
    // Estados Simulados (Em um app real, viriam do MPNowPlayingInfoCenter)
    @State private var isPlaying = true
    @State private var progress: CGFloat = 0.35
    
    var body: some View {
        HStack(spacing: 12) {
            // 1. CAPA DO ÁLBUM (Com Glow Dinâmico)
            ZStack {
                // Sombra Colorida (Baseada na arte)
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.purple.opacity(0.5))
                    .frame(width: 48, height: 48)
                    .blur(radius: 12)
                
                // Arte da Capa
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.indigo, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        Image(systemName: "music.note")
                            .font(.system(size: 20))
                            .foregroundStyle(.white.opacity(0.5))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
            }
            
            // 2. INFORMAÇÕES E CONTROLES
            VStack(alignment: .leading, spacing: 6) {
                // Título e Artista
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Midnight City")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        
                        Text("M83 • Hurry Up, We're Dreaming")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color.appleLakeGrey)
                            .lineLimit(1)
                    }
                    Spacer()
                    
                    // Waveform (Animado)
                    HStack(spacing: 2) {
                        ForEach(0..<4) { _ in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.appleLakeGreen)
                                .frame(width: 3, height: CGFloat.random(in: 8...16))
                        }
                    }
                }
                
                // Barra de Progresso e Botões
                HStack(spacing: 12) {
                    // Barra
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.white.opacity(0.1))
                            Capsule().fill(Color.white)
                                .frame(width: geo.size.width * progress)
                        }
                    }
                    .frame(height: 4)
                    
                    // Controles Compactos
                    HStack(spacing: 14) {
                        Button(action: {}) {
                            Image(systemName: "backward.fill").font(.system(size: 12))
                        }
                        Button(action: { withAnimation { isPlaying.toggle() } }) {
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 14))
                        }
                        Button(action: {}) {
                            Image(systemName: "forward.fill").font(.system(size: 12))
                        }
                    }
                    .foregroundStyle(.white)
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(12)
        .appleLakeCard() // Usa o estilo do arquivo AppleLakeStyles
    }
}
