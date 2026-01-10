//
//  DashboardView.swift
//  V2-Dynamic Island
//
//  Ver. 21.0 - Compact & Refined Dashboard
//

import SwiftUI

struct DashboardView: View {
    @State private var volume: CGFloat = 0.6
    @State private var brightness: CGFloat = 0.8
    @AppStorage("showWeather") private var showWeather: Bool = true
    @AppStorage("showCalendar") private var showCalendar: Bool = true
    
    var body: some View {
        VStack(spacing: 10) { // Espaçamento entre linhas reduzido
            
            // 1. LINHA DE WIDGETS
            if showWeather || showCalendar {
                HStack(spacing: 8) {
                    if showWeather { WeatherWidget() }
                    if showCalendar { CalendarWidget() }
                }
                .frame(height: 44) // Altura fixa reduzida
            }
            
            // 2. MEDIA PLAYER COMPACTO
            CompactMediaView()
            
            // 3. SLIDERS FINOS
            HStack(spacing: 8) {
                CompactSlider(icon: "speaker.wave.3.fill", value: $volume)
                CompactSlider(icon: "sun.max.fill", value: $brightness)
            }
        }
    }
}

// --- WIDGETS COMPACTOS ---

struct WeatherWidget: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "cloud.drizzle.fill")
                .symbolRenderingMode(.palette).foregroundStyle(.white, .cyan)
                .font(.system(size: 14))
            VStack(alignment: .leading, spacing: 0) {
                Text("18°").font(.system(size: 12, weight: .bold)).foregroundStyle(.white)
                Text("Chuva").font(.system(size: 9)).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct CalendarWidget: View {
    var body: some View {
        HStack(spacing: 8) {
            Rectangle().fill(Color.green).frame(width: 2).clipShape(Capsule())
            VStack(alignment: .leading, spacing: 1) {
                Text("REUNIÃO").font(.system(size: 7, weight: .bold)).foregroundStyle(.secondary)
                Text("Design System").font(.system(size: 10, weight: .semibold)).foregroundStyle(.white)
            }
            Spacer()
        }
        .padding(8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct CompactMediaView: View {
    var body: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 8).fill(Color.purple)
                .frame(width: 36, height: 36)
                .overlay(Image(systemName: "music.note").font(.system(size: 14)).foregroundStyle(.white))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Midnight City").font(.system(size: 11, weight: .semibold)).foregroundStyle(.white)
                Text("M83").font(.system(size: 9)).foregroundStyle(.secondary)
            }
            Spacer()
            
            HStack(spacing: 12) {
                Image(systemName: "backward.fill").font(.system(size: 10))
                Image(systemName: "pause.fill").font(.system(size: 14))
                Image(systemName: "forward.fill").font(.system(size: 10))
            }.foregroundStyle(.white)
        }
        .padding(8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct CompactSlider: View {
    let icon: String; @Binding var value: CGFloat
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 9)).foregroundStyle(.secondary).frame(width: 12)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.1))
                    Capsule().fill(.white).frame(width: geo.size.width * value)
                }
            }
            .frame(height: 4)
        }
        .padding(8)
        .frame(height: 28)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }
}
