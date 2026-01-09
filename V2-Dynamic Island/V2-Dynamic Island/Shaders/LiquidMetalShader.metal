//
//  LiquidMetalShader.metal
//  V2-Dynamic Island
//
//  Ver. 6.0 - Shader Volumétrico de Vidro Líquido
//

#include <metal_stdlib>
using namespace metal;

struct LiquidVertexOut {
    float4 position [[position]];
    float2 uv;
};

// --- FUNÇÕES DE RUÍDO (Mantidas) ---
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

// --- SHADER 1: LIQUID GLASS BACKGROUND (NOVO) ---
struct LiquidBackgroundUniforms {
    float time;
    float2 resolution;
    float2 mousePos;
};

fragment float4 liquid_fragment_background(LiquidVertexOut in [[stage_in]],
                                           constant LiquidBackgroundUniforms &uni [[buffer(0)]]) {
    
    float2 uv = in.uv;
    float t = uni.time * 0.4; // Movimento lento e fluido
    
    // 1. Geração do Campo de Altura (Height Map)
    // Cria ondas grandes e suaves
    float2 q = float2(0.);
    q.x = fbm(uv + 0.00 * t);
    q.y = fbm(uv + float2(1.0));
    
    float2 r = float2(0.);
    r.x = fbm(uv + 1.0 * q + float2(1.7, 9.2) + 0.15 * t);
    r.y = fbm(uv + 1.0 * q + float2(8.3, 2.8) + 0.126 * t);
    
    float f = fbm(uv + r);
    
    // 2. Simulação de Vidro/Gelo (Cores Frias)
    // Mistura azul profundo, ciano e preto transparente
    float3 color = mix(float3(0.0, 0.05, 0.1), float3(0.0, 0.1, 0.2), clamp((f*f)*4.0, 0.0, 1.0));
    color = mix(color, float3(0.0, 0.4, 0.6), clamp(length(q), 0.0, 1.0));
    color = mix(color, float3(0.6, 0.9, 1.0), clamp(r.x, 0.0, 1.0));
    
    // 3. Iluminação Especular (O Brilho do Vidro)
    // Calcula um "pseudo-normal" baseado na derivada do ruído
    float val = f * f * f + 0.6 * t;
    float brightness = smoothstep(0.4, 0.9, f); // Pontos altos brilham mais
    
    // Adiciona brilho branco nas cristas das ondas
    float3 specular = float3(1.0) * brightness * 0.5;
    
    // 4. Alpha Dinâmico (A mágica da transparência)
    // Se for "fundo" (escuro), fica transparente. Se for "onda" (brilho), fica opaco.
    // Isso permite ver o wallpaper através das partes escuras.
    float alpha = smoothstep(0.1, 0.8, f) * 0.6;
    
    // Combina cor + brilho
    float3 finalColor = color * 0.5 + specular;
    
    return float4(finalColor, alpha);
}

// --- SHADER 2: RIPPLE BUTTON (Mantido Original) ---
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
    float turbulence = fbm(uv * 5.0 + uni.time);
    float fluid = ripple * uni.hoverStrength;
    
    return float4(float3(1.0) * (fluid + 0.2), fluid * 0.5);
}
