import NSUI

public extension NSUIFont {
	var lineHeight: CGFloat {
		return heightAboveBaseline + heightBelowBaseline
	}

	var heightBelowBaseline: CGFloat {
		return abs(descender) + leading
	}

	var heightAboveBaseline: CGFloat {
		return ascender
	}

	var advancementForSpaceGlyph: CGFloat {
		NSAttributedString(string: " ", attributes: [.font: self]).size().width
	}
}

public extension NSUIFont {
	static let defaultSystemFont = systemFont(ofSize: systemFontSize)
}
