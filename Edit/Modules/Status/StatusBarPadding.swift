import SwiftUI

public struct StatusBarPaddingKey: EnvironmentKey {
    public static let defaultValue = EdgeInsets()
}

extension EnvironmentValues {
    public var statusBarPadding: EdgeInsets {
        get { self[StatusBarPaddingKey.self] }
        set { self[StatusBarPaddingKey.self] = newValue }
    }
}
