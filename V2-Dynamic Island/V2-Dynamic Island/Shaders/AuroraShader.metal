//
//  AuroraShader.metal
//  V2-Dynamic Island
//
//  Shader para efeito de borda aurora/neon animada
//

#include <metal_stdlib>
using namespace metal;

struct AuroraVertexOut {
    float4 position [[position]];
    float2 uv;
};

struct AuroraUniforms {
    float time;
    float progress;   // 0.0 a 1.0 (Controlado pelo Swift)
    float isActive;   // Estado geral para fade-in da borda
    float2 resolution;
};

vertex AuroraVertexOut aurora_vertex_main(uint vertexID [[vertex_id]],
                                          constant float4 *vertices [[buffer(0)]]) {
    AuroraVertexOut out;
    float2 positions[4] = { float2(-1, -1), float2(1, -1), float2(-1, 1), float2(1, 1) };
    out.position = float4(positions[vertexID], 0.0, 1.0);
    out.uv = positions[vertexID] * 0.5 + 0.5;
    return out;
}

fragment float4 aurora_fragment_main(AuroraVertexOut in [[stage_in]],
                                     constant AuroraUniforms &uniforms [[buffer(0)]]) {
    
    float2 uv = in.uv;
    float p = uniforms.progress;
    float active = uniforms.isActive;
    
    // Cor da linha em repouso (Cinza Discreto)
    float3 restingColor = float3(0.2, 0.255, 0.333);
    
    // Se a animação acabou (p=0 ou p=1), retorna apenas a cor de repouso
    if (p <= 0.001 || p >= 0.999) {
        float3 steadyColor = mix(restingColor, float3(0.6), active);
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
