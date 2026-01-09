//
//  GradientRenderer.swift
//  V2-Dynamic Island
//
//  Renderer Metal para efeitos de gradiente animado
//

import Foundation
import MetalKit

class GradientRenderer: NSObject, MTKViewDelegate {
    weak var view: MTKView?
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState!
    var startTime: Date
    
    override init() {
        self.startTime = Date()
        super.init()
        setupMetal()
    }
    
    private func setupMetal() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("GPU não suportada neste dispositivo")
        }
        self.device = device
        self.commandQueue = device.makeCommandQueue()
        
        do {
            // Carrega shaders do arquivo .metal compilado
            guard let library = device.makeDefaultLibrary() else {
                fatalError("Não foi possível carregar a biblioteca Metal padrão")
            }
            
            let vertexFunction = library.makeFunction(name: "gradient_vertex_main")
            let fragmentFunction = library.makeFunction(name: "gradient_fragment_main")
            
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexFunction = vertexFunction
            pipelineDescriptor.fragmentFunction = fragmentFunction
            pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            
            self.pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            print("Erro ao criar pipeline de gradiente: \(error)")
        }
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let pipelineState = pipelineState else { return }
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        
        renderEncoder?.setRenderPipelineState(pipelineState)
        
        // Envia tempo
        var time = Float(Date().timeIntervalSince(startTime))
        renderEncoder?.setFragmentBytes(&time, length: MemoryLayout<Float>.size, index: 0)
        
        // Envia resolução
        var resolution = SIMD2<Float>(Float(view.drawableSize.width), Float(view.drawableSize.height))
        renderEncoder?.setFragmentBytes(&resolution, length: MemoryLayout<SIMD2<Float>>.size, index: 1)
        
        renderEncoder?.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        
        renderEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
