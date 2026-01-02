import SwiftUI

@main
struct DynamicIslandApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: DynamicIslandWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        // Aumentamos a largura da janela de 400 para 600 para garantir que
        // a expansão de 350px tenha margem de sobra para sombras e glow.
        let windowWidth: CGFloat = 600
        let windowHeight: CGFloat = 300

        window = DynamicIslandWindow(
            contentRect: NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight),
            view: IslandView()
        )
        
        if let screen = NSScreen.main {
            let screenFrame = screen.frame
            let xPos = (screenFrame.width - windowWidth) / 2
            // Colado no topo absoluto do M2 13"
            let yPos = screenFrame.height - windowHeight
            
            window?.setFrameOrigin(NSPoint(x: xPos, y: yPos))
        }

        window?.makeKeyAndOrderFront(nil)
    }
}
