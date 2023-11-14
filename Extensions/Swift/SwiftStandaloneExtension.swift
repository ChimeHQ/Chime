import Foundation
import ExtensionFoundation

import ChimeKit

@main
final class SwiftStandaloneExtension: ChimeExtension {
	private let localExtension: StandaloneExtension<SwiftExtension>

	required nonisolated init() {
		self.localExtension = MainActor.assumeIsolated {
			StandaloneExtension(extensionProvider: { SwiftExtension(host: $0) })
		}
	}

	func acceptHostConnection(_ host: HostProtocol) throws {
		try localExtension.acceptHostConnection(host)
	}
}

extension SwiftStandaloneExtension {
	var configuration: ExtensionConfiguration {
		get throws {
			return try localExtension.configuration
		}
	}

	var applicationService: ApplicationService {
		get throws {
			return try localExtension.applicationService
		}
	}
}

