import ServiceManagement
import SwiftUI

/// First-launch (and every-launch) window: explains the two setup steps and shows live status.
struct SetupView: View {
    
    @State private var model = SetupModel()
    @State private var isConfirmingUninstall = false

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            header

            VStack(alignment: .leading, spacing: 20) {
                helperStep
                Divider()
                controlStep
                Divider()
                tryItStep
            }

            if let errorMessage = model.errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.triangle")
                    .font(.callout)
                    .foregroundStyle(.red)
            }

            footer
        }
        .padding(28)
        .frame(width: 460)
        .task {
            model.registerHelper()
            // Poll while the window is open so the checkmarks update as the user works through
            // System Settings and Control Center.
            while !Task.isCancelled {
                await model.refreshAll()
                try? await Task.sleep(for: .seconds(2))
            }
        }
        .confirmationDialog(
            "Uninstall Glowy?",
            isPresented: $isConfirmingUninstall,
            titleVisibility: .visible
        ) {
            Button("Uninstall", role: .destructive) {
                Task { await model.uninstall() }
            }
        } message: {
            Text("The Apple logo will be turned back on, the helper will be removed from Login Items, and Glowy will be moved to the Trash.")
        }
    }

    private var header: some View {
        HStack(spacing: 16) {
            Image(systemName: "apple.logo")
                .font(.system(size: 40))
                .frame(width: 56, height: 56)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 14))
            VStack(alignment: .leading, spacing: 4) {
                Text("Glowy")
                    .font(.title.bold())
                Text("Control the glowing Apple logo from Control Center.")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var helperStep: some View {
        StepRow(
            number: 1,
            title: "Allow the helper",
            isComplete: model.helperIsEnabled
        ) {
            switch model.helperStatus {
            case .enabled:
                Text("The helper is approved. It changes the setting as root, so you'll never be asked for a password.")
            case .requiresApproval:
                Text("macOS needs your permission for Glowy's helper to run in the background. In System Settings, find **Glowy** under Login Items & Extensions and turn it on.")
                Button("Open Login Items…") {
                    model.openLoginItems()
                }
            case .notFound:
                Text("The helper couldn't be found inside the app. Reinstall Glowy.")
            case .notRegistered:
                Text("Registering the helper…")
                Button("Try Again") {
                    model.registerHelper()
                }
            @unknown default:
                Text("Unknown helper status.")
            }
        }
    }

    private var controlStep: some View {
        StepRow(
            number: 2,
            title: "Add the control",
            isComplete: model.controlIsAdded
        ) {
            if model.controlIsAdded {
                Text("The Apple Logo toggle is in your Control Center.")
            } else {
                Text("Click **Control Center** in the menu bar, choose **Edit Controls**, then add **Apple Logo** from Glowy. You can also do this in System Settings › Control Center.")
            }
        }
    }

    private var tryItStep: some View {
        StepRow(
            number: 3,
            title: "Try it",
            isComplete: false,
            showsStatus: false
        ) {
            Toggle(isOn: Binding(
                get: { model.logoIsOn ?? true },
                set: { newValue in Task { await model.setLogo(on: newValue) } }
            )) {
                Text(model.logoIsOn == nil ? "Apple logo (approve the helper first)" : "Apple logo")
            }
            .toggleStyle(.switch)
            .disabled(!model.helperIsEnabled || model.isBusy)
        }
    }

    private var footer: some View {
        HStack {
            Button("Uninstall…", role: .destructive) {
                isConfirmingUninstall = true
            }
            .disabled(model.isBusy)
            Spacer()
            Text("Glowy has no Dock or menu bar icon. Open it again from Applications to see this window.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: 260, alignment: .trailing)
                .multilineTextAlignment(.trailing)
        }
    }
}

/// A numbered step with a completion indicator and free-form detail content.
private struct StepRow<Detail: View>: View {
    let number: Int
    let title: String
    let isComplete: Bool
    var showsStatus = true
    @ViewBuilder let detail: Detail

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(isComplete ? Color.green : Color.secondary.opacity(0.2))
                    .frame(width: 28, height: 28)
                if isComplete && showsStatus {
                    Image(systemName: "checkmark")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                } else {
                    Text("\(number)")
                        .font(.callout.bold())
                        .foregroundStyle(isComplete ? .white : .primary)
                }
            }
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                detail
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    SetupView()
}
