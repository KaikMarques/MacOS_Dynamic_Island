//
//  AppleLakeStyles.swift
//  V2-Dynamic Island
//
//  Ver. 14.0 - Design System Definitions (Colors & Modifiers)
//

import SwiftUI

// --- EXTENSÃO DE CORES DO SISTEMA ---
extension Color {
    // Backgrounds
    static let appleLakeBlack = Color(red: 0, green: 0, blue: 0)
    static let appleLakeCharcoal = Color(red: 0.11, green: 0.11, blue: 0.12) // #1C1C1E
    
    // System Colors
    static let appleLakeGreen = Color(red: 0.20, green: 0.78, blue: 0.35) // #34C759
    static let appleLakeRed = Color(red: 1.0, green: 0.23, blue: 0.19)   // #FF3B30
    static let appleLakeGrey = Color(red: 0.56, green: 0.56, blue: 0.58) // #8E8E93
    
    // Accents (Gradients)
    static let accentGradient = LinearGradient(
        colors: [.indigo, .purple, .pink],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// --- MODIFICADORES DE UI (Squircle & Glass) ---

struct AppleLakeCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Camada 1: Blur
                    Rectangle()
                        .fill(.ultraThinMaterial)
                    // Camada 2: Tintura Carvão
                    Rectangle()
                        .fill(Color.appleLakeCharcoal.opacity(0.6))
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous)) // Squircle
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(.white.opacity(0.08), lineWidth: 0.5) // Borda sutil
            )
    }
}

extension View {
    func appleLakeCard() -> some View {
        self.modifier(AppleLakeCardModifier())
    }
}
