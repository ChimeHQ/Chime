import AppKit
import ExtensionKit

import ChimeKit

public struct UIExtensionDescriptor {
    public let extensionConnection: any ExtensionProtocol
    public let identity: AppExtensionIdentity
    public let sceneID: ChimeExtensionSceneIdentifier
    public let icon: NSImage

    public init(_ extensionConnection: any ExtensionProtocol, identity: AppExtensionIdentity) {
        self.extensionConnection = extensionConnection
        self.identity = identity
        self.sceneID = ChimeExtensionSceneIdentifier.main
        self.icon = NSImage(systemSymbolName: "puzzlepiece.extension", accessibilityDescription: "Extension") ?? NSImage()
    }

    public var hostConfiguration: EXHostViewController.Configuration {
        return .init(appExtension: identity, sceneID: sceneID.rawValue)
    }
}

extension UIExtensionDescriptor: Identifiable {
    public var id: String {
        identity.bundleIdentifier
    }
}
