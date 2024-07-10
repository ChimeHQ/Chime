import Foundation
import ExtensionFoundation

import ChimeKit
import Extendable

@main
final class ElixirStandaloneExtension: ChimeExtension {
	@InitializerTransferred private var localExtension: StandaloneExtension<ElixirExtension>

	nonisolated init() {
		self._localExtension = InitializerTransferred(mainActorProvider: {
			StandaloneExtension(extensionProvider: { host in
				ElixirExtension(host: host)
			})
		})
	}

	func acceptHostConnection(_ host: HostProtocol) throws {
		try localExtension.acceptHostConnection(host)
	}
}

extension ClojureStandaloneExtension {
	var configuration: ExtensionConfiguration {
		get throws {
			try localExtension.configuration
		}
	}

	var applicationService: some ApplicationService {
		get throws {
			try localExtension.applicationService
		}
	}
}
