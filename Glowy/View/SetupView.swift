//
//  SetupView.swift
//  Glowy
//
//  Created by Martin Stric on 2026-11-12.
//

import SwiftUI
import ServiceManagement

struct SetupView: View {
    
    @State private var setup = SetupModel()
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            switch setup.step {
            case .loginItem:
                LoginItemSetupStepView()
                    .transition(.blurReplace.animation(.snappy))
            case .controlCenter:
                ControlCenterSetupStepView()
                    .transition(.blurReplace.animation(.snappy))
            case .done:
                DoneSetupStepView()
                    .transition(.blurReplace.animation(.snappy))
            }
        }
        .environment(setup)
        .isAnimating(isAnimating)
        .task {
            while !Task.isCancelled {
                await setup.refreshAll()
                try? await Task.sleep(for: .seconds(2))
            }
        }
        .task {
            try? await Task.sleep(for: .milliseconds(500))
            withAnimation(.smooth) {
                isAnimating = true
            }
        }
    }
}

private struct SetupStepView<Content, ImageContent>: View where Content: View, ImageContent: View {
    
    @Environment(\.isAnimating) private var isAnimating
    
    var title: LocalizedStringKey
    var description: LocalizedStringKey
    @ViewBuilder var content: Content
    @ViewBuilder var image: ImageContent
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                image
                    .font(.system(size: 108))
                    .contentTransition(.symbolEffect)
                    .transition(.symbolEffect)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .symbolRenderingMode(.hierarchical)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(description)
                        .foregroundStyle(.secondary)
                        .lineLimit(2, reservesSpace: true)
                }
                
                content
            }
        }
        .multilineTextAlignment(.center)
        .animation(.snappy, value: description)
    }
}

// MARK: Login Item

private struct LoginItemSetupStepView: View {
    
    @Environment(SetupModel.self) private var setup
    @Environment(\.isAnimating) private var isAnimating
    
    @State private var isRegisteringHelper = false
    
    private var description: LocalizedStringKey {
        if isRegisteringHelper {
            "Approve Glowy under 'Background App Activity' in Login Items."
        } else {
            "Approve it once. Never again."
        }
    }
    
    private var symbol: some View {
        if isRegisteringHelper {
            switch setup.helperStatus {
            case .notRegistered:
                Image(systemName: "gear.badge")
            default:
                Image(systemName: "arrow.down")
            }
        } else {
            Image(systemName: "gear")
        }
    }
    
    var body: some View {
        SetupStepView(
            title: "Let Glowy run in the background",
            description: description
        ) {
            GlassEffectContainer {
                if isRegisteringHelper {
                    Button("Open Login Items") {
                        setup.openLoginItems()
                    }
                    .buttonStyle(.glowyGlass)
                } else {
                    Button("Approve Glowy") {
                        setup.registerHelper()
                        
                        withAnimation(.snappy) {
                            isRegisteringHelper = true
                        }
                    }
                    .buttonStyle(.glowyGlassProminent)
                }
            }
        } image: {
            Image(systemName: isRegisteringHelper ? "gear.badge" : "gear")
        }
        .buttonSizing(.flexible)
        .controlSize(.extraLarge)
        .task {
            setup.refreshHelperStatus()
        }
    }
}

// MARK: Control Center

private struct ControlCenterSetupStepView: View {
    
    @Environment(SetupModel.self) private var setup
    @Environment(\.isAnimating) private var isAnimating
    
    var body: some View {
        SetupStepView(
            title: "Add Glowy to Control Center",
            description: "Open Control Center → Edit Controls → find Glowy."
        ) {
            
        } image: {
            Image(systemName: "switch.2")
        }
    }
}

// MARK: Done

private struct DoneSetupStepView: View {
    
    @Environment(SetupModel.self) private var setup
    @Environment(\.isAnimating) private var isAnimating
    
    @State private var isConfirmingUninstall = false
    
    var body: some View {
        SetupStepView(
            title: "You're all set",
            description: "Glow on. Or not. That’s up to you."
        ) {
            VStack(spacing: 16) {
                let isAppLogoOn = Binding {
                    setup.logoIsOn ?? false
                } set: { newValue in
                    Task {
                        await setup.setLogo(on: newValue)
                    }
                }

                Toggle(isOn: isAppLogoOn) {
                    Text("Back Light On")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .toggleStyle(.switch)
                .controlSize(.small)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.quaternary, in: .rect(cornerRadius: 14))
                .padding(.top, -16)
                
                HStack(spacing: 0) {
                    Text("Glowy will run in the background. Feel free to close the app.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .padding(.leading, 14)
                    Spacer(minLength: 16)
                    Button("Uninstall") {
                        isConfirmingUninstall = true
                    }
                    .buttonStyle(.glowyGlass)
                }
            }
        } image: {
            Image(systemName: "checkmark")
                .foregroundStyle(.green)
                .symbolVariant(.circle.fill)
        }
        .confirmationDialog("Uninstall Glowy?", isPresented: $isConfirmingUninstall) {
            Button("Uninstall", role: .destructive) {
                Task {
                    await setup.uninstall()
                }
            }
        } message: {
            Text("This removes Glowy and its background helper. Your logo goes back to glowing the way Apple intended.")
        }
    }
}

// MARK: - Previews -

#Preview(traits: .glowyWindow) {
    SetupView()
}
