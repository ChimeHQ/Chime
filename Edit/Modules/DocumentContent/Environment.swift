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
