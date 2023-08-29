import Foundation
import OSLog

import ChimeKit
import Utility

@MainActor
struct CompositeDocumentService {
    let context: DocumentContext
    let documentServices: [DocumentService]
    private let logger = Logger(type: CompositeDocumentService.self)

    init(context: DocumentContext, documentServices: [DocumentService]) {
        self.context = context
        self.documentServices = documentServices
    }
}

extension CompositeDocumentService: DocumentService {
    func willApplyChange(_ change: CombinedTextChange) throws {
        for service in documentServices {
            try service.willApplyChange(change)
        }
    }

    func didApplyChange(_ change: CombinedTextChange) throws {
        for service in documentServices {
            try service.didApplyChange(change)
        }
    }

    func willSave() throws {
        for service in documentServices {
            try service.willSave()
        }
    }

    func didSave() throws {
        for service in documentServices {
            try service.didSave()
        }
    }

    var completionService: CompletionService? {
        get throws { return self }
    }

    var formattingService: FormattingService? {
        get throws { return self }
    }

    var semanticDetailsService: SemanticDetailsService? {
        get throws { return self }
    }

    var defintionService: DefinitionService? {
        get throws { return self }
    }

    var tokenService: TokenService? {
        get throws { return self }
    }

    var symbolService: SymbolQueryService? {
        get throws { return self }
    }
}

extension CompositeDocumentService: CompletionService {
    func completions(at position: CombinedTextPosition, trigger: CompletionTrigger) async throws -> [Completion] {
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

    func formatting(for ranges: [CombinedTextRange]) async throws -> [TextChange] {
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

    func organizeImports() async throws -> [TextChange] {
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
    func semanticDetails(at position: CombinedTextPosition) async throws -> SemanticDetails? {
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
    func tokens(in range: CombinedTextRange) async throws -> [Token] {
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
    func definitions(at position: CombinedTextPosition) async throws -> [DefinitionLocation] {
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
    func symbols(matching query: String) async throws -> [Symbol] {
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

