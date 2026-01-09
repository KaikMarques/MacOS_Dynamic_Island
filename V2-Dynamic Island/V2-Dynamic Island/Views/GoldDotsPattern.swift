//
//  GoldDotsPattern.swift
//  V2-Dynamic Island
//
//  Padrão de pontos dourados para efeitos visuais
//

import SwiftUI

struct GoldDotsPattern: View {
    let color: Color
    
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 3.0
            for x in stride(from: 0, to: size.width, by: spacing) {
                for y in stride(from: 0, to: size.height, by: spacing) {
                    let rect = CGRect(
                        x: x + CGFloat.random(in: -0.4...0.4),
                        y: y + CGFloat.random(in: -0.4...0.4),
                        width: 1.0,
                        height: 1.0
                    )
                    context.fill(Path(ellipseIn: rect), with: .color(color))
                }
            }
        }
    }
}

#Preview {
    GoldDotsPattern(color: Color(red: 0.85, green: 0.72, blue: 0.25))
        .frame(width: 100, height: 100)
        .background(.black)
}
