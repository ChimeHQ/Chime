import DocumentContent
import IBeam
import NSUI
import SourceView
import TextFormation
import MainOffender

// Type adatpers
extension TextFormation.MutationOutput {
	init(_ value: IBeam.MutationOutput<TextRange>) {
		self.init(selection: value.selection, delta: value.delta)
	}
}

//extension AttributedString {
//	var string: String {
//		NSAttributedString(self).string
//	}
//}

/// TextFormation in terms of IBeam.
@MainActor
struct TextFormationInterface<Interface: IBeam.TextSystemInterface>
	where Interface.TextPosition == Int, Interface.TextRange == NSRange
{
	let ibeamInterface: Interface
	let substringProvider: (TextRange) -> String?

	init(ibeamInterface: Interface, substringProvider: @escaping (TextRange) -> String?) {
		self.ibeamInterface = ibeamInterface
		self.substringProvider = substringProvider
	}
}

extension TextFormationInterface: @preconcurrency TextFormation.TextSystem {
	typealias TextRange = IBeamTextViewSystem.TextRange
	typealias TextPosition = IBeamTextViewSystem.TextPosition

	func offset(from: TextPosition, to toPosition: TextPosition) -> Int {
		toPosition - from
	}

	func positions(composing range: TextRange) -> (TextPosition, TextPosition) {
		ibeamInterface.positions(composing: range)
	}

	func position(from start: TextPosition, offset: Int) -> TextPosition? {
		ibeamInterface.position(from: start, offset: offset)
	}

	func textRange(from start: TextPosition, to end: TextPosition) -> TextRange? {
		ibeamInterface.textRange(from: start, to: end)
	}

	func substring(in range: TextRange) -> String? {
		substringProvider(range)
	}

	func applyMutation(_ range: TextRange, string: String) -> Output? {
		let attrString = AttributedString(string)

		return ibeamInterface
			.applyMutation(range, string: attrString)
			.map { Output($0) }
	}

	func applyWhitespace(for position: TextPosition, in direction: Direction) -> Output? {
		nil
	}
}

/// IBeam in terms of TextStorage.
@MainActor
final class IbeamStorageInterface<Version> {
	private let storage: TextStorage<Version>
	private let ibeamViewSystem: IBeamTextViewSystem

	init(textView: NSUITextView, storage: TextStorage<Version>) {
		self.storage = storage
		self.ibeamViewSystem = IBeamTextViewSystem(textView: textView)
	}
}

extension IbeamStorageInterface: @preconcurrency IBeam.TextSystemInterface {
	typealias TextRange = IBeamTextViewSystem.TextRange
	typealias TextPosition = IBeamTextViewSystem.TextPosition

	func beginEditing() {
		storage.beginEditing()
	}

	func endEditing() {
		storage.endEditing()
	}

	func boundingRect(for range: TextRange) -> CGRect? {
		ibeamViewSystem.boundingRect(for: range)
	}

	func position(
		from position: TextPosition,
		moving direction: IBeam.TextDirection,
		by granularity: IBeam.TextGranularity
	) -> IBeamTextViewSystem.TextPosition? {
		ibeamViewSystem.position(from: position, moving: direction, by: granularity)
	}

	func position(from start: TextPosition, offset: Int) -> TextPosition? {
		ibeamViewSystem.position(from: start, offset: offset)
	}

	func layoutDirection(at position: TextPosition) -> IBeam.TextLayoutDirection? {
		ibeamViewSystem.layoutDirection(at: position)
	}

	var beginningOfDocument: TextPosition {
		ibeamViewSystem.beginningOfDocument
	}

	var endOfDocument: TextPosition {
		ibeamViewSystem.endOfDocument
	}

	func compare(_ position: TextPosition, to other: TextPosition) -> ComparisonResult {
		ibeamViewSystem.compare(position, to: other)
	}

	func positions(composing range: TextRange) -> (TextPosition, TextPosition) {
		ibeamViewSystem.positions(composing: range)
	}

