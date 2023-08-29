import AppKit

import ChimeKit

public struct OpenQuicklyItem: Hashable {
	public struct Location: Hashable {
		let icon: NSImage
		let parts: [String]
        public let fileURL: URL
		let range: ChimeKit.TextRange?

		init(icon: NSImage, parts: [String], fileURL: URL, range: ChimeKit.TextRange? = nil) {
			self.icon = icon
			self.parts = parts
			self.fileURL = fileURL
			self.range = range
		}
	}

	let image: NSImage
    public let title: String
	let emphasizedRanges: [NSRange]
    public let location: Location
	let score: Int

	static let defaultScore = 100

	init(image: NSImage, title: String, emphasizedRanges: [NSRange] = [], location: OpenQuicklyItem.Location, score: Int = OpenQuicklyItem.defaultScore) {
		self.image = image
		self.title = title
		self.emphasizedRanges = emphasizedRanges
		self.location = location
		self.score = score
	}
}

extension OpenQuicklyItem: Comparable {
	public static func < (lhs: OpenQuicklyItem, rhs: OpenQuicklyItem) -> Bool {
		return lhs.score < rhs.score
	}
}
