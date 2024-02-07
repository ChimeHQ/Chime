import Foundation
import OSLog

import ChimeKit
import Utility

@MainActor
public struct CompositeDocumentService {
    let context: DocumentContext
    let documentServices: [any DocumentService]
    private let logger = Logger(type: CompositeDocumentService.self)

    init(context: DocumentContext, documentServices: [any DocumentService]) {
        self.context = context
        self.documentServices = documentServices
    }
}

extension CompositeDocumentService: DocumentService {
	public func willApplyChange(_ change: CombinedTextChange) throws {
        for service in documentServices {
            try service.willApplyChange(change)
        }
    }

	public  func didApplyChange(_ change: CombinedTextChange) throws {
        for service in documentServices {
            try service.didApplyChange(change)
        }
    }

	public func willSave() throws {
        for service in documentServices {
            try service.willSave()
        }
    }

	public func didSave() throws {
        for service in documentServices {
            try service.didSave()
        }
    }

	public var completionService: Self? {
        get throws { return self }
    }

	public var formattingService: Self? {
        get throws { return self }
    }

	public var semanticDetailsService: Self? {
        get throws { return self }
    }

	public var defintionService: Self? {
        get throws { return self }
    }

	public var tokenService: Self? {
        get throws { return self }
    }

	public var symbolService: Self? {
        get throws { return self }
    }
}

extension CompositeDocumentService: CompletionService {
	public func completions(at position: CombinedTextPosition, trigger: CompletionTrigger) async throws -> [Completion] {
        var values = [Completion]()

        for service in documentServices {
            do {
                let serviceValues = try await service.completionService?.completions(at: position, trigger: trigger) ?? []

                values.append(contentsOf: serviceValues)
            } catch {
                logger.error("failed to get completions: \(error, privacy: .public)")
            }
        }

        return values
    }
}

extension CompositeDocumentService: FormattingService {
    // Return the first non-empty result. This is not ideal, because it needs
    // to go out to each extension, and may not guarantee the same
    // extension replies each time.

	public func formatting(for ranges: [CombinedTextRange]) async throws -> [TextChange] {
        for service in documentServices {
            do {
                if let values = try await service.formattingService?.formatting(for: ranges) {
                    return values
                }
            } catch {
                logger.error("failed to get formatting: \(error, privacy: .public)")
            }
        }

        logger.info("no formatting available")

        return []
    }

	public func organizeImports() async throws -> [TextChange] {
        for service in documentServices {
            do {
                if let values = try await service.formattingService?.organizeImports() {
                    return values
                }
            } catch {
                logger.error("failed to organize imports: \(error, privacy: .public)")
            }
        }

        logger.info("no organize imports available")

        return []
    }
}

extension CompositeDocumentService: SemanticDetailsService {
	public func semanticDetails(at position: CombinedTextPosition) async throws -> SemanticDetails? {
        for service in documentServices {
            do {
                if let values = try await service.semanticDetailsService?.semanticDetails(at: position) {
                    return values
                }
            } catch {
                logger.error("failed to get semantic details: \(error, privacy: .public)")
            }
        }

        logger.info("no semantic details available")

        return nil
    }
}

extension CompositeDocumentService: TokenService {
	public func tokens(in range: CombinedTextRange) async throws -> [Token] {
        var values = [Token]()

        for service in documentServices {
            do {
                let serviceValues = try await service.tokenService?.tokens(in: range) ?? []

                values.append(contentsOf: serviceValues)
            } catch {
                logger.error("failed to get tokens: \(error, privacy: .public)")
            }
        }

        return values
    }
}

extension CompositeDocumentService: DefinitionService {
	public func definitions(at position: CombinedTextPosition) async throws -> [DefinitionLocation] {
        var values = [DefinitionLocation]()

        for service in documentServices {
            do {
                let serviceValues = try await service.defintionService?.definitions(at: position) ?? []

                values.append(contentsOf: serviceValues)
            } catch {
                logger.error("failed to get definitions: \(error, privacy: .public)")
            }
        }

        return values
    }
}

extension CompositeDocumentService: SymbolQueryService {
	public func symbols(matching query: String) async throws -> [Symbol] {
        var values = [Symbol]()

        for service in documentServices {
            do {
                let serviceValues = try await service.symbolService?.symbols(matching: query) ?? []

                values.append(contentsOf: serviceValues)
            } catch {
                logger.error("failed to get symbols: \(error, privacy: .public)")
            }
        }

        return values
    }
}

