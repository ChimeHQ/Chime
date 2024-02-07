import Foundation

import ChimeKit
import Document
import ExtensionHost

@MainActor
public final class ExtensionSystem {
	private let extensionManager: ExtensionManager<AppHost>
	private let appHost: AppHost
	private let eventRouter: ApplicationServiceEventRouter
	private let documentController: ProjectDocumentController

	public init(documentController: ProjectDocumentController) {
		self.documentController = documentController

		let contentAdapter = DocumentContentAdapter(documentController: documentController)

		self.appHost = AppHost(contentAdapter: contentAdapter)
		self.extensionManager = ExtensionManager(host: appHost)

		self.eventRouter = ApplicationServiceEventRouter(
			documentController: documentController,
			extensionInterface: extensionManager.extensionRouter,
			host: appHost
		)

		extensionManager.extensionsWillChangeHandler = { [eventRouter] _ in
			eventRouter.extensionsWillChange()
		}

		extensionManager.extensionsDidChangeHandler = { [eventRouter] _ in
			eventRouter.extensionsDidChange()
		}
	}
}
