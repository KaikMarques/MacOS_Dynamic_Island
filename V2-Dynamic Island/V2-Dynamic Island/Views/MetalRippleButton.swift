//
//  MetalRippleButton.swift
//  V2-Dynamic Island
//
//  Ver. 6.6 - Glass Base & 3D Icon Animation
//

import SwiftUI

struct MetalRippleButton: View {
    let icon: String
    let label: String
    var iconColor: Color
    var iconBgColor: Color
    
    @State private var isHovered = false
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                // Ícone com SF Symbol
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(iconColor)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(iconBgColor.gradient.opacity(0.8))
                    )
                    // --- ANIMAÇÃO 3D EXPANDING ---
                    // 1. Aumenta o tamanho (Pop)
                    .scaleEffect(isHovered ? 1.25 : 1.0)
                    // 2. Sombra deslocada para baixo (Levitação)
                    .shadow(
                        color: iconBgColor.opacity(0.6),
                        radius: isHovered ? 12 : 4,
                        y: isHovered ? 8 : 2
                    )
                    // 3. Rotação 3D (Inclinação para profundidade)
                    .rotation3DEffect(
                        .degrees(isHovered ? 15 : 0),
                        axis: (x: 1.0, y: 0.0, z: 0.0)
                    )
            }
            // Animação separada para o ícone não herdar a animação do botão container
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isHovered)
            
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.white.opacity(isHovered ? 1.0 : 0.7)) // Texto acende levemente
        }
        .frame(height: 72)
        .frame(maxWidth: .infinity)
        
        // --- FUNDO DO BOTÃO ---
        .background(
            ZStack {
                // 1. CAMADA DE VIDRO (Estado de Repouso)
                // Substitui a linha por uma placa de vidro sutil
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .opacity(0.2) // Vidro bem sutil
                
                // 2. SHADER LIQUID LENS (Estado Hover)
                // O efeito "Lupa Líquida" que criamos na Ver 6.5
                RippleMetalView(isHovered: isHovered)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .opacity(isHovered ? 1.0 : 0.0) // Só aparece no hover
            }
        )
        // Nota: Removi o .overlay com stroke que criava a linha fixa.
        
        // Gestos
        .onHover { h in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isHovered = h
            }
        }
    }
}

// Preview para testar visualmente
#Preview {
    ZStack {
        Color.black
        HStack {
            MetalRippleButton(icon: "star.fill", label: "Favorito", iconColor: .white, iconBgColor: .yellow)
                .frame(width: 100)
        }
    }
}
