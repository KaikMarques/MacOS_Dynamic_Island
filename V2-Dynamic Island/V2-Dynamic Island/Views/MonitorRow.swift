//
//  MonitorRow.swift
//  V2-Dynamic Island
//
//  Componente auxiliar para exibir dados de monitoramento
//

import SwiftUI

struct MonitorRow: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 14, design: .monospaced))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    HStack {
        MonitorRow(label: "CPU", value: "45%", color: .green)
        MonitorRow(label: "RAM", value: "8.2 GB", color: .blue)
    }
    .padding()
    .background(.black)
}
