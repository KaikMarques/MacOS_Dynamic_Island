//
//  LiquidSlider.swift
//  V2-Dynamic Island
//
//  Ver. 22.0 - Custom Jello/Liquid Physics Slider
//

import SwiftUI

struct LiquidSlider: View {
    let icon: String
    @Binding var value: CGFloat // Valor de 0.0 a 1.0
    
    // Estados para a física da animação
    @State private var isDragging: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            
            // Calcula a largura da barra baseada no valor
            let fillWidth = max(0, min(width * value, width))
            
            ZStack(alignment: .leading) {
                
                // 1. TRILHA DE FUNDO (Vidro Fosco)
                Capsule()
                    .fill(.white.opacity(0.1))
                    .frame(height: isDragging ? 32 : 28) // Efeito Squash (Engorda ao arrastar)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isDragging)
                
                // 2. LÍQUIDO (Preenchimento)
                Capsule()
                    .fill(Color.white)
                    .frame(width: fillWidth, height: isDragging ? 32 : 28)
                    // A MÁGICA DO JELLO: Interpolating Spring
                    // Isso faz a barra balançar quando para e ter inércia
                    .animation(.interpolatingSpring(stiffness: 170, damping: 15), value: value)
                
                // 3. ÍCONE (Contraste Inteligente)
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(
                        // Se a barra branca passar por cima do ícone, ele fica preto. Se não, branco.
                        (fillWidth > 24) ? Color.black.opacity(0.8) : Color.white.opacity(0.8)
                    )
                    .padding(.leading, 10)
                    .animation(.easeInOut(duration: 0.2), value: value)
            }
            // GESTO DE ARRASTE
            .contentShape(Rectangle()) // Aumenta área de toque
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        // 1. Ativa o estado de "pressão"
                        if !isDragging {
                            withAnimation(.spring(response: 0.3)) {
                                isDragging = true
                            }
                            // Feedback tátil (se disponível no trackpad)
                            NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .default)
                        }
                        
                        // 2. Calcula novo valor
                        let newValue = gesture.location.x / width
                        self.value = min(max(0, newValue), 1)
                    }
                    .onEnded { _ in
                        // 3. Solta a pressão (o spring faz ela balançar)
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                            isDragging = false
                        }
                    }
            )
        }
        .frame(height: 32) // Altura total reservada
    }
}
