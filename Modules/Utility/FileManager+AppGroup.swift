import Foundation

extension FileManager {
	public var appGroupContainerURL: URL? {
		containerURL(forSecurityApplicationGroupIdentifier: CHMAppGroupIdentifier)
	}
}
