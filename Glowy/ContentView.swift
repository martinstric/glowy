//
//  ContentView.swift
//  Glowy
//
//  Created by Martin Stric on 2026-11-12.
//

import SwiftUI
import ServiceManagement

struct ContentView: View {
    
    @Environment(\.dismissWindow) private var dismissWindow
    
    @AppStorage("firstLaunch") private var isFirstLaunch = true
    
    var body: some View {
        ZStack {
            if isFirstLaunch {
                FirstLaunchView {
                    isFirstLaunch = false
                }
                .transition(.blurReplace.animation(.snappy))
            } else {
                SetupView()
                    .transition(.blurReplace.animation(.snappy))
            }
        }
    }
}

// MARK: - Previews -

#Preview(traits: .glowyWindow) {
    ContentView()
}
