import Foundation

import DocumentContent
import IBeam
import Rearrange
import SourceView
import TextFormation

@MainActor
final class TextFormationInterfaceAdapter {
	let storage: TextStorage<Int>
	let whitespaceCalculator: WhitespaceCalculator
	let undoProvider: () -> UndoManager?

	init(
		storage: TextStorage<Int>,
		whitespaceCalculator: WhitespaceCalculator,
		undoProvider: @escaping () -> UndoManager?
	) {
		self.storage = storage
		self.whitespaceCalculator = whitespaceCalculator
		self.undoProvider = undoProvider
	}

	private var undoManager: UndoManager? {
		undoProvider()
	}
}

extension TextFormationInterfaceAdapter: @preconcurrency TextFormation.TextSystemInterface {
	typealias TextRange = NSRange

	func applyMutation(_ range: NSRange, string: String) throws -> Output {
		let plainString = string
		let length = plainString.utf16.count
		let delta = length - range.length

		let mutation = TextStorageMutation(range: range, string: plainString)

		let existingString = try! storage.substring(with: range)
		let inverseRange = NSRange(
			location: range.location,
			length: range.length + delta
		)

		undoManager?.registerUndo(withTarget: self) { target in
			_ = try! target.applyMutation(inverseRange, string: existingString)
		}

		storage.applyMutation(mutation)

		let position = min(range.lowerBound + length, storage.currentLength)

		let newSelection = NSRange(position..<position)

		return MutationOutput<NSRange>(selection: newSelection, delta: delta)
	}
	
	func substring(in range: NSRange) throws -> String? {
		try storage.substring(with: range)
	}
	
	func whitespaceTextRange(at position: Position, in direction: TextFormation.Direction) -> NSRange? {
		whitespaceCalculator.whitespaceTextRange(at: position, in: direction)
	}
	
	func whitespaceMutation(
		for position: Position,
		in direction: TextFormation.Direction
	) throws -> TextFormation.RangedString<NSRange>? {
		try whitespaceCalculator.whitespaceMutation(for: position, in: direction)
	}
	
	var endOfDocument: Position {
		storage.currentLength
	}
}
