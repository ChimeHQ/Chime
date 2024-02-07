import ExtensionFoundation
import Foundation
import OSLog

import ChimeKit

@MainActor
final class FilteringExtension<Extension: ExtensionProtocol> {
	private var docState = ExtensionDocumentState()
	private var filteredDocState = ExtensionDocumentState()
	private let wrappedExtension: Extension
	private let logger = Logger(subsystem: "com.chimehq.Edit", category: "FilteringExtension")
	private let deactivateBlock: () -> Void
	private var configCacheTask: Task<ExtensionConfiguration, Error>? = nil

	init(ext: Extension, deactivate: @escaping () -> Void = {}) {
		self.wrappedExtension = ext
		self.deactivateBlock = deactivate
	}

	private var wrappedAppService: Extension.AppService {
		get throws { try wrappedExtension.applicationService }
	}
}

extension FilteringExtension {
	private func checkActive(for context: DocumentContext) throws -> Bool {
		if filteredDocState.openDocuments.contains(context) {
			return true
		}

		let config = try configuration
		let included = config.isDocumentIncluded(context)

		if included == false {
			deactivateIfUnneeded()
		}

		return included
	}

	private func checkActive(for context: ProjectContext) throws -> Bool {
		if filteredDocState.openProjects.contains(context) {
			return true
		}

		let config = try configuration
		let included: Bool

		do {
			included = try config.isDirectoryIncluded(at: context.url)
		} catch {
			logger.error("failed to evaluate directory \(error, privacy: .public)")
			included = true
		}

		if included == false {
			deactivateIfUnneeded()
		}

		return included
	}

	private func openFilteredContent(for context: DocumentContext) throws {
		guard let projectContext = context.projectContext else { return }

		if filteredDocState.openProjects.contains(projectContext) { return }

		try unfilteredDidOpenProject(with: projectContext)

		let filteredDocs = docState.openDocuments.filter({ $0.projectContext == projectContext })

		for doc in filteredDocs {
			if doc == context {
				continue
			}

			try unfilteredDidOpenDocument(with: doc)
		}
	}
}

extension FilteringExtension {
	private func unfilteredDidOpenProject(with context: ProjectContext) throws {
		filteredDocState.didOpenProject(with: context)

		try wrappedAppService.didOpenProject(with: context)
	}

	private func filteredDidOpenProject(with context: ProjectContext) throws {
		guard try checkActive(for: context) else { return }

		try unfilteredDidOpenProject(with: context)
	}

	private func unfilteredDidOpenDocument(with context: DocumentContext) throws {
		filteredDocState.didOpenDocument(with: context)

		return try wrappedAppService.didOpenDocument(with: context)
	}

	private func filteredDidOpenDocument(with context: DocumentContext) throws {
		guard try checkActive(for: context) else { return }

		try openFilteredContent(for: context)

		try unfilteredDidOpenDocument(with: context)
	}

	private func unfilteredWillCloseDocument(with context: DocumentContext) throws {
		filteredDocState.willCloseDocument(with: context)

		try wrappedAppService.willCloseDocument(with: context)

		deactivateIfUnneeded()
	}

	private func deactivateIfUnneeded() {
		guard filteredDocState.isEmpty else { return }

		deactivateBlock()
	}
}

extension FilteringExtension: ExtensionProtocol {
	var configuration: ExtensionConfiguration {
		get throws { try wrappedExtension.configuration }
	}

	var applicationService: some ApplicationService {
		get throws { self }
	}
}

extension FilteringExtension: ApplicationService {
	func didOpenProject(with context: ProjectContext) throws {
		docState.didOpenProject(with: context)

		try filteredDidOpenProject(with: context)
	}

	func willCloseProject(with context: ProjectContext) throws {
		docState.willCloseProject(with: context)

		guard try checkActive(for: context) else { return }

		filteredDocState.willCloseProject(with: context)

		try wrappedAppService.willCloseProject(with: context)

		deactivateIfUnneeded()
	}

	func didOpenDocument(with context: DocumentContext) throws {
		docState.didOpenDocument(with: context)

		return try filteredDidOpenDocument(with: context)
	}

	func didChangeDocumentContext(from oldContext: DocumentContext, to newContext: DocumentContext) throws {
		docState.didChangeDocumentContext(from: oldContext, to: newContext)

		let oldActive = try checkActive(for: oldContext)
		let newActive = try checkActive(for: newContext)

		switch (oldActive, newActive) {
		case (false, false):
			return
		case (false, true):
			_ = try unfilteredDidOpenDocument(with: newContext)
		case (true, false):
			try unfilteredWillCloseDocument(with: oldContext)
		case (true, true):
			filteredDocState.didChangeDocumentContext(from: oldContext, to: newContext)

			try wrappedAppService.didChangeDocumentContext(from: oldContext, to: newContext)
		}
	}

	func willCloseDocument(with context: DocumentContext) throws {
		docState.willCloseDocument(with: context)

		guard try checkActive(for: context) else { return }

		try unfilteredWillCloseDocument(with: context)
	}

	func documentService(for context: DocumentContext) throws -> (some DocumentService)? {
		let nilValue: Extension.AppService.DocumentServiceType? = nil

		guard try checkActive(for: context) else { return nilValue }

		guard let service = try wrappedAppService.documentService(for: context) else {
			return nilValue
		}

		guard try configuration.isDocumentIncluded(context) else {
			return nilValue
		}

		return service
	}

	func symbolService(for context: ProjectContext) throws -> (some SymbolQueryService)? {
		// little bit tricky to return nil here
		guard try checkActive(for: context) else { return Extension.AppService.SymbolQueryServiceType?.none }

		return try wrappedAppService.symbolService(for: context)
	}
}

