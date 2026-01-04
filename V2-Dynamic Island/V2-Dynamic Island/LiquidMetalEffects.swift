import SwiftUI
import MetalKit

// MARK: - SHADERS (Metal Shading Language)
// O código Metal fica dentro desta string
let liquidMetalShaders = """
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

// --- FUNÇÕES DE RUÍDO ---
float hash(float2 p) {
    return fract(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453);
}

float noise(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i + float2(0.0, 0.0)), hash(i + float2(1.0, 0.0)), f.x),
               mix(hash(i + float2(0.0, 1.0)), hash(i + float2(1.0, 1.0)), f.x), f.y);
}

float fbm(float2 p) {
    float v = 0.0;
    v += 0.5 * noise(p); p *= 2.0;
    v += 0.25 * noise(p); p *= 2.0;
    v += 0.125 * noise(p); p *= 2.0;
    return v;
}

vertex VertexOut vertex_main(uint vertexID [[vertex_id]]) {
    VertexOut out;
    float2 positions[4] = { float2(-1, -1), float2(1, -1), float2(-1, 1), float2(1, 1) };
    out.position = float4(positions[vertexID], 0.0, 1.0);
    out.uv = positions[vertexID] * 0.5 + 0.5;
    return out;
}

// --- SHADER 1: BACKGROUND LIQUID GLASS ---
struct BackgroundUniforms {
    float time;
    float2 resolution;
    float2 mousePos;
};

fragment float4 fragment_background(VertexOut in [[stage_in]],
                                    constant BackgroundUniforms &uni [[buffer(0)]]) {
    float2 uv = in.uv;
    float t = uni.time * 0.15; // Movimento ainda mais lento e majestoso
    
    // Domain Warping para o efeito "Líquido"
    float2 q = float2(0.);
    q.x = fbm(uv + 0.00 * t);
    q.y = fbm(uv + float2(1.0));

    float2 r = float2(0.);
    r.x = fbm(uv + 1.0 * q + float2(1.7, 9.2) + 0.15 * t);
    r.y = fbm(uv + 1.0 * q + float2(8.3, 2.8) + 0.126 * t);

    float f = fbm(uv + r);

    // Iluminação Volumétrica
    float3 normal = normalize(float3(differentiate(f, uv), 0.1)); // Pseudo-normal baseada no gradiente
    
    // Aberração Cromática (Distorção RGB nas bordas)
    // Isso é a chave para o look "Apple Glass"
    float3 color;
    color.r = fbm(uv + r + 0.01);
    color.g = f;
    color.b = fbm(uv + r - 0.01);
    
    // Luz Especular Suave
    float3 lightPos = float3(0.5, 0.5, 1.0);
    float3 lightDir = normalize(lightPos - float3(uv, 0.0));
    float spec = pow(max(dot(normal, lightDir), 0.0), 16.0);
    
    // Mistura final
    float3 baseColor = float3(0.05, 0.05, 0.08); // Fundo quase preto
    float3 liquid = mix(baseColor, float3(0.15, 0.18, 0.22), color); // Tinge com azul-aço
    
    liquid += spec * 0.2; // Brilho
    
    // Vinheta para focar no centro
    float vignette = 1.0 - smoothstep(0.4, 1.4, length(uv - 0.5));
    
    return float4(liquid * vignette, 0.85); // Alta opacidade para glass profundo
}

// Função auxiliar para calcular derivadas (simula normais 3D)
float3 differentiate(float h, float2 p) {
    float2 e = float2(0.01, 0.0);
    float hx = fbm(p + e.xy) - h;
    float hy = fbm(p + e.yx) - h;
    return float3(hx, hy, 1.0);
}


// --- SHADER 2: RIPPLE BUTTON (PHYSICAL WATER SIMULATION) ---
struct RippleUniforms {
    float time;
    float hoverStrength;
    float2 resolution;
};

fragment float4 fragment_ripple(VertexOut in [[stage_in]],
                                constant RippleUniforms &uni [[buffer(0)]]) {
    float2 uv = in.uv;
    float2 center = float2(0.5, 0.5);
    
    // Distância do toque
    float d = length(uv - center);
    
    // A mágica da física:
    // Em vez de seno puro, usamos uma queda exponencial combinada com seno
    // para simular a tensão superficial da água quebrando.
    
    float wavePhase = uni.time * 8.0;
    
    // Onda principal (expansão)
    float ripple = sin(d * 25.0 - wavePhase) * exp(-d * 4.0);
    
    // Turbulência secundária (detalhes líquidos)
    float turbulence = fbm(uv * 5.0 + uni.time);
    
    // Mistura a onda com a turbulência baseada na força do hover
    float fluid = ripple * uni.hoverStrength;
    
    // Distorção Óptica (Refração)
    // Onde a onda é alta, a luz dobra mais
    float distortion = fluid * 0.05;
    
    // Highlight (Caustics)
    // Áreas brilhantes onde a luz se concentra na onda
    float highlight = smoothstep(0.4, 0.6, fluid + 0.5 + turbulence * 0.1);
    
    // Cor final
    float4 color = float4(0.0);
    
    // Brilho branco puro nas cristas das ondas
    color.rgb = float3(1.0);
    
    // Alpha complexo:
    // - Visível apenas onde há onda (fluid)
    // - Mais forte no centro
    // - Suavizado pela turbulência
    color.a = highlight * 0.3 * uni.hoverStrength * (1.0 - d);
    
    // Adiciona um pouco de aberração cromática nas bordas da onda
    color.r += distortion * 2.0;
    color.b -= distortion * 2.0;
    
    return color;
}
"""

