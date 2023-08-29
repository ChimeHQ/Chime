import ExtensionFoundation

import ChimeKit

extension AppExtensionIdentity {
    var isDocumentSynced: Bool {
        return extensionPointIdentifier == ChimeExtensionPoint.documentSyncedUI.rawValue
    }

    var hasUserInterface: Bool {
        return extensionPointIdentifier != ChimeExtensionPoint.nonui.rawValue
    }
}
