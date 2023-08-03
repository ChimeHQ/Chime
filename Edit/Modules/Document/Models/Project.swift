import AppKit

import ChimeKit

public final class Project {
	public private(set) var documents = Set<TextDocument>()
	public var directoryRootDocument: DirectoryDocument?

	public let context: ProjectContext

	public init(url: URL) {
		self.context = ProjectContext(url: url)
	}

	public var url: URL {
		context.url
	}

	public var frontmostWindow: NSWindow? {
		nil
	}
}

extension Project: Hashable {
	public static func == (lhs: Project, rhs: Project) -> Bool {
		lhs.context == rhs.context && lhs.documents == rhs.documents
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(context)
		hasher.combine(documents)
	}
}

extension Project {
	func addDocument(_ document: any ProjectDocument) {
		switch document {
		case let doc as TextDocument:
			assert(documents.contains(doc) == false)

			documents.insert(doc)
		case let doc as DirectoryDocument:
			assert(directoryRootDocument == nil)

			directoryRootDocument = doc
		default:
			assertionFailure("Unsupported document type")
		}
	}

	func removeDocument(_ document: any ProjectDocument) {
		switch document {
		case let doc as TextDocument:
			assert(documents.remove(doc) != nil)
		case let doc as DirectoryDocument:
			assert(directoryRootDocument == doc)

			directoryRootDocument = nil
		default:
			assertionFailure("Unsupported document type")
		}
	}
}
