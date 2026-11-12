import Foundation

/// Identifiers shared by the app, the Control Center extension, and the privileged helper.
enum GlowyHelper {
    
    /// Mach service name advertised by the helper's launchd property list.
    static let machServiceName = "ca.martinstric.Glowy.helper"

    /// File name of the launchd property list inside `Glowy.app/Contents/Library/LaunchDaemons`.
    static let plistName = "ca.martinstric.Glowy.helper.plist"

    /// Unique identifier of the Control Center toggle.
    static let controlKind = "ca.martinstric.Glowy.logoToggle"

    /// Error domain used by the helper when reporting failures over XPC.
    static let errorDomain = "ca.martinstric.Glowy.helper"
}

/// XPC interface exposed by the root helper.
///
/// The helper runs as root, so these calls map directly onto Apple's documented commands
/// without needing `sudo` in the caller.
@objc protocol GlowyHelperProtocol {
    
    /// Turns the glowing Apple logo on (`defaults delete`) or off (`defaults write ... -int 0`).
    func setLogoEnabled(_ enabled: Bool, reply: @escaping @Sendable (NSError?) -> Void)

    /// Reports whether the logo is currently enabled. A missing preference means enabled.
    func isLogoEnabled(reply: @escaping @Sendable (Bool, NSError?) -> Void)
}
