import Foundation

final class NumberWidthCalculator {
	typealias AttributeProvider = () -> [[NSAttributedString.Key: Any]]

	private var lastDigitCount = 0
	private var cachedWidth: CGFloat?
	private let attributeProvider: AttributeProvider

	var reservedDigits = 3 {
		didSet {
			precondition(reservedDigits >= 0)

			invalidateWidth()
		}
	}

	var maximumLineNumber: Int = 0 {
		didSet {
			if cachedWidth == nil {
				return
			}

			let digitCount = minimumDigitsRequired

			if lastDigitCount != digitCount {
				invalidateWidth()
			}
		}
	}

	init(attributeProvider: @escaping AttributeProvider) {
		self.attributeProvider = attributeProvider
	}

	func invalidateWidth() {
		lastDigitCount = 0
		cachedWidth = nil
	}

	var minimumDigitsRequired: Int {
		let total = max(maximumLineNumber + 1, reservedDigits)

		precondition(total > 0)

		return Int(ceil(log10(CGFloat(total))))
	}

	var requiredWidth: CGFloat {
		if let width = cachedWidth {
			return width
		}

		let digitCount = minimumDigitsRequired

		// this assumes that zeros are the widest number and I'm not sure that's really a good idea
		let zeroedString = String(repeating: "0", count: digitCount)

		var maxWidth = 0.0

		for attrs in attributeProvider() {
			let measurableString = NSAttributedString(string: zeroedString, attributes: attrs)

			let size = measurableString.size()

			maxWidth = max(size.width, maxWidth)
		}

		// round up and cache the value
		let width = ceil(maxWidth)

		self.cachedWidth = width

		return width
	}
}
