import Combine
import Foundation
import OSLog

import ChimeKit
import ProcessEnv
import Utility

public struct DocumentDiagnostics: Hashable, Sendable {
    public let version: Int?
    public let url: URL
    public let diagnostics: [Diagnostic]
}

@MainActor
public final class AppHost {
    public typealias ServiceConfigurationHandler = (ServiceConfiguration) -> Void
    public typealias ContentProvider = (UUID) throws -> (String, Int)
    public typealias CombinedContentProvider = (UUID, ChimeKit.TextRange) throws -> CombinedTextContent

    public struct Configuration {
        public let contentProvider: ContentProvider
        public let combinedContentProvider: CombinedContentProvider

        public init(
            contentProvider: @escaping ContentProvider,
            combinedContentProvider: @escaping CombinedContentProvider
        ) {
            self.contentProvider = contentProvider
            self.combinedContentProvider = combinedContentProvider
        }
    }

    private let config: Configuration
    private let logger = Logger(type: AppHost.self)
    private var diagnosticsSubject: CurrentValueSubject<[URL: DocumentDiagnostics], Never>
    private var tokenInvalidationSubjects: [DocumentIdentity: PassthroughSubject<TextTarget, Never>]
    private var serviceConfigurationHandlers = [DocumentIdentity: ServiceConfigurationHandler]()
    private var hostedProcesses = [UUID: Process]()

    public init(config: Configuration) {
        self.config = config
        self.diagnosticsSubject = CurrentValueSubject([:])
        self.tokenInvalidationSubjects = [:]
    }

    private func tokenInvalidateSubject(for id: DocumentIdentity) -> PassthroughSubject<TextTarget, Never> {
        if let existing = tokenInvalidationSubjects[id] {
            return existing
        }

        let subject = PassthroughSubject<TextTarget, Never>()

        tokenInvalidationSubjects[id] = subject

        return subject
    }
}

extension AppHost: HostProtocol {
    public func textContent(for documentId: UUID) async throws -> (String, Int) {
        try config.contentProvider(documentId)
    }

    public func textContent(for documentId: UUID, in range: ChimeKit.TextRange) async throws -> CombinedTextContent {
        try config.combinedContentProvider(documentId, range)
    }

    public func textBounds(for documentId: DocumentIdentity, in ranges: [ChimeKit.TextRange], version: Int) async throws -> [NSRect] {
        throw ServiceProviderError.unsupported
//        guard let doc = textDocument(for: documentId) else {
//            throw ServiceProviderError.unsupported
//        }
//
//        let content = doc.content
//        let lineService = content.lineService
//
//        if content.storage.version != version {
//            throw ServiceProviderError.staleDocumentState
//        }
//
//        let rects = ranges
//            .compactMap({ $0.resolve(with: lineService) })
//            .compactMap({ doc.textView.boundingRect(for: $0) })
//
//        if rects.count != ranges.count {
//            throw ServiceProviderError.unableToTransformRange
//        }
//
//        return rects
    }

    public func publishDiagnostics(_ diagnostics: [Diagnostic], for documentURL: URL, version: Int?) {
        DispatchQueue.main.async {
            var newValue = self.diagnosticsSubject.value

            newValue[documentURL] = DocumentDiagnostics(version: version, url: documentURL, diagnostics: diagnostics)

            self.diagnosticsSubject.send(newValue)
        }
    }

    public func invalidateTokens(for documentId: DocumentIdentity, in target: TextTarget) {
        let subject = self.tokenInvalidateSubject(for: documentId)

        subject.send(target)
    }

    public func serviceConfigurationChanged(for documentId: DocumentIdentity, to configuration: ServiceConfiguration) {
        serviceConfigurationHandlers[documentId]?(configuration)
    }

    public func launchProcess(with parameters: Process.ExecutionParameters, inUserShell: Bool) async throws -> LaunchedProcess {
        let id = UUID()
        let process = Process()

        process.parameters = inUserShell ? parameters.userShellInvocation() : parameters

        let pipeSet = Process.StdioPipeSet()

        process.stdioPipeSet = pipeSet

        let launchedProcess = LaunchedProcess(id: id,
                                              stdinHandle: pipeSet.stdin.fileHandleForWriting,
                                              stdoutHandle: pipeSet.stdout.fileHandleForReading,
                                              stderrHandle: pipeSet.stderr.fileHandleForReading)

        process.terminationHandler = { [weak self] _ in
            self?.nonisolatedHandleTermination(of: id)
            launchedProcess.terminationHandler()
        }

        self.hostedProcesses[id] = process

        do {
            try process.run()
        } catch {
            print("launch failure \(error)")
            self.hostedProcesses[id] = nil
            throw error
        }

        return launchedProcess
    }

    public func captureUserEnvironment() async throws -> [String : String] {
        ProcessInfo.processInfo.userEnvironment
    }
}

extension AppHost {
    private nonisolated func nonisolatedHandleTermination(of id: UUID) {
        Task {
            await handleTermination(of: id)
        }
    }

    private func handleTermination(of id: UUID) {
        guard hostedProcesses[id] != nil else {
            logger.error("No process found for \(id, privacy: .public)")
            return
        }

        self.hostedProcesses[id] = nil
    }
}

extension AppHost {
    public var diagnosticsPublisher: some Publisher<[URL: DocumentDiagnostics], Never> {
        return diagnosticsSubject
    }

    public func tokenInvalidatePublisher(for documentId: DocumentIdentity) -> some Publisher<TextTarget, Never> {
        return tokenInvalidateSubject(for: documentId)
    }

    public func setServiceConfigurationHandler(for documentId: DocumentIdentity, handler: ServiceConfigurationHandler?) {
        serviceConfigurationHandlers[documentId] = handler
    }
}

