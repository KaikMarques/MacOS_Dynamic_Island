//
//  DesignSystem.swift
//  V2-Dynamic Island
//
//  Centralização de Medidas e Cores (Mantendo o Design Original)
//

import SwiftUI

enum DS {
    // MARK: - Layout & Dimensões
    enum Layout {
        // Modo Colapsado (Original)
        static let collapsedWidth: CGFloat = 285.0
        static let collapsedHeight: CGFloat = 37.0
        static let cornerRadiusCollapsed: CGFloat = 14.0
        
        // Modo Expandido (Ajuste aqui se quiser diminuir/aumentar)
        static let expandedWidth: CGFloat = 440.0
        static let expandedHeight: CGFloat = 255.0
        static let cornerRadiusExpanded: CGFloat = 32.0
    }
    
    // MARK: - Cores & Materiais
    enum Color {
        static let accentPrimary = SwiftUI.Color.blue
        static let statusSuccess = SwiftUI.Color.green
        static let statusWarning = SwiftUI.Color.orange
        
        // O SEU Gradiente Original (Preto Profundo -> Cinza 0.08)
        static let hardwareGradient = LinearGradient(
            stops: [
                .init(color: .black, location: 0),
                .init(color: .black, location: 0.85),
                .init(color: SwiftUI.Color(white: 0.08), location: 1.0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // MARK: - Animações
    enum Anim {
        // Sua mola calibrada (0.52 / 0.75)
        static let spring = Animation.spring(response: 0.52, dampingFraction: 0.75)
        static let pulse = Animation.easeInOut(duration: 4.0).repeatForever(autoreverses: false)
    }
}
