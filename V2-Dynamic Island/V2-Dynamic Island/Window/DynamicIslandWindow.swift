//
//  DynamicIslandWindow.swift
//  V2-Dynamic Island
//
//  Janela customizada sem bordas para a Dynamic Island
//

import AppKit
import SwiftUI

class DynamicIslandWindow: NSWindow {
    init<Content: View>(contentRect: NSRect, view: Content) {
        super.init(
            contentRect: contentRect,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        self.isOpaque = false
        self.backgroundColor = .clear
        
        // Mantém nível ScreenSaver para ficar acima de tudo
        self.level = .screenSaver
        
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
        self.hasShadow = false
        
        // Permite cliques passarem se não houver conteúdo
        self.contentView = NSHostingView(rootView: view)
    }
    
    override var canBecomeKey: Bool {
        return true
    }
}
