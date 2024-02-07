import AppKit
import Foundation
import OSLog

import ChimeKit
import Document
import ExtensionHost
import Utility

@MainActor
final class ApplicationServiceEventRouter {
	private let logger = Logger(type: ApplicationServiceEventRouter.self)
	private let extensionInterface: ExtensionRouter
	private let host: AppHost
	private let documentController: ProjectDocumentController
	private var tokenInvalidationTasks = [DocumentIdentity: Task<Void, Never>]()

	init(documentController: ProjectDocumentController, extensionInterface: ExtensionRouter, host: AppHost) {
		self.extensionInterface = extensionInterface
		self.host = host
		self.documentController = documentController

		documentController.projectAddedHandler = { [weak self] in self?.projectAdded($0) }
		documentController.projectRemovedHandler = { [weak self] in self?.projectRemoved($0) }
		documentController.documentDidOpenHandler = { [weak self] in self?.documentOpened($0) }
		documentController.documentWillCloseHandler = { [weak self] in self?.documentClosed($0) }
	}
}

extension ApplicationServiceEventRouter {
	public func extensionsWillChange() {

	}

	public func extensionsDidChange() {
		for document in documentController.projectDocuments {
			updateAppService(for: document)
		}
	}
}

extension ApplicationServiceEventRouter {
	private var appService: ExtensionRouter.AppService {
		get throws { extensionInterface.applicationService }
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

		guard let doc = document as? TextDocument else {
			return
		}

		doc.stateChangedHandler = { [weak self] in self?.documentStateChanged(doc, $0, $1) }

		do {
			try appService.didOpenDocument(with: doc.context)
		} catch {
			logger.error("Failed to route didOpenDocument: \(error, privacy: .public)")
		}

		updateAppService(for: document)
		beginMonitoring(for: doc.context.id)
	}

	private func documentClosed(_ document: NSDocument) {
		guard let doc = document as? TextDocument else { return }

		do {
			try appService.willCloseDocument(with: doc.context)
		} catch {
			logger.error("Failed to route didOpenDocument: \(error, privacy: .public)")
		}

		endMonitoring(for:  doc.context.id)
	}

	private func documentStateChanged(_ document: TextDocument, _ oldState: DocumentState, _ newState: DocumentState) {
		let changed = (oldState == newState) == false

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

	private func beginMonitoring(for documentId: DocumentIdentity) {
		tokenInvalidationTasks[documentId] = Task { [host, documentController] in
			for await invalidation in host.tokenInvalidateSequence(for: documentId) {
				if let textDoc = documentController.textDocument(for: documentId) {
					textDoc.invalidateTokens(invalidation)
				}
			}
		}
	}

	private func endMonitoring(for documentId: DocumentIdentity) {
		tokenInvalidationTasks[documentId]?.cancel()
		tokenInvalidationTasks[documentId] = nil
	}
}
