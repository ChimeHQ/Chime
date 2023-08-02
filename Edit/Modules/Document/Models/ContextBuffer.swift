import ChimeKit

@MainActor
final class ContextBuffer<Service: ApplicationService> {
	private let wrappedService: Service
	private var documentBuffers = [DocumentIdentity : DocumentContext]()

	init(wrappedService: Service) {
		self.wrappedService = wrappedService
	}
}

extension ContextBuffer {
	func beginBufferingChanges(with context: DocumentContext) {
		let id = context.id

		precondition(documentBuffers[id] == nil)
		documentBuffers[id] = context
	}

	func endBufferingChanges(with context: DocumentContext) throws {
		let id = context.id

		guard let initialContext = documentBuffers[id] else {
			preconditionFailure()
		}

		self.documentBuffers[id] = nil

		guard initialContext != context else { return }

		try wrappedService.didChangeDocumentContext(from: initialContext, to: context)
	}
}

extension ContextBuffer: ApplicationService {
	func didOpenProject(with context: ProjectContext) throws {
		try wrappedService.didOpenProject(with: context)
	}

	func willCloseProject(with context: ProjectContext) throws {
		try wrappedService.willCloseProject(with: context)
	}

	func didOpenDocument(with context: DocumentContext) throws {
		try wrappedService.didOpenDocument(with: context)
	}

	func didChangeDocumentContext(from oldContext: DocumentContext, to newContext: DocumentContext) throws {
		let id = oldContext.id
		precondition(id == newContext.id)

		guard documentBuffers[id] == nil else { return }

		try wrappedService.didChangeDocumentContext(from: oldContext, to: newContext)
	}

	func willCloseDocument(with context: DocumentContext) throws {
		try wrappedService.willCloseDocument(with: context)
	}

	// Accessing these is a logical error
	func documentService(for context: DocumentContext) throws -> DocumentService? { fatalError() }
	func symbolService(for context: ProjectContext) throws -> SymbolQueryService? { fatalError() }
}
