import AppKit

public extension NSFont {
	var lineHeight: CGFloat {
		return heightAboveBaseline + heightBelowBaseline
	}

	var heightBelowBaseline: CGFloat {
		return abs(descender) + leading
	}

	var heightAboveBaseline: CGFloat {
		return ascender
	}

	var advancementForSpaceGlyph: NSSize {
		return advancement(forGlyph: NSGlyph(" "))
	}
}

public extension NSFont {
	static let defaultSystemFont = systemFont(ofSize: systemFontSize)
}
