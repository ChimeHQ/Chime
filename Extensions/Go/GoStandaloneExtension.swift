import Foundation
import ExtensionFoundation

import ChimeKit
import Extendable

@main
final class GoStandaloneExtension: ChimeExtension {
	@InitializerTransferred private var localExtension: StandaloneExtension<GoExtension>

	nonisolated init() {
		self._localExtension = InitializerTransferred(mainActorProvider: {
			StandaloneExtension(extensionProvider: { host in
				GoExtension(host: host)
			})
		})
	}

	func acceptHostConnection(_ host: HostProtocol) throws {
		try localExtension.acceptHostConnection(host)
	}
}

extension GoStandaloneExtension {
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
