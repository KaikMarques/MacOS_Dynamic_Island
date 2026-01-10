//
//  FloatingWindowController.swift
//  V2-Dynamic Island
//
//  Ver. 20.0 - Invisible Window for True Glassmorphism
//

import Cocoa
import SwiftUI

class FloatingWindowController: NSWindowController {
    
    convenience init() {
        // Cria uma janela sem bordas, sem título e que suporta transparência total
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 440, height: 255), // Tamanho máximo suportado
            styleMask: [.borderless, .fullSizeContentView], // Sem borda, conteúdo total
            backing: .buffered,
            defer: false
        )
        
        // --- CONFIGURAÇÕES DE TRANSPARÊNCIA (O SEGREDO DO VIDRO) ---
        window.isOpaque = false // Permite ver através da janela
        window.backgroundColor = .clear // Remove qualquer cor de fundo padrão
        window.hasShadow = false // Remove sombra nativa (nós desenhamos a nossa no SwiftUI)
        
        // Comportamento de Nível e Espaço
        window.level = .floating // Fica acima das outras janelas
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary] // Aparece em todos os desktops
        window.ignoresMouseEvents = false // Permite clicar na ilha
        
        // Inicializa com a View Principal
        let contentView = IslandView()
        window.contentView = NSHostingView(rootView: contentView)
        
        // Posicionamento Inicial (Centro do Topo)
        if let screen = NSScreen.main {
            let screenRect = screen.visibleFrame
            let xPos = screenRect.midX - (window.frame.width / 2)
            let yPos = screenRect.maxY - window.frame.height + 37 // Ajuste fino para o topo
            window.setFrameOrigin(NSPoint(x: xPos, y: yPos))
        }
        
        self.init(window: window)
    }
}
