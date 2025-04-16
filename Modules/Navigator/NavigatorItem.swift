import Foundation

import Utility

public enum NavigatorItem: Hashable, Identifiable {
	case none
	case file(URL)

	public func children() -> [NavigatorItem] {
		switch self {
		case .none:
			return []
		case .file(let url):
			if url.isDirectory == false {
				return []
			}

			return url.directoryContents.map { NavigatorItem.file($0) }
		}
	}

	public var hasChildren: Bool {
		switch self {
		case .none:
			return false
		case let .file(url):
			return url.isDirectory
		}
	}

	var name: String {
		switch self {
		case .none:
			return "<none>"
		case let .file(url):
			return url.lastPathComponent
		}
	}

	public var id: String {
		switch self {
		case .none:
			""
		case let .file(url):
			url.absoluteString
		}
	}
}
