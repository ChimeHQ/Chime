import SwiftUI

import ChimeKit

public struct SearchBar: View {
	@Environment(\.projectContext) private var context
	
	public init() {
	}

	public var body: some View {
		ZStack {
			Color.blue
			Text("context: \(context?.url.absoluteString ?? "none")")
		}
			.frame(height: 30.0)
	}
}
