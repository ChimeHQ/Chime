import Foundation

import ChimeKit
import Document

extension ProjectDocumentController {
	func textDocument(for docId: DocumentIdentity) -> TextDocument? {
		textDocuments.first(where: { $0.context.id == docId })
	}
}
