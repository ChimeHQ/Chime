import SwiftUI

import WindowTreatment

public struct Inspector: View {
	@Environment(\.windowState) private var windowState
	
	public init() {
	}

	private var edges: Edge.Set {
		windowState.tabBarVisible ? [] : [.all]
	}
	
	public var body: some View {
		Color.green
			.ignoresSafeArea(.container, edges: edges)
	}
}
