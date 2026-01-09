//
//  RippleRenderer.swift
//  V2-Dynamic Island
//
//  Renderer Metal para efeito de ondas (ripple) em botões
//

import Foundation
import MetalKit

class RippleRenderer: NSObject, MTKViewDelegate {
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState!
    var startTime = Date()
    
    // Controle de hover
    var currentHover: Float = 0.0
    var targetHover: Float = 0.0
    
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
            desc.fragmentFunction = library.makeFunction(name: "liquid_fragment_ripple")
            desc.colorAttachments[0].pixelFormat = .bgra8Unorm
            desc.colorAttachments[0].isBlendingEnabled = true
            desc.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
            desc.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
            
            self.pipelineState = try device.makeRenderPipelineState(descriptor: desc)
        } catch {
            print("Ripple Metal Error: \(error)")
        }
    }
    
    func setHovered(_ isHovered: Bool) {
        targetHover = isHovered ? 1.0 : 0.0
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {
        // Animação suave do valor de hover
        currentHover += (targetHover - currentHover) * 0.1
        
        // Otimização: não renderiza se não houver efeito visível
        if currentHover < 0.01 && targetHover == 0 { return }
        
        guard let draw = view.currentDrawable,
              let desc = view.currentRenderPassDescriptor,
              let pipe = pipelineState else { return }
        
        let buf = commandQueue.makeCommandBuffer()
        let enc = buf?.makeRenderCommandEncoder(descriptor: desc)
        enc?.setRenderPipelineState(pipe)
        
        var uni = LiquidRippleUniforms(
            time: Float(Date().timeIntervalSince(startTime)),
            hoverStrength: currentHover,
            resolution: SIMD2<Float>(0, 0)
        )
        
        enc?.setFragmentBytes(&uni, length: MemoryLayout<LiquidRippleUniforms>.size, index: 0)
        enc?.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        enc?.endEncoding()
        buf?.present(draw)
        buf?.commit()
    }
}
