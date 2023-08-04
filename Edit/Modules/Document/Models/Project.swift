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

	private var allDocuments: Set<NSDocument> {
		guard let dirDoc = directoryRootDocument else {
			return documents
		}

		return (documents as Set<NSDocument>).union(Set([dirDoc as NSDocument]))
	}

	@MainActor
	public var frontmostWindow: NSWindow? {
		allDocuments
			.flatMap { $0.windowControllers }
			.compactMap { $0.window }
			.sorted(by: { $0.orderedIndex < $1.orderedIndex })
			.first
	}
}

extension Project: Hashable {
	public static func == (lhs: Project, rhs: Project) -> Bool {
		lhs.context == rhs.context && lhs.allDocuments == rhs.allDocuments
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(context)
		hasher.combine(allDocuments)
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
			preconditionFailure("Unsupported document type")
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
			preconditionFailure("Unsupported document type")
		}
	}
}
