//
//  DashboardView.swift
//  V2-Dynamic Island
//
//  Ver. 14.0 - Widget Dashboard (Weather & Calendar)
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        HStack(spacing: 12) {
            // --- WIDGET 1: CLIMA ---
            HStack(spacing: 12) {
                // Ícone do Clima (Símbolo SF com gradiente)
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "cloud.drizzle.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, .cyan)
                        .font(.system(size: 18))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("18°")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text("Chuva Moderada")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.appleLakeGrey)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .appleLakeCard() // Aplica o Design System
            
            // --- WIDGET 2: CALENDÁRIO (Timeline) ---
            HStack(spacing: 12) {
                // Linha do Tempo Visual
                VStack(spacing: 0) {
                    Circle()
                        .fill(Color.appleLakeGreen)
                        .frame(width: 6, height: 6)
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 1.5, height: 24)
                }
                .padding(.top, 4)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("UPCOMING")
                        .font(.system(size: 8, weight: .bold))
                        .tracking(1.0)
                        .foregroundStyle(Color.appleLakeGrey)
                    
                    Text("Reunião de Design")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white)
                    
                    Text("10:00 - 11:30 • Sala 2")
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .appleLakeCard()
        }
        .padding(.horizontal, 4)
    }
}

#Preview {
    ZStack {
        Color.black
        DashboardView()
            .frame(width: 440)
    }
}
