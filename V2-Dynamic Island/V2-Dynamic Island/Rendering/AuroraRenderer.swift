//
//  AuroraRenderer.swift
//  V2-Dynamic Island
//
//  Renderer Metal para efeito de borda aurora/neon
//

import Foundation
import MetalKit

class AuroraRenderer: NSObject, MTKViewDelegate {
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState!
    var startTime: Date
    
    // Controle de animação
    var progress: Float = 0.0
    var isAnimating: Bool = false
    var wasActiveLastFrame: Bool = false
    var currentActiveLevel: Float = 0.0
    var targetActiveLevel: Float = 0.0
    
    override init() {
        self.startTime = Date()
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
            
            let vertexFn = library.makeFunction(name: "aurora_vertex_main")
            let fragmentFn = library.makeFunction(name: "aurora_fragment_main")
            
            let descriptor = MTLRenderPipelineDescriptor()
            descriptor.vertexFunction = vertexFn
            descriptor.fragmentFunction = fragmentFn
            descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            descriptor.colorAttachments[0].isBlendingEnabled = true
            descriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
            descriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
            descriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
            descriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
            
            self.pipelineState = try device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            print("Metal Error: \(error)")
        }
    }
    
    func triggerOneShotAnimation() {
        progress = 0.0
        isAnimating = true
    }
    
    func updateActiveState(isActive: Bool) {
        if isActive && !wasActiveLastFrame {
            triggerOneShotAnimation()
        }
        wasActiveLastFrame = isActive
        targetActiveLevel = isActive ? 1.0 : 0.0
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let rpd = view.currentRenderPassDescriptor,
              let pipelineState = pipelineState else { return }
        
        // Atualiza progresso da animação
        if isAnimating {
            let speed: Float
            if progress < 0.3 { speed = 0.04 }
            else if progress < 0.7 { speed = 0.005 }
            else { speed = 0.04 }
            
            progress += speed
            if progress >= 1.0 { progress = 1.0; isAnimating = false }
        } else {
            if progress > 0.0 { progress = 0.0 }
        }
        
        // Interpolação suave do nível de ativação
        currentActiveLevel += (targetActiveLevel - currentActiveLevel) * 0.1
        
        let buffer = commandQueue.makeCommandBuffer()
        let encoder = buffer?.makeRenderCommandEncoder(descriptor: rpd)
        encoder?.setRenderPipelineState(pipelineState)
        
        var uniforms = AuroraUniforms(
            time: Float(Date().timeIntervalSince(startTime)),
            progress: progress,
            isActive: currentActiveLevel,
            resolution: SIMD2<Float>(Float(view.drawableSize.width), Float(view.drawableSize.height))
        )
        
        encoder?.setVertexBytes(&uniforms, length: MemoryLayout<AuroraUniforms>.size, index: 1)
        encoder?.setFragmentBytes(&uniforms, length: MemoryLayout<AuroraUniforms>.size, index: 0)
        encoder?.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        encoder?.endEncoding()
        buffer?.present(drawable)
        buffer?.commit()
    }
}
