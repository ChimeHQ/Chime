import SwiftUI

public struct DocumentContentKey: EnvironmentKey {
	public static let defaultValue = DocumentContent()
}

extension EnvironmentValues {
	public var documentContent: DocumentContent {
		get { self[DocumentContentKey.self] }
		set { self[DocumentContentKey.self] = newValue }
	}
}

public struct DocumentSelectionKey: EnvironmentKey {
	public static let defaultValue: [NSRange] = []
}

extension EnvironmentValues {
	public var documentSelection: [NSRange] {
		get { self[DocumentSelectionKey.self] }
		set { self[DocumentSelectionKey.self] = newValue }
	}
}
