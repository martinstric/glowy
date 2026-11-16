//
//  WindowPreview.swift
//  Glowy
//
//  Created by Martin Stric on 2026-11-15.
//

import SwiftUI

struct WindowPreview: PreviewModifier {
    
    private let windowSize = NSSize(width: 320, height: 368)
    
    func body(content: Content, context: Void) -> some View {
        content
            .safeAreaPadding([.horizontal, .bottom], 24)
            .safeAreaPadding(.top, 16)
            .frame(maxWidth: .infinity)
            .modifyWindow { window in
                window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                window.standardWindowButton(.zoomButton)?.isHidden = true
                window.titlebarAppearsTransparent = true
                window.titleVisibility = .hidden
                window.setContentSize(windowSize)
            }
    }
}

extension PreviewTrait where T == Preview.ViewTraits {
    
    @MainActor static var glowyWindow: PreviewTrait {
        .modifier(WindowPreview())
    }
}
