//
//  LiquidMetalShader.metal
//  V2-Dynamic Island
//
//  Ver. 6.1.1 - Shader Volumétrico de Vidro Líquido (Sintaxe C++ Metal Fix)
//

#include <metal_stdlib>
using namespace metal;

// Estrutura de dados que sai do Vertex Shader para o Fragment Shader
struct LiquidVertexOut {
    float4 position [[position]];
    float2 uv;
};

// --- FUNÇÃO VERTEX (Obrigatória para desenhar o quadrado na tela) ---
vertex LiquidVertexOut liquid_vertex_main(uint vertexID [[vertex_id]]) {
    LiquidVertexOut out;
    
    // Coordenadas de um quadrado que cobre a tela inteira (Full Screen Quad)
    // Triângulo Strip: (-1,-1), (1,-1), (-1,1), (1,1)
    float2 grid[4] = {
        float2(-1.0, -1.0),
        float2( 1.0, -1.0),
        float2(-1.0,  1.0),
        float2( 1.0,  1.0)
    };
    
    out.position = float4(grid[vertexID], 0.0, 1.0);
    // Converte de coordenadas normalizadas [-1, 1] para coordenadas de textura [0, 1]
    // Y invertido se necessário, mas para metal geralmente é direto.
    out.uv = grid[vertexID] * 0.5 + 0.5;
    
    return out;
}

// --- FUNÇÕES AUXILIARES DE RUÍDO ---
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

// --- SHADER 1: BACKGROUND LÍQUIDO (VIBRANTE) ---
struct LiquidBackgroundUniforms {
    float time;
    float2 resolution;
    float2 mousePos;
};

fragment float4 liquid_fragment_background(LiquidVertexOut in [[stage_in]],
                                           constant LiquidBackgroundUniforms &uni [[buffer(0)]]) {
    
    float2 uv = in.uv;
    // Inverte o Y da UV para coincidir com a orientação da tela se necessário
    uv.y = 1.0 - uv.y;
    
    float t = uni.time * 0.4;
    
    // Geração de Ondas
    float2 q = float2(0.);
    q.x = fbm(uv + 0.00 * t);
    q.y = fbm(uv + float2(1.0));
    
    float2 r = float2(0.);
    r.x = fbm(uv + 1.0 * q + float2(1.7, 9.2) + 0.15 * t);
    r.y = fbm(uv + 1.0 * q + float2(8.3, 2.8) + 0.126 * t);
    
    float f = fbm(uv + r);
    
    // Cores Vibrantes (Electric Fluid)
    // Cor 1: Azul Royal (Base)
    float3 color = mix(float3(0.1, 0.2, 0.6), float3(0.2, 0.4, 0.8), clamp((f*f)*4.0, 0.0, 1.0));
    
    // Cor 2: Ciano Brilhante (Meio)
    color = mix(color, float3(0.0, 0.8, 0.9), clamp(length(q), 0.0, 1.0));
    
    // Cor 3: Roxo/Branco (Picos)
    color = mix(color, float3(0.7, 0.9, 1.0), clamp(r.x, 0.0, 1.0));
    
    // Iluminação Especular
    float brightness = smoothstep(0.4, 0.9, f);
    float3 specular = float3(1.0) * brightness * 0.8;
    
    // Alpha
    float alpha = smoothstep(0.2, 0.7, f) * 0.9;
    
    return float4(color * 0.6 + specular, alpha);
}

// --- SHADER 2: RIPPLE BUTTON ---
struct RippleUniforms {
    float time;
    float hoverStrength;
    float2 resolution;
};

fragment float4 liquid_fragment_ripple(LiquidVertexOut in [[stage_in]],
                                       constant RippleUniforms &uni [[buffer(0)]]) {
    float2 uv = in.uv;
    float2 center = float2(0.5, 0.5);
    
    float d = length(uv - center);
    float wavePhase = uni.time * 8.0;
    
    float ripple = sin(d * 25.0 - wavePhase) * exp(-d * 4.0);
    float fluid = ripple * uni.hoverStrength;
    
    return float4(float3(1.0) * (fluid + 0.2), fluid * 0.5);
}
