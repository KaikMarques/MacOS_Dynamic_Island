//
//  DashboardView.swift
//  V2-Dynamic Island
//
//  Ver. 18.0 - Full Dashboard Integration (Widgets + Media + Sliders)
//

import SwiftUI

struct DashboardView: View {
    @State private var volumeLevel: CGFloat = 0.6
    @State private var brightnessLevel: CGFloat = 0.8
    
    // Configurações para visibilidade condicional
    @AppStorage("showWeather") private var showWeather: Bool = true
    @AppStorage("showCalendar") private var showCalendar: Bool = true
    
    var body: some View {
        VStack(spacing: 12) {
            
            // 1. LINHA DE WIDGETS (Clima & Calendário)
            if showWeather || showCalendar {
                HStack(spacing: 12) {
                    if showWeather {
                        WeatherWidget()
                    }
                    if showCalendar {
                        CalendarWidget()
                    }
                }
                .frame(height: 56) // Altura fixa para widgets
            }
            
            // 2. MEDIA PLAYER
            MediaNowPlayingView()
            
            // 3. SLIDERS DE SISTEMA
            HStack(spacing: 12) {
                SystemSliderView(icon: "speaker.wave.3.fill", value: $volumeLevel)
                SystemSliderView(icon: "sun.max.fill", value: $brightnessLevel, isBrightness: true)
            }
        }
    }
}

// --- SUBCOMPONENTES DE WIDGET (Extraídos para limpeza) ---

struct WeatherWidget: View {
    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle().fill(Color.blue.opacity(0.2)).frame(width: 32, height: 32)
                Image(systemName: "cloud.drizzle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .cyan)
                    .font(.system(size: 16))
            }
            VStack(alignment: .leading, spacing: 0) {
                Text("18°").font(.system(size: 14, weight: .bold)).foregroundStyle(.white)
                Text("Chuva").font(.system(size: 10)).foregroundStyle(Color.appleLakeGrey)
            }
            Spacer()
        }
        .padding(10)
        .appleLakeCard()
    }
}

struct CalendarWidget: View {
    var body: some View {
        HStack(spacing: 10) {
            Rectangle().fill(Color.appleLakeGreen).frame(width: 3)
                .clipShape(Capsule())
            
            VStack(alignment: .leading, spacing: 2) {
                Text("REUNIÃO").font(.system(size: 8, weight: .bold)).foregroundStyle(Color.appleLakeGrey)
                Text("Design System").font(.system(size: 11, weight: .semibold)).foregroundStyle(.white)
                Text("10:00 AM").font(.system(size: 9)).foregroundStyle(.white.opacity(0.6))
            }
            Spacer()
        }
        .padding(10)
        .appleLakeCard()
    }
}
