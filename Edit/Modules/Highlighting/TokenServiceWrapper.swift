import Foundation

import ChimeKit
import DocumentContent
import TextSystem
import Neon

@MainActor
final class TokenServiceWrapper<Service: TokenService> {
	public var service: Service?
	private let textSystem: TextViewSystem

	init(textSystem: TextViewSystem) {
		self.textSystem = textSystem
	}
}

extension TokenServiceWrapper {
	private static func convertTokens(_ tokens: [ChimeKit.Token], metrics: TextMetrics) -> [Neon.Token] {
		let tokens = tokens.compactMap({ token -> Neon.Token? in
			guard let range = NSRange(textRange: token.textRange, metrics: metrics) else {
				return nil
			}

			return Neon.Token(name: token.name, range: range)
		})

		return tokens
	}

	public func tokens(for range: NSRange) async -> TokenApplication {
		guard let service else { return .init(tokens: []) }
		let textMetrics = await textSystem.textMetrics.valueProvider.mainActorAsync(.location(range.max, fill: .optional))

		let combinedRange = CombinedTextRange(range: range, metrics: textMetrics)

		let serviceTokens = try! await service.tokens(in: combinedRange!)
		let tokens = Self.convertTokens(serviceTokens, metrics: textMetrics)

		return .init(tokens: tokens)
	}

	public var tokenProvider: TokenProvider {
		.init(
			mainActorAsyncValue: { [textSystem] range in
				guard let service = self.service else { return .init(tokens: []) }
				let textMetrics = await textSystem.textMetrics.valueProvider.mainActorAsync(.location(range.max, fill: .optional))

				let combinedRange = CombinedTextRange(range: range, metrics: textMetrics)

				let serviceTokens = try! await service.tokens(in: combinedRange!)
				let tokens = Self.convertTokens(serviceTokens, metrics: textMetrics)

				return .init(tokens: tokens)
			}
		)
	}
}
