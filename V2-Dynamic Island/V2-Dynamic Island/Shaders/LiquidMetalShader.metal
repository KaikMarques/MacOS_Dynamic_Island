//
//  LiquidMetalShader.metal
//  V2-Dynamic Island
//
//  Ver. 9.5 - Specular Damping (Removes Initial Center Flash)
//

#include <metal_stdlib>
using namespace metal;

struct LiquidVertexOut {
    float4 position [[position]];
    float2 uv;
};

// --- FUNÇÃO VERTEX ---
vertex LiquidVertexOut liquid_vertex_main(uint vertexID [[vertex_id]]) {
    LiquidVertexOut out;
    float2 grid[4] = {
        float2(-1.0, -1.0), float2( 1.0, -1.0),
        float2(-1.0,  1.0), float2( 1.0,  1.0)
    };
    out.position = float4(grid[vertexID], 0.0, 1.0);
    out.uv = grid[vertexID] * 0.5 + 0.5;
    return out;
}

// --- SHADER 1: BACKGROUND (Mantido) ---
// ...

// --- SHADER 2: RIPPLE WITH SPECULAR DAMPING ---

struct RippleUniforms {
    float time;
    float hoverStrength;
    float2 resolution;
    float2 mousePos;
};

fragment float4 liquid_fragment_ripple(LiquidVertexOut in [[stage_in]],
                                       constant RippleUniforms &uni [[buffer(0)]]) {
    float2 uv = in.uv;
    
    // 1. GEOMETRIA (Crescimento da Bolha)
    float2 center = float2(0.5, 0.5);
    float dist = length(uv - center);
    
    // A bolha cresce do centro baseada no hover
    float lensShape = smoothstep(0.6, 0.0, dist) * uni.hoverStrength;
    
    if (lensShape <= 0.001) { return float4(0.0); }
    
    // 2. CÁLCULO DE NORMAIS
    float3 normal = normalize(float3(uv - center, 1.0 - lensShape * 2.0));
    
    // 3. ILUMINAÇÃO FIXA
    // Luz travada no canto superior esquerdo
    float3 lightDir = normalize(float3(-0.5, 0.5, 1.0));
    float3 viewDir = float3(0.0, 0.0, 1.0);
    
    float3 halfDir = normalize(lightDir + viewDir);
    float rawSpecular = pow(max(dot(normal, halfDir), 0.0), 25.0);
    
    // --- ENGENHARIA DA CORREÇÃO (Specular Damping) ---
    // O problema: No início (hoverStrength < 0.2), a bolha reflete luz no centro.
    // A solução: Criamos uma curva de visibilidade para a luz.
    // A luz começa apagada (0.0) e só começa a acender quando o hover passa de 0.2.
    // Quando chega em 0.8, a luz está totalmente acesa.
    float specularFade = smoothstep(0.2, 0.9, uni.hoverStrength);
    
    // Aplicamos o fade ao brilho calculado
    float finalSpecular = rawSpecular * specularFade;
    
    // 4. COMPOSIÇÃO
    // A cor do vidro aparece logo (para dar feedback visual), mas o brilho forte espera.
    float3 glassColor = float3(0.7, 0.85, 1.0) * (lensShape * 0.2);
    
    float3 finalColor = glassColor + (finalSpecular * 0.9);
    
    // Alpha
    float alpha = smoothstep(0.0, 1.0, lensShape * 0.6 + finalSpecular);
    
    return float4(finalColor, clamp(alpha, 0.0, 1.0));
}
