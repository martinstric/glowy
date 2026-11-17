//
//  GlowyApp.swift
//  Glowy
//
//  Created by Martin Stric on 2026-11-10.
//

import AppKit
import SwiftUI
import ServiceManagement

@main struct GlowyApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    private let openGlowyURLAction = OpenURLAction { url in
        guard url.scheme == "glowy", url.host == "login-items" else {
            return .systemAction
        }
        
        SMAppService.openSystemSettingsLoginItems()
        return .handled
    }

    var body: some Scene {
        Window("Glowy", id: "setup") {
            ContentView()
                .safeAreaPadding([.horizontal, .bottom], 24)
                .safeAreaPadding(.top, 16)
                .frame(width: 320, height: 340)
                .modifyWindow { window in
                    window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                    window.standardWindowButton(.zoomButton)?.isHidden = true
                    window.isMovableByWindowBackground = true
                }
        }
        .environment(\.openURL, openGlowyURLAction)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        #if DEBUG
        .commands {
            CommandGroup(after: .appSettings) {
                Button("Show Welcome Screen") {
                    UserDefaults.standard.set(true, forKey: "firstLaunch")
                }
            }
        }
        #endif
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // The toggle works through the helper and the Control Center extension, so there is
        // nothing for the app to do once the window is closed.
        true
    }
}
