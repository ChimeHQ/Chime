import Foundation

import ChimeKit

final class MockExtension: ExtensionProtocol {
	var configurationHandler: (() throws -> ExtensionConfiguration)?

	var didOpenProjectHandler: ((ProjectContext) throws -> Void)?
	var willCloseProjectHandler: ((ProjectContext) throws -> Void)?

	var didOpenDocumentHandler: ((DocumentContext) throws -> Void)?
	var didChangeDocumentContextHandler: ((DocumentContext, DocumentContext) throws -> Void)?
	var willCloseDocumentHandler: ((DocumentContext) throws -> Void)?

	init() {
	}

	var configuration: ExtensionConfiguration {
		get throws {
			return try configurationHandler?() ?? ExtensionConfiguration()
		}
	}

	var applicationService: some ApplicationService {
		return self
	}
}

extension MockExtension: ApplicationService {
	func didOpenProject(with context: ProjectContext) throws {
		try didOpenProjectHandler?(context)
	}

	func willCloseProject(with context: ProjectContext) throws {
		try willCloseProjectHandler?(context)
	}

	func didOpenDocument(with context: DocumentContext) throws {
		try didOpenDocumentHandler?(context)
	}

	func didChangeDocumentContext(from oldContext: DocumentContext, to newContext: DocumentContext) throws {
		try didChangeDocumentContextHandler?(oldContext, newContext)
	}

	func willCloseDocument(with context: DocumentContext) throws {
		try willCloseDocumentHandler?(context)
	}

	func documentService(for context: DocumentContext) throws -> (some DocumentService)? {
		DocumentServicePlaceholder()
	}

	func symbolService(for context: ProjectContext) throws -> (some SymbolQueryService)? {
		SymbolQueryServicePlaceholder()
	}
}

