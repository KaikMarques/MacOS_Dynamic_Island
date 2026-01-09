//
//  SystemSliderView.swift
//  V2-Dynamic Island
//
//  Ver. 18.0 - Interactive Volume & Brightness Sliders
//

import SwiftUI

struct SystemSliderView: View {
    let icon: String
    @Binding var value: CGFloat // 0.0 a 1.0
    var isBrightness: Bool = false
    
    @State private var isDragging = false
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let activeWidth = width * value
            
            ZStack(alignment: .leading) {
                // 1. Fundo do Slider
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: isDragging ? 32 : 28) // Engrossa ao interagir
                
                // 2. Parte Ativa (Preenchimento)
                Capsule()
                    .fill(Color.white)
                    .frame(width: max(32, activeWidth), height: isDragging ? 32 : 28)
                    .animation(.spring(response: 0.3), value: value)
                
                // 3. Ícone (Muda de cor dependendo se está na parte branca ou escura)
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.appleLakeCharcoal) // Ícone sempre escuro dentro do branco
                    .padding(.leading, 10)
            }
            // GESTO DE ARRASTAR
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        withAnimation(.interactiveSpring()) {
                            isDragging = true
                            // Calcula porcentagem baseada na posição X
                            let newProgress = min(max(0, value.location.x / width), 1)
                            self.value = newProgress
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.spring()) {
                            isDragging = false
                        }
                    }
            )
        }
        .frame(height: 32)
    }
}