// MARK: - VIEWS SWIFTUI

// Estruturas de dados para passar ao Metal (devem ser compatíveis com C)
struct BackgroundUniforms {
    var time: Float
    var resolution: SIMD2<Float>
    var mousePos: SIMD2<Float>
}

struct RippleUniforms {
    var time: Float
    var hoverStrength: Float
    var resolution: SIMD2<Float>
}

struct LiquidGlassBackground: NSViewRepresentable {
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    func makeNSView(context: Context) -> MTKView {
        let view = MTKView()
        if let device = MTLCreateSystemDefaultDevice() {
            view.device = device
        }
        view.delegate = context.coordinator
        view.framebufferOnly = true
        view.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        view.layer?.isOpaque = false
        return view
    }
    
    func updateNSView(_ nsView: MTKView, context: Context) {}
    
    class Coordinator: NSObject, MTKViewDelegate {
        var parent: LiquidGlassBackground
        var device: MTLDevice!
        var queue: MTLCommandQueue!
        var pipeline: MTLRenderPipelineState!
        var startTime = Date()
        
        init(_ parent: LiquidGlassBackground) {
            self.parent = parent
            super.init()
            guard let device = MTLCreateSystemDefaultDevice() else { return }
            self.device = device
            self.queue = device.makeCommandQueue()
            
            do {
                let lib = try device.makeLibrary(source: liquidMetalShaders, options: nil)
                let desc = MTLRenderPipelineDescriptor()
                desc.vertexFunction = lib.makeFunction(name: "vertex_main")
                desc.fragmentFunction = lib.makeFunction(name: "fragment_background")
                desc.colorAttachments[0].pixelFormat = .bgra8Unorm
                desc.colorAttachments[0].isBlendingEnabled = true
                desc.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
                desc.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
                
                self.pipeline = try device.makeRenderPipelineState(descriptor: desc)
            } catch { print(error) }
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
        
        func draw(in view: MTKView) {
            guard let drawable = view.currentDrawable,
                  let desc = view.currentRenderPassDescriptor,
                  let pipe = pipeline else { return }
            
            let buffer = queue.makeCommandBuffer()
            let encoder = buffer?.makeRenderCommandEncoder(descriptor: desc)
            encoder?.setRenderPipelineState(pipe)
            
            // Usando a struct definida fora do método
            var uni = BackgroundUniforms(
                time: Float(Date().timeIntervalSince(startTime)),
                resolution: SIMD2<Float>(Float(view.drawableSize.width), Float(view.drawableSize.height)),
                mousePos: SIMD2<Float>(0, 0)
            )
            
            encoder?.setFragmentBytes(&uni, length: MemoryLayout<BackgroundUniforms>.size, index: 0)
            encoder?.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
            encoder?.endEncoding()
            buffer?.present(drawable)
            buffer?.commit()
        }
    }
}

// Botão com Ripple Effect Metalizado
struct MetalRippleButton: View {
    let icon: String
    let label: String
    var iconColor: Color
    var iconBgColor: Color
    
