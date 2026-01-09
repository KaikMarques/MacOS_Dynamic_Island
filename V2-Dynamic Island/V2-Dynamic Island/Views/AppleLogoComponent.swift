//
//  AppleLogoComponent.swift
//  V2-Dynamic Island
//
//  Componente do logo Apple com efeitos visuais
//

import SwiftUI

struct AppleLogoComponent: View {
    let isExpanded: Bool
    let isSettingsOpen: Bool
    
    var onTap: (() -> Void)? = nil
    
    @State private var lightPos: CGFloat = -1.5
    @State private var glowOpacity: Double = 0.0
    @State private var revealProgress: CGFloat = 0.0
    @State private var pulseIntensity: Double = 0.6
    
    private let silverColors: [Color] = [
        Color(white: 0.45),
        Color(white: 0.90),
        Color(white: 0.65),
        Color(white: 0.95),
        Color(white: 0.55)
    ]
    
    private let goldColor = Color(red: 0.85, green: 0.72, blue: 0.25)
    private let offWhite = Color(white: 0.90)

    var body: some View {
        ZStack {
            // Logo base
            Image(systemName: "applelogo")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(isExpanded ? offWhite : .white)
            
            // Logo com efeito metalizado
            ZStack {
                Image(systemName: "applelogo")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: silverColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                GoldDotsPattern(color: goldColor)
                    .mask(
                        Image(systemName: "applelogo")
                            .font(.system(size: 14, weight: .medium))
                    )
            }
            .opacity(isExpanded ? 1 : 0)
            .mask(
                Rectangle()
                    .scaleEffect(x: revealProgress, y: 1.0, anchor: .leading)
            )
            .shadow(
                color: isSettingsOpen
                    ? .white.opacity(0.8 * pulseIntensity)
                    : goldColor.opacity(0.35 * glowOpacity),
                radius: isSettingsOpen ? 12 : 6
            )
            .shadow(
                color: isSettingsOpen
                    ? .white.opacity(0.5 * pulseIntensity)
                    : .clear,
                radius: isSettingsOpen ? 35 : 0
            )
            
            // Efeito de brilho quando settings está aberto
            if isSettingsOpen {
                ZStack {
                    Image(systemName: "applelogo")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                        .blur(radius: 0.6)
                    Image(systemName: "applelogo")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                        .blur(radius: 3.0)
                        .opacity(1.0)
                    Image(systemName: "applelogo")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                        .blur(radius: 6.0)
                        .opacity(0.8)
                }
                .opacity(pulseIntensity)
                .blendMode(.screen)
            }
            
            // Efeito de luz passando
            GeometryReader { geo in
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                .white.opacity(0.4),
                                .white.opacity(1.0),
                                .white.opacity(0.4),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .scaleEffect(x: 0.45)
                    .rotationEffect(.degrees(-25))
                    .offset(x: lightPos * geo.size.width)
                    .mask(
                        Image(systemName: "applelogo")
                            .font(.system(size: 14, weight: .medium))
                            .position(x: geo.size.width/2, y: geo.size.height/2)
                    )
            }
            .opacity(isExpanded ? 1 : 0)
        }
        .frame(width: 20, height: 20)
        .contentShape(Rectangle())
        .onTapGesture { onTap?() }
        .onChange(of: isExpanded) { _, newValue in
            if newValue {
                startAnimation()
            } else {
                resetAnimation()
            }
        }
        .onChange(of: isSettingsOpen) { _, newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                    pulseIntensity = 2.0
                }
            } else {
                withAnimation(.easeOut(duration: 0.5)) {
                    pulseIntensity = 0.6
                }
            }
        }
    }
    
    private func startAnimation() {
        lightPos = -1.5
        revealProgress = 0.0
        glowOpacity = 0.0
        
        let slowMotionCurve = Animation.timingCurve(0.1, 0.9, 0.9, 0.1, duration: 3.8)
        withAnimation(slowMotionCurve.delay(1.5)) {
            lightPos = 2.5
            revealProgress = 1.5
        }
        withAnimation(.easeInOut(duration: 1.5).delay(1.5)) {
            glowOpacity = 1.0
        }
    }
    
    private func resetAnimation() {
        lightPos = -1.5
        revealProgress = 0.0
        glowOpacity = 0.0
        pulseIntensity = 0.6
    }
}

#Preview {
    HStack(spacing: 40) {
        AppleLogoComponent(isExpanded: false, isSettingsOpen: false)
        AppleLogoComponent(isExpanded: true, isSettingsOpen: false)
        AppleLogoComponent(isExpanded: true, isSettingsOpen: true)
    }
    .padding(40)
    .background(.black)
}
