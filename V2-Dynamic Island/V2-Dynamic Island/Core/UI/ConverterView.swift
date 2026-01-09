//
//  ConverterView.swift
//  V2-Dynamic Island
//
//  Ver. 16.0 - File Conversion Interface (UI)
//

import SwiftUI

struct ConverterView: View {
    // Arquivo que foi solto
    let fileURL: URL
    
    // Callback para fechar/cancelar
    var onCancel: () -> Void
    
    @State private var isConverting = false
    @State private var conversionProgress: CGFloat = 0.0
    @State private var success = false
    
    // Formatos Suportados
    let formats = ["PNG", "JPG", "PDF", "SVG"]
    
    var body: some View {
        HStack(spacing: 16) {
            
            // 1. PREVIEW DO ARQUIVO (Ícone)
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 48, height: 48)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
                
                Image(systemName: "doc.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.blue.gradient)
            }
            
            // 2. INFORMAÇÕES E AÇÕES
            VStack(alignment: .leading, spacing: 4) {
                // Nome do Arquivo
                Text(fileURL.lastPathComponent)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .truncationMode(.middle)
                
                if success {
                    Label("Salvo em Downloads", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.appleLakeGreen)
                } else if isConverting {
                    // Barra de Progresso
                    HStack(spacing: 8) {
                        ProgressView(value: conversionProgress, total: 1.0)
                            .progressViewStyle(.linear)
                            .tint(Color.blue)
                            .frame(height: 4)
                        Text("\(Int(conversionProgress * 100))%")
                            .font(.system(size: 9))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                } else {
                    // Menu de Formatos
                    HStack(spacing: 6) {
                        Text("Converter para:")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.appleLakeGrey)
                        
                        ForEach(formats, id: \.self) { format in
                            Button(action: { startConversion(to: format) }) {
                                Text(format)
                                    .font(.system(size: 9, weight: .bold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Color.white.opacity(0.15))
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            
            Spacer()
            
            // 3. BOTÃO FECHAR
            Button(action: onCancel) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.appleLakeGrey.opacity(0.5))
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(Color.appleLakeCharcoal)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
    }
    
    // Simulação de Conversão Complexa
    func startConversion(to format: String) {
        withAnimation { isConverting = true }
        
        // Simula processamento assíncrono
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            withAnimation {
                conversionProgress += 0.05
            }
            if conversionProgress >= 1.0 {
                timer.invalidate()
                withAnimation {
                    isConverting = false
                    success = true
                }
                // Fecha automaticamente após sucesso
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    onCancel()
                }
            }
        }
    }
}
