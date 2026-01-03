import SwiftUI
import MetalKit

// MARK: - Metal Shader Source (MSL)
// Define a lógica de renderização na GPU.
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
    float isActive; // 0.0 = Repouso, 1.0 = Ativo
    float2 resolution;
};

vertex VertexOut vertex_main(uint vertexID [[vertex_id]],
                             constant float4 *vertices [[buffer(0)]]) {
    VertexOut out;
    // Quadrado simples para cobrir a área da view
    float2 positions[4] = { float2(-1, -1), float2(1, -1), float2(-1, 1), float2(1, 1) };
    out.position = float4(positions[vertexID], 0.0, 1.0);
    out.uv = positions[vertexID] * 0.5 + 0.5; // Normaliza coordenadas 0..1
    return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]],
                              constant Uniforms &uniforms [[buffer(0)]]) {
    
    float2 uv = in.uv;
    float t = uniforms.time;
    float active = uniforms.isActive; // Controla a transição suave
    
    // --- MODO REPOUSO (Cor Sólida) ---
    // Cor #334155 (Slate 700) convertida para RGB normalizado (0..1)
    // R: 51/255 = 0.2
    // G: 65/255 = 0.255
    // B: 85/255 = 0.333
    float3 restingColor = float3(0.2, 0.255, 0.333);
    
    // --- MODO ATIVO (Aurora Animada) ---
    // Cores vibrantes
    float3 c1 = float3(0.1, 0.5, 0.9); // Azul elétrico
    float3 c2 = float3(0.6, 0.1, 0.8); // Roxo profundo
    float3 c3 = float3(0.1, 0.8, 0.7); // Ciano neon
    
    // Ondas senoidais para criar movimento orgânico
    float wave1 = sin(uv.x * 5.0 + t * 1.5) * 0.5 + 0.5;
    float wave2 = cos(uv.y * 3.0 - t * 2.0) * 0.5 + 0.5;
    float wave3 = sin((uv.x + uv.y) * 4.0 - t) * 0.5 + 0.5;
    
    // Mistura as cores baseada nas ondas
    float3 activeColor = mix(c1, c2, wave1);
    activeColor = mix(activeColor, c3, wave2 * wave3);
    
    // Adiciona um "brilho" (scanline) que passa
    float shine = smoothstep(0.45, 0.55, sin(uv.x * 2.0 + uv.y - t * 3.0) * 0.5 + 0.5);
    activeColor += float3(0.3) * shine;

    // --- MISTURA FINAL ---
    // Interpola entre o cinza sólido e a aurora baseado na atividade
    float3 finalColor = mix(restingColor, activeColor, active);
    
    return float4(finalColor, 1.0);
}
"""

// MARK: - SwiftUI Bridge (macOS)
struct AuroraBackground: NSViewRepresentable {
    var isActive: Bool // Estado vindo do SwiftUI
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.device = context.coordinator.device
        mtkView.framebufferOnly = true
        mtkView.enableSetNeedsDisplay = false // Renderização contínua pelo CADisplayLink interno
        mtkView.isPaused = false
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        // Garante que o layer suporte transparência
        mtkView.layer?.isOpaque = false
        
        return mtkView
    }
    
    func updateNSView(_ nsView: MTKView, context: Context) {
        // Atualiza o alvo da animação no Coordinator
        context.coordinator.targetActiveState = isActive ? 1.0 : 0.0
    }
    
    // MARK: - Metal Coordinator
    class Coordinator: NSObject, MTKViewDelegate {
        var parent: AuroraBackground
        var device: MTLDevice!
        var commandQueue: MTLCommandQueue!
        var pipelineState: MTLRenderPipelineState!
        var startTime: Date
        
        // Controle de interpolação suave
        var currentActiveState: Float = 0.0
        var targetActiveState: Float = 0.0
        
        struct Uniforms {
            var time: Float
            var isActive: Float
            var resolution: SIMD2<Float>
        }
        
        init(_ parent: AuroraBackground) {
            self.parent = parent
            self.startTime = Date()
            super.init()
            
            // Configuração do dispositivo padrão do Mac
            guard let device = MTLCreateSystemDefaultDevice() else {
                print("Metal não suportado neste Mac")
                return
            }
            self.device = device
            self.commandQueue = device.makeCommandQueue()
            
            do {
                // Compilação do shader em tempo de execução
                let library = try device.makeLibrary(source: auroraShaderSource, options: nil)
                let vertexFn = library.makeFunction(name: "vertex_main")
                let fragmentFn = library.makeFunction(name: "fragment_main")
                
                let descriptor = MTLRenderPipelineDescriptor()
                descriptor.vertexFunction = vertexFn
                descriptor.fragmentFunction = fragmentFn
                descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
                
                // Configuração de Blending para transparência correta no macOS
                descriptor.colorAttachments[0].isBlendingEnabled = true
                descriptor.colorAttachments[0].rgbBlendOperation = .add
                descriptor.colorAttachments[0].alphaBlendOperation = .add
                descriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
                descriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
                descriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
                descriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
                
                self.pipelineState = try device.makeRenderPipelineState(descriptor: descriptor)
            } catch {
                print("Erro ao compilar shader: \(error)")
            }
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
        
        func draw(in view: MTKView) {
            guard let drawable = view.currentDrawable,
                  let rpd = view.currentRenderPassDescriptor,
                  let pipelineState = pipelineState else { return }
            
            // Animação suave (Lerp) do valor 'isActive'
            // Isso faz a transição de cinza para colorido ser fluida
            let smoothing: Float = 0.1
            currentActiveState += (targetActiveState - currentActiveState) * smoothing
            
            let buffer = commandQueue.makeCommandBuffer()
            let encoder = buffer?.makeRenderCommandEncoder(descriptor: rpd)
            
            encoder?.setRenderPipelineState(pipelineState)
            
            // Envio de dados para GPU
            var uniforms = Uniforms(
                time: Float(Date().timeIntervalSince(startTime)),
                isActive: currentActiveState,
                resolution: SIMD2<Float>(Float(view.drawableSize.width), Float(view.drawableSize.height))
            )
            
            encoder?.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.size, index: 1) // Dummy index
            encoder?.setFragmentBytes(&uniforms, length: MemoryLayout<Uniforms>.size, index: 0)
            
            encoder?.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
            encoder?.endEncoding()
            
            buffer?.present(drawable)
            buffer?.commit()
        }
    }
}