	func textRange(from start: TextPosition, to end: TextPosition) -> TextRange? {
		ibeamViewSystem.textRange(from: start, to: end)
	}

	func applyMutation(_ range: TextRange, string: NSAttributedString) -> IBeam.MutationOutput<TextRange>? {
		// ibeamViewSystem has an implementation of applyMutation, but we need to do in terms of our storage
		let plainString = string.string
		let length = plainString.utf16.count
		let delta = length - range.length

		let mutation = TextStorageMutation(range: range, string: plainString)

		let existingString = try! storage.substring(with: range)
		let inverseRange = NSRange(
			location: range.location,
			length: range.length + delta
		)

		let view = ibeamViewSystem.textView

		view.undoManager?.registerMainActorUndo(withTarget: self) { target in
			_ = target.applyMutation(inverseRange, string: NSAttributedString(string: existingString))
		}

		storage.applyMutation(mutation)

		let position = min(range.lowerBound + length, storage.currentLength)

		let newSelection = NSRange(position..<position)

		return MutationOutput<NSRange>(selection: newSelection, delta: delta)
	}

	func applyMutation(_ range: TextRange, string: AttributedString) -> IBeam.MutationOutput<TextRange>? {
		applyMutation(range, string: NSAttributedString(string))
	}
}

@MainActor
final class TransformingTextSystem<Version> {
	private let ibeamInterface: IbeamStorageInterface<Version>
	private let textFormationInterface: TextFormationInterface<IbeamStorageInterface<Version>>
	public var filter: (any NewFilter)?

	init(textView: NSUITextView, storage: TextStorage<Version>) {
		self.ibeamInterface = IbeamStorageInterface(textView: textView, storage: storage)
		self.textFormationInterface = TextFormationInterface(
			ibeamInterface: ibeamInterface,
			substringProvider: { [storage] in try? storage.substring(with: $0) }
		)
	}
}

extension TransformingTextSystem: @preconcurrency IBeam.TextSystemInterface {
	typealias TextRange = IBeamTextViewSystem.TextRange
	typealias TextPosition = IBeamTextViewSystem.TextPosition

	func beginEditing() {
		ibeamInterface.beginEditing()
	}

	func endEditing() {
		ibeamInterface.endEditing()
	}

	func boundingRect(for range: TextRange) -> CGRect? {
		ibeamInterface.boundingRect(for: range)
	}

	func position(from position: TextPosition, moving direction: IBeam.TextDirection, by granularity: IBeam.TextGranularity) -> IBeamTextViewSystem.TextPosition? {
		ibeamInterface.position(from: position, moving: direction, by: granularity)
	}

	func position(from start: TextPosition, offset: Int) -> TextPosition? {
		ibeamInterface.position(from: start, offset: offset)
	}

	func layoutDirection(at position: TextPosition) -> IBeam.TextLayoutDirection? {
		ibeamInterface.layoutDirection(at: position)
	}

	var beginningOfDocument: TextPosition {
		ibeamInterface.beginningOfDocument
	}

	var endOfDocument: TextPosition {
		ibeamInterface.endOfDocument
	}

	func compare(_ position: TextPosition, to other: TextPosition) -> ComparisonResult {
		ibeamInterface.compare(position, to: other)
	}

	func positions(composing range: TextRange) -> (TextPosition, TextPosition) {
		ibeamInterface.positions(composing: range)
	}

	func textRange(from start: TextPosition, to end: TextPosition) -> TextRange? {
		ibeamInterface.textRange(from: start, to: end)
	}

	func applyMutation(_ range: TextRange, string: AttributedString) -> IBeam.MutationOutput<TextRange>? {
		let attrString = NSAttributedString(string)

		if let output = filter?.processMutation(range, string: attrString.string, in: textFormationInterface) {
			return IBeam.MutationOutput(selection: output.selection, delta: output.delta)
		}

		// fall back to just applying the mutation
		return ibeamInterface.applyMutation(range, string: attrString)
	}
}
