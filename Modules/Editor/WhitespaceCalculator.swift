import Foundation

import Borderline
import DocumentContent
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

//extension TextualContext.Line where TextRange == NSRange {
//	init(line: Line<Int>, storage: TextStorage<Int>) throws {
//		let range = line.range(of: .full)
//		let contentRange = line.range(of: .content)
//		let content = try storage.substring(with: contentRange)
//		
//		self.init(range: range, nonwhitespaceContent: content)
//	}
//}

@MainActor
final class WhitespaceCalculator {
	typealias TextPosition = Int
	typealias TextRange = NSRange
	typealias Output = TextFormation.MutationOutput<TextRange>
	
	let textSystem: TextViewSystem
	let textualIndenter: TextualIndenter<TextRange>
	
	init(textSystem: TextViewSystem) {
		self.textSystem = textSystem
		self.textualIndenter = TextualIndenter()
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
	
	func applyWhitespace(for position: TextPosition, in direction: Direction) -> Output? {
		guard
			let metrics = metrics(for: position),
			let line = metrics.line(for: position),
			let precedingLine = metrics.line(at: line.index - 1)
		else {
			return nil
		}

		// no-op trialing whitespace
		if direction == .trailing {
			return Output(selection: line.range(of: .trailingWhitespace), delta: 0)
		}

		let indentationUnit = "\t"

		do {
			let currentContent = try textSystem.storage.substring(with: line.range(of: .content))
			let precedingContent = try textSystem.storage.substring(with: precedingLine.range(of: .content))
			
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
			let whitespace = try textSystem.storage.substring(with: range)
			let leadingRange = line.range(of: .leadingWhitespace)
			
			switch indentation {
			case .relativeIncrease:
				// very wrong
				let newWhitespace = whitespace + indentationUnit
				let mutation = TextStorageMutation(range: leadingRange, string: newWhitespace)
				
				textSystem.storage.applyMutation(mutation)

				// the line information is now stale
				guard let selection = leadingRange.shifted(by: indentationUnit.utf8.count) else {
					preconditionFailure()
				}

				return Output(selection: selection, delta: mutation.delta)
			case .relativeDecrease:
				// TODO: make this work
				break
			case .equal:
				let mutation = TextStorageMutation(range: leadingRange, string: whitespace)
				
				textSystem.storage.applyMutation(mutation)
				
				return Output(selection: leadingRange, delta: mutation.delta)
			}
		} catch {
			print("failed to compute indentation:", error)
		}
		
		return nil
	}
}
