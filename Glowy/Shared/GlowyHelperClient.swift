import Foundation

/// Async client for the privileged helper. Used by both the app and the Control Center extension.
///
/// Each call opens a fresh connection; launchd starts the helper on demand and it exits when idle,
/// so there is no benefit to keeping a connection alive.
struct GlowyHelperClient: Sendable {
    
    enum ClientError: LocalizedError {
        case invalidProxy

        var errorDescription: String? {
            switch self {
            case .invalidProxy:
                return "The helper connection could not be established."
            }
        }
    }

    func isLogoEnabled() async throws -> Bool {
        try await withHelper { helper, continuation in
            helper.isLogoEnabled { enabled, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: enabled)
                }
            }
        }
    }

    func setLogoEnabled(_ enabled: Bool) async throws {
        try await withHelper { (helper, continuation: CheckedContinuation<Void, any Error>) in
            helper.setLogoEnabled(enabled) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    /// Opens a connection to the privileged mach service, runs `body`, then tears the connection down.
    /// XPC guarantees that either the reply block or the error handler runs, never both.
    private func withHelper<T: Sendable>(
        _ body: (GlowyHelperProtocol, CheckedContinuation<T, any Error>) -> Void
    ) async throws -> T {
        let connection = NSXPCConnection(machServiceName: GlowyHelper.machServiceName, options: .privileged)
        connection.remoteObjectInterface = NSXPCInterface(with: GlowyHelperProtocol.self)
        connection.resume()
        defer { connection.invalidate() }

        return try await withCheckedThrowingContinuation { continuation in
            let proxy = connection.remoteObjectProxyWithErrorHandler { error in
                continuation.resume(throwing: error)
            }
            guard let helper = proxy as? GlowyHelperProtocol else {
                continuation.resume(throwing: ClientError.invalidProxy)
                return
            }
            
            body(helper, continuation)
        }
    }
}
