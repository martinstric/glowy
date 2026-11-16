//
//  FirstLaunchView.swift
//  Glowy
//
//  Created by Martin Stric on 2026-11-12.
//

import SwiftUI

struct FirstLaunchView: View {
    
    var action: () -> Void
    
    @State private var isLogoGlowing = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            Image(systemName: "apple.logo")
                .font(.system(size: 80))
                .foregroundStyle(isLogoGlowing ? .primary : .quaternary)
                .shadow(color: .primary.opacity(isLogoGlowing ? 0.67 : 0), radius: isLogoGlowing ? 12 : 0)
                .pointerStyle(.link)
                .padding(.vertical, 24)
                .onTapGesture(perform: toggleLogoGlowing)
                .onAppear {
                    setLogoGlowing(true, delay: 0.5)
                }
            
            VStack(spacing: 4) {
                Text("Welcome to Glowy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("The simplest way to control your glowing back light")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .multilineTextAlignment(.center)
            
            // Get started button
            Button("Get Started", action: action)
                .buttonStyle(.glowyGlassProminent)
                .buttonSizing(.flexible)
                .controlSize(.extraLarge)
                .tint(.primary)
        }
    }
    
    private func setLogoGlowing(_ toggle: Bool, delay: TimeInterval = 0) {
        withAnimation(.smooth(duration: toggle ? 0.5 : 0.2).delay(delay)) {
            isLogoGlowing = toggle
        }
    }
    
    private func toggleLogoGlowing() {
        setLogoGlowing(!isLogoGlowing)
    }
}

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
            .frame(maxWidth: buttonSizing == .flexible ? .infinity : nil)
            .padding(padding)
            .glassEffect(glass.interactive(isEnabled), in: .capsule)
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

// MARK: - Previews -

#Preview(traits: .glowyWindow) {
    FirstLaunchView {
        // do something
    }
}
