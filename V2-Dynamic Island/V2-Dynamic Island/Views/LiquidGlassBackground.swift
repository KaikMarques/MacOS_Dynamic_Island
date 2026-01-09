//
//  LiquidGlassBackground.swift
//  V2-Dynamic Island
//
//  View SwiftUI para efeito de vidro líquido
//  Apenas a ponte NSViewRepresentable - lógica de render está em LiquidGlassRenderer
//

import SwiftUI
import MetalKit

struct LiquidGlassBackground: NSViewRepresentable {
    
    func makeCoordinator() -> LiquidGlassRenderer {
        LiquidGlassRenderer()
    }
    
    func makeNSView(context: Context) -> MTKView {
        let view = MTKView()
        view.device = context.coordinator.device
        view.delegate = context.coordinator
        view.framebufferOnly = true
        view.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        view.layer?.isOpaque = false
        return view
    }
    
    func updateNSView(_ nsView: MTKView, context: Context) {}
}

#Preview {
    LiquidGlassBackground()
        .frame(width: 400, height: 300)
}
