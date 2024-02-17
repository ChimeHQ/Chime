import Foundation
import ExtensionFoundation

import ChimeKit
import Extendable

@main
final class SwiftStandaloneExtension: ChimeExtension {
	@InitializerTransferred private var localExtension: StandaloneExtension<SwiftExtension>

	nonisolated init() {
		self._localExtension = InitializerTransferred(mainActorProvider: {
			StandaloneExtension(extensionProvider: { host in
				SwiftExtension(host: host)
			})
		})
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

	var applicationService: some ApplicationService {
		get throws {
			return try localExtension.applicationService
		}
	}
}
