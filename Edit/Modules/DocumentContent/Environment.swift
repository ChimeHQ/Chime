import SwiftUI

public struct DocumentContentKey: EnvironmentKey {
	public static let defaultValue: DocumentContent? = nil
}

extension EnvironmentValues {
	public var documentContent: DocumentContent? {
		get { self[DocumentContentKey.self] }
		set { self[DocumentContentKey.self] = newValue }
	}
}

public struct DocumentCursorsKey: EnvironmentKey {
	public static let defaultValue: [Cursor] = []
}

extension EnvironmentValues {
	public var documentCursors: [Cursor] {
		get { self[DocumentCursorsKey.self] }
		set { self[DocumentCursorsKey.self] = newValue }
	}
}