    @State private var isHovered = false
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                // Fundo do ícone
                Circle()
                    .fill(iconBgColor.gradient)
                    .frame(width: 32, height: 32)
                    .shadow(color: iconBgColor.opacity(0.3), radius: isHovered ? 6 : 3)
                
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(iconColor)
            }
            .scaleEffect(isHovered ? 1.1 : 1.0)
            
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.white.opacity(0.85))
        }
        .frame(height: 72)
        .frame(maxWidth: .infinity)
        // FUNDO METAL RIPPLE
        .background(
            RippleMetalView(isHovered: isHovered)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        )
        // Borda de vidro estática
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
        )
        .onHover { h in withAnimation { isHovered = h } }
    }
}

struct RippleMetalView: NSViewRepresentable {
    var isHovered: Bool
    
    func makeCoordinator() -> Coordinator { Coordinator() }
    
    func makeNSView(context: Context) -> MTKView {
        let v = MTKView()
        if let device = MTLCreateSystemDefaultDevice() {
            v.device = device
        }
        v.delegate = context.coordinator
        v.framebufferOnly = true
        v.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0) // Transparente
        v.layer?.isOpaque = false
        return v
    }
    
    func updateNSView(_ nsView: MTKView, context: Context) {
        context.coordinator.targetHover = isHovered ? 1.0 : 0.0
    }
    
    class Coordinator: NSObject, MTKViewDelegate {
        var device: MTLDevice!
        var queue: MTLCommandQueue!
        var pipeline: MTLRenderPipelineState!
        var startTime = Date()
        var currentHover: Float = 0.0
        var targetHover: Float = 0.0
        
        override init() {
            super.init()
            guard let device = MTLCreateSystemDefaultDevice() else { return }
            self.device = device
            self.queue = device.makeCommandQueue()
            
            do {
                let lib = try device.makeLibrary(source: liquidMetalShaders, options: nil)
                let desc = MTLRenderPipelineDescriptor()
                desc.vertexFunction = lib.makeFunction(name: "vertex_main")
                desc.fragmentFunction = lib.makeFunction(name: "fragment_ripple")
                desc.colorAttachments[0].pixelFormat = .bgra8Unorm
                desc.colorAttachments[0].isBlendingEnabled = true
                desc.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
                desc.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
                self.pipeline = try device.makeRenderPipelineState(descriptor: desc)
            } catch { print(error) }
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
        
        func draw(in view: MTKView) {
            // Animação suave do valor de hover
            currentHover += (targetHover - currentHover) * 0.1
            if currentHover < 0.01 && targetHover == 0 { return } // Otimização
            
            guard let draw = view.currentDrawable,
                  let desc = view.currentRenderPassDescriptor,
                  let pipe = pipeline else { return }
            
            let buf = queue.makeCommandBuffer()
            let enc = buf?.makeRenderCommandEncoder(descriptor: desc)
            enc?.setRenderPipelineState(pipe)
            
            // Usando a struct RippleUniforms externa
            var uni = RippleUniforms(
                time: Float(Date().timeIntervalSince(startTime)),
                hoverStrength: currentHover,
                resolution: SIMD2<Float>(0, 0)
            )
            
            enc?.setFragmentBytes(&uni, length: MemoryLayout<RippleUniforms>.size, index: 0)
            enc?.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
            enc?.endEncoding()
            buf?.present(draw)
            buf?.commit()
        }
    }
}
