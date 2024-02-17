import Foundation
import ExtensionFoundation

import ChimeKit
import Extendable

@main
final class UserScriptStandaloneExtension: ChimeExtension {
	@InitializerTransferred private var localExtension: StandaloneExtension<UserScriptExtension>

	nonisolated init() {
		self._localExtension = InitializerTransferred(mainActorProvider: {
			StandaloneExtension(extensionProvider: { host in
				UserScriptExtension(host: host)
			})
		})
	}

	func acceptHostConnection(_ host: HostProtocol) throws {
		try localExtension.acceptHostConnection(host)
	}
}

extension UserScriptStandaloneExtension {
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
