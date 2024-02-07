import Foundation
import OSLog

import ChimeKit
import Utility

@MainActor
public final class ExtensionRouter {
	public typealias TokenService = CompositeDocumentService

    private var openProjects = Set<ProjectContext>()
    private var openDocuments = [DocumentIdentity: DocumentContext]()
    private let logger = Logger(type: ExtensionRouter.self)
    private var activeExtensions = [any ExtensionProtocol]()

    init(extensions: [any ExtensionProtocol]) {
        self.activeExtensions = extensions
    }

    func updateExtensions(with newValue: [any ExtensionProtocol]) {
        let extensions = self.activeExtensions

        var addedExtensions = [any ExtensionProtocol]()
        var removedExtensions = [any ExtensionProtocol]()

        for ext in newValue {
            if extensions.contains(where: { $0 === ext }) {
                continue
            }

            addedExtensions.append(ext)
        }

        for ext in extensions {
            if newValue.contains(where: { $0 === ext }) {
                continue
            }

            removedExtensions.append(ext)
        }

        self.activeExtensions = newValue

        handleChangedExtension(removedExtensions: removedExtensions, addedExtensions: addedExtensions)
    }

    private func handleChangedExtension(removedExtensions: [any ExtensionProtocol], addedExtensions: [any ExtensionProtocol]) {
        let activeProjects = self.openProjects
        let activeDocs = self.openDocuments

        tearDownExtensions(removedExtensions, projects: activeProjects, documents: activeDocs)
        setUpExtensions(addedExtensions, projects: activeProjects, documents: activeDocs)
    }
}

extension ExtensionRouter: ExtensionProtocol {
    public var configuration: ExtensionConfiguration {
        fatalError()
    }

	public var applicationService: ExtensionRouter {
		get { return self }
	}
}

extension ExtensionRouter: ApplicationService {
	public func didOpenProject(with context: ProjectContext) throws {
        assert(openProjects.contains(context) == false)
        self.openProjects.insert(context)

        relayOpenProject(with: context, to: activeExtensions)
    }

	public func willCloseProject(with context: ProjectContext) throws {
        assert(openProjects.contains(context))
        openProjects.remove(context)

        relayCloseProject(with: context, to: activeExtensions)
    }

	public func didOpenDocument(with context: DocumentContext) throws {
        assert(openDocuments[context.id] == nil)
        self.openDocuments[context.id] = context

        relayDidOpenDocument(with: context, to: activeExtensions)
    }

	public func didChangeDocumentContext(from oldContext: DocumentContext, to newContext: DocumentContext) throws {
        precondition(oldContext.id == newContext.id)
        precondition(oldContext != newContext)
        assert(openDocuments[oldContext.id] != nil)

        self.openDocuments[oldContext.id] = newContext

        relayDidChangeDocumentContext(from: oldContext, to: newContext, toExtensions: activeExtensions)
    }

	public func willCloseDocument(with context: DocumentContext) throws {
        assert(openDocuments[context.id] != nil)
        self.openDocuments[context.id] = nil

        relayWillCloseDocument(with: context, to: activeExtensions)
    }

	public func documentService(for context: DocumentContext) throws -> CompositeDocumentService? {
        var services = [(any DocumentService)?]()

        for ext in activeExtensions {
            do {
                services.append(try ext.applicationService.documentService(for: context))
            } catch {
                self.logger.error("CompositeService failed to get document service: \(error, privacy: .public)")
            }
        }

        return CompositeDocumentService(context: context, documentServices: services.compactMap({ $0 }))
    }

	public func symbolService(for context: ProjectContext) throws -> (some SymbolQueryService)? {
        var services = [SymbolQueryService?]()

        for ext in activeExtensions {
            do {
                services.append(try ext.applicationService.symbolService(for: context))
            } catch {
                self.logger.error("CompositeService failed to get document service: \(error, privacy: .public)")
            }
        }

        return CompositeProjectService(context: context, symbolServices: services.compactMap({ $0 }))
    }
}

extension ExtensionRouter {
    private func relayOpenProject(with context: ProjectContext, to extensions: [any ExtensionProtocol]) {
        for ext in extensions {
            do {
                try ext.applicationService.didOpenProject(with: context)
            } catch {
                logger.error("didOpenProject failed \(error, privacy: .public)")
            }
        }
    }

    private func relayCloseProject(with context: ProjectContext, to extensions: [any ExtensionProtocol]) {
        for ext in extensions {
            do {
                try ext.applicationService.willCloseProject(with: context)
            } catch {
                logger.error("willCloseProject failed \(error, privacy: .public)")
            }
        }
    }

    private func relayDidOpenDocument(with context: DocumentContext, to extensions: [any ExtensionProtocol]) {
        for ext in extensions {
            do {
                try ext.applicationService.didOpenDocument(with: context)
            } catch {
                logger.error("didOpenDocument failed \(error, privacy: .public)")
            }
        }
    }

    private func relayDidChangeDocumentContext(from oldContext: DocumentContext, to newContext: DocumentContext, toExtensions extensions: [any ExtensionProtocol]) {
        for ext in extensions {
            do {
                try ext.applicationService.didChangeDocumentContext(from: oldContext, to: newContext)
            } catch {
                logger.error("didChangeDocumentContext failed \(error, privacy: .public)")
            }
        }
    }

    private func relayWillCloseDocument(with context: DocumentContext, to extensions: [any ExtensionProtocol]) {
        for ext in extensions {
            do {
                try ext.applicationService.willCloseDocument(with: context)
            } catch {
                logger.error("willCloseDocument failed \(error, privacy: .public)")
            }
        }
    }
}

extension ExtensionRouter {
    private func tearDownExtensions(_ extensions: [any ExtensionProtocol], projects: Set<ProjectContext>, documents: [DocumentIdentity: DocumentContext]) {
        // relay documents
        for doc in documents.values {
            relayWillCloseDocument(with: doc, to: extensions)
        }

        // relay projects
        for proj in projects {
            relayCloseProject(with: proj, to: extensions)
        }
    }

    private func setUpExtensions(_ extensions: [any ExtensionProtocol], projects: Set<ProjectContext>, documents: [DocumentIdentity: DocumentContext]) {
        // relay projects
        for proj in projects {
            relayOpenProject(with: proj, to: extensions)
        }

        // relay documents
        for doc in documents.values {
            relayDidOpenDocument(with: doc, to: extensions)
        }
    }
}
