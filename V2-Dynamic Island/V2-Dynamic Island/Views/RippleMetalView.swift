//
//  RippleMetalView.swift
//  V2-Dynamic Island
//
//  View SwiftUI para efeito de ondas (ripple) em botões
//  Apenas a ponte NSViewRepresentable - lógica de render está em RippleRenderer
//

import SwiftUI
import MetalKit

struct RippleMetalView: NSViewRepresentable {
    var isHovered: Bool
    
    func makeCoordinator() -> RippleRenderer {
        RippleRenderer()
    }
    
    func makeNSView(context: Context) -> MTKView {
        let v = MTKView()
        v.device = context.coordinator.device
        v.delegate = context.coordinator
        v.framebufferOnly = true
        v.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        v.layer?.isOpaque = false
        return v
    }
    
    func updateNSView(_ nsView: MTKView, context: Context) {
        context.coordinator.setHovered(isHovered)
    }
}

#Preview {
    RippleMetalView(isHovered: true)
        .frame(width: 100, height: 100)
        .background(.black)
}
