import SwiftUI
import MetalKit

// MARK: - Metal Shading Language (MSL)
// Normalmente, isso ficaria em um arquivo .metal separado.
// Estamos definindo aqui como string para manter tudo em um único arquivo Swift portátil.
let shaderSource = """
#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[attribute(0)]];
    float2 textureCoordinate [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 textureCoordinate;
};

// Vertex Shader: Passa a geometria (um quadrado simples)
vertex VertexOut vertex_main(uint vertexID [[vertex_id]],
                             constant float4 *vertices [[buffer(0)]]) {
    VertexOut out;
    // Usamos um array hardcoded de vértices para cobrir a tela (Full Screen Quad)
    // 0: (-1, -1), 1: (1, -1), 2: (-1, 1), 3: (1, 1)
    float2 positions[4] = { float2(-1, -1), float2(1, -1), float2(-1, 1), float2(1, 1) };
    
    out.position = float4(positions[vertexID], 0.0, 1.0);
    out.textureCoordinate = positions[vertexID]; // Passa coordenada normalizada
    return out;
}

// Fragment Shader: Onde a mágica das cores acontece
fragment float4 fragment_main(VertexOut in [[stage_in]],
                              constant float &time [[buffer(0)]],
                              constant float2 &resolution [[buffer(1)]]) {
    
    float2 uv = in.textureCoordinate;
    
    // Cria um movimento ondulatório baseado no tempo e posição
    float t = time * 0.5;
    
    // Mistura de cores baseada em coordenadas (Gradient Logic)
    // Cor 1: Azul Profundo (estilo Slate 900)
    float3 colorA = float3(0.05, 0.1, 0.2);
    
    // Cor 2: Roxo/Azul vibrante
    float3 colorB = float3(0.5, 0.2, 0.9);
    
    // Fator de mistura dinâmico
    float mixFactor = sin(uv.x * 3.0 + t) * 0.5 + 0.5;
    mixFactor += cos(uv.y * 2.0 - t) * 0.2;
    
    // Interpolação
    float3 finalColor = mix(colorA, colorB, mixFactor);
    
    // Adiciona uma linha "brilho" sutil que percorre a tela (efeito scanline moderno)
    float lineGlow = smoothstep(0.48, 0.52, sin(uv.x + uv.y - t * 2.0) * 0.5 + 0.5);
    finalColor += float3(0.1, 0.1, 0.3) * lineGlow;

    return float4(finalColor, 1.0);
}
"""

// MARK: - Metal Renderer
// Classe responsável por gerenciar a comunicação com a GPU
class MetalRenderer: NSObject, MTKViewDelegate {
    var parent: MetalGradientView
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState!
    var startTime: Date
    
    init(_ parent: MetalGradientView) {
        self.parent = parent
        self.startTime = Date()
        super.init()
        
        // 1. Configura o Dispositivo (GPU)
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("GPU não suportada neste dispositivo")
        }
        self.device = device
        self.commandQueue = device.makeCommandQueue()
        
        // 2. Compila o Shader em Tempo de Execução
        do {
            let library = try device.makeLibrary(source: shaderSource, options: nil)
            let vertexFunction = library.makeFunction(name: "vertex_main")
            let fragmentFunction = library.makeFunction(name: "fragment_main")
            
            // 3. Configura o Pipeline de Renderização
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexFunction = vertexFunction
            pipelineDescriptor.fragmentFunction = fragmentFunction
            pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            
            self.pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            print("Erro ao compilar shaders: \(error)")
        }
    }
    
    // Chamado quando a view muda de tamanho (rotação, etc)
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    // O Loop de Renderização (chamado 60 ou 120 vezes por segundo)
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let pipelineState = pipelineState else { return }
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        
        renderEncoder?.setRenderPipelineState(pipelineState)
        
        // Envia dados para o Shader (Tempo)
        var time = Float(Date().timeIntervalSince(startTime))
        renderEncoder?.setFragmentBytes(&time, length: MemoryLayout<Float>.size, index: 0)
        
        // Envia dados de resolução
        var resolution = SIMD2<Float>(Float(view.drawableSize.width), Float(view.drawableSize.height))
        renderEncoder?.setFragmentBytes(&resolution, length: MemoryLayout<SIMD2<Float>>.size, index: 1)
        
        // Desenha o quadrado que cobre a tela (4 vértices)
        renderEncoder?.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        
        renderEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}

// MARK: - SwiftUI Representable
// Ponte entre o SwiftUI e o MetalKit (Adaptado para macOS)
struct MetalGradientView: NSViewRepresentable {
    
    func makeCoordinator() -> MetalRenderer {
        MetalRenderer(self)
    }
    
    func makeNSView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.device = context.coordinator.device
        mtkView.framebufferOnly = true
        mtkView.enableSetNeedsDisplay = false // Permite loop contínuo
        mtkView.isPaused = false
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        return mtkView
    }
    
    func updateNSView(_ nsView: MTKView, context: Context) {
        // Atualizações de estado do SwiftUI podem vir aqui
    }
}

// MARK: - Exemplo de Uso
struct ContentView: View {
    var body: some View {
        ZStack {
            // Fundo Metal
            MetalGradientView()
                .ignoresSafeArea()
            
            // Conteúdo UI por cima
            VStack {
                Text("Swift + Metal")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 10)
                
                Text("Renderização nativa de alta performance")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}

// Para visualização no Canvas do Xcode
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
