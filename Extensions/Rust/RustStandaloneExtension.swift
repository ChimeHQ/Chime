import Foundation
import ExtensionFoundation

import ChimeKit
import Extendable

@main
final class RustStandaloneExtension: ChimeExtension {
	@InitializerTransferred private var localExtension: StandaloneExtension<RustExtension>

	nonisolated init() {
		self._localExtension = InitializerTransferred(mainActorProvider: {
			StandaloneExtension(extensionProvider: { host in
				RustExtension(host: host)
			})
		})
	}

	func acceptHostConnection(_ host: HostProtocol) throws {
		try localExtension.acceptHostConnection(host)
	}
}

extension RustStandaloneExtension {
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
