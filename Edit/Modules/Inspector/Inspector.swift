import SwiftUI

import WindowTreatment

public struct Inspector: View {
	public init() {
	}

	public var body: some View {
        TrailingSidebarView() {
            Text("hello")
        }
	}
}
