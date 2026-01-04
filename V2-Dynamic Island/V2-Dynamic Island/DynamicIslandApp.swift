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

        // Tamanho ajustado para caber o novo menu expandido
        let windowWidth: CGFloat = 600
        let windowHeight: CGFloat = 300

        window = DynamicIslandWindow(
            contentRect: NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight),
            view: IslandView()
        )
        
        if let screen = NSScreen.main {
            let screenFrame = screen.frame
            let xPos = (screenFrame.width - windowWidth) / 2
            let yPos = screenFrame.height - windowHeight
            
            window?.setFrameOrigin(NSPoint(x: xPos, y: yPos))
        }

        window?.makeKeyAndOrderFront(nil)
    }
}
