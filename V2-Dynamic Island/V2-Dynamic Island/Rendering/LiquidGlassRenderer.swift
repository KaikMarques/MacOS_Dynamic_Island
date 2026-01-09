//
//  LiquidGlassRenderer.swift
//  V2-Dynamic Island
//
//  Renderer Metal para efeito de vidro líquido no fundo
//

import Foundation
import MetalKit

class LiquidGlassRenderer: NSObject, MTKViewDelegate {
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState!
    var startTime = Date()
    
    override init() {
        super.init()
        setupMetal()
    }
    
    private func setupMetal() {
        guard let device = MTLCreateSystemDefaultDevice() else { return }
        self.device = device
        self.commandQueue = device.makeCommandQueue()
        
        do {
            guard let library = device.makeDefaultLibrary() else {
                print("Não foi possível carregar a biblioteca Metal padrão")
                return
            }
            
            let desc = MTLRenderPipelineDescriptor()
            desc.vertexFunction = library.makeFunction(name: "liquid_vertex_main")
            desc.fragmentFunction = library.makeFunction(name: "liquid_fragment_background")
            desc.colorAttachments[0].pixelFormat = .bgra8Unorm
            desc.colorAttachments[0].isBlendingEnabled = true
            desc.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
            desc.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
            
            self.pipelineState = try device.makeRenderPipelineState(descriptor: desc)
        } catch {
            print("LiquidGlass Metal Error: \(error)")
        }
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let desc = view.currentRenderPassDescriptor,
              let pipe = pipelineState else { return }
        
        let buffer = commandQueue.makeCommandBuffer()
        let encoder = buffer?.makeRenderCommandEncoder(descriptor: desc)
        encoder?.setRenderPipelineState(pipe)
        
        var uni = LiquidBackgroundUniforms(
            time: Float(Date().timeIntervalSince(startTime)),
            resolution: SIMD2<Float>(Float(view.drawableSize.width), Float(view.drawableSize.height)),
            mousePos: SIMD2<Float>(0, 0)
        )
        
        encoder?.setFragmentBytes(&uni, length: MemoryLayout<LiquidBackgroundUniforms>.size, index: 0)
        encoder?.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        encoder?.endEncoding()
        buffer?.present(drawable)
        buffer?.commit()
    }
}
