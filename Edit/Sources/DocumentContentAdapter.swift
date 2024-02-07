import Foundation

import ChimeKit
import Document
import ExtensionHost

extension AppHost {
	convenience init(contentAdapter: DocumentContentAdapter) {
		self.init(
			config: .init(
				contentProvider: contentAdapter.content(for:),
				combinedContentProvider: contentAdapter.combinedContent(for:range:)
			)
		)
	}
}

enum DocumentContentAdapterError: Error {
	case noDocument(DocumentIdentity)
}

@MainActor
final class DocumentContentAdapter {
	private let documentController: ProjectDocumentController

	init(documentController: ProjectDocumentController) {
		self.documentController = documentController
	}

	func content(for documentId: DocumentIdentity) throws -> (String, Int) {
		guard let doc = documentController.textDocument(for: documentId) else {
			throw DocumentContentAdapterError.noDocument(documentId)
		}

		let string = doc.textSystem.storage.string
		let version = doc.textSystem.storage.currentVersion

		return (string, version)
	}

	func combinedContent(for id: DocumentIdentity, range: ChimeKit.TextRange) throws -> CombinedTextContent {
		throw DocumentContentAdapterError.noDocument(id)
	}
}
