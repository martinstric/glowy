import AppKit
import SwiftUI

@main struct GlowyApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        // Glowy is an agent app (LSUIElement): no Dock icon, no menu bar. Its only UI is this
        // setup window, shown whenever the app is launched from Finder.
        Window("Glowy", id: "setup") {
            SetupView()
        }
        .windowResizability(.contentSize)
        .restorationBehavior(.disabled)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Agent apps don't come to the front on their own.
        NSApp.activate()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // The toggle works through the helper and the Control Center extension, so there is
        // nothing for the app to do once the window is closed.
        true
    }
}
