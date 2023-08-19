import Foundation

extension URL {
	public var directoryContents: [URL] {
		let keys: [URLResourceKey] = [
			.isDirectoryKey,
			.isHiddenKey
		]

		let children = try? FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: keys)

		return children ?? []
	}

	public var isDirectory: Bool {
		(try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
	}
}
