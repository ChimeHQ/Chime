import Foundation

import ChimeKit

struct CompositeProjectService {
    let context: ProjectContext
    let symbolServices: [SymbolQueryService]

    init(context: ProjectContext, symbolServices: [SymbolQueryService]) {
        self.context = context
        self.symbolServices = symbolServices
    }
}

extension CompositeProjectService: SymbolQueryService {
    func symbols(matching query: String) async throws -> [Symbol] {
        var symbols = [Symbol]()

        for service in symbolServices {
            symbols.append(contentsOf: try await service.symbols(matching: query))
        }

        return symbols
    }
}
