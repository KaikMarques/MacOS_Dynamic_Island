//
//  GradientShader.metal
//  V2-Dynamic Island
//
//  Shader de gradiente dinâmico para fundos animados
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 textureCoordinate;
};

// Vertex Shader: Passa a geometria (um quadrado simples)
vertex VertexOut gradient_vertex_main(uint vertexID [[vertex_id]],
                                      constant float4 *vertices [[buffer(0)]]) {
    VertexOut out;
    // Full Screen Quad
    float2 positions[4] = { float2(-1, -1), float2(1, -1), float2(-1, 1), float2(1, 1) };
    
    out.position = float4(positions[vertexID], 0.0, 1.0);
    out.textureCoordinate = positions[vertexID];
    return out;
}

// Fragment Shader: Gradiente animado
fragment float4 gradient_fragment_main(VertexOut in [[stage_in]],
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
