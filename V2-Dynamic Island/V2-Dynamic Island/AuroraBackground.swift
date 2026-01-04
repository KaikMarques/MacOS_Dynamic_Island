import SwiftUI
import MetalKit

// MARK: - Metal Shader Source (MSL)
let auroraShaderSource = """
#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[attribute(0)]];
    float2 uv [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 uv;
};

struct Uniforms {
    float time;
    float progress;   // 0.0 a 1.0 (Controlado pelo Swift com curva Rápido-Lento-Rápido)
    float isActive;   // Estado geral para fade-in da borda
    float2 resolution;
};

vertex VertexOut vertex_main(uint vertexID [[vertex_id]],
                             constant float4 *vertices [[buffer(0)]]) {
    VertexOut out;
    float2 positions[4] = { float2(-1, -1), float2(1, -1), float2(-1, 1), float2(1, 1) };
    out.position = float4(positions[vertexID], 0.0, 1.0);
    out.uv = positions[vertexID] * 0.5 + 0.5;
    return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]],
                              constant Uniforms &uniforms [[buffer(0)]]) {
    
    float2 uv = in.uv;
    float p = uniforms.progress;
    float active = uniforms.isActive;
    
    // Cor da linha em repouso (Cinza Discreto)
    float3 restingColor = float3(0.2, 0.255, 0.333);
    
    // Se a animação acabou (p=0 ou p=1), retorna apenas a cor de repouso (ou branco se estiver ativo)
    if (p <= 0.001 || p >= 0.999) {
        float3 steadyColor = mix(restingColor, float3(0.6), active); // Branco suave se mouse estiver em cima
        return float4(steadyColor, 1.0);
    }
    
    // --- EFEITO DE LINHAS COLORIDAS (BURST) ---
    float3 c1 = float3(0.0, 1.0, 1.0); // Ciano
    float3 c2 = float3(1.0, 0.0, 1.0); // Magenta
    float3 c3 = float3(0.0, 0.5, 1.0); // Azul
    
    float scanPos = (p * 3.0) - 1.0; 
    
    float wave1 = sin(uv.x * 10.0 + uniforms.time * 5.0) * 0.5 + 0.5;
    float wave2 = cos(uv.y * 8.0 - uniforms.time * 3.0) * 0.5 + 0.5;
    
    float3 burstColor = mix(c1, c2, wave1);
    burstColor = mix(burstColor, c3, wave2);
    
    float dist = abs((uv.x + uv.y * 0.2) - scanPos);
    float glow = exp(-dist * 4.0);
    float fadeEdge = smoothstep(0.0, 0.1, p) * smoothstep(1.0, 0.9, p);
    
    float3 finalColor = mix(restingColor, float3(0.5), active);
    finalColor += burstColor * glow * fadeEdge * 2.5;

    return float4(finalColor, 1.0);
}
"""

struct AuroraBackground: NSViewRepresentable {
    var isActive: Bool
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
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
        if isActive && !context.coordinator.wasActiveLastFrame {
            context.coordinator.triggerOneShotAnimation()
        }
        context.coordinator.wasActiveLastFrame = isActive
        context.coordinator.targetActiveLevel = isActive ? 1.0 : 0.0
    }
    
    class Coordinator: NSObject, MTKViewDelegate {
        var parent: AuroraBackground
        var device: MTLDevice!
        var commandQueue: MTLCommandQueue!
        var pipelineState: MTLRenderPipelineState!
        var startTime: Date
        
        var progress: Float = 0.0
        var isAnimating: Bool = false
        var wasActiveLastFrame: Bool = false
        var currentActiveLevel: Float = 0.0
        var targetActiveLevel: Float = 0.0
        
        init(_ parent: AuroraBackground) {
            self.parent = parent
            self.startTime = Date()
            super.init()
            guard let device = MTLCreateSystemDefaultDevice() else { return }
            self.device = device
            self.commandQueue = device.makeCommandQueue()
            
            do {
                let library = try device.makeLibrary(source: auroraShaderSource, options: nil)
                let vertexFn = library.makeFunction(name: "vertex_main")
                let fragmentFn = library.makeFunction(name: "fragment_main")
                
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
            } catch { print("Metal Error: \(error)") }
        }
        
        func triggerOneShotAnimation() {
            progress = 0.0
            isAnimating = true
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
        
        func draw(in view: MTKView) {
            guard let drawable = view.currentDrawable,
                  let rpd = view.currentRenderPassDescriptor,
                  let pipelineState = pipelineState else { return }
            
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
            
            currentActiveLevel += (targetActiveLevel - currentActiveLevel) * 0.1
            
            let buffer = commandQueue.makeCommandBuffer()
            let encoder = buffer?.makeRenderCommandEncoder(descriptor: rpd)
            encoder?.setRenderPipelineState(pipelineState)
            
            struct Uniforms { var time: Float; var progress: Float; var isActive: Float; var resolution: SIMD2<Float>; }
            var uniforms = Uniforms(time: Float(Date().timeIntervalSince(startTime)),
                                    progress: progress,
                                    isActive: currentActiveLevel,
                                    resolution: SIMD2<Float>(Float(view.drawableSize.width), Float(view.drawableSize.height)))
            
            encoder?.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.size, index: 1)
            encoder?.setFragmentBytes(&uniforms, length: MemoryLayout<Uniforms>.size, index: 0)
            encoder?.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
            encoder?.endEncoding()
            buffer?.present(drawable)
            buffer?.commit()
        }
    }
}
