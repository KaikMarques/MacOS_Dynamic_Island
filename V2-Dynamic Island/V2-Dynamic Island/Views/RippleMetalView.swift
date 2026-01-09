//
//  RippleMetalView.swift
//  V2-Dynamic Island
//
//  Ver. 9.2 - Standard Animation Engine (No Elasticity)
//

import SwiftUI
import MetalKit

struct RippleUniforms {
    var time: Float
    var hoverStrength: Float
    var resolution: SIMD2<Float>
    var mousePos: SIMD2<Float>
}

struct RippleMetalView: View {
    var isHovered: Bool
    var mouseLocation: CGPoint
    
    var body: some View {
        RippleRendererContainer(isHovered: isHovered, mouseLocation: mouseLocation)
    }
}

struct RippleRendererContainer: NSViewRepresentable {
    var isHovered: Bool
    var mouseLocation: CGPoint
    
    func makeNSView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.device = MTLCreateSystemDefaultDevice()
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60
        mtkView.enableSetNeedsDisplay = false
        mtkView.isPaused = false
        mtkView.framebufferOnly = false
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        mtkView.layer?.isOpaque = false
        return mtkView
    }
    
    func updateNSView(_ nsView: MTKView, context: Context) {
        context.coordinator.targetIsHovered = isHovered
        context.coordinator.mouseLocation = mouseLocation
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, MTKViewDelegate {
        var commandQueue: MTLCommandQueue?
        var pipelineState: MTLRenderPipelineState?
        var startTime: Date = Date()
        
        var targetIsHovered: Bool = false
        var currentHoverStrength: Float = 0.0
        var mouseLocation: CGPoint = .zero
        
        override init() {
            super.init()
            guard let device = MTLCreateSystemDefaultDevice() else { return }
            self.commandQueue = device.makeCommandQueue()
            
            guard let library = device.makeDefaultLibrary() else { return }
            let vertexFunc = library.makeFunction(name: "liquid_vertex_main")
            let fragmentFunc = library.makeFunction(name: "liquid_fragment_ripple")
            
            let pipelineDesc = MTLRenderPipelineDescriptor()
            pipelineDesc.vertexFunction = vertexFunc
            pipelineDesc.fragmentFunction = fragmentFunc
            pipelineDesc.colorAttachments[0].pixelFormat = .bgra8Unorm
            pipelineDesc.colorAttachments[0].isBlendingEnabled = true
            pipelineDesc.colorAttachments[0].rgbBlendOperation = .add
            pipelineDesc.colorAttachments[0].alphaBlendOperation = .add
            pipelineDesc.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
            pipelineDesc.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
            pipelineDesc.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
            pipelineDesc.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
            
            self.pipelineState = try? device.makeRenderPipelineState(descriptor: pipelineDesc)
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
        
        func draw(in view: MTKView) {
            guard let drawable = view.currentDrawable,
                  let pipelineState = pipelineState,
                  let descriptor = view.currentRenderPassDescriptor,
                  let commandBuffer = commandQueue?.makeCommandBuffer(),
                  let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else { return }
            
            let time = Float(Date().timeIntervalSince(startTime))
            let targetStrength: Float = targetIsHovered ? 1.0 : 0.0
            
            // Interpolação Linear Padrão (Sem efeito elástico/mola)
            // 0.1 dá uma velocidade agradável de resposta
            currentHoverStrength += (targetStrength - currentHoverStrength) * 0.1
            
            if currentHoverStrength < 0.001 && !targetIsHovered {
                renderEncoder.endEncoding()
                commandBuffer.commit()
                return
            }
            
            var uniforms = RippleUniforms(
                time: time,
                hoverStrength: currentHoverStrength,
                resolution: SIMD2<Float>(Float(view.drawableSize.width), Float(view.drawableSize.height)),
                mousePos: SIMD2<Float>(Float(mouseLocation.x), Float(mouseLocation.y))
            )
            
            renderEncoder.setRenderPipelineState(pipelineState)
            renderEncoder.setFragmentBytes(&uniforms, length: MemoryLayout<RippleUniforms>.size, index: 0)
            renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
            
            renderEncoder.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}
