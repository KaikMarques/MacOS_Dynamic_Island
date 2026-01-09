//
//  FileSelectorComponent.swift
//  V2-Dynamic Island
//
//  Ver. 15.1 - File Selector Component (Restored)
//

import SwiftUI
import UniformTypeIdentifiers

struct FileSelectorComponent: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        HStack(spacing: 8) {
            // Campo de Texto (Visualização do Caminho)
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.3))
                        .padding(.horizontal, 10)
                }
                
                TextField("", text: $text)
                    .textFieldStyle(.plain)
                    .font(.system(size: 11))
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.black.opacity(0.3))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.white.opacity(text.isEmpty ? 0.05 : 0.2), lineWidth: 1)
                    )
            }
            
            // Botão de Seleção (Pasta)
            Button(action: openFilePanel) {
                Image(systemName: "folder.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.9))
                    .frame(width: 32, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .help("Escolher arquivo local")
        }
    }
    
    // Lógica do Finder (NSOpenPanel)
    private func openFilePanel() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.movie, .video, .quickTimeMovie, .mpeg4Movie]
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                self.text = url.absoluteString
            }
        }
    }
}
