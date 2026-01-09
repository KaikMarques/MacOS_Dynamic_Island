//
//  AuroraBackground.swift
//  V2-Dynamic Island
//
//  View SwiftUI para efeito de borda aurora/neon
//  Apenas a ponte NSViewRepresentable - lógica de render está em AuroraRenderer
//

import SwiftUI
import MetalKit

struct AuroraBackground: NSViewRepresentable {
    var isActive: Bool
    
    func makeCoordinator() -> AuroraRenderer {
        AuroraRenderer()
    }
    
    func makeNSView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.device = context.coordinator.device
        mtkView.framebufferOnly = true
        mtkView.enableSetNeedsDisplay = false
        mtkView.isPaused = false
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        mtkView.layer?.isOpaque = false
        return mtkView
    }
    
    func updateNSView(_ nsView: MTKView, context: Context) {
        context.coordinator.updateActiveState(isActive: isActive)
    }
}

#Preview {
    AuroraBackground(isActive: true)
        .frame(width: 300, height: 50)
        .background(.black)
}
