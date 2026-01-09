//
//  MacBookNotchShape.swift
//  V2-Dynamic Island
//
//  Shape customizado que imita o formato do notch do MacBook
//  Integrado ao DesignSystem para consistência
//

import SwiftUI

struct MacBookNotchShape: Shape {
    var isExpanded: Bool
    
    var animatableData: CGFloat {
        get { isExpanded ? 1 : 0 }
        set { }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        let transitionRadius: CGFloat = 10
        
        // Agora busca os valores exatos no DesignSystem
        let cornerRadius: CGFloat = isExpanded
            ? DS.Layout.cornerRadiusExpanded
            : DS.Layout.cornerRadiusCollapsed
        
        path.move(to: CGPoint(x: 0, y: 0))
        path.addArc(center: CGPoint(x: 0, y: transitionRadius),
                    radius: transitionRadius,
                    startAngle: Angle(degrees: -90),
                    endAngle: Angle(degrees: 0),
                    clockwise: false)
        path.addLine(to: CGPoint(x: transitionRadius, y: height - cornerRadius))
        path.addArc(center: CGPoint(x: transitionRadius + cornerRadius, y: height - cornerRadius),
                    radius: cornerRadius,
                    startAngle: Angle(degrees: 180),
                    endAngle: Angle(degrees: 90),
                    clockwise: true)
        path.addLine(to: CGPoint(x: width - transitionRadius - cornerRadius, y: height))
        path.addArc(center: CGPoint(x: width - transitionRadius - cornerRadius, y: height - cornerRadius),
                    radius: cornerRadius,
                    startAngle: Angle(degrees: 90),
                    endAngle: Angle(degrees: 0),
                    clockwise: true)
        path.addLine(to: CGPoint(x: width - transitionRadius, y: transitionRadius))
        path.addArc(center: CGPoint(x: width, y: transitionRadius),
                    radius: transitionRadius,
                    startAngle: Angle(degrees: 180),
                    endAngle: Angle(degrees: 270),
                    clockwise: false)
        path.closeSubpath()
        return path
    }
}
