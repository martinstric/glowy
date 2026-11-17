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
//            Image(systemName: "apple.logo")
//                .font(.system(size: 108))
//                .foregroundStyle(isLogoGlowing ? .primary : .quaternary)
//                .shadow(color: .white.opacity(isLogoGlowing ? 0.67 : 0), radius: isLogoGlowing ? 12 : 0)
//                .pointerStyle(.link)
//                .onTapGesture(perform: toggleLogoGlowing)
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .padding(.bottom, 16)
//                .onAppear {
//                    setLogoGlowing(true, delay: 0.5)
//                }
            
            Image("glowy.laptop", variableValue: isLogoGlowing ? 1 : 0)
                .font(.system(size: 108))
                .symbolVariableValueMode(.draw)
                .symbolRenderingMode(.multicolor)
                .animation(.smooth, value: isLogoGlowing)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .task {
                    try? await Task.sleep(for: .milliseconds(500))
                    isLogoGlowing = true
                }
                .onTapGesture {
                    isLogoGlowing.toggle()
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

// MARK: - Previews -

#Preview(traits: .glowyWindow) {
    FirstLaunchView {
        // do something
    }
}
