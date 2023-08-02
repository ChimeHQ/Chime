import Foundation

extension URL {
	static func resolveFileBookmark(_ data: Data) -> URL? {
		var stale = false

		guard let url = try? URL(resolvingBookmarkData: data, bookmarkDataIsStale: &stale) else {
			return nil
		}

		if stale {
			return nil
		}

		return url
	}

	func fileBookmarkData() -> Data? {
		let options: URL.BookmarkCreationOptions = [.withSecurityScope]
		let fileURL = standardizedFileURL

		guard let data = try? fileURL.bookmarkData(options: options, includingResourceValuesForKeys: nil, relativeTo: nil) else {
			return nil
		}

		return data
	}
}

