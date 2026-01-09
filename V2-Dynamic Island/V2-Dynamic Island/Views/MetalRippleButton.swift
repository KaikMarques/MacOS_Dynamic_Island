//
//  MetalRippleButton.swift
//  V2-Dynamic Island
//
//  Componente de botão com efeito ripple metalizado
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
                // Fundo do ícone
                Circle()
                    .fill(iconBgColor.gradient)
                    .frame(width: 32, height: 32)
                    .shadow(color: iconBgColor.opacity(0.3), radius: isHovered ? 6 : 3)
                
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(iconColor)
            }
            .scaleEffect(isHovered ? 1.1 : 1.0)
            
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.white.opacity(0.85))
        }
        .frame(height: 72)
        .frame(maxWidth: .infinity)
        // FUNDO METAL RIPPLE
        .background(
            RippleMetalView(isHovered: isHovered)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        )
        // Borda de vidro estática
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
        )
        .onHover { h in withAnimation { isHovered = h } }
    }
}

#Preview {
    HStack {
        MetalRippleButton(icon: "lock.fill", label: "Bloquear", iconColor: .white, iconBgColor: .orange)
        MetalRippleButton(icon: "moon.zzz.fill", label: "Repouso", iconColor: .white, iconBgColor: .indigo)
    }
    .padding()
    .background(.black)
}
