//
//  GlowyGlassButtonStyle.swift
//  Glowy
//
//  Created by Martin Stric on 2026-11-16.
//

import SwiftUI

struct GlowyGlassButtonStyle: ButtonStyle {
    
    @Environment(\.buttonSizing) private var buttonSizing
    @Environment(\.controlSize) private var controlSize
    @Environment(\.isEnabled) private var isEnabled
    
    var isProminent: Bool
    
    private var padding: EdgeInsets {
        switch controlSize {
        case .mini:
            EdgeInsets(top: 1, leading: 3, bottom: 1, trailing: 3)
        case .small:
            EdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5)
        case .large:
            EdgeInsets(top: 8, leading: 18, bottom: 8, trailing: 18)
        case .extraLarge:
            EdgeInsets(top: 10, leading: 24, bottom: 10, trailing: 24)
        default:
            EdgeInsets(top: 5, leading: 14, bottom: 5, trailing: 14)
        }
    }
    
    private var glass: Glass {
        isProminent ? .regular.tint(.accentColor) : .regular
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isProminent ? .white : .primary)
            .frame(maxWidth: buttonSizing == .flexible ? .infinity : nil)
            .padding(padding)
            .glassEffect(glass.interactive(isEnabled), in: .capsule)
            .shadow(color: .black.opacity(0.1), radius: 8, y: 1)
            .contentShape(.capsule)
            .pointerStyle(.link)
    }
}

extension ButtonStyle where Self == GlowyGlassButtonStyle {
    
    static var glowyGlass: GlowyGlassButtonStyle {
        GlowyGlassButtonStyle(isProminent: false)
    }
    
    static var glowyGlassProminent: GlowyGlassButtonStyle {
        GlowyGlassButtonStyle(isProminent: true)
    }
}
