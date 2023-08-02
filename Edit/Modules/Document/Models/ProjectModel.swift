import AppKit

import ChimeKit

public final class ProjectModel: ObservableObject {
	public private(set) var documents = Set<BaseDocument>()

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

extension ProjectModel: Hashable {
	public static func == (lhs: ProjectModel, rhs: ProjectModel) -> Bool {
		lhs.context == rhs.context && lhs.documents == rhs.documents
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(context)
		hasher.combine(documents)
	}
}

extension ProjectModel {
	public func addDocument(_ document: BaseDocument) {
		assert(documents.contains(document) == false)
		
		documents.insert(document)
	}

	public func removeDocument(_ document: BaseDocument) {
		assert(documents.remove(document) != nil)
	}
}
