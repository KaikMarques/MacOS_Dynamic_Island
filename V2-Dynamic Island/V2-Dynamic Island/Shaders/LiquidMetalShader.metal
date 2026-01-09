//
//  LiquidMetalShader.metal
//  V2-Dynamic Island
//
//  Ver. 6.5 - Liquid Glass LENS Effect for Buttons
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

// --- FUNÇÕES DE RUÍDO (Mantidas para o background, não usadas no botão) ---
float hash(float2 p) {
    p = fract(p * float2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}
float noise(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i + float2(0.0, 0.0)), hash(i + float2(1.0, 0.0)), f.x),
               mix(hash(i + float2(0.0, 1.0)), hash(i + float2(1.0, 1.0)), f.x), f.y);
}
float fbm(float2 p) {
    float v = 0.0; float amp = 0.5; float2 shift = float2(100.0);
    float2x2 rot = float2x2(cos(0.5), sin(0.5), -sin(0.5), cos(0.50));
    for (int i = 0; i < 3; ++i) { v += amp * noise(p); p = rot * p * 2.0 + shift; amp *= 0.5; }
    return v;
}

// --- SHADER 1: BACKGROUND LÍQUIDO (Mantido da Ver 6.2) ---
struct LiquidBackgroundUniforms { float time; float2 resolution; float2 mousePos; };
fragment float4 liquid_fragment_background(LiquidVertexOut in [[stage_in]], constant LiquidBackgroundUniforms &uni [[buffer(0)]]) {
    float2 uv = in.uv; uv.y = 1.0 - uv.y;
    float2 p = uv * 3.0; float t = uni.time * 0.15;
    float2 q = float2(0.); q.x = fbm(p + 0.00 * t); q.y = fbm(p + float2(1.0));
    float2 r = float2(0.); r.x = fbm(p + 1.0 * q + float2(1.7, 9.2) + 0.15 * t); r.y = fbm(p + 1.0 * q + float2(8.3, 2.8) + 0.126 * t);
    float f = fbm(p + r);
    float3 c1 = float3(0.1, 0.3, 0.4); float3 c2 = float3(0.0, 0.6, 0.7); float3 c3 = float3(0.4, 0.0, 0.4);
    float3 color = mix(c1, c2, clamp(length(q), 0.0, 1.0)); color = mix(color, c3, clamp(r.x, 0.0, 1.0));
    float highlight = pow(f * f * 1.5, 3.0); color += float3(0.8, 0.9, 1.0) * highlight * 0.5;
    float alpha = smoothstep(0.1, 0.9, f) * 0.85;
    return float4(color, alpha);
}

// --- SHADER 2: LIQUID GLASS LENS (NOVO EFEITO PARA BOTÕES) ---
struct RippleUniforms {
    float time;
    float hoverStrength; // 0.0 a 1.0 dependendo do hover
    float2 resolution;
};

fragment float4 liquid_fragment_ripple(LiquidVertexOut in [[stage_in]],
                                       constant RippleUniforms &uni [[buffer(0)]]) {
    float2 uv = in.uv;
    float2 center = float2(0.5, 0.5);
    
    // Distância do centro (corrigida para aspecto do botão se necessário, mas ok aqui)
    float d = length(uv - center);
    
    // 1. Criar a forma da "Lente" (Bulge)
    // smoothstep cria um domo suave que diminui do centro para as bordas.
    // Multiplicamos por hoverStrength para que ele apareça suavemente.
    float lensShape = smoothstep(0.6, 0.0, d) * uni.hoverStrength;
    
    // Se não houver hover, retorna transparente imediatamente para otimizar
    if (lensShape <= 0.01) { return float4(0.0); }
    
    // 2. Simular Normais (Curvatura 3D)
    // Estimamos a inclinação da superfície baseado na distância do centro.
    // Vetores apontando do centro para fora.
    float3 normal = normalize(float3(uv - center, 1.0 - lensShape * 2.0));
    
    // 3. Iluminação Especular (O Brilho do Vidro)
    // Definimos uma luz vinda do canto superior esquerdo
    float3 lightDir = normalize(float3(-1.0, 1.0, 1.0));
    // Direção da visão (olhando diretamente para a tela)
    float3 viewDir = float3(0.0, 0.0, 1.0);
    
    // Cálculo de reflexão Phong modificado para parecer "molhado"
    float3 reflection = reflect(-lightDir, normal);
    float specular = pow(max(dot(reflection, viewDir), 0.0), 16.0); // 16.0 define o quão "nítido" é o brilho
    
    // 4. Cor Base do Vidro
    // Um branco azulado sutil nas bordas da lente (efeito Fresnel simplificado)
    float3 glassColor = float3(0.8, 0.9, 1.0) * (lensShape * 0.3);
    
    // Combinar Cor Base + Brilho Especular
    float3 finalColor = glassColor + specular;
    
    // A opacidade final depende da forma da lente.
    // As bordas são mais transparentes, o centro e os brilhos são mais opacos.
    float finalAlpha = smoothstep(0.0, 1.0, lensShape * 0.5 + specular * 0.8);
    
    return float4(finalColor, finalAlpha);
}
