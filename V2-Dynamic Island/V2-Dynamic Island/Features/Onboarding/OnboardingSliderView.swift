import SwiftUI

// MARK: - Data Model for Slides
struct OnboardingSlide: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let description: String
    let systemIcon: String
    let accentColor: Color
}

// MARK: - Main Slider View
struct OnboardingSliderView: View {
    // Estado para controlar o índice atual
    @State private var currentIndex: Int = 0
    
    // Configuração do Timer: Dispara a cada 5s, mas a animação leva 2s (muito suave)
    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    // Dados dos Slides
    private let slides: [OnboardingSlide] = [
        OnboardingSlide(title: "Integração Total", description: "Conecte Notion, Evernote e Notes em um único lugar.", systemIcon: "square.stack.3d.up.fill", accentColor: .blue),
        OnboardingSlide(title: "Liquid Glass UI", description: "Uma experiência visual imersiva e moderna para macOS.", systemIcon: "sparkles.rectangle.stack.fill", accentColor: .purple),
        OnboardingSlide(title: "Produtividade Fluida", description: "Organize suas ideias com a rapidez que você precisa.", systemIcon: "bolt.fill", accentColor: .orange)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Layer (Círculo de luz atrás do vidro)
                Circle()
                    .fill(slides[currentIndex].accentColor.opacity(0.3))
                    .frame(width: 450, height: 450)
                    .blur(radius: 90)
                    .offset(x: -120, y: -120)
                    .animation(.easeInOut(duration: 2.0), value: currentIndex)
                
                // Content Layer
                VStack(spacing: 20) {
                    // Área do Slide com Transição
                    TabView(selection: $currentIndex) {
                        ForEach(0..<slides.count, id: \.self) { index in
                            SlideContentView(slide: slides[index], size: geometry.size)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: geometry.size.height * 0.75) // Aumentado para 75% da altura
                    
                    // Indicadores de Página Personalizados
                    HStack(spacing: 12) {
                        ForEach(0..<slides.count, id: \.self) { index in
                            Capsule()
                                .fill(currentIndex == index ? Color.primary : Color.secondary.opacity(0.3))
                                .frame(width: currentIndex == index ? 30 : 10, height: 10) // Indicadores maiores
                                .animation(.spring(response: 0.8, dampingFraction: 0.7), value: currentIndex)
                        }
                    }
                    .padding(.bottom, 40)
                }
                .padding()
                // Aplicação do Tema Liquid Glass
                .liquidGlass(cornerRadius: 30)
                .padding(30) // Margem externa maior para "respirar"
            }
        }
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: 2.0)) { // ANIMAÇÃO LENTA DE 2 SEGUNDOS
                currentIndex = (currentIndex + 1) % slides.count
            }
        }
    }
}

// MARK: - Subcomponent: Slide Content
struct SlideContentView: View {
    let slide: OnboardingSlide
    let size: CGSize
    
    var body: some View {
        VStack(spacing: 30) { // Espaçamento maior entre elementos
            Image(systemName: slide.systemIcon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120) // Ícone ampliado para 120pt
                .foregroundStyle(
                    LinearGradient(
                        colors: [slide.accentColor, slide.accentColor.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: slide.accentColor.opacity(0.5), radius: 25, x: 0, y: 15)
                .padding(.top, 30)
            
            VStack(spacing: 16) {
                Text(slide.title)
                    .font(.system(size: 42, weight: .bold, design: .rounded)) // Título ampliado
                    .foregroundStyle(.primary)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
                
                Text(slide.description)
                    .font(.title2) // Descrição maior
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 40)
                    .lineLimit(3)
            }
        }
        .frame(width: size.width, height: size.height * 0.75)
    }
}
