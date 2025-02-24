import SwiftUI

@MainActor
@Observable
public final class EditorStateModel {
	public var cursors: CursorSet = CursorSet()
	public var visibleFrame = CGRect.zero
	public var contentInsets = EdgeInsets()
	public var statusBarVisible: Bool
	public var searchCount = 0

	public init(statusBarVisible: Bool) {
		self.statusBarVisible = statusBarVisible
	}
}
