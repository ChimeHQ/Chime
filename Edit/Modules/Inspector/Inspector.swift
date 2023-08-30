import SwiftUI

import Status
import WindowTreatment

public struct Inspector: View {
	public init() {
	}

	public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TrailingSidebarView() {
                Text("hello")
            }
            ExtensionSelectorItem()
        }
	}
}
