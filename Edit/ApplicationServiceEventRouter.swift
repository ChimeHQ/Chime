import AppKit
import Foundation
import OSLog

import ChimeKit
import Document
import Utility

@MainActor
final class ApplicationServiceEventRouter {
	private let logger = Logger(type: ApplicationServiceEventRouter.self)
	private let extensionInterface: any ExtensionProtocol

	init(documentController: ProjectDocumentController, extensionInterface: any ExtensionProtocol) {
		self.extensionInterface = extensionInterface

		documentController.projectAddedHandler = { [weak self] in self?.projectAdded($0) }
		documentController.projectRemovedHandler = { [weak self] in self?.projectRemoved($0) }
		documentController.documentDidOpenHandler = { [weak self] in self?.documentOpened($0) }
		documentController.documentWillCloseHandler = { [weak self] in self?.documentClosed($0) }
	}
}

extension ApplicationServiceEventRouter {
	private var appService: any ApplicationService {
		get throws { try extensionInterface.applicationService }
	}

	private func projectAdded(_ project: Project) {
		do {
			try appService.didOpenProject(with: project.context)
		} catch {
			logger.error("Failed to route didOpenProject: \(error, privacy: .public)")
		}
	}

	private func projectRemoved(_ project: Project) {
		do {
			try appService.willCloseProject(with: project.context)
		} catch {
			logger.error("Failed to route willCloseProject: \(error, privacy: .public)")
		}
	}

	private func documentOpened(_ document: any ProjectDocument) {
		logger.info("Document opened")

		updateAppService(for: document)

		guard let doc = document as? TextDocument else {
			return
		}

		doc.stateChangedHandler = { [weak self] in self?.documentStateChanged(doc, $0, $1) }

		do {
			try appService.didOpenDocument(with: doc.context)
		} catch {
			logger.error("Failed to route didOpenDocument: \(error, privacy: .public)")
		}
	}

	private func documentClosed(_ document: NSDocument) {
		guard let doc = document as? TextDocument else { return }

		do {
			try appService.willCloseDocument(with: doc.context)
		} catch {
			logger.error("Failed to route didOpenDocument: \(error, privacy: .public)")
		}
	}

	private func documentStateChanged(_ document: TextDocument, _ oldState: DocumentState, _ newState: DocumentState) {
		let changed = oldState != newState

		logger.info("State change: \(document.context.id, privacy: .public), \(changed, privacy: .public)")
		if changed == false {
			return
		}

		updateAppService(for: document)
	}
}

extension ApplicationServiceEventRouter {
	private func updateAppService(for document: any ProjectDocument) {
		do {
			document.updateApplicationService(try appService)
		} catch {
			logger.error("Failed to update document application service: \(error, privacy: .public)")
		}
	}
}
