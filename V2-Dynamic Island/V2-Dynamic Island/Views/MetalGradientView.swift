//
//  MetalGradientView.swift
//  V2-Dynamic Island
//
//  View SwiftUI que renderiza gradiente animado via Metal
//  Apenas a ponte NSViewRepresentable - lógica de render está em GradientRenderer
//

import SwiftUI
import MetalKit

struct MetalGradientView: NSViewRepresentable {
    
    func makeCoordinator() -> GradientRenderer {
        GradientRenderer()
    }
    
    func makeNSView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.device = context.coordinator.device
        mtkView.framebufferOnly = true
        mtkView.enableSetNeedsDisplay = false
        mtkView.isPaused = false
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        return mtkView
    }
    
    func updateNSView(_ nsView: MTKView, context: Context) {
        // Atualizações de estado do SwiftUI podem vir aqui
    }
}

#Preview {
    MetalGradientView()
        .frame(width: 400, height: 300)
}
