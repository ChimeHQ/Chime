import SwiftUI

public struct TextViewSystemKey: EnvironmentKey {
	public static let defaultValue: TextViewSystem? = nil
}

extension EnvironmentValues {
	public var textViewSystem: TextViewSystem? {
		get { self[TextViewSystemKey.self] }
		set { self[TextViewSystemKey.self] = newValue }
	}
}
