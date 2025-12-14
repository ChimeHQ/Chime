import Foundation

import DocumentContent
import IBeam
import SourceView
import Textbook

@MainActor
final class IBeamInterfaceAdapter {
	private let formationAdapter: TextFormationInterfaceAdapter
	private let partialSystem: MultiCursorTransformingPartialSystem<TextFormationInterfaceAdapter>
	private let storage: TextStorage<Int>
	
	init(
		textView: PlatformTextView,
		storage: TextStorage<Int>,
		whitespaceCalculator: WhitespaceCalculator,
		filterProvider: @escaping CursorFilterRouter<TextFormationInterfaceAdapter>.FilterProvider
	) {
		self.storage = storage
		self.formationAdapter = TextFormationInterfaceAdapter(
			storage: storage,
			whitespaceCalculator: whitespaceCalculator,
			undoProvider: { textView.undoManager }
		)

		self.partialSystem = MultiCursorTransformingPartialSystem(
			baseSystem: formationAdapter,
			textView: textView,
			filterProvider: filterProvider
		)
	}
}

extension IBeamInterfaceAdapter: @preconcurrency IBeam.TextSystemInterface {
	typealias TextRange = TextFormationInterfaceAdapter.TextRange

	func boundingRect(for range: NSRange) -> CGRect? {
		partialSystem.boundingRect(for: range)
	}
	
	func position(from position: Position, moving direction: IBeam.TextDirection, by granularity: IBeam.TextGranularity) -> Position? {
		partialSystem.position(from: position, moving: direction, by: granularity)
	}
	
	func layoutDirection(at position: Position) -> IBeam.TextLayoutDirection? {
		partialSystem.textView.textStorage?.layoutDirection(at: position)
	}
	
	func beginEditing() {
		storage.beginEditing()
	}
	
	func endEditing() {
		storage.endEditing()
	}
	
	func applyMutation(_ mutation: IBeam.TextMutation<NSRange>) throws -> IBeam.MutationOutput<NSRange> {
		try partialSystem.applyMutation(mutation)
	}
	
	var endOfDocument: Position {
		partialSystem.endOfDocument
	}
}
