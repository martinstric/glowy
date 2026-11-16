//
//  WindowAccessor.swift
//  Glowy
//
//  Created by Martin Stric on 2026-11-12.
//

import SwiftUI
import AppKit

// MARK: - Window Accessor -

struct WindowAccessor: NSViewRepresentable {
    
    var callback: (NSWindow) -> Void
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                callback(window)
            }
        }
        
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

extension View {
    
    func modifyWindow(callback: @escaping (NSWindow) -> Void) -> some View {
        background { WindowAccessor(callback: callback) }
    }
}
