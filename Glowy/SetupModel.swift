//
//  SetupModel.swift
//  Glowy
//
//  Created by Martin Stric on 2026-11-10.
//

import AppKit
import ServiceManagement
import WidgetKit

// MARK: State

enum SetupStep: CaseIterable, Hashable {
    case loginItem, controlCenter, done
}

// MARK: AppModel

@Observable
final class SetupModel {
    
    var step: SetupStep {
        if !helperIsEnabled {
            .loginItem
        } else if !controlIsAdded {
            .controlCenter
        } else {
            .done
        }
    }
    
    var helperStatus: SMAppService.Status = .notRegistered
    var controlIsAdded = false
    /// `nil` until the helper has been approved and reports the current state.
    var logoIsOn: Bool?
    var errorMessage: String?
    var isBusy = false

    private let service = SMAppService.daemon(plistName: GlowyHelper.plistName)
    private let client = GlowyHelperClient()

    var helperIsEnabled: Bool { helperStatus == .enabled }

    // MARK: Helper

    /// Registers the launch daemon. The first time, macOS asks the user to approve it in
    /// System Settings; afterwards `status` becomes `.enabled` and no password is ever needed.
    func registerHelper() {
        do {
            try service.register()
        } catch let error as NSError where error.code == kSMErrorAlreadyRegistered || error.code == kSMErrorLaunchDeniedByUser {
            // Already registered, or waiting on the user in System Settings. `status` reflects both.
        } catch {
            errorMessage = "Couldn't register the helper: \(error.localizedDescription)"
        }
        
        refreshHelperStatus()
    }

    func refreshHelperStatus() {
        helperStatus = service.status
    }

    func openLoginItems() {
        SMAppService.openSystemSettingsLoginItems()
    }

    // MARK: Control Center

    func refreshControlStatus() async {
        let controls = (try? await ControlCenter.shared.currentControls()) ?? []
        controlIsAdded = controls.contains { $0.kind == GlowyHelper.controlKind }
    }

    // MARK: Logo

    func refreshLogoState() async {
        guard helperIsEnabled else {
            logoIsOn = nil
            return
        }
        
        logoIsOn = try? await client.isLogoEnabled()
    }

    func setLogo(on: Bool) async {
        isBusy = true
        defer { isBusy = false }
        
        do {
            try await client.setLogoEnabled(on)
            logoIsOn = on
            errorMessage = nil
            // Keep the Control Center toggle in sync with what the app just did.
            ControlCenter.shared.reloadControls(ofKind: GlowyHelper.controlKind)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshAll() async {
        refreshHelperStatus()
        await refreshControlStatus()
        await refreshLogoState()
    }

    // MARK: Uninstall

    /// Restores Apple's default logo setting, removes the helper's Login Items entry,
    /// moves the app to the Trash, and quits. Order matters: the logo can only be restored
    /// while the helper still exists.
    func uninstall() async {
        isBusy = true
        defer { isBusy = false }

        if helperIsEnabled {
            do {
                try await client.setLogoEnabled(true)
            } catch {
                errorMessage = "Couldn't restore the logo: \(error.localizedDescription)"
                return
            }
        }

        do {
            try await service.unregister()
        } catch let error as NSError where error.code == kSMErrorJobNotFound {
            // Nothing was registered; fine.
        } catch {
            errorMessage = "Couldn't remove the helper: \(error.localizedDescription)"
            return
        }

        do {
            _ = try await NSWorkspace.shared.recycle([Bundle.main.bundleURL])
        } catch {
            errorMessage = "Couldn't move Glowy to the Trash: \(error.localizedDescription)"
            return
        }

        NSApp.terminate(nil)
    }
}
