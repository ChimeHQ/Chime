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
