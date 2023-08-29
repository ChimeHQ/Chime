import ExtensionKit
import Foundation
import OSLog

import ChimeKit
import Utility

@MainActor
final class ExtensionManager {
    private static let extensionsEnabled = true

    private let localExtensions: [any ExtensionProtocol]
    private var loadedExtensions = [AppExtensionIdentity: ExtensionProtocol]()
    private let logger = Logger(type: ExtensionManager.self)
    var extensionsWillChangeHandler: ([any ExtensionProtocol]) -> Void
    var extensionsDidChangeHandler: ([any ExtensionProtocol]) -> Void
    let host: any HostProtocol
    private let extensionRouter: ExtensionRouter

    init(host: any HostProtocol) {
        self.host = host

        if Self.extensionsEnabled {
            self.localExtensions = [
            ]
        } else {
            self.localExtensions = [
//                FilteringExtension(ext: ElixirExtension(host: host)),
//                FilteringExtension(ext: GoExtension(host: host)),
//                FilteringExtension(ext: PythonExtension(host: host)),
//                FilteringExtension(ext: RubyExtension(host: host)),
//                FilteringExtension(ext: RustExtension(host: host)),
//                FilteringExtension(ext: SwiftExtension(host: host)),
            ]
        }

        logger.debug("local extensions: \(self.localExtensions.count, privacy: .public)")

        self.extensionRouter = ExtensionRouter(extensions: self.localExtensions)

        self.extensionsWillChangeHandler = { _ in }
        self.extensionsDidChangeHandler = { _ in }

        guard Self.extensionsEnabled else {
            logger.info("external extensions unavailable")
            return
        }

        Task {
            await matchIdentities()
        }
    }

    private var extensions: [any ExtensionProtocol] {
        localExtensions + externalExtensions
    }

    var externalExtensions: [ExtensionProtocol] {
        return Array(loadedExtensions.values)
    }

    @available(macOS 13.0, *)
    var uiExtensions: [UIExtensionDescriptor] {
        loadedExtensions
            .filter({ $0.key.hasUserInterface })
            .map { identity, ext in
                UIExtensionDescriptor(ext, identity: identity)
            }
    }

    var extensionInterface: some ExtensionProtocol {
        return extensionRouter
    }

    private func extensionsUpdated() {
        guard Self.extensionsEnabled else {
            logger.warning("extensions disabled, skipping update")
            return
        }

        let currentExtensions = self.extensions

        extensionsWillChangeHandler(currentExtensions)

        extensionRouter.updateExtensions(with: currentExtensions)

        extensionsDidChangeHandler(currentExtensions)
    }
}

extension ExtensionManager {
    private func matchIdentities() async {
        do {
            let stream = try AppExtensionIdentity.matching(appExtensionPointIDs:
                                                        ChimeExtensionPoint.nonui.rawValue,
                                                        ChimeExtensionPoint.sidebarUI.rawValue,
                                                        ChimeExtensionPoint.documentSyncedUI.rawValue)

            for try await identities in stream {
                for identity in identities {
                    await setUpIdentity(identity)
                }

                extensionsUpdated()
            }
        } catch {
            logger.error("Failed to set up extensions: \(String(describing: error), privacy: .public)")
        }
    }

    private func setUpIdentity(_ identity: AppExtensionIdentity) async {
        logger.info("Setting up: \(identity.bundleIdentifier, privacy: .public)")

        do {
            let lazyExt = try await LazyRemoteExtension(identity: identity, host: host)
            let filteringExt = FilteringExtension(ext: lazyExt, deactivate: { lazyExt.deactivate() })

            self.loadedExtensions[identity] = filteringExt
        } catch {
            logger.error("Failed to set up \(identity.bundleIdentifier, privacy: .public): \(String(describing: error), privacy: .public)")
        }
    }
}
