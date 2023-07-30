import SwiftUI

import Status

struct SourceRootView: View {
	var body: some View {
		ZStack(alignment: .bottomTrailing) {
			Color.teal
			StatusBar()
				.frame(maxHeight: 20.0)
		}
		.ignoresSafeArea()
	}
}
