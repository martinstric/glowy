import Foundation

// GlowyHelper is a LaunchDaemon embedded in Glowy.app and registered with SMAppService.
// launchd starts it on demand when a client connects to the mach service and runs it as root,
// which is what lets it change the CoreBrightness preference without a password prompt.

let delegate = ListenerDelegate()
let listener = NSXPCListener(machServiceName: GlowyHelper.machServiceName)
listener.delegate = delegate
listener.resume()
dispatchMain()
