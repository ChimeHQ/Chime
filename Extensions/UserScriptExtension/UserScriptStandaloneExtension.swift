import Foundation
import ExtensionFoundation

import ChimeKit

@main
final class UserScriptStandaloneExtension: ChimeExtension {
	private let localExtension: StandaloneExtension<UserScriptExtension>

	required init() {
		self.localExtension = StandaloneExtension(extensionProvider: { UserScriptExtension(host: $0) })
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
