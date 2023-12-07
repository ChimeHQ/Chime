import AppKit
import Foundation

public protocol TextStorageMonitor {
	func willApplyMutations(_ mutations: [TextStorageMutation]) -> Void
	func didApplyMutations(_ mutations: [TextStorageMutation]) -> Void
	func didCompleteMutations(_ mutations: [TextStorageMutation]) -> Void
}

extension TextStorageMonitor {
	public func willApplyMutations(_ mutations: [TextStorageMutation]) -> Void {}
	public func didCompleteMutations(_ mutations: [TextStorageMutation]) -> Void {}
}

extension TextStorageMonitor where Self: AnyObject {
	public var textStorageMonitor: TextStorageDispatcher.Monitor {
		.init(
			willApplyMutations: { [weak self] in self?.willApplyMutations($0) },
			didApplyMutations: { [weak self] in self?.didApplyMutations($0) },
			didCompleteMutations: { [weak self] in self?.didCompleteMutations($0) }
		)
	}
}

public final class TextStorageDispatcher {
	public typealias Storage = TextStorage

	public struct Monitor {
		public typealias Handler = ([TextStorageMutation]) -> Void

		public let willApplyMutations: Handler
		public let didApplyMutations: Handler
		public let didCompleteMutations: Handler

		public init(
			willApplyMutations: @escaping Handler,
			didApplyMutations: @escaping Handler,
			didCompleteMutations: @escaping Handler
		) {
			self.willApplyMutations = willApplyMutations
			self.didApplyMutations = didApplyMutations
			self.didCompleteMutations = didCompleteMutations
		}
	}

	public enum AsynchronousMutationPhase {
		case none
		case started
		case progress(Int, Int)
	}

	public var storage: Storage
	public let monitors: [Monitor]

	public init(storage: Storage = .null, monitors: [Monitor]) {
		self.storage = storage
		self.monitors = monitors
	}

	public var hasPendingMutations: Bool {
		false
	}

	public func handleProposedMutations(_ mutations: [TextStorageMutation]) -> Bool {
		beginEditing(with: mutations)

		storage.applyMutation(mutations)

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
	public func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
		guard let string = replacementString else { return true }

		let rangedString = RangedString(range: affectedCharRange, string: string)
		let cursor = Cursor(index: 0, selection: textView.selectedRange())
		let cursorMutation = CursorMutation(cursor: cursor, selection: nil)
		let mutation = TextStorageMutation(stringMutations: [rangedString], cursorMutation: cursorMutation)

		return handleProposedMutation(mutation)
	}
}
