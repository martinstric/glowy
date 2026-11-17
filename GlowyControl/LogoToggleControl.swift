//
//  LogoToggleControl.swift
//  Glowy
//
//  Created by Martin Stric on 2026-11-10.
//

import AppIntents

import SwiftUI
import WidgetKit

/// The Control Center toggle for the glowing Apple logo.
struct LogoToggleControl: ControlWidget {
    
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: GlowyHelper.controlKind, provider: Provider()) { isOn in
            ControlWidgetToggle("Logo Glow", isOn: isOn, action: SetLogoIntent()) { isActive in
                Label(isActive ? "On" : "Off", image: "glowy.laptop")
            }
            .tint(.black)
        }
        .displayName("Logo Glow")
        .description("Turn the glowing Apple logo on or off.")
    }
}

extension LogoToggleControl {
    
    struct Provider: ControlValueProvider {
        var previewValue: Bool { true }

        func currentValue() async throws -> Bool {
            // Before the helper is approved the state can't be read; show Apple's default, which is on.
            (try? await GlowyHelperClient().isLogoEnabled()) ?? true
        }
    }
}

/// Performed by the toggle. Runs in the extension and asks the root helper to apply the change.
struct SetLogoIntent: SetValueIntent {
    
    static let title: LocalizedStringResource = "Set Apple Logo"

    @Parameter(title: "Logo is on")
    var value: Bool

    func perform() async throws -> some IntentResult {
        do {
            try await GlowyHelperClient().setLogoEnabled(value)
        } catch {
            throw SetLogoError.helperUnavailable
        }
        return .result()
    }
}

enum SetLogoError: Error, CustomLocalizedStringResourceConvertible {
    case helperUnavailable

    var localizedStringResource: LocalizedStringResource {
        "Open Glowy to finish setting up its helper."
    }
}
