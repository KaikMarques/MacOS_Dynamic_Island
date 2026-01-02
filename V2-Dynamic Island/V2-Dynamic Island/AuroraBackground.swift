import SwiftUI

struct AuroraBackground: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Gradientes nativos animados (Zero dependência de WebKit/Rede)
            Circle()
                .fill(Color.blue.opacity(0.5))
                .frame(width: 250, height: 250)
                .offset(x: animate ? 50 : -50, y: animate ? -20 : 20)
                .blur(radius: 40)
            
            Circle()
                .fill(Color.purple.opacity(0.4))
                .frame(width: 200, height: 200)
                .offset(x: animate ? -60 : 60, y: animate ? 30 : -30)
                .blur(radius: 40)
            
            Circle()
                .fill(Color.cyan.opacity(0.3))
                .frame(width: 150, height: 150)
                .offset(x: animate ? 20 : -20, y: animate ? 50 : -50)
                .blur(radius: 30)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 7).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
    }
}
