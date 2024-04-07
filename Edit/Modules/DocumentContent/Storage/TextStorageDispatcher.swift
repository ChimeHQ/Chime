import Foundation

import NSUI

public final class TextStorageDispatcher<Version: Sendable> {
	public typealias Storage = TextStorage<Version>

	public enum AsynchronousMutationPhase {
		case none
		case started
		case progress(Int, Int)
	}

	public let storage: Storage
	public let monitors: [TextStorageMonitor]

	public init(storage: Storage, monitors: [TextStorageMonitor]) {
		self.storage = storage
		self.monitors = monitors
	}

	public var hasPendingMutations: Bool {
		false
	}

	public func handleProposedMutations(_ mutations: [TextStorageMutation]) -> Bool {
		beginEditing(with: mutations)

		storage.applyMutations(mutations)

		endEditing(with: mutations)
		completeEditing(with: mutations)

		return false
	}

	public func handleProposedMutation(_ mutation: TextStorageMutation) -> Bool {
		handleProposedMutations([mutation])
	}
}

extension TextStorageDispatcher {
	private func beginEditing(with mutations: [TextStorageMutation]) {
		for monitor in monitors {
			monitor.willApplyMutations(mutations)
		}

		storage.beginEditing()
	}

	private func endEditing(with mutations: [TextStorageMutation]) {
		for monitor in monitors {
			monitor.didApplyMutations(mutations)
		}

		storage.endEditing()
	}

	private func completeEditing(with mutations: [TextStorageMutation]) {
		for monitor in monitors {
			monitor.didCompleteMutations(mutations)
		}
	}
}

extension TextStorageDispatcher {
	@MainActor
	public func textView(_ textView: NSUITextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
		let cursor = Cursor(index: 0, selection: textView.nsuiSelectedRange)

		return shouldChangeText(in: affectedCharRange, replacementString: replacementString, cursor: cursor)
	}

	public func shouldChangeText(in range: NSRange, replacementString: String?, cursor: Cursor) -> Bool {
		guard let string = replacementString else { return true }

		let rangedString = RangedString(range: range, string: string)
		let cursorMutation = CursorMutation(cursor: cursor, selection: nil)
		let mutation = TextStorageMutation(stringMutations: [rangedString], cursorMutation: cursorMutation)

		return handleProposedMutation(mutation)

	}
}
