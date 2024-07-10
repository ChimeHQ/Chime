import ExtensionKit
import Foundation
import OSLog

import ChimeKit
import Utility

@MainActor
public final class ExtensionManager<Host: HostProtocol> {
	private static var extensionsEnabled: Bool { true }

    private let localExtensions: [any ExtensionProtocol]
    private var loadedExtensions = [AppExtensionIdentity: any ExtensionProtocol]()
    private let logger = Logger(type: ExtensionManager.self)
    public var extensionsWillChangeHandler: ([any ExtensionProtocol]) -> Void
    public var extensionsDidChangeHandler: ([any ExtensionProtocol]) -> Void
    let host: any HostProtocol
    public let extensionRouter: ExtensionRouter

    public init(host: Host) {
        self.host = host

		if Self.extensionsEnabled {
			self.localExtensions = [
			]
		} else {
			// To use local extensions, you must uncomment one of these, *and also* make sure to add the extension sources to the ExtensionHost target.
			self.localExtensions = [
//				FilteringExtension(ext: ClojureExtension(host: host)),
//				FilteringExtension(ext: SwiftExtension(host: host)),
//				FilteringExtension(ext: UserScriptExtension(host: host))
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

        matchIdentities()
    }

    private var extensions: [any ExtensionProtocol] {
        localExtensions + externalExtensions
    }

    var externalExtensions: [any ExtensionProtocol] {
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
	private func matchIdentities() {
		Task.detached {
			do {
				let stream = try AppExtensionIdentity.matching(
					appExtensionPointIDs:
						ChimeExtensionPoint.nonui.rawValue,
					ChimeExtensionPoint.sidebarUI.rawValue,
					ChimeExtensionPoint.documentSyncedUI.rawValue
				)


				for try await identities in stream {
					for identity in identities {
						await self.setUpIdentity(identity)
					}

					await self.extensionsUpdated()
				}
			} catch {
				await self.logError(error)
			}
		}
	}

	private func logError(_ error: Error) {
		logger.error("Failed to set up extensions: \(String(describing: error), privacy: .public)")
	}

    private func setUpIdentity(_ identity: AppExtensionIdentity) async {
		let bundleIdLoaded = loadedExtensions.keys.contains(where: { $0.bundleIdentifier == identity.bundleIdentifier })
		if bundleIdLoaded {
			logger.warning("Already loaded an extension with id \(identity.bundleIdentifier, privacy: .public)")
			return
		}

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
