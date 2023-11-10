import AppKit

import ChimeKit
import ProjectWindow

@MainActor
public final class Project {
	public private(set) var textDocuments = Set<TextDocument>()
	public internal(set) var directoryRootDocument: DirectoryDocument?

	public let state: ProjectState

	public init(url: URL) {
		self.state = ProjectState(url: url)
	}

	public var context: ProjectContext {
		state.context
	}

	public var url: URL {
		context.url
	}

	/// The set of all contained documents.
	///
	/// This is a superset of `textDocuments`, possibly also including the root directory.
	public var documents: Set<NSDocument> {
		guard let dirDoc = directoryRootDocument else {
			return textDocuments
		}

		var docs = textDocuments as Set<NSDocument>

		docs.insert(dirDoc)

		return docs
	}
}

@MainActor
extension Project {
	public var frontmostWindow: NSWindow? {
		documents
			.flatMap { $0.windowControllers }
			.compactMap { $0.window }
			.sorted(by: { $0.orderedIndex < $1.orderedIndex })
			.first
	}
}

extension Project {
	func addDocument(_ document: any ProjectDocument) {
		switch document {
		case let doc as TextDocument:
			assert(textDocuments.contains(doc) == false)

			textDocuments.insert(doc)
		case let doc as DirectoryDocument:
			assert(directoryRootDocument == nil)

			directoryRootDocument = doc
		default:
			preconditionFailure("Unsupported document type")
		}

		document.projectState = state
	}

	func removeDocument(_ document: any ProjectDocument) {
		switch document {
		case let doc as TextDocument:
			let removed = textDocuments.remove(doc) != nil

			assert(removed)
		case let doc as DirectoryDocument:
			assert(directoryRootDocument == doc)

			directoryRootDocument = nil
		default:
			preconditionFailure("Unsupported document type")
		}
	}
}
