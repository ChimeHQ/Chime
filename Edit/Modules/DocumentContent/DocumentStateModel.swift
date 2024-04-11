import SwiftUI

@MainActor
@Observable
public final class EditorStateModel {
	public var cursors: [Cursor] = []
	public var visibleFrame = CGRect.zero
	public var contentInsets = EdgeInsets()

	public init() {
	}

	public var selectedRanges: [NSRange] {
		get {
			cursors.map { $0.selection }
		}
		set {
			self.cursors = zip(newValue, newValue.indices).map { Cursor(index: $0.1, selection: $0.0) }
		}
	}
}
