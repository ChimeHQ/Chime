import Foundation

import Borderline
import DocumentContent
import Rearrange
import TextFormation
import TextSystem

extension Line where TextPosition == Int {
	public func whitespaceRange(in direction: TextFormation.Direction) -> NSRange {
		switch direction {
		case .leading:
			range(of: .leadingWhitespace)
		case .trailing:
			range(of: .trailingWhitespace)
		}
	}
}

@MainActor
final class WhitespaceCalculator {
	typealias TextPosition = Int
	typealias TextRange = NSRange
	typealias Output = TextFormation.MutationOutput<TextRange>
	
	let textSystem: TextViewSystem
	let textualIndenter: TextualIndenter<TextRange>
	let storage: TextStorage<TextViewSystem.Version>

	init(textSystem: TextViewSystem, storage: TextStorage<TextViewSystem.Version>) {
		self.textSystem = textSystem
		self.textualIndenter = TextualIndenter()
		self.storage = storage
	}
	
	private func metrics(for position: TextPosition) -> TextMetrics? {
		textSystem
			.textMetricsCalculator
			.valueProvider
			.sync(.location(position, fill: .optional))
	}
}

extension WhitespaceCalculator {
	func whitespaceTextRange(at position: TextPosition, in direction: Direction) -> TextRange? {
		metrics(for: position)?
			.line(for: position)?
			.whitespaceRange(in: direction)
	}

	func whitespaceMutation(for position: TextPosition, in direction: Direction) throws -> RangedString<TextRange>? {
		guard
			let metrics = metrics(for: position),
			let line = metrics.line(for: position),
			let precedingLine = metrics.line(at: line.index - 1)
		else {
			return nil
		}

		// no-op trailing whitespace
		if direction == .trailing {
			let trailingRange = line.range(of: .trailingWhitespace)

			return RangedString<TextRange>(
				range: NSRange(trailingRange.upperBound..<trailingRange.upperBound),
				string: ""
			)
		}

		let indentationUnit = "\t"
		let width = 4

		let currentContent = try storage.substring(with: line.range(of: .content))
		let precedingContent = try storage.substring(with: precedingLine.range(of: .content))

		let context = TextualContext<TextRange>(
			current: currentContent,
			preceding: precedingContent,
			precedingLeadingWhitespaceRange: precedingLine.range(of: .leadingWhitespace)
		)

		let indentation = try textualIndenter.computeIndentation(
			at: position,
			context: context
		)

		let range = indentation.range
		let whitespace = try storage.substring(with: range)
		let leadingRange = line.range(of: .leadingWhitespace)

		let newWhitespace = indentation.apply(to: whitespace, indentationUnit: indentationUnit, width: width)

		return RangedString(
			range: leadingRange,
			string: newWhitespace
		)
	}
}
