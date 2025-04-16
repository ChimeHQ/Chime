import SwiftUI

public struct StatusBar: View {
    @Environment(\.statusBarPadding) private var padding

	public init() {
	}
	
	public var body: some View {
		StatusBarContent()
            .padding(padding)
	}
}
