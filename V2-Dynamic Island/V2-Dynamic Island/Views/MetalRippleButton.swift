//
//  MetalRippleButton.swift
//  V2-Dynamic Island
//
//  Ver. 9.2 - Static Base & Floating Icon
//

import SwiftUI

struct MetalRippleButton: View {
    let icon: String
    let label: String
    var iconColor: Color
    var iconBgColor: Color
    
    @State private var isHovered = false
    @State private var mouseLoc: CGPoint = CGPoint(x: 0.5, y: 0.5)
    
    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            
            // Paralaxe do ícone
            let parallaxX = isHovered ? (mouseLoc.x - 0.5) * 6 : 0
            let parallaxY = isHovered ? (mouseLoc.y - 0.5) * 6 : 0
            
            VStack(spacing: 6) {
                ZStack {
                    // CAMADA 1: BASE (Estática)
                    Circle()
                        .fill(iconBgColor.gradient.opacity(0.8))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        stops: [
                                            .init(color: .white.opacity(0.4), location: 0.1),
                                            .init(color: .clear, location: 0.5),
                                            .init(color: .white.opacity(0.1), location: 0.9)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .scaleEffect(isHovered ? 1.1 : 1.0)
                        .shadow(
                            color: iconBgColor.opacity(0.4),
                            radius: isHovered ? 12 : 0,
                            y: isHovered ? 6 : 0
                        )
                    
                    // CAMADA 2: ÍCONE (Dinâmico)
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(iconColor)
                        .offset(x: parallaxX, y: parallaxY)
                        .scaleEffect(isHovered ? 1.25 : 1.0)
                        .shadow(
                            color: .black.opacity(0.4),
                            radius: isHovered ? 4 : 0,
                            x: parallaxX * 0.5,
                            y: isHovered ? 6 : 0
                        )
                }
                .animation(.interpolatingSpring(mass: 0.5, stiffness: 170, damping: 15), value: mouseLoc)
                .animation(.easeInOut(duration: 0.25), value: isHovered)
                
                Text(label)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.white.opacity(isHovered ? 1.0 : 0.7))
            }
            .frame(width: size.width, height: size.height)
            .contentShape(Rectangle())
            
            // CAMADA 3: EFEITO SHADER
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .opacity(0.2)
                    
                    RippleMetalView(isHovered: isHovered, mouseLocation: mouseLoc)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .opacity(isHovered ? 1.0 : 0.0)
                }
            )
            .onContinuousHover { phase in
                switch phase {
                case .active(let location):
                    isHovered = true
                    let normalizedX = location.x / size.width
                    let normalizedY = location.y / size.height
                    self.mouseLoc = CGPoint(
                        x: min(max(normalizedX, 0), 1),
                        y: min(max(normalizedY, 0), 1)
                    )
                case .ended:
                    isHovered = false
                    withAnimation(.easeOut(duration: 0.4)) {
                        self.mouseLoc = CGPoint(x: 0.5, y: 0.5)
                    }
                }
            }
        }
        .frame(height: 72)
        .frame(maxWidth: .infinity)
    }
}
