import SwiftUI

public struct DocumentCursorsKey: EnvironmentKey {
	public static let defaultValue: [Cursor] = []
}

extension EnvironmentValues {
	public var documentCursors: [Cursor] {
		get { self[DocumentCursorsKey.self] }
		set { self[DocumentCursorsKey.self] = newValue }
	}
}

public struct EditorVisibleRectKey: EnvironmentKey {
	public static let defaultValue = CGRect.zero
}

extension EnvironmentValues {
	public var editorVisibleRect: CGRect {
		get { self[EditorVisibleRectKey.self] }
		set { self[EditorVisibleRectKey.self] = newValue }
	}
}
