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
        
        // MUDANÇA CRÍTICA: .screenSaver é o nível mais alto possível.
        // Isso permite que a Island sobreponha a barra de menus e o notch físico.
        self.level = .screenSaver
        
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
        self.hasShadow = false
        
        // Permite que cliques passem para o sistema se não houver conteúdo
        self.contentView = NSHostingView(rootView: view)
    }
    
    override var canBecomeKey: Bool {
        return true
    }
}
