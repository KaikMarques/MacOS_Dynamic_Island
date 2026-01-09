//
//  MetalUniforms.swift
//  V2-Dynamic Island
//
//  Structs de dados compartilhadas entre Swift e Metal Shaders
//  Devem ser compatíveis com layout de memória C
//

import Foundation
import simd

// MARK: - Aurora Shader Uniforms
struct AuroraUniforms {
    var time: Float
    var progress: Float
    var isActive: Float
    var resolution: SIMD2<Float>
}

// MARK: - Gradient Shader Uniforms
struct GradientUniforms {
    var time: Float
    var resolution: SIMD2<Float>
}

// MARK: - Liquid Glass Background Uniforms
struct LiquidBackgroundUniforms {
    var time: Float
    var resolution: SIMD2<Float>
    var mousePos: SIMD2<Float>
}

// MARK: - Ripple Effect Uniforms
struct LiquidRippleUniforms {
    var time: Float
    var hoverStrength: Float
    var resolution: SIMD2<Float>
}
