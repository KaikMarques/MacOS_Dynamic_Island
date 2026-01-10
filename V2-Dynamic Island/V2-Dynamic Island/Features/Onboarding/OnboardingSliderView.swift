import SwiftUI
import Combine // CORREÇÃO: Import necessário para usar Timer.publish e autoconnect

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
    
    // Configuração do Timer para 4 segundos (tempo de leitura) + Animação de 2 segundos
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
                // Background Layer (opcional, para dar contexto ao vidro)
                Circle()
                    .fill(slides[currentIndex].accentColor.opacity(0.3))
                    .frame(width: 400, height: 400)
                    .blur(radius: 80)
                    .offset(x: -100, y: -100)
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
                    // CORREÇÃO: .page style não existe no macOS.
                    // Removemos o estilo para usar o padrão, ocultando a UI nativa via lógica ou aceitando o padrão.
                    // Os indicadores customizados abaixo farão o papel visual.
                    .frame(height: geometry.size.height * 0.7)
                    
                    // Indicadores de Página Personalizados
                    HStack(spacing: 12) {
                        ForEach(0..<slides.count, id: \.self) { index in
                            Capsule()
                                .fill(currentIndex == index ? Color.primary : Color.secondary.opacity(0.3))
                                .frame(width: currentIndex == index ? 24 : 8, height: 8)
                                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: currentIndex)
                        }
                    }
                    .padding(.bottom, 30)
                }
                .padding()
                // Aplicação do Tema Liquid Glass no Container Principal
                .liquidGlass(cornerRadius: 30)
                .padding(20)
            }
        }
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: 2.0)) {
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
        VStack(spacing: 24) {
            Image(systemName: slide.systemIcon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundStyle(
                    LinearGradient(
                        colors: [slide.accentColor, slide.accentColor.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: slide.accentColor.opacity(0.5), radius: 20, x: 0, y: 10)
                .padding(.top, 20)
            
            VStack(spacing: 12) {
                Text(slide.title)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text(slide.description)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 30)
            }
        }
        .frame(width: size.width, height: size.height * 0.7)
    }
}
