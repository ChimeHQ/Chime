import DocumentContent
import IBeam
import NSUI
import SourceView
import TextFormation

@MainActor
struct TextFormationSystem {
	let internalTextSystem: IBeamTextViewSystem
}

extension TextFormationSystem: @preconcurrency TextFormation.TextSystem {
	typealias TextRange = IBeamTextViewSystem.TextRange
	typealias TextPosition = IBeamTextViewSystem.TextPosition

	func offset(from: TextPosition, to toPosition: TextPosition) -> Int {
		toPosition - from
	}

	func positions(composing range: TextRange) -> (TextPosition, TextPosition) {
		internalTextSystem.positions(composing: range)
	}

	func position(from start: TextPosition, offset: Int) -> TextPosition? {
		internalTextSystem.position(from: start, offset: offset)
	}

	func textRange(from start: TextPosition, to end: TextPosition) -> TextRange? {
		internalTextSystem.textRange(from: start, to: end)
	}

	func substring(in range: TextRange) -> String? {
		internalTextSystem.textView.substring(from: range)
	}

	func applyMutation(_ range: TextRange, string: String) -> Output? {
		internalTextSystem.applyMutation(range, string: AttributedString(string))
			.map { TextFormation.MutationOutput(selection: $0.selection, delta: $0.delta) }
	}

	func applyWhitespace(for position: TextPosition, in direction: Direction) -> Output? {
		nil
	}
}

@MainActor
final class TransformingTextSystem<Version> {
	private let internalTextSystem: IBeamTextViewSystem
	private let tfSystem: TextFormationSystem
	public var filter: (any NewFilter)?

	init(textView: NSUITextView, storage: TextStorage<Version>) {
		self.internalTextSystem = IBeamTextViewSystem(textView: textView)
		self.tfSystem = TextFormationSystem(internalTextSystem: internalTextSystem)
	}
}

extension TransformingTextSystem: @preconcurrency IBeam.TextSystemInterface {
	typealias TextRange = IBeamTextViewSystem.TextRange
	typealias TextPosition = IBeamTextViewSystem.TextPosition

	func beginEditing() {
		internalTextSystem.beginEditing()
	}

	func endEditing() {
		internalTextSystem.endEditing()
	}

	func boundingRect(for range: TextRange) -> CGRect? {
		internalTextSystem.boundingRect(for: range)
	}

	func position(from position: TextPosition, moving direction: IBeam.TextDirection, by granularity: IBeam.TextGranularity) -> IBeamTextViewSystem.TextPosition? {
		internalTextSystem.position(from: position, moving: direction, by: granularity)
	}

	func position(from start: TextPosition, offset: Int) -> TextPosition? {
		internalTextSystem.position(from: start, offset: offset)
	}

	func layoutDirection(at position: TextPosition) -> IBeam.TextLayoutDirection? {
		internalTextSystem.layoutDirection(at: position)
	}

	var beginningOfDocument: TextPosition {
		internalTextSystem.beginningOfDocument
	}

	var endOfDocument: TextPosition {
		internalTextSystem.endOfDocument
	}

	func compare(_ position: TextPosition, to other: TextPosition) -> ComparisonResult {
		internalTextSystem.compare(position, to: other)
	}

	func positions(composing range: TextRange) -> (TextPosition, TextPosition) {
		internalTextSystem.positions(composing: range)
	}

	func textRange(from start: TextPosition, to end: TextPosition) -> TextRange? {
		internalTextSystem.textRange(from: start, to: end)
	}

	func applyMutation(_ range: TextRange, string: AttributedString) -> IBeam.MutationOutput<TextRange>? {
		if let output = filter?.processMutation(range, string: NSAttributedString(string).string, in: tfSystem) {
			return IBeam.MutationOutput(selection: output.selection, delta: output.delta)
		}

		// fall back to just applying the mutation
		return internalTextSystem.applyMutation(range, string: string)
	}
}
