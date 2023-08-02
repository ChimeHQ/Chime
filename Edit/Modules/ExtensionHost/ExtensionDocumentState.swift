import Foundation

import ChimeKit

struct ExtensionDocumentState {
	private(set) var openProjects = Set<ProjectContext>()
	private var openDocumentsMap = [DocumentIdentity: DocumentContext]()

	var openDocuments: Set<DocumentContext> {
		return Set(openDocumentsMap.values)
	}

	var isEmpty: Bool {
		return openProjects.isEmpty && openDocumentsMap.isEmpty
	}
}

extension ExtensionDocumentState {
	mutating func didOpenProject(with context: ProjectContext) {
		assert(openProjects.contains(context) == false)
		self.openProjects.insert(context)
	}
	
	mutating func willCloseProject(with context: ProjectContext) {
		assert(openProjects.contains(context))
		openProjects.remove(context)
	}

	mutating func didOpenDocument(with context: DocumentContext) {
		assert(openDocumentsMap[context.id] == nil)
		self.openDocumentsMap[context.id] = context
	}

	mutating func didChangeDocumentContext(from oldContext: DocumentContext, to newContext: DocumentContext) {
		precondition(oldContext.id == newContext.id)
		precondition(oldContext != newContext)

		assert(openDocumentsMap[oldContext.id] != nil)
		self.openDocumentsMap[oldContext.id] = newContext
	}

	mutating func willCloseDocument(with context: DocumentContext) {
		assert(openDocumentsMap[context.id] != nil)
		self.openDocumentsMap[context.id] = nil
	}
}

