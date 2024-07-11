import Foundation
import ExtensionFoundation

import ChimeKit
import Extendable

@main
final class PythonStandaloneExtension: ChimeExtension {
	@InitializerTransferred private var localExtension: StandaloneExtension<PythonExtension>

	nonisolated init() {
		self._localExtension = InitializerTransferred(mainActorProvider: {
			StandaloneExtension(extensionProvider: { host in
				PythonExtension(host: host)
			})
		})
	}

	func acceptHostConnection(_ host: HostProtocol) throws {
		try localExtension.acceptHostConnection(host)
	}
}

extension PythonStandaloneExtension {
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
