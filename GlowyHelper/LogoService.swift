//
//  LogoService.swift
//  Glowy
//
//  Created by Martin Stric on 2026-11-10.
//

import Foundation

/// Accepts XPC connections, but only from Glowy's own app and Control Centre extension.
final class ListenerDelegate: NSObject, NSXPCListenerDelegate {
    
    /// Peer must be signed by this team and be one of Glowy's two bundles. The parentheses matter:
    /// without them the trailing `or` would accept any process using that identifier.
    private static let codeSigningRequirement = """
        anchor apple generic and certificate leaf[subject.OU] = "88XU89TSNP" and \
        (identifier "ca.martinstric.Glowy" or identifier "ca.martinstric.Glowy.GlowyControl")
        """

    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        newConnection.setCodeSigningRequirement(Self.codeSigningRequirement)
        newConnection.exportedInterface = NSXPCInterface(with: GlowyHelperProtocol.self)
        newConnection.exportedObject = LogoService()
        newConnection.resume()
        return true
    }
}

/// Runs Apple's documented `defaults` commands for the glowing logo. Because this process is root,
/// they are the exact commands from the documentation minus `sudo`.
final class LogoService: NSObject, GlowyHelperProtocol {
    
    private static let domain = "com.apple.CoreBrightness"
    private static let key = "LEBacklightMode"

    func setLogoEnabled(_ enabled: Bool, reply: @escaping @Sendable (NSError?) -> Void) {
        do {
            if enabled {
                // `defaults delete com.apple.CoreBrightness LEBacklightMode`
                let result = try Self.runDefaults(["delete", Self.domain, Self.key])
                
                // `delete` fails when the key is already absent, which already means "enabled".
                if result.status != 0, try Self.readRawValue() != nil {
                    throw Self.error("Could not restore the default logo setting.", output: result.output)
                }
            } else {
                // `defaults write com.apple.CoreBrightness LEBacklightMode -int 0`
                let result = try Self.runDefaults(["write", Self.domain, Self.key, "-int", "0"])
                guard result.status == 0 else {
                    throw Self.error("Could not turn the logo off.", output: result.output)
                }
            }
            
            reply(nil)
        } catch {
            reply(error as NSError)
        }
    }

    func isLogoEnabled(reply: @escaping @Sendable (Bool, NSError?) -> Void) {
        do {
            // Absent key means Apple's default, which is on. Only an explicit 0 means off.
            let value = try Self.readRawValue()
            reply(value != "0", nil)
        } catch {
            reply(true, error as NSError)
        }
    }

    /// Returns the current raw value of the preference, or `nil` when it isn't set.
    private static func readRawValue() throws -> String? {
        let result = try runDefaults(["read", domain, key])
        guard result.status == 0 else { return nil }
        return result.output.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func runDefaults(_ arguments: [String]) throws -> (status: Int32, output: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
        process.arguments = arguments

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        try process.run()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        return (process.terminationStatus, String(decoding: data, as: UTF8.self))
    }

    private static func error(_ message: String, output: String) -> NSError {
        let detail = output.trimmingCharacters(in: .whitespacesAndNewlines)
        return NSError(
            domain: GlowyHelper.errorDomain,
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: detail.isEmpty ? message : "\(message) \(detail)"]
        )
    }
}
